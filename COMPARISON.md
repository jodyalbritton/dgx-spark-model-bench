# Three local coding agents on two DGX Sparks

**GLM-5.3-Flash · Qwen3.8-Flash-Next · DeepSeek-V4-Flash, doing real coding
work with tools**

Run 2026-09-05/06 on a pair of DGX Sparks. This is a first look; a wider
set of benchmarks pushing all three harder is in progress.

## What was measured, and why it is different

Most local-model coding benchmarks are one shot: make a Flappy Bird clone,
write an HTML page, fix this function. They measure one reply. Real coding
work is a hundred tool calls: read the repo, plan, edit, build, run the
tests, start the server, look at the page, fix what is wrong, and know when
to stop.

So each model here drove an agent loop with 21 native tools (file read,
edit, write, bash, grep, tree, background jobs, a headless browser preview)
through two kinds of work, graded entirely by machines:

- **17 bug-fix tasks.** Each is an Elixir module whose documentation is the
  specification and whose body has at least one deliberate bug: from a
  swapped `min`/`max`, through a concurrent rate limiter and a functional
  LRU cache, to signed integer division, shell-safe echo, and a module that
  ships a visible test which contradicts its own spec. Hidden ExUnit tests
  grade the result.
- **One application.** Generate a Phoenix LiveView app from a template,
  strip the demo content, then build a fictional product's landing site to
  a written contract: responsive nav with a phone menu and a theme toggle,
  a hero, a live server-driven countdown, a newsletter form with validation
  and duplicate detection, a live stats strip, an activity feed capped at
  ten entries, a feature grid built from a registered design-system
  component, an `/about` page, and LiveView tests for all of it. 19 checks:
  it compiles, its own tests pass, lint passes, five hidden LiveView tests
  pass, it boots on the assigned port, and a headless browser confirms the
  phone menu, the dark theme, and that the countdown actually ticks.

The agent loop keeps each model's reasoning and returns it on the
following tool calls within a turn, as the vendors specify for tool use.
All three ran at reasoning effort `low`, the one grade every model's chat
template honours literally. One run per model. No LLM judge anywhere.

**Hardware and builds.** Two DGX Sparks, tensor-parallel 2 over the
ConnectX link, one model at a time.

| model | quant / engine | context |
|---|---|---:|
| GLM-5.3-Flash | EXL3 4 bpw, custom vLLM-fork image, dflash speculative decoding | 524k |
| Qwen3.8-Flash-Next | NVFP4, vLLM, MTP speculative decoding | 1M |
| DeepSeek-V4-Flash-Vision-Exp | fp8, `dspark-vllm-gx10`, dspark speculative decoding | 1M |

## The results

| | GLM-5.3-Flash | Qwen3.8-Flash-Next | DeepSeek-V4-Flash |
|---|---:|---:|---:|
| bug fixes passed | **17/17** | 16/17 | **17/17** |
| bug-fix rounds / wall | 114 / 654 s | 82 / **465 s** | **71** / 496 s |
| application checks | **19/19** | **19/19** | **19/19** |
| app rounds | 93 | 102 | **77** |
| app wall | **18.4 min** | 27.6 min | 24.0 min |
| app output tokens (text + reasoning) | **20k** | 59k | 51k |
| of which reasoning | 5.9k | 38k | 28k |
| app prompt tokens not served from cache | 193k | 342k | **97k** |
| tests the model wrote | 9 | **18** | 10 |
| lint warnings | 0 | 0 | 0 |

All three completed the application to the full contract. That alone puts
them in a different class from most local models; a year ago none of this
ran on desk hardware. The differences are in how they got there, what it
cost, and what the code and the page look like when they are done.

## Who is fastest, and why

**GLM finished the application first, by a lot: 18 minutes against 24
and 28.** It did not take the fewest rounds. It said the least. Time in an
agent loop is prefill plus generation per round, times rounds, and GLM's
output over the whole task was 20k tokens against 51k and 59k. At `low`
effort it hardly reasons at all, so each round is a short tool call and a
short result. It is fast the way a terse colleague is fast.

**DeepSeek took the fewest rounds** (77) and the fewest bug-fix rounds
(71). It reads, plans once, and edits; it also spent twelve of its 77
rounds on a self-inflicted detour, running the project generator in the
foreground twice and getting killed at the shell timeout both times before
backgrounding it. Without that it would have been within a few minutes of
GLM.

**Qwen was the slowest to finish** because it thinks on every round, at
length, and because its own reasoning rides along in the context for the
rest of the turn: its prompt per round was 70k tokens against DeepSeek's
57k and GLM's 41k. On the bug fixes it was the fastest of the three, tied
with DeepSeek at four to five rounds per task.

Raw engine speed, measured separately on the same loads with a synthetic
prompt, points the other way from the finish times and is worth knowing:

| | GLM | Qwen | DeepSeek |
|---|---:|---:|---:|
| prefill throughput | 1.1k tok/s | **2.7k tok/s** | 1.8k tok/s |
| decode, single stream | 45–58 tok/s | **55–65 tok/s** | 48–73 tok/s |
| time to first token, 150k-token prompt | 138 s | **61 s** | 92 s |

**Qwen's NVFP4 build is the fastest engine on this hardware**, by more
than two to one over GLM's EXL3 build on prefill, which is what an agent
loop spends most of its time doing. GLM's finish-line speed comes from
brevity, not from the engine, and would shrink on tasks with much longer
contexts. Decode is a near tie for all three at the Spark's bandwidth
ceiling.

## Who is the thinker

All three are reasoning models. They use the capability in three distinct
ways, visible in a per-round record of what each said versus what it
thought.

| on the application | GLM | Qwen | DeepSeek |
|---|---:|---:|---:|
| rounds with any reasoning | 33 of 93 | **102 of 102** | 53 of 77 |
| total reasoning, characters | 23k | **152k** | 113k |
| largest single reasoning block | 6k | **43k** | 16k |
| visible text over the whole task | 1.1k chars | 3.8k chars | 4.4k chars |

**Qwen is the thinker.** It reasons on every round, its visible output is
a sentence or nothing, and it plans in one enormous block: after 28 rounds
of reading it produced a 43,000-character reasoning pass laying out the
entire application, then edited for 70 rounds against it without ever
re-planning. Its later reasoning spikes were a single debugging episode on
its own signup test, solved with a temporary print. Everything Qwen knows
lives in its reasoning; an agent harness that does not return reasoning to
it would be throwing away its working memory.

**DeepSeek thinks once, then acts.** On 13 of the 17 bug fixes it reasoned
on exactly one round. On the application it wrote a 16k-character plan, a
9k block to design the main page, and then edited with no reasoning on
most rounds, announcing each step in a short visible sentence. It is the
easiest of the three to follow in a transcript.

**GLM barely thinks at `low`.** A 6k plan on round 9, then reasoning only
on diagnosis rounds (an edit anchor that missed, a killed command, a huge
tool output) and none on edits. GLM's template collapses `low` to almost
nothing, so `low` is a lighter setting for GLM than for the other two.
That is a large part of why it was fast, and it makes GLM's `high` the
most interesting untested setting in this bench.

## Who has the best quality

### Bug fixes

GLM and DeepSeek went 17/17. Qwen missed one: on a fixture that requires
removing exactly one trailing newline, it used `String.trim_trailing`,
which removes all of them; the spec's own example (`"x\n\n" => "x\n"`) is
the failing test. Its reasoning on that task was 315 tokens, its lightest
of the run; the other 16 were clean.

Passing hidden tests is the floor. Reading all 51 drafts:

- Where Elixir has an idiom, all three found it: `Agent.get_and_update`
  for the atomic rate limiter, pattern-matched heads, identical ring-buffer
  and slug fixes.
- Where they diverged, Qwen tended to reach the more idiomatic form:
  `Integer.floor_div` for signed division where GLM and DeepSeek corrected
  `div`/`rem` by hand; a shell-free `System.cmd` where the others quoted
  input into a shell.
- All three followed the documentation over the lying visible test in the
  fixture built to check that. Qwen alone explained in its summary why the
  test was wrong.
- GLM finds bugs by running things. It took 114 rounds across the 17
  fixtures against 71 and 82, and one fix took 16 rounds, but the fixes
  were right and its summaries described the bug accurately.

### The application

Nineteen of nineteen for everyone, so the differences are in engineering
and in taste.

- **Qwen wrote the most tests (18) and the most idiomatic LiveView**: the
  only implementation to use a `stream` for the activity feed with explicit
  `stream_delete` to hold the ten-entry cap, empty states on every list,
  duplicate detection, the kit's theme toggle reused rather than rebuilt.
- **DeepSeek's is the most conventional**: assigns-based lists, a clean
  separation of sections, two registered composites (a feature grid and a
  stat card) with `/design` previews, ten tests.
- **GLM's is the leanest**: nine tests, two composites, a countdown that
  reschedules unconditionally (harmless), and one leftover `max(x, 0)` in a
  fix that can never bind. Its edit tool missed its anchor several times
  and it recovered each time.

### The pages

Judged by eye from the harness's own screenshots (desktop and phone, light
and dark):

- **GLM's "Solstice"**, a desk lamp, is the only page that reads as a
  product rather than a demo of the component kit. The countdown is
  reframed as "early-bird places remaining, one spot opens up every five
  seconds", which is the only copy of the three that makes the
  five-second tick make sense. Six lamp-specific feature cards, empty
  states everywhere, one blank icon from a misspelled icon name.
- **DeepSeek's "Lumen"** is a spacious, conventional marketing page:
  full-width bands, a big countdown, a waitlist section, product copy
  throughout, one missing empty state.
- **Qwen's "Lumen"** is the most compact and the most engineered: the
  countdown, form, signups, and activity feed all live in one card beside
  the hero, and it works well on a phone. Its feature copy describes the
  component kit itself rather than a product, the one place it read the
  brief as an engineer instead of as a marketer.

Two of the three named their product "Lumen".

## What it feels like to use each one

**DeepSeek-V4-Flash is the one you can leave alone.** It reads enough,
writes one plan, and executes it in short visible steps, using the
background-job tool for the server, a todo list for its checklist, and the
browser preview to look at its own page before it says it is done. It
finishes in one line. Its 98% prefix-cache hit rate makes it the cheapest
per task in prompt compute by a factor of two to three. Its faults are
small: it will sometimes run a long command in the foreground and get
killed, and it writes fewer tests than Qwen.

**Qwen3.8-Flash-Next is the thorough one.** Watching it work is watching
almost nothing: the transcript shows a sentence per round or a blank,
because everything it knows is in its reasoning. What comes out the other
end is the best-tested, most idiomatic code of the three. It costs the
most: the most rounds, the most reasoning, and a prompt per round a
quarter larger than DeepSeek's. It also has the fastest engine on this
hardware, which matters if you serve more than one seat.

**GLM-5.3-Flash is the sprinter.** It finishes first, emits a third of the
tokens, writes the most human copy, and fixes bugs by running things
rather than by deliberating. It is terse to the point of silence in the
transcript. Its engine is the slowest of the three per token on this
hardware, so its speed lives entirely in brevity, and at `low` its
thinking is nearly off. Whether `high` makes it better or just slower is
the next thing to find out.

## Which one to run

For two Sparks and one person at the keyboard:

- **Default: DeepSeek-V4-Flash at `low`.** Complete, cheap, easy to follow,
  the fewest rounds.
- **If you want the most tests and the most idiomatic code, and your
  harness returns reasoning within the turn: Qwen3.8-Flash-Next.** Budget
  about 20% more wall time and two to three times the prompt compute. Also
  the pick for concurrent users; its engine has the best prefill and
  concurrency here.
- **If you want the fastest complete answer at the lowest output cost:
  GLM-5.3-Flash at `low`.** Check that thinking is enabled in your
  serving config; its template does not turn it on from `reasoning_effort`
  alone.

## Caveats

- One run per model. Run-to-run variance is real (Qwen's one fixture miss;
  DeepSeek's generator detour) and nothing here has error bars.
- Different quantizations (4-bit EXL3, NVFP4, fp8) on different engine
  builds. Raw speed is partly the stack.
- Effort was `low` for all three, and `low` means less for GLM than for
  the others. Higher grades are the obvious next experiment.
- The tasks are Elixir and Phoenix. Rankings on other stacks may differ.

## Data

Everything is in this folder: `design/CODING_BENCH.md` for the prompts,
tools, oracle and checklist as run; `results/2026-09-05-r2/` for the raw
rows, the generated apps, the screenshots, and the per-round reasoning
record; `design/TESTPLAN.md` for the protocol.

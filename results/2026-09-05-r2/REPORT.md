# Round 2026-09-05-r2 (round 4) — report

Written 2026-09-06 from this round's `RUNLOG.md`, `RESULTS.md`, the raw
rows, the per-round reasoning sidecars in `raw/reasoning/`, round 3
(`results/2026-09-05/`, including the superseded DeepSeek `high` row), the
two round-4 apps under `work/`, and the harness screenshots. helm sprint
docs `T24-coding-bench-3.md` and `T25-reasoning-content.md` carry the
harness readouts; this report is the independent read of the same data.

**What changed between round 3 and round 4:** helm only. Round 3's helm
discarded each round's `reasoning_content` after the round; the next
request carried content and tool calls but none of the model's thinking.
Round 4's helm (T25) persists the reasoning and echoes it back as
`reasoning_content` on every assistant message of the current turn. Same
harness, same prompts (`6fb75d99`), same hidden tests (`6ccd80bc`), same
effort (`low` for everyone), same caps. Qwen and DeepSeek are the two
models that put their thinking in the reasoning field, so they are the
ones the fix was built for. GLM turned out to be a different story (§1a):
it had never been thinking at all, in any round, and round 4 is its first
run with thinking on.

## 1. The headline diff

| | Qwen 3.8 Flash Next | | DeepSeek V4 Flash Vision Exp | |
|---|---:|---:|---:|---:|
| | round 3 (no echo) | round 4 (echo) | round 3 (no echo) | round 4 (echo) |
| fixtures | 17/17 | 16/17 | 17/17 | 17/17 |
| fixture rounds / wall | 87 / 600 s | 82 / 465 s | 72 / 438 s | 71 / 496 s |
| fixture reasoning tokens | 13,351 (counter) | 8,331 (counter) | ~7,916 (est.) | ~8,667 (est.) |
| app | **abandoned**, 42 rounds, nothing written | **19/19 done** | 19/19 done | 19/19 done |
| app rounds / wall | 42 / 49 min (stopped) | 102 / 1,655 s | 92 / 1,451 s | 77 / 1,440 s |
| app reasoning tokens | — | 38,214 (counter) | ~31,118 (est.) | ~28,186 (est.) |
| app completion tokens | — | 59,098 | 54,149 | 50,626 |
| app prompt / uncached | — | 7.15M / 342k | 4.77M / 96k | 4.35M / 97k |
| app prompt per round | — | 70k | 52k | 57k |
| tests added / composites | — | 18 / 2 | 16 / 2 | 10 / 2 |

**For Qwen the echo is the difference between no app and a complete
one.** Round 3 was stopped by the operator after 42 rounds and 28 bash
calls with zero writes; the model re-derived the whole product plan every
round because the plan lived in reasoning that helm threw away. Round 4:
102 rounds, every hidden LiveView and rendered check green, 18 tests of
its own, two registered composites, lint clean, no nudge. The fix did
exactly what T25 said it would.

**For DeepSeek the echo changes cost, not outcome.** It was already 19/19
without it. With it: 15 fewer rounds (92 → 77), about 10% fewer completion
and reasoning tokens, the same wall time. Twelve of the 77 rounds were a
self-inflicted generator detour (§4), so the reading-and-writing part of
the run shrank by roughly a third.

Ranking is unchanged from round 3 on quality (both 19/19), and the
fixture sheets are now within noise of each other (Qwen 82 rounds / 465
s, DeepSeek 71 / 496). On this round's evidence Qwen and DeepSeek are
peers on the app, DeepSeek stays cheaper (§3), and GLM's row decides
third place when it lands.

## 1a. GLM: the row that was supposed to be the null case

T25 predicted GLM would not move, on the theory that it writes its
thinking as visible content. The pre-flight probe before its round-4 run
found something else: **GLM had thinking off in every previous round.**
As served through airo, the GLM template's `enable_thinking` was off and
`reasoning_effort` alone does not turn it on. A helm-shaped request
returned 2 to 4 completion tokens and no reasoning at `low` or `high`
and got a bat-and-ball question wrong both times. Rounds 1 to 3 agree:
98 completion tokens over three rounds on `clamp`, 17.8k over 128 rounds
on the round-3 app, reasoning never reported. The fix was on the airo
side: `chat_template_kwargs.enable_thinking: true` in the GLM
deployment's request defaults. Re-probed through helm's own wire,
reasoning is present and the answers are right.

This corrects two earlier statements of mine. Round 2's report (§5 item
11) said GLM "ran at `max`": the template injects a "Reasoning Effort:
Max" line, but with thinking disabled that line governed an empty
`<think></think>`. And this report's opening said GLM keeps its thinking
in visible content: its round-4 visible content is 1,093 characters over
93 rounds, median zero, the tersest of the three. GLM was not a
think-in-the-open model. It was a no-thinking model that did as well as
it did on reflexes.

| GLM | round 3 (no thinking, no echo) | round 4 (thinking on, echo) |
|---|---:|---:|
| fixtures | 15/17 | **17/17** |
| fixture rounds / wall / reasoning | 110 / 512 s / 0 | 114 / 654 s / 2.5k |
| app | 15/19 at the 128-round cap | **19/19 done**, 93 rounds |
| app wall | 992 s (cap) | **1,103 s**, the fastest complete app of the round |
| app reasoning / completion | 0 / 17.8k | 5.9k / 20.3k |
| app uncached prompt | 266k | 193k |
| tests added / composites / lint | 10 / 2 / 0 | 9 / 2 / 0 |

**The two stable GLM fixture misses both flipped.** `pricing`, which GLM
got wrong in rounds 2 and 3 with three stacked `when` clauses, went from
a 3-round fail to a 16-round pass with 1,389 reasoning tokens, and its
summary names the bug: "the previous split `when` form silently ignored
the second guard". `safe_echo_exact`, wrong in round 3 on the grapheme
slice, is now `String.replace_suffix`. Both were no-thinking artefacts.
`split_bill` went from 17 rounds to 6 and `split_bill_signed` from 21 to
5; the reasoning it now spends (87 and 97 tokens) replaced dozens of
trial-and-error bash rounds.

**How GLM thinks at `low`.** Barely, and only where it matters. It
reasoned on 33 of 93 app rounds and on zero to four rounds per fixture
(none at all on `first_or` and `parse_int`). The plan is a single 6,087-
character block on round 9 followed by a 2.6k design block on round 10;
after that, reasoning appears on diagnosis rounds (edit anchors missing,
a killed foreground command, a 56k-token tool output) and is absent on
edits. Its per-round reasoning is a tenth of Qwen's and a fifth of
DeepSeek's, and it finished first. The run log's ladder probe explains
the scale: at `low` this template collapses GLM's thinking to almost
nothing (13 / 0 / 0 bytes on three prompts, against 3,617 with no effort
field), so `low` on GLM is a much lighter setting than `low` on the other
two.

**Comparability.** For Qwen and DeepSeek the round-3 → round-4 delta is
the echo alone. For GLM it is thinking on plus the echo, and the two
cannot be separated from this data: round 3 had no reasoning to echo.
The echo is what makes GLM's plan block survive from round 9 to round
93, so it is part of the result, but the first-order effect is that a
model with its reasoning disabled was being benchmarked for three
rounds. Every GLM conclusion in rounds 1 to 3 (the round-2 collapse, the
`pricing` guards, "confident and wrong", "fast but round-hungry")
describes GLM with thinking off.

## 1b. Round 4, all three

| | Qwen 3.8 Flash Next | DeepSeek V4 Flash Vision Exp | GLM 5.3 Flash |
|---|---:|---:|---:|
| fixtures | 16/17 | **17/17** | **17/17** |
| fixture rounds / wall | 82 / 465 s | 71 / 496 s | 114 / 654 s |
| fixture reasoning tokens | 8.3k | ~8.7k | 2.5k |
| app | 19/19 done | 19/19 done | 19/19 done |
| app rounds / wall | 102 / 27.6 min | 77 / 24.0 min | **93 / 18.4 min** |
| app reasoning / completion | 38.2k / 59.1k | ~28.2k / 50.6k | **5.9k / 20.3k** |
| app uncached prompt | 342k | **97k** | 193k |
| app cache hit | 95.2% | **97.8%** | 94.9% |
| tests added / composites | **18** / 2 | 10 / 2 | 9 / 2 |
| product | Lumen | Lumen | Solstice (a desk lamp) |

Three complete apps at `low`, the first round in which every model
shipped. On the checklist they are tied. Off the checklist:

- **GLM is the cheapest and fastest to a complete app** by a wide margin
  in completion tokens (a third of DeepSeek's) and wall (18 minutes), at
  a cache hit rate a little below the others and uncached spend between
  them. It also produced the only non-Lumen product and the most
  product-like copy. Its fixtures cost the most rounds (114) and wall,
  because with reasoning this light it still finds bugs by running things.
- **DeepSeek is the cheapest in prompt spend** and the most economical in
  rounds on the app. Middle on everything else.
- **Qwen is the most thorough** (18 tests, the only `stream`-based
  activity feed) and the most expensive: most rounds, most reasoning,
  most completion, highest uncached prompt. Its one fixture miss is
  variance (§4).

On this round's evidence there is no clear loser. If one model has to be
ranked lowest it is Qwen, on cost and the fixture miss; if one has to be
ranked highest it is a coin between GLM (cheapest, fastest, 17/17) and
DeepSeek (cheapest prompt, fewest rounds, 17/17). Given that GLM has one
thinking run on record and the other two have four rounds, the safer
statement is that GLM has moved from a clear third to a contender, and
one more round is needed before ranking it above either.

## 2. Why the same fix moved one model and not the other

The sidecars (`raw/reasoning/<label>-<task>.jsonl`, one line per round:
tools, visible content, reasoning) show two different ways of using the
reasoning channel.

| | Qwen | DeepSeek |
|---|---:|---:|
| app rounds with any reasoning | **102 of 102** | 53 of 77 |
| app reasoning, chars: total / median / largest round | 152k / 385 / **42,924** | 113k / 492 / 16,259 |
| app visible content, chars total (102 and 77 rounds) | **3,768** | 4,389 |
| fixture rounds with reasoning | every round of every fixture | usually **one** round per fixture (13 of 17 fixtures think exactly once) |

**Qwen thinks on every round and says almost nothing out loud.** Its
visible content over the whole app turn is under 4k characters, a median
of zero per round: the transcript a human or the next request sees is one
sentence ("Now I have enough understanding. Let me check…") or nothing.
Everything it knows about the product, the plan, and what it has already
decided is in the reasoning field. Take that away between rounds and the
model is amnesiac by construction; round 3's "new product name every
round" is the visible symptom.

The round-4 profile shows what the echo bought: 28 rounds of reading with
small reasoning (100 to 700 chars, one 3.4k spike), then **one 42,924-
character reasoning block on round 29** that lays out the entire app,
then edits from round 30 onward with the plan echoed in every subsequent
request. It never re-planned. Its later reasoning spikes (4.6k, 7.4k,
5.7k on rounds 45–49; 7.6k and 5.7k on 64–65) are all one episode:
debugging its own signup test's params shape, which it solved with a
temporary print.

**DeepSeek thinks once, then executes.** On fixtures it reasons on the
first substantive round and then edits and verifies with no reasoning at
all. On the app it reasoned on 53 of 77 rounds, but the pattern is the
same at larger scale: a 16k-character plan block on round 22, an 8.9k
block to design HomeLive on round 29, 6k blocks for the two composites,
and zero reasoning on most `edit` rounds. Because its plan is a third the
size of Qwen's and it writes a short visible sentence per round
announcing the step, losing the reasoning between rounds in round 3 cost
it re-derivation on some rounds but never the whole plan. That is why
round 3 still finished at 92 rounds and round 4 finished at 77.

Put differently: the echo is a fix for models whose working memory is
the reasoning field. Qwen is the extreme case; DeepSeek is a mild one;
GLM with thinking on (§1a) is a third pattern: one small plan block, then
almost no reasoning, so the echo carries little but carries the thing
that matters.

## 3. What the echo costs

The echo appends every earlier round's reasoning of the turn to every
later request. For Qwen that means the 43k-character plan (roughly 10k
tokens) rides in the prompt of all 73 rounds after it.

| app | prompt per round | cache hit | uncached prompt |
|---|---:|---:|---:|
| Qwen round 4 | 70k | 95.2% | 342k |
| DeepSeek round 3 | 52k | 98.0% | 96k |
| DeepSeek round 4 | 57k | 97.8% | 97k |

DeepSeek's per-round prompt grew 9% with the echo and its uncached total
did not move, so for a think-once model the echo is close to free under
prefix caching. Qwen's per-round prompt is a quarter larger than
DeepSeek's and its uncached spend is 3.5× higher, but that ratio is the
same one seen on the fixtures (200k vs 46k) and in every earlier round:
it is the Qwen backend's cache behaviour, not the echo. Within this
round the echo's marginal cost to Qwen is the growth of an already
well-cached prefix; the compute that actually costs is the 38k reasoning
tokens it generated, which is what let it finish.

A note on comparability: Qwen's reasoning counts are the backend's
`reasoning_tokens` counter; DeepSeek's are helm's estimate from the
surfaced text (`~` in the tables) because its server still emits no
`completion_tokens_details`. Treat the two columns as the same quantity
to about ±10%.

## 4. Round-to-round noise, and the things that are not the echo

- **Qwen's fixture miss** (`safe_echo_exact`, `String.trim_trailing`
  strips every trailing newline where the spec keeps all but one) is
  variance, not regression: round 3 passed it with a one-byte
  `binary_part` slice at the same prompt and effort. Reasoning on the
  task was 315 tokens, the lightest of its run; round 3's was 2,343. At
  `low`, Qwen sometimes under-thinks a fixture that was built to punish
  exactly that shortcut.
- **Qwen's fixture wall fell 22%** (600 → 465 s) and reasoning 38%, but
  per fixture the movement is both ways (`lru_cache` 11 rounds / 3.7k
  reasoning → 5 / 133; `pricing` 1.7k → 2.7k). Fixtures are 4 to 5
  rounds and carry no plan worth echoing, so read this as run-to-run
  spread, with the echo possibly trimming the odd re-derivation.
- **DeepSeek's generator detour.** It ran `mix joby_kit.new` in the
  foreground at the 30 s default, was killed, ran it again at the 120 s
  maximum, was killed, then ran it in the background, found the two
  orphaned generators with `pstree`, killed them (its own processes) and
  waited. Twelve rounds and about 150 s of wall. Round 3's DeepSeek
  backgrounded the generator from the start. Same model, same prompt; the
  bash tool's description names both limits, so this is a coin the model
  flips. One sentence in the prompt ("the generator takes longer than the
  foreground limit; run it in the background") would remove the coin.
- **DeepSeek wrote fewer tests** (16 → 10) and a taller page (1,670 →
  2,539 px). Neither is graded beyond the ≥5 threshold. Both are within
  what the same model does on different days.
- **Both apps are called "Lumen."** That is four Lumens in three rounds
  across all three models (Qwen, DeepSeek twice, GLM's "LumenLab").
  DeepSeek's round-3 product was "Nimbus."

## 5. The `high` data point, re-read with the echo in mind

Round 3 began with DeepSeek at `high`: fixtures 16/17 in 91 rounds and
1,434 s with 60.7k completion tokens (`low`: 17/17, 72 rounds, 438 s,
18.2k), then an app turn that read for an hour, 51 rounds, 33 reads, zero
edits, 126k completion tokens, up to 18k hidden reasoning tokens per
round, timed out on an untouched scaffold. That row is in
`results/2026-09-05/raw/superseded/` and T24 calls the effort dial "the
largest single effect measured on this model."

It is, but it was measured **without the echo**, on the helm that
discarded reasoning. At `high` DeepSeek's plan blocks are far larger, so
the amnesia that only mildly taxed it at `low` may be what turned `high`
into a read loop: each round it thought at length, the thinking vanished,
and it read again. T25 says as much ("the `high` collapse becomes a fair
question again"). Until a `high` run exists on the T25 helm, the honest
statement is: `high` is much more expensive on DeepSeek, and whether it
is also unable to finish the app is unknown.

## 6. The three round-4 apps

All pass every check; `DESIGN_REVIEW.md` in this folder compares them
visually. Three things worth recording here:

- **Qwen's is the more compact and more engineered page** (1,387 px): a
  two-column hero with the countdown, signup form, recent signups, and
  activity feed all inside one card on the right, a stats card under the
  hero copy, six feature cards with eyebrow tags, a footer. It used a
  LiveView `stream` for the activity feed with explicit `stream_delete`
  to hold the ten-entry cap, which is the idiomatic solution and the only
  one across four rounds to use it. Empty states on both lists. Mobile:
  theme toggle and hamburger both visible, everything stacks. One
  blemish: the feature-grid intro copy describes the kit itself ("Built
  from `<.feature_grid>`, a registered composite…"), which is meta rather
  than product copy; the prompt forbids benchmark-themed copy, not this,
  but it reads like a model narrating its own work.
- **DeepSeek's is the more spacious marketing page** (2,539 px): hero,
  a full-width countdown band, a waitlist section, a stats strip, a
  "Live activity" section, six feature cards, footer. Product copy
  throughout ("Launch like the future depends on it"). The recent-signups
  heading has no empty-state line; the activity section does. Mobile is
  fine. Assigns-based lists rather than streams.
- **GLM's "Solstice" is the one that reads like a product page.** A
  desk lamp; the countdown is reframed as "early-bird places remaining,
  one spot opens up every five seconds", the only copy across four
  rounds that makes the five-second tick make sense. Two-column hero
  with the countdown card, a three-stat strip (the third stat, "60k
  hours of light", is decorative), six feature cards, newsletter and
  activity side by side, footer. Empty states on both lists. One feature
  tile ("Built to last") has a blank icon: an invalid heroicon name that
  the kit renders as an empty tile. The `pricing` fix carries a leftover
  `max(discounted, 0)` that can never bind; harmless.

## 7. What this round settles and what it leaves open

Settled:

1. helm's discarding of reasoning between rounds was a harness defect
   that made round 3's Qwen app row (and, in part, round 2's) a measure
   of helm, not of Qwen. Round 4 corrects it and Qwen ships.
2. GLM's thinking was off through airo in rounds 1 to 3. Every GLM
   result before round 4 is a no-thinking result. With thinking on it
   goes 17/17 and ships the fastest complete app.
3. With both defects fixed, all three models complete the app at `low`.
   The checklist no longer separates them; cost does.
4. The models differ in where and how much they think. Qwen: every
   round, in reasoning, silent in content. DeepSeek: once per task, then
   act. GLM at `low`: a small plan, then reflexes. Any change to the
   reasoning channel hits them in that order.

Open:

5. A second GLM thinking round, so its rank rests on more than one run.
6. A `high` run for all three on the T25 helm, to separate the effort
   effect from the echo effect in the superseded DeepSeek row, and to
   see what GLM's `high` (which the probe shows is real) does.
7. Whether Qwen's uncached-prompt ratio (3.5× DeepSeek at the same cache
   hit rate) is block-size granularity on its vLLM build or something in
   how the echo re-chunks the prefix; a Phase A run with the caching
   counters on would answer it.
8. The generator-in-foreground coin flip (§4), fixable with one prompt
   sentence.
9. The harness saved five screenshots for Qwen and six for the others:
   Qwen has no `desktop-dark` shot although its `dark_theme` check
   passed on the DOM probe. Small capture bug.

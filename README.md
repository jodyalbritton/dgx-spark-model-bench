# dgx-spark-model-bench

Three local models, benchmarked as working coding agents and as front-end
designers on a pair of NVIDIA DGX Sparks (`sparky` + `sparky2`, tensor
parallel 2): **GLM-5.3-Flash** (EXL3 4 bpw), **Qwen3.8-Flash-Next** (NVFP4),
and **DeepSeek-V4-Flash-Vision-Exp** (fp8). Everything here is graded by
machines and, for design, by a blind rubric review. No LLM judge decides a
score; the raw rows, transcripts of reasoning, generated apps, and
screenshots are all in the repo.

## Start here

| read | for |
|---|---|
| [`COMPARISON.md`](COMPARISON.md) | The comparison written for people deciding which model to run: bug fixes, a full application build with tools, both at each model's lowest and highest reasoning effort. Who is fastest and why, who thinks and how, what effort buys and costs. |
| [`REALWORLD.md`](REALWORLD.md) | What throughput looks like inside a working session, round by round: context growth, cache hits, seconds per round, tok/s you actually wait on, against the headline decode numbers. |
| [`results/2026-09-06-design/DESIGN_REVIEW.md`](results/2026-09-06-design/DESIGN_REVIEW.md) | The design bench: the same three models building the JobyCorp website from one brief and one design direction, ranked by a blind three-pass rubric review. |

## Status (2026-09-07)

- **Coding bench: five rounds complete on the first harness, one on the
  second.** Rounds 1 to 3 were harness shakedown (effort not sent,
  reasoning discarded between rounds, GLM's thinking off through a serving
  default); rounds 4 and 5 are the fair runs, at `low` and at each model's
  maximum, and all six of those runs pass every graded check. Round 6
  (2026-09-07) re-baselines at `low` on a harness that gives the models
  verbatim tool results, their own vision, browser hands, server jobs, and
  a budget countdown; its rows start a new table rather than continuing
  the old one. One GLM fixture pass in round 5 awaits a clean re-run.
- **Real-world throughput: complete** for the round-4 sessions; ledger
  exports exist for round 5 as well.
- **Design bench: round 1 complete**, gates and rubric review in. The
  public vote on the anonymised composites is recorded when it closes.
- **Raw inference (Phase A)** was measured once, in round 1, with a
  synthetic prompt; a re-run with natural text and aligned engine settings
  is in the plan and has not happened.

## What was tested, and the short answer

| bench | what it measures | result |
|---|---|---|
| **Raw inference** (`design/spark_bench.py`, round 1) | TTFT, prefill and decode tok/s at 256 to 154k tokens, 4-stream concurrency, one reasoning probe | Qwen's NVFP4 build has the fastest prefill (2.7k tok/s vs 1.8k DeepSeek, 1.1k GLM) and the best concurrency; decode is a near tie at 50 to 65 tok/s; DeepSeek has the lowest fixed overhead. |
| **Bug fixes** (17 seeded-bug Elixir modules, hidden tests) | Can the agent read a spec, find the bug, fix it minimally, and stop | At `low` and `max`: GLM 17/17, DeepSeek 17/17, Qwen 16/17 (the same fixture both times). Effort did not change a score; it made the fixes slower. |
| **Application** (a Phoenix LiveView landing site to a 19-check contract, ~100 tool calls) | Can the agent plan, build, test, boot, and finish a real task with tools | All three 19/19 at both efforts. At `low`: GLM 18 min, DeepSeek 24, Qwen 28. At `max`: GLM 39, DeepSeek 45, Qwen 63. Effort bought tests, composites, and page identity, not correctness, at about twice the wall. |
| **Tool use** (round 6: the same task with vision, browser hands, and server jobs on the wire) | When given tools, how well does the agent use them | DeepSeek looked at its page 17 times and shipped no visual defects; GLM looked 0 times, finished in 14 minutes, and shipped four; Qwen looked 7 rounds' worth, then cut verification when it read the clock. |
| **Real-world throughput** (per-round ledger of the app sessions) | What a session feels like | 35 to 40 tok/s per round end to end for DeepSeek and Qwen, 19 for GLM; 95 to 98% prefix-cache hits keep a 90k-token round at about one second to first token; the slow rounds are the planning rounds. |
| **Design** (the JobyCorp website from one brief and one `DESIGN.md`, three pages, both themes, both widths) | Can the agent execute a design direction, judged by mechanical gates and a blind rubric | Gates: Qwen 19/19, DeepSeek 19/19, GLM 18/19 (light-theme table headers at 4.24:1). Rubric mean of 5: Qwen 4.54, DeepSeek 4.08, GLM 3.75. |

Two lessons that apply to any agent harness, learned the hard way in
rounds 1 to 3 and written up in the round reports: send `reasoning_effort`
explicitly and confirm thinking is actually on for each model, and return
the model's reasoning on the following tool calls within a turn. Without
the second, Qwen cannot finish a long task.

## The design bench, in short

One brief (a landing page and simple site for JobyCorp, a local-AI
research company that publishes its benchmarks), one design direction
(`design/DESIGN.md`: two voices, a signal-teal accent, a record card on
plotting paper as the hero's one bold object, a figure on every page), one
byte-identical JobyKit base per model, each model at its ceiling effort
with its own vision route so it can look at its own pages.

Two layers, never blended. **Gates** are mechanical: compile, tests, lint,
demo content gone, routes, current-page marking, no overflow at 390 px,
WCAG AA contrast on every text element in both themes, icons resolve, copy
free of kit and task words, the theme pair in place, a registered
composite used on two pages, boots, mobile nav, theme toggle, dark theme.
**Ranking** is an eight-line rubric (identity, hierarchy, type, colour,
phone, copy, restraint, composite) scored by three fresh blind reviewer
sessions on anonymised composites in three shuffled orders, with the key
sealed until the prose was written.

| model | gates | rubric mean | rounds / wall | reasoning | composites reused | tests added |
|---|---:|---:|---:|---:|---:|---:|
| Qwen3.8-Flash-Next (`xhigh`) | 19/19 | **4.54** | 152 (cap, last call) / 63 min | 92k | 6 | 19 |
| DeepSeek-V4-Flash (`max`) | 19/19 | 4.08 | 139 / 61 min | 94k | 1 | 3 |
| GLM-5.3-Flash (`max`) | 18/19 | 3.75 | **103 / 50 min** | **40k** | 4 | 6 |

The shuffle earned its place: every reviewer pass ranked first the set it
saw first, and the mean order held anyway. Qwen developed the direction's
bold object rather than repeating it and led on identity, restraint, and
the composite; its faults are those of the most ambitious set (one wrong
number in copy, one self-referential caption). DeepSeek had the best
desktop composition and the best single line of copy, and repeated its
record fields four times. GLM executed the direction with no errors,
finished fastest on the fewest tokens, and under-spent: a half-empty
desktop column and the one contrast miss. Full prose, per-set, in the
review; twelve screenshots per model under the round's `screenshots/`.

## Results by round

| round | what | outcome |
|---|---|---|
| [`2026-09-04`](results/2026-09-04/) | Round 1: raw inference + first-edition coding bench | Three-way tie at the bench floor; effort not sent; cache counters missing for two engines. [`REPORT.md`](results/2026-09-04/REPORT.md) |
| [`2026-09-04-r2`](results/2026-09-04-r2/) | Round 2: second-edition coding bench (17 fixtures, hidden LiveView tests, rendered checks) | DeepSeek 18/18, GLM 14/18 at the cap, Qwen's app did not compile. [`REPORT.md`](results/2026-09-04-r2/REPORT.md) |
| [`2026-09-05`](results/2026-09-05/) | Round 3: effort explicit (`low`), endings classified, reasoning counted | DeepSeek 19/19; GLM 15/19 at the cap; Qwen abandoned because the harness discarded its reasoning between rounds. DeepSeek `high` row superseded. |
| [`2026-09-05-r2`](results/2026-09-05-r2/) | **Round 4: the fair `low` run** (reasoning echoed within the turn; GLM's thinking on for the first time) | All three 19/19; GLM and DeepSeek 17/17, Qwen 16/17. [`REPORT.md`](results/2026-09-05-r2/REPORT.md) · [`DESIGN_REVIEW.md`](results/2026-09-05-r2/DESIGN_REVIEW.md) |
| [`2026-09-05-r3`](results/2026-09-05-r3/) | **Round 5: the fair `max` run** (150-round / 90-min cap, last call, stopping instruction) | All three 19/19; GLM and DeepSeek 17/17, Qwen 16/17. [`REPORT.md`](results/2026-09-05-r3/REPORT.md) · [`DESIGN_REVIEW.md`](results/2026-09-05-r3/DESIGN_REVIEW.md) |
| [`2026-09-07`](results/2026-09-07/) | **Coding round 6: re-baseline at `low` on the second harness** (verbatim results, native vision, browser hands, server jobs, approval pin, budget countdown) | GLM 16/17 + 19/19 in 62 rounds / 14 min with no previews; DeepSeek 17/17 + 19/19 with a 15-round visual review; Qwen 16/17 + 16/19 after parking its timer under test. [`REPORT.md`](results/2026-09-07/REPORT.md) |
| [`2026-09-06-design`](results/2026-09-06-design/) | **Design bench, round 1** | Gates 19 / 19 / 18; rubric Qwen 4.54, DeepSeek 4.08, GLM 3.75. [`DESIGN_REVIEW.md`](results/2026-09-06-design/DESIGN_REVIEW.md) · [`RESULTS.md`](results/2026-09-06-design/RESULTS.md) |
| `dryrun` | Unscored harness dry run before round 2 | Found the narrated-ending case that led to the nudge. |

Each round folder has its `RUNLOG.md` (what was loaded, decided, and when,
in UTC), its rendered `RESULTS.md`, its raw rows under `raw/`, the
generated apps under `work/`, and the harness's screenshots.

## Layout

```
COMPARISON.md        the model comparison (coding bench, rounds 4 and 5)
REALWORLD.md         per-round throughput inside a working session
design/              what a round IS — stable across rounds
  TESTPLAN.md          the round protocol and pre-flight checks
  CODING_BENCH.md      coding bench: prompts, policy, tools, oracle, checklist
  DESIGN_BENCH.md      design bench: gates, rubric, review protocol
  DESIGN.md            the JobyCorp design direction given to every model
  spark_bench.py       raw inference harness
  make_report.py       renders a round's RESULTS.md from its raw/ JSON
  tools/               shoot_app.sh, cdp_shoot.py (boot and screenshot an app),
                       realworld_charts.py (REALWORLD charts), effort_probe.py
docs/                charts referenced by REALWORLD.md
results/
  current -> <round>   symlink; the harnesses write into results/current/
  <round>/
    RUNLOG.md  RESULTS.md  REPORT.md  DESIGN_REVIEW.md
    raw/               coding-<label>.json or design-<label>.json per model,
                       *.regrade.json (later oracle, run-time file untouched),
                       reasoning/ (per-round reasoning sidecars),
                       rounds/ (per-round ledger exports as CSV),
                       review/ (design: sealed key, passes, scores, vote),
                       superseded/ (off-protocol runs, kept as evidence)
    work/              the generated apps as each model left them (source only)
    screenshots/       the harness's captures; review/ holds the blind composites
```

## How a round runs

Make `results/<round>`, point `results/current` at it, load one model
(and, for the design bench, route vision to it), run the harness from
helm's dev seat, unload, repeat. Then `python3 design/make_report.py`
renders `RESULTS.md`; the reports are written by hand from the raw rows.
Every step, its acceptance criteria, and the open decisions are in
`design/TESTPLAN.md`; the coding and design benches each have their own
protocol file beside it.

Harness: [helm](https://github.com/JobyCorp), an Elixir agent with 21
native tools, driving each model through the [airo](https://github.com/JobyCorp)
gateway. Apps are generated with [JobyKit](https://hex.pm/packages/joby_kit_new).

# dgx-spark-model-bench

Three local models, benchmarked as working coding agents, as front-end
designers, and as serving engines on a pair of NVIDIA DGX Sparks (`sparky`
+ `sparky2`, tensor parallel 2): **GLM-5.3-Flash** (EXL3 4 bpw),
**Qwen3.8-Flash-Next** (NVFP4), and **DeepSeek-V4-Flash-Vision-Exp** (fp8).
Everything here is graded by machines and, for design, by a blind rubric
review. No LLM judge decides a score; the raw rows, transcripts of
reasoning, generated apps, and screenshots are all in the repo.

## Start here

| read | for |
|---|---|
| [`COMPARISON.md`](COMPARISON.md) | The comparison written for people deciding which model to run: bug fixes, a Phoenix application, a JavaScript application and a design brief, all with tools, on one harness at `low`. Who is fastest and why, who thinks and how, who has the best quality, which one to run. |
| [`THROUGHPUT.md`](THROUGHPUT.md) | Raw throughput on one method, three runs per model: prose, structured output and a 13k-token ingest, with prefill and time to first token, and the two published benchmark cells run verbatim beside them so the inflation is measured rather than argued. |
| [`REALWORLD.md`](REALWORLD.md) | What throughput looks like inside a working session, round by round: context growth, cache hits, seconds per round, the tok/s you actually wait on, against the headline numbers. |
| [`results/2026-09-10-baseline/RESULTS.md`](results/2026-09-10-baseline/RESULTS.md) | The rendered record of the baseline round: every row, every check, every constant. |

## Status (2026-09-11)

- **Baseline complete.** Round `2026-09-10-baseline` ran all three models
  through five benches on one harness commit: 17 bug fixes, the Phoenix
  app, the JavaScript app, the design brief, and throughput (three runs
  each). Every report in this folder is written from that round. The
  earlier rounds (2026-09-04 to 09-09) were harness shakedown and the
  effort study; they stay under `results/` as history and are not quoted.
- **Design rubric review: pending** for the baseline round. The gates are
  in; the blind three-pass review and the public vote have not been run on
  these sets.
- **Raw inference at concurrency and long context** was measured once,
  in round 1, with a synthetic prompt; it has not been repeated on the
  current serving configs.

## What was tested, and the short answer

| bench | what it measures | result |
|---|---|---|
| **Bug fixes** (17 seeded-bug Elixir modules, hidden tests) | Can the agent read a spec, find the bug, fix it minimally, and stop | GLM 17/17 in 8.4 min, Qwen 17/17 in 13.2 min, DeepSeek 16/17 in 8.1 min. DeepSeek declared the exact-newline fixture done with its tests failing; Qwen passed the fixture it had missed in every earlier round. |
| **Phoenix application** (a LiveView landing site to a 19-check contract, ~100 tool calls) | Can the agent plan, build, test, boot, look, and finish a real task with tools | All three 19/19. GLM in 90 rounds and 17 min on 19k output tokens; DeepSeek 104 rounds and 28 min with 31 browser looks; Qwen 103 rounds and 33 min. |
| **JavaScript application** (the same contract on Vite + React + TypeScript, 6 checks) | The same task on a stack with less training-set support | Qwen 6/6 in 6 min. GLM and DeepSeek 4/6: each failed one hidden test and one of its own, and replied "done". |
| **Design** (the JobyCorp website from one brief and one `DESIGN.md`, three pages, both themes, both widths) | Can the agent execute a design direction, judged by mechanical gates and a blind rubric | Gates: GLM 18/19 (mobile theme toggle), Qwen 18/19 (table headers at 4.24:1), DeepSeek 17/19 (no composite registered). Rubric review not yet run. |
| **Throughput** (`Helm.Evals.Throughput`, three runs per model, thinking off) | Decode, prefill and TTFT on real output kinds at c=1, against the published benchmark cells | Prose: Qwen 47 tok/s, DeepSeek 37, GLM 26, repeating within 1 to 4 %; prefill 2.9k / 1.5k / 1.0k tok/s. The forced-filler script cell puts all three within 10 % of each other; real prose puts Qwen at 1.8× GLM. |
| **Real-world throughput** (per-round ledger of the agent sessions) | What a session feels like | 40 / 30 / 18 tok/s per round end to end for DeepSeek, Qwen and GLM; 93 to 98 % prefix-cache hits keep a 100k-token round at one to four seconds to first token; the slow rounds are the planning rounds. |

Two lessons that apply to any agent harness, learned the hard way in the
shakedown rounds: send `reasoning_effort` explicitly and confirm what it
does for each model (`low` leaves Qwen and DeepSeek thinking on 60 % of
their output and GLM on a third), and return the model's reasoning on the
following tool calls within a turn. Without the second, Qwen cannot finish
a long task.

## Results by round

| round | what | outcome |
|---|---|---|
| [`2026-09-10-baseline`](results/2026-09-10-baseline/) | **The baseline**: five benches × three models on helm `bcf1e7d` (Qwen's agent rows on `c535e08`), effort `low`, throughput three runs each | Fixtures 17 / 17 / 16; Phoenix app 19/19 ×3; JS app 4 / 6 / 4 (GLM / Qwen / DeepSeek); design gates 18 / 18 / 17; prose decode 26 / 47 / 37 tok/s. [`RESULTS.md`](results/2026-09-10-baseline/RESULTS.md) · [`RUNLOG.md`](results/2026-09-10-baseline/RUNLOG.md) |
| [`2026-09-10-throughput`](results/2026-09-10-throughput/) | Throughput, one run per model on the pre-merge harness | Superseded by the baseline's three runs; kept as the first stream-timed rows. |
| [`2026-09-09`](results/2026-09-09/) | GLM coding rounds 8 to 10 at `low`; serving and prefill notes | Dense FP8 is the whole decode gain on GLM's serve; a controlled uncached prefill ladder. [`SERVING.md`](results/2026-09-09/SERVING.md) · [`PREFILL.md`](results/2026-09-09/PREFILL.md) |
| [`2026-09-07`](results/2026-09-07/) | Coding round 6: re-baseline at `low` on the second harness (verbatim results, native vision, browser hands, server jobs) | GLM 16/17 + 19/19 in 62 rounds with no previews; DeepSeek 17/17 + 19/19 with a 15-round visual review; Qwen 16/17 + 16/19. [`REPORT.md`](results/2026-09-07/REPORT.md) |
| [`2026-09-06-design`](results/2026-09-06-design/) | Design bench, round 1, at each model's maximum effort | Gates 19 / 19 / 18; rubric Qwen 4.54, DeepSeek 4.08, GLM 3.75. [`DESIGN_REVIEW.md`](results/2026-09-06-design/DESIGN_REVIEW.md) |
| [`2026-09-05-r3`](results/2026-09-05-r3/) | Round 5: all three at maximum effort, first harness | All three 19/19; effort bought tests and identity, not correctness, at twice the wall. [`REPORT.md`](results/2026-09-05-r3/REPORT.md) |
| [`2026-09-05-r2`](results/2026-09-05-r2/) | Round 4: the fair `low` run on the first harness | All three 19/19; GLM and DeepSeek 17/17, Qwen 16/17. [`REPORT.md`](results/2026-09-05-r2/REPORT.md) |
| [`2026-09-05`](results/2026-09-05/), [`2026-09-04-r2`](results/2026-09-04-r2/), [`2026-09-04`](results/2026-09-04/) | Rounds 1 to 3: harness shakedown and the raw inference ladder | Effort not sent, reasoning discarded between rounds, GLM's thinking off through a serving default. [`REPORT.md`](results/2026-09-04/REPORT.md) |
| `dryrun` | Unscored harness dry run before round 2 | Found the narrated-ending case that led to the nudge. |

Each round folder has its `RUNLOG.md` (what was loaded, decided, and when,
in UTC), its rendered `RESULTS.md`, its raw rows under `raw/`, the
generated apps under `work/`, and the harness's screenshots.

## Layout

```
COMPARISON.md        the model comparison (baseline round)
THROUGHPUT.md        raw throughput comparison (baseline round)
REALWORLD.md         per-round throughput inside a working session (baseline round)
design/              what a round IS — stable across rounds
  TESTPLAN.md          the round protocol and pre-flight checks
  CODING_BENCH.md      coding bench: prompts, policy, tools, oracle, checklist
  DESIGN_BENCH.md      design bench: gates, rubric, review protocol
  DESIGN.md            the JobyCorp design direction given to every model
  spark_bench.py       raw inference harness (round 1)
  make_report.py       renders a round's RESULTS.md from its raw/ JSON
                       (a copy of helm's priv/bench/make_report.py)
  tools/               export_rounds.py (per-round ledger → raw/rounds/*.csv),
                       realworld_charts.py (REALWORLD charts), shoot_app.sh,
                       cdp_shoot.py (boot and screenshot an app), effort_probe.py
docs/                charts referenced by REALWORLD.md
results/
  current -> <round>   symlink; the harnesses write into results/current/
  <round>/
    RUNLOG.md  RESULTS.md  REPORT.md  DESIGN_REVIEW.md
    raw/               fixtures-, phoenix-, js_app-, design-, throughput-<label>.json,
                       *.regrade.json (later oracle, run-time file untouched),
                       reasoning/ (per-round reasoning sidecars),
                       rounds/ (per-round ledger exports as CSV),
                       review/ (design: sealed key, passes, scores, vote)
    work/              the generated apps as each model left them (source only)
    screenshots/       the harness's captures; review/ holds the blind composites
```

## How a round runs

Make `results/<round>`, point `results/current` at it, load one model
(and route vision to it), run the bench chain from helm's dev seat
(`mix bench.fixtures`, `bench.phoenix_app`, `bench.js_app`,
`bench.design`, `bench.throughput`), unload, repeat. Then
`python3 design/make_report.py` renders `RESULTS.md`,
`design/tools/export_rounds.py` writes the per-round ledgers, and the
reports are written by hand from the raw rows. Every step, its acceptance
criteria, and the open decisions are in `design/TESTPLAN.md`; the coding
and design benches each have their own protocol file beside it.

Harness: [helm](https://github.com/JobyCorp), an Elixir agent with 18
native tools on the wire, driving each model through the
[airo](https://github.com/JobyCorp) gateway. Apps are generated with
[JobyKit](https://hex.pm/packages/joby_kit_new).

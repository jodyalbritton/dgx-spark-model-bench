# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-05`

Rendered by `design/make_report.py` from `results/2026-09-05/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Coding (helm agent) — the helm coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. **App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter); *none seen* = the backend reported no counter and no reasoning text reached helm — either the model did not think (GLM: completion tokens match the visible text at both grades) or the channel is not surfaced (DeepSeek before its 2026-09-05 reload).

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `0e79f20`, prompt `6fb75d99`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-05T20:33:17Z → 2026-09-05T21:00:46Z
- **qwen38-flash-next-nvfp4** — helm `0e79f20`, prompt `6fb75d99`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-05T21:19:26Z → (running)
- **dsv4-flash-vision-exp** — helm `0e79f20`, prompt `6fb75d99`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-05T19:37:28Z → 2026-09-05T20:11:20Z

### Quality

| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |
|---|---:|---:|---:|---:|---:|---|---|---|
| glm53-flash-exl3 | 15/17 | 3/3 | 6/7 | 6/7 | 15/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ❌ · ❌ · ✅ · ✅ · ❌ · ✅ · ❌ | lint warnings 0 · tests +10 · components +2 |
| qwen38-flash-next-nvfp4 | 17/17 | 3/3 | 7/7 | 7/7 | — | — · — · — · — · — · — · — · — | — · — · — · — · — · — · — · — · — · — | — |
| dsv4-flash-vision-exp | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +16 · components +2 |

Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | app tool calls | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 513 | 20 | 992 | 128 | 128 | 2 | 17.9 |
| qwen38-flash-next-nvfp4 | 600 | 21 | — | — | — | — | — |
| dsv4-flash-vision-exp | 438 | 23 | 1,451 | 92 | 100 | 1 | 37.3 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 186,862 | 7,447 | none seen | 4,972,285 | 4,705,792 | 266,493 | 17,800 | none seen |
| qwen38-flash-next-nvfp4 | 215,641 | 22,709 | 13,351 | — | — | — | — | — |
| dsv4-flash-vision-exp | 38,667 | 18,246 | ~7,916 | 4,771,871 | 4,676,352 | 95,519 | 54,149 | ~31,118 |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 0/15 | 0/0/0 | max_rounds (blank, 0 nudges) | 0/7 | bash 88, edit 23, preview 6, write 5, read 3, read_artifact 2, job 1 | bash (failed): killed: exceeded 30000ms timeout; bash (failed): exit 1 defmodule BenchappWeb.Layouts do @moduledoc """ Layou; bash (failed): exit 1 sed: 2: "test/benchapp_web/live/ ...": undefined labe; bash (failed): exit 1 deps/lazy_html/lib/lazy_html.ex:325: def filter(%Lazy; edit (failed): old_string not found in file; bash (failed): exit 1 503 0; read_artifact (failed): vision tier unavailable: {:http, 404, "{\"error\":{\"code\": |
| qwen38-flash-next-nvfp4 | 0/4 | 0/0/0 | — | —/— | — | — |
| dsv4-flash-vision-exp | 0/6 | 0/0/0 | done (summary, 0 nudges) | 0/2 | bash 42, edit 20, read 15, preview 8, write 6, todo 3, grep 2, glob 1, job 1, read_artifact 1, tree 1 | todo (failed): add needs items; set/remove need an integer id; bash (failed): exit 1 See the `Phoenix.LiveViewTest` documentation for usag |

Fixtures failed: glm53-flash-exl3: pricing (medium, done), glm53-flash-exl3: safe_echo_exact (hard, done)

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


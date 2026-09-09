# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-08-r2`

Rendered by `design/make_report.py` from `results/2026-09-08-r2/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Coding (helm agent) — the helm coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. **App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter); *none seen* = the backend reported no counter and no reasoning text reached helm — either the model did not think (GLM: completion tokens match the visible text at both grades) or the channel is not surfaced (DeepSeek before its 2026-09-05 reload).

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `1f72e76`, prompt `39413706`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 18 tools on the wire, warm fixture clamp, 2026-09-09T01:03:30Z → 2026-09-09T01:35:32Z

### Quality

| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |
|---|---:|---:|---:|---:|---:|---|---|---|
| glm53-flash-exl3 | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +13 · components +1 |

Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | green at | app tool calls | tool time (s) | files touched | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 592 | 28 | 1,120 | 108 | R89 (+19) | 133 | 88 | 22 (+692/−171) | 3 | 20.8 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 228,213 | 10,111 | ~2,266 | 5,174,409 | 4,910,080 | 264,329 | 23,320 | ~8,481 |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 2/14 | 0/0/0 | done (summary, 0 nudges) | 0/3 | bash 44, edit 34, read 21, preview 15, write 10, grep 5, job 2, glob 1, todo 1 | read (failed): cannot read /Users/jody/dgx-spark-model-bench/results/2026-0; edit (failed): old_string not found in file (line 19 equals old_string's fi; edit (failed): old_string not found in file (line 52 equals old_string's fi |

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


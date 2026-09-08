# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-08`

Rendered by `design/make_report.py` from `results/2026-09-08/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Coding (helm agent) — the helm coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. **App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter); *none seen* = the backend reported no counter and no reasoning text reached helm — either the model did not think (GLM: completion tokens match the visible text at both grades) or the channel is not surfaced (DeepSeek before its 2026-09-05 reload).

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `1f72e76`, prompt `39413706`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 18 tools on the wire, warm fixture clamp, 2026-09-08T09:57:07Z → 2026-09-08T10:25:30Z
- **qwen38-flash-next-nvfp4** — helm `1f72e76`, prompt `39413706`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 18 tools on the wire, warm fixture clamp, 2026-09-08T08:24:33Z → 2026-09-08T09:40:03Z
- **dsv4-flash-vision-exp** — helm `1f72e76`, prompt `39413706`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 18 tools on the wire, warm fixture clamp, 2026-09-08T11:01:26Z → 2026-09-08T11:36:28Z

### Quality

| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |
|---|---:|---:|---:|---:|---:|---|---|---|
| glm53-flash-exl3 | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +14 · components +1 |
| qwen38-flash-next-nvfp4 | 16/17 | 3/3 | 7/7 | 6/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +27 · components +3 |
| dsv4-flash-vision-exp | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +11 · components +1 |

Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | green at | app tool calls | tool time (s) | files touched | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 666 | 23 | 892 | 61 | R46 (+15) | 69 | 78 | 18 (+628/−168) | 3 | 18.7 |
| qwen38-flash-next-nvfp4 | 674 | 25 | 3,331 | 130 | R127 (+3) | 129 | 140 | 27 (+1628/−177) | 1 | 35.4 |
| dsv4-flash-vision-exp | 482 | 22 | 1,455 | 94 | R87 (+7) | 104 | 94 | 18 (+627/−166) | 3 | 33.7 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 231,496 | 11,836 | ~3,019 | 2,137,488 | 1,974,784 | 162,704 | 16,643 | ~6,453 |
| qwen38-flash-next-nvfp4 | 269,592 | 25,655 | 12,797 | 14,554,622 | 13,800,000 | 754,622 | 118,037 | 75,041 |
| dsv4-flash-vision-exp | 72,299 | 18,360 | ~7,289 | 8,031,938 | 7,858,432 | 173,506 | 49,056 | ~30,067 |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 0/16 | 0/0/0 | done (summary, 0 nudges) | 0/3 | bash 30, edit 15, preview 7, read 7, write 5, job 4, todo 1 | edit (failed): old_string not found in file (line 75 contains old_string's ; bash (failed): exit 1 sed: 2: "test/benchapp_web/live/ ...": undefined labe; job (failed): no job 2 — job(action: "list") shows what exists |
| qwen38-flash-next-nvfp4 | 1/4 | 0/0/0 | max_rounds (summary, 0 nudges); last call done in 2 rounds | 0/2 | bash 61, write 27, read 19, edit 16, job 3, tree 2, todo 1 | edit (failed): old_string not found in file (line 35 equals old_string's fi; bash (failed): exit 1 root=503 about=503 0 |
| dsv4-flash-vision-exp | 1/7 | 0/0/0 | done (summary, 0 nudges) | 0/4 | bash 37, preview 20, edit 16, read 11, todo 6, write 6, glob 4, job 2, grep 1, tree 1 | bash (failed): killed: exceeded 30000ms timeout /System/Volumes/Data/privat; bash (failed): killed: exceeded 30000ms timeout ** (Mix) app name is requir; bash (failed): exit 1 /bin/sh: scratch/debug_test.exs: No such file or dire; bash (failed): exit 1 sed: 2: "test/benchapp_web/live/ ...": undefined labe |

Fixtures failed: qwen38-flash-next-nvfp4: safe_echo_exact (hard, done)

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


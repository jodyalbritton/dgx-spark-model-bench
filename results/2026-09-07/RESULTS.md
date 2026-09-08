# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-07`

Rendered by `design/make_report.py` from `results/2026-09-07/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Coding (helm agent) — the helm coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. **App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter); *none seen* = the backend reported no counter and no reasoning text reached helm — either the model did not think (GLM: completion tokens match the visible text at both grades) or the channel is not surfaced (DeepSeek before its 2026-09-05 reload).

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `93ba25a`, prompt `b0b69c07`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 18 tools on the wire, warm fixture clamp, 2026-09-07T23:36:13Z → 2026-09-08T00:01:03Z
- **qwen38-flash-next-nvfp4** — helm `93ba25a`, prompt `b0b69c07`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 18 tools on the wire, warm fixture clamp, 2026-09-08T00:20:04Z → 2026-09-08T01:08:14Z
- **dsv4-flash-vision-exp** — helm `d258872`, prompt `b0b69c07`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 18 tools on the wire, warm fixture clamp, 2026-09-07T21:21:48Z → 2026-09-07T22:12:16Z

### Quality

| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |
|---|---:|---:|---:|---:|---:|---|---|---|
| glm53-flash-exl3 | 16/17 | 3/3 | 7/7 | 6/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +11 · components +3 |
| qwen38-flash-next-nvfp4 | 16/17 | 3/3 | 7/7 | 6/7 | 16/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ❌ · ✅ · ✅ · ❌ · ❌ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +16 · components +1 |
| dsv4-flash-vision-exp | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 1 · tests +11 · components +1 |

Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | green at | app tool calls | tool time (s) | files touched | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 511 | 26 | 844 | 62 | R60 (+2) | 74 | 43 | 18 (+672/−170) | 3 | 20.8 |
| qwen38-flash-next-nvfp4 | 609 | 31 | 2,148 | 105 | R103 (+2) | 129 | 22 | 20 (+996/−186) | 1 | 37.7 |
| dsv4-flash-vision-exp | 474 | 22 | 2,071 | 105 | R103 (+2) | 137 | 53 | 18 (+665/−157) | 1 | 36.5 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 201,220 | 8,022 | ~1,291 | 2,656,190 | 2,476,544 | 179,646 | 17,543 | ~5,224 |
| qwen38-flash-next-nvfp4 | 260,465 | 23,670 | 11,364 | 9,593,725 | 9,084,800 | 508,925 | 81,002 | 49,521 |
| dsv4-flash-vision-exp | 68,851 | 20,039 | ~8,816 | 9,937,097 | 9,753,344 | 183,753 | 75,609 | ~50,910 |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 2/12 | 0/0/0 | done (summary, 0 nudges) | 0/1 | edit 34, bash 14, read 13, write 5, job 4, grep 2, todo 1, tree 1 | edit (failed): old_string not found in file (line 134 equals old_string's f |
| qwen38-flash-next-nvfp4 | 0/9 | 0/0/0 | done (summary, 0 nudges) | 1/2 | bash 54, edit 21, write 14, read 13, preview 12, job 11, todo 2, tree 2 | bash (failed): exit 1 CHECKSUM contents.tar.gz metadata.config VERSION tar:; bash (refused): denied by the operator (or approval timed out); todo (failed): no item 11 — the current list is in your context |
| dsv4-flash-vision-exp | 2/4 | 0/0/0 | done (summary, 0 nudges) | 0/4 | bash 46, read 29, edit 20, preview 17, todo 13, job 6, write 6 | job (failed): tool task exited: {:normal, {GenServer, :call, [#PID<0.11844; bash (failed): exit 1 test/support/conn_case.ex test/support/data_case.ex t; bash (failed): exit 1 grep: deps/phoenix_html/lib/phoenix/html/form_data.ex; bash (failed): exit 1 Traceback (most recent call last): File "<string>", l |

Fixtures failed: glm53-flash-exl3: rate_limiter (hard, done), qwen38-flash-next-nvfp4: safe_echo_exact (hard, done)

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


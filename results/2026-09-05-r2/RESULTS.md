# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-05-r2`

Rendered by `design/make_report.py` from `results/2026-09-05-r2/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Coding (helm agent) — the helm coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. **App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter); *none seen* = the backend reported no counter and no reasoning text reached helm — either the model did not think (GLM: completion tokens match the visible text at both grades) or the channel is not surfaced (DeepSeek before its 2026-09-05 reload).

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `170dc2b`, prompt `6fb75d99`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-06T00:49:53Z → 2026-09-06T01:21:36Z
- **qwen38-flash-next-nvfp4** — helm `7c3f879`, prompt `6fb75d99`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-05T22:39:25Z → 2026-09-05T23:16:57Z
- **dsv4-flash-vision-exp** — helm `9b75ff3`, prompt `6fb75d99`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort low, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-05T23:32:02Z → 2026-09-06T00:06:56Z

### Quality

| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |
|---|---:|---:|---:|---:|---:|---|---|---|
| glm53-flash-exl3 | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +9 · components +2 |
| qwen38-flash-next-nvfp4 | 16/17 | 3/3 | 7/7 | 6/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +18 · components +2 |
| dsv4-flash-vision-exp | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +10 · components +2 |

Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | app tool calls | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 654 | 28 | 1,103 | 93 | 111 | 3 | 18.4 |
| qwen38-flash-next-nvfp4 | 465 | 20 | 1,655 | 102 | 101 | 1 | 35.7 |
| dsv4-flash-vision-exp | 496 | 25 | 1,440 | 77 | 92 | 1 | 35.2 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 196,025 | 10,775 | ~2,477 | 3,788,205 | 3,594,752 | 193,453 | 20,313 | ~5,862 |
| qwen38-flash-next-nvfp4 | 199,668 | 17,754 | 8,331 | 7,147,342 | 6,804,800 | 342,542 | 59,098 | 38,214 |
| dsv4-flash-vision-exp | 46,042 | 18,651 | ~8,667 | 4,353,599 | 4,256,512 | 97,087 | 50,626 | ~28,186 |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 0/21 | 0/0/0 | done (summary, 0 nudges) | 0/9 | bash 53, edit 38, read 9, write 5, preview 4, grep 1, read_artifact 1 | bash (failed): killed: exceeded 30000ms timeout; grep (failed): ripgrep failed (exit 2):; bash (failed): exit 1 sed: 1: "lib/benchapp_web/live/d ...": extra characte; edit (failed): old_string not found in file; edit (failed): old_string not found in file; edit (failed): old_string matches 2 times — make it unique or set replace_a; edit (failed): old_string not found in file; edit (failed): old_string not found in file; bash (failed): [artifact:8caa1392-8d0c-4002-a79d-f19afff28374 — 56k tokens, |
| qwen38-flash-next-nvfp4 | 0/3 | 0/0/0 | done (summary, 0 nudges) | 0/2 | bash 41, read 21, edit 18, write 9, preview 3, read_artifact 3, job 2, todo 2, outline 1, tree 1 | read (failed): cannot read /Users/jody/benchmarks/results/2026-09-05-r2/wor; read_artifact (failed): vision tier unavailable: {:http, 404, "{\"error\":{\"code\": |
| dsv4-flash-vision-exp | 0/2 | 0/0/0 | done (summary, 0 nudges) | 0/5 | bash 33, edit 20, read 16, write 8, job 7, preview 3, todo 3, outline 1, tree 1 | bash (failed): killed: exceeded 30000ms timeout total 0 drwxr-xr-x 2 jody s; bash (failed): killed: exceeded 120000ms timeout; todo (failed): add needs items; set/remove need an integer id; todo (failed): no item 1 — the current list is in your context; todo (failed): no item 10 — the current list is in your context |

Fixtures failed: qwen38-flash-next-nvfp4: safe_echo_exact (hard, done)

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


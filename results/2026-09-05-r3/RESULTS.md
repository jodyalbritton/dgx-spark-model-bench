# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-05-r3`

Rendered by `design/make_report.py` from `results/2026-09-05-r3/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Coding (helm agent) — the helm coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. **App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter); *none seen* = the backend reported no counter and no reasoning text reached helm — either the model did not think (GLM: completion tokens match the visible text at both grades) or the channel is not surfaced (DeepSeek before its 2026-09-05 reload).

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `6e0f0f1`, prompt `60276f47`, round caps 35 (fixture) / 150 (app), deadlines 600/5,400 s, effort max, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-06T04:49:12Z → 2026-09-06T05:53:12Z
- **qwen38-flash-next-nvfp4** — helm `01c8674`, prompt `60276f47`, round caps 35 (fixture) / 150 (app), deadlines 600/5,400 s, effort max, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-06T08:24:29Z → 2026-09-06T09:45:40Z
- **dsv4-flash-vision-exp** — helm `7d2c4ec`, prompt `60276f47`, round caps 35 (fixture) / 150 (app), deadlines 600/5,400 s, effort max, PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-06T06:34:42Z → 2026-09-06T07:36:36Z

### Quality

| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |
|---|---:|---:|---:|---:|---:|---|---|---|
| glm53-flash-exl3 | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +17 · components +2 |
| qwen38-flash-next-nvfp4 | 16/17 | 3/3 | 7/7 | 6/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +39 · components +7 |
| dsv4-flash-vision-exp | 17/17 | 3/3 | 7/7 | 7/7 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | lint warnings 0 · tests +13 · components +3 |

Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.

Oracle provenance — a later oracle fixed a harness mistake, and the row above is the app under that oracle (`raw/coding-<label>.regrade.json`; the run-time file is untouched):

- **glm53-flash-exl3** — graded under hidden tests `6ed2e858` on helm `a2b0d51` (run-time oracle `6ccd80bc`); the oracle fix corrected: activity, nav

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | app tool calls | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 1,372 | 70 | 2,342 | 90 | 118 | 2 | 21.1 |
| qwen38-flash-next-nvfp4 | 933 | 40 | 3,760 | 152 | 195 | 1 | 37.5 |
| dsv4-flash-vision-exp | 906 | 44 | 2,674 | 137 | 154 | 1 | 36.8 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 190,350 | 30,314 | ~18,781 | 6,116,599 | 5,917,184 | 199,415 | 49,308 | ~30,835 |
| qwen38-flash-next-nvfp4 | 314,594 | 37,187 | 15,857 | 20,817,985 | 20,140,800 | 677,185 | 140,848 | 68,844 |
| dsv4-flash-vision-exp | 73,123 | 39,031 | ~24,062 | 13,048,443 | 12,886,016 | 162,427 | 98,280 | ~59,498 |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 0/11 | 0/0/0 | done (summary, 0 nudges) | 0/3 | bash 47, edit 27, read 26, write 10, preview 3, todo 2, tree 2, read_artifact 1 | bash (failed): [artifact:7a466ecd-2e3d-4d63-bce1-2d2bc7927f34 — 8k tokens, ; todo (failed): add needs items; set/remove need an integer id; bash (failed): exit 1 sed: 2: "test/benchapp_web/live/ ...": undefined labe |
| qwen38-flash-next-nvfp4 | 2/8 | 0/0/0 | max_rounds (summary, 0 nudges); last call done in 2 rounds | 1/4 | bash 63, edit 59, read 32, write 27, preview 7, tree 2, glob 1, job 1, outline 1, read_artifact 1, todo 1 | write (refused): path escapes the session roots: /tmp/pptest/verify.js; bash (failed): exit 1 === built bundle ThemeSwitch === grep: priv/assets/js; read (failed): tool crashed: no function clause matching in Helm.Tools.Read; read (failed): tool crashed: no function clause matching in Helm.Tools.Read; read_artifact (failed): no such artifact in this session: f1017018-447e-43a4-b98b-d8 |
| dsv4-flash-vision-exp | 1/6 | 0/0/0 | done (summary, 0 nudges) | 1/22 | bash 66, edit 22, read 21, job 15, todo 14, preview 9, write 6, read_artifact 1 | todo (failed): add needs items; set/remove need an integer id; todo (failed): add needs items; set/remove need an integer id; bash (failed): killed: exceeded 30000ms timeout; bash (failed): killed: exceeded 120000ms timeout; bash (failed): killed: exceeded 30000ms timeout; read (refused): path escapes the session roots: /Users/jody/Work/joby_kit_ne; bash (failed): exit 1 joby_kit joby_kit.ex mix ---components:; edit (failed): old_string not found in file; edit (failed): old_string not found in file; edit (failed): old_string not found in file; bash (failed): killed: exceeded 30000ms timeout 503 503 503; todo (failed): no item 1 — the current list is in your context; todo (failed): no item 2 — the current list is in your context; todo (failed): no item 3 — the current list is in your context; todo (failed): no item 4 — the current list is in your context; todo (failed): no item 5 — the current list is in your context; todo (failed): no item 6 — the current list is in your context; todo (failed): no item 7 — the current list is in your context; todo (failed): no item 8 — the current list is in your context; todo (failed): no item 9 — the current list is in your context; todo (failed): no item 10 — the current list is in your context; todo (failed): no item 11 — the current list is in your context; todo (failed): no item 12 — the current list is in your context |

Fixtures failed: qwen38-flash-next-nvfp4: safe_echo_exact (hard, done)

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


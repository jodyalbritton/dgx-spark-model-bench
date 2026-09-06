# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-04-r2`

Rendered by `design/make_report.py` from `results/2026-09-04-r2/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Coding (helm agent) — the helm coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. **App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter).

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `0080265`, prompt `025cf1ec`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort not set (template default), PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-04T22:54:02Z → 2026-09-04T23:41:36Z
- **qwen38-flash-next-nvfp4** — helm `529686a`, prompt `025cf1ec`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort not set (template default), PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-04T18:34:08Z → 2026-09-04T19:14:03Z
- **dsv4-flash-vision-exp** — helm `d1f9891`, prompt `025cf1ec`, round caps 35 (fixture) / 128 (app), deadlines 600/3,600 s, effort not set (template default), PORT=4099, memory off, tools native, 21 tools on the wire, warm fixture clamp, 2026-09-05T02:30:29Z → 2026-09-05T03:11:20Z

### Quality

| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |
|---|---:|---:|---:|---:|---:|---|---|---|
| glm53-flash-exl3 | 15/17 | 3/3 | 5/7 | 7/7 | 14/18 | ✅ · ❌ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ❌ · ✅ · ❌ · ❌ · ✅ · ✅ · — · ✅ · ✅ | lint warnings 1 · tests +15 · components +1 |
| qwen38-flash-next-nvfp4 | 17/17 | 3/3 | 7/7 | 7/7 | 5/18 | ❌ · ❌ · ❌ · ✅ · ✅ · ✅ · ❌ · ✅ | ❌ · ❌ · ❌ · ❌ · ❌ · ❌ · ❌ · — · ❌ · ❌ | lint warnings 0 · tests +0 · components +1 |
| dsv4-flash-vision-exp | 17/17 | 3/3 | 7/7 | 7/7 | 17/18 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ❌ · ✅ · ✅ · — · ✅ · ✅ | lint warnings 0 · tests +9 · components +2 |

Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.

#### Re-graded under a later oracle

The rows above are as graded during the run. A re-grade re-runs the app checklist on the stored app under the current hidden tests and rendered checks and writes `raw/coding-<label>.regrade.json`; the as-graded file is never modified.

| model | as graded | re-graded | oracle (hidden tests sha) | helm | checks that changed |
|---|---:|---:|---|---|---|
| glm53-flash-exl3 | 14/18 | 14/18 | `2924139b` | `ed0c6d8` | none |
| dsv4-flash-vision-exp | 17/18 | 18/18 | `2924139b` | `ed0c6d8` | activity ❌→✅ |

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | app tool calls | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 1,673 | 75 | 1,048 | 128 | 141 | 4 | 18.8 |
| qwen38-flash-next-nvfp4 | 632 | 34 | 1,611 | 47 | 51 | 290 | 34.6 |
| dsv4-flash-vision-exp | 723 | 35 | 1,614 | 99 | 126 | 10 | 34.7 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 514,425 | 33,236 | — | 5,751,075 | 5,479,936 | 271,139 | 19,677 | — |
| qwen38-flash-next-nvfp4 | 338,454 | 22,333 | — | 1,617,125 | 1,411,200 | 205,925 | 55,825 | — |
| dsv4-flash-vision-exp | 47,494 | 29,478 | — | 5,312,916 | 5,210,368 | 102,548 | 56,013 | — |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 2/43 | 2/0/— | max_rounds | 1/12 | bash 78, edit 23, read 19, write 13, todo 4, glob 1, grep 1, outline 1, tree 1 | bash (failed): exit 1 benchapp/config/config.exs:22: pubsub_server: Benchap; todo (failed): add needs items; set/remove need an integer id; todo (failed): [guardrail] this exact call has now failed 2 times — change ; edit (failed): old_string not found in file; bash (failed): exit 1; bash (failed): exit 1 Compiling 23 files (.ex) Generated benchapp app ---- ; bash (failed): exit 1 Erlang/OTP 28 [erts-16.4] [source] [64-bit] [smp:18:1; bash (failed): exit 1; bash (failed): exit 1; bash (failed): exit 2 grep: /tmp/beam_out.erl: No such file or directory; write (refused): path escapes the session roots: /tmp/dump.erl; bash (failed): exit 1 no _build in cwd means removed ls: _build/dev/lib/ben; bash (failed): exit 1 0 |
| qwen38-flash-next-nvfp4 | 2/4 | 0/0/— | done | 0/1 | bash 30, edit 7, read 6, todo 5, write 3 | todo (failed): items must be non-empty strings |
| dsv4-flash-vision-exp | 0/5 | 0/0/— | done | 0/3 | bash 37, todo 23, read 22, edit 21, preview 8, write 6, job 5, read_artifact 4 | edit (failed): old_string not found in file; preview (failed): net::ERR_CONNECTION_REFUSED; bash (failed): exit 7 000 |

Fixtures failed: glm53-flash-exl3: pricing (medium, done), glm53-flash-exl3: interval_merge (medium, done)

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks

Harness: `spark_bench.py` run on sparky against the head node over loopback. Decode rows use thinking off, `temperature 0.6`, fixed 128-token output (`min_tokens=max_tokens=128`, `ignore_eos`). TTFT = first streamed token (content or reasoning). Prefill tok/s = prompt tokens / TTFT. Decode tok/s = 128 / (end − first token). Prompts are unique per request (no prefix-cache hits). Reasoning probe: greedy (`temperature 0`), thinking on, one question, correctness checked against the known answer.

## Runs

- **glm53-flash-exl3** — 2026-09-04T09:24:45Z → 2026-09-04T09:31:29Z — model `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3` · max_model_len 524,288 · engine 0.1.dev20051+g487ecf187 · image `glm53-flash-sm121:eb0469fb` · ctx 524288 · parallel 4 · tp 2
- **qwen38-flash-next-nvfp4** — 2026-09-04T10:11:35Z → 2026-09-04T10:14:51Z — model `RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt` · max_model_len 1,000,000 · engine 0.1.dev20073+g8e685d198 · image `vllm/vllm-openai:qwen38-flash-next` · ctx 1000000 · parallel 8 · tp 2
- **dsv4-flash-vision-exp** — 2026-09-04T10:44:01Z → 2026-09-04T10:49:05Z — model `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8` · max_model_len 1,048,576 · engine 0.25.2.dev0+g752a3a504.d20260714 · image `ghcr.io/anemll/dspark-vllm-gx10:0.1.1` · ctx 1048576 · parallel 6 · tp 2

## Time to first token (s), c=1

| prompt tokens | glm53-flash-exl3 | qwen38-flash-next-nvfp4 | dsv4-flash-vision-exp |
|---:|---:|---:|---:|
| 256 | 0.85 | 1.26 | 0.31 |
| 2,048 | 2.34 | 1.27 | 1.21 |
| 8,192 | 8.12 | 3.44 | 4.49 |
| 32,768 | 29.28 | 12.07 | 17.80 |
| 65,536 | 58.02 | 23.83 | 37.38 |
| 102,400 | 90.71 | 38.88 | 58.14 |
| 153,600 | 137.51 | 60.79 | 92.29 |

## Prefill throughput (prompt tok/s), c=1

| prompt tokens | glm53-flash-exl3 | qwen38-flash-next-nvfp4 | dsv4-flash-vision-exp |
|---:|---:|---:|---:|
| 256 | 330 | 226 | 884 |
| 2,048 | 884 | 1,633 | 1,707 |
| 8,192 | 1,015 | 2,397 | 1,833 |
| 32,768 | 1,121 | 2,719 | 1,843 |
| 65,536 | 1,130 | 2,753 | 1,754 |
| 102,400 | 1,129 | 2,636 | 1,762 |
| 153,600 | 1,117 | 2,528 | 1,665 |

## Decode throughput (tok/s per stream), c=1

| prompt tokens | glm53-flash-exl3 | qwen38-flash-next-nvfp4 | dsv4-flash-vision-exp |
|---:|---:|---:|---:|
| 256 | 50.5 | 55.1 | 55.9 |
| 2,048 | 44.9 | 57.5 | 57.4 |
| 8,192 | 55.5 | 63.8 | 51.7 |
| 32,768 | 46.7 | 64.9 | 51.4 |
| 65,536 | 46.7 | 55.4 | 47.7 |
| 102,400 | 55.9 | 60.5 | 64.4 |
| 153,600 | 58.2 | 59.4 | 73.1 |

## Concurrency (c>1): output tok/s over the whole wall (prefill included) · per-stream decode tok/s · median TTFT

| prompt tokens | c | glm53-flash-exl3 | qwen38-flash-next-nvfp4 | dsv4-flash-vision-exp |
|---:|---:|---:|---:|---:|
| 256 | 4 | 81.0 wall · 30.9/stream · 1.51 s | 92.5 wall · 38.9/stream · 1.62 s | 95.5 wall · 30.4/stream · 1.10 s |
| 8,192 | 4 | 15.1 wall · 19.4/stream · 24.50 s | 32.7 wall · 40.7/stream · 12.40 s | 23.2 wall · 14.7/stream · 11.47 s |

## Reasoning probe (thinking on, greedy)

Question: _What is the smallest positive integer that leaves a remainder of 1 when divided by each of 2, 3, 4, 5 and 6, and is exactly divisible by 7? Show your reasoning, then give the final answer on its own line as 'ANSWER: <number>'._ Expected answer: **301**.

| model | correct | reasoning tokens | answer tokens | total completion | wall time (s) | decode tok/s | finish |
|---|:---:|---:|---:|---:|---:|---:|---|
| glm53-flash-exl3 | ✅ | 361 | 465 | 828 | 16.6 | 51.2 | stop |
| qwen38-flash-next-nvfp4 | ✅ | 378 | 334 | 716 | 13.4 | 57.0 | stop |
| dsv4-flash-vision-exp | ✅ | 217 | 191 | 410 | 7.0 | 60.5 | stop |

## Coding (helm agent) — T22 coding bench

Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop (memory off, MCP off, consult denied). **Fixtures** = the 12 T08 seeded-bug tasks, graded by hidden ExUnit tests. **App** = the phoenix countdown prompt, graded by a mechanical checklist (compile, test, lint, countdown, nav, layout replaced, boots on the bench port) — no LLM judge. Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); *failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn (graded on what was on disk); *timeout* = the deadline did.

Every row below ran on one harness; the constants are written into each run's JSON:

- **glm53-flash-exl3** — helm `6629000`, round caps 35 (fixture) / 128 (app), deadlines 600/2,400 s, PORT=4099, memory off, tools native, 21 tools on the wire, 2026-09-04T13:47:37Z → 2026-09-04T14:01:05Z
- **qwen38-flash-next-nvfp4** — helm `f20cefe`, round caps 35 (fixture) / 128 (app), deadlines 600/2,400 s, PORT=4099, memory off, tools native, 21 tools on the wire, 2026-09-04T14:46:16Z → 2026-09-04T14:58:22Z
- **dsv4-flash-vision-exp** — helm `fd0c053`, round caps 35 (fixture) / 128 (app), deadlines 600/2,400 s, PORT=4099, memory off, tools native, 21 tools on the wire, 2026-09-04T14:13:52Z → 2026-09-04T14:31:25Z

### Quality

| model | fixtures | easy | medium | hard | app checks | compile · test · lint · countdown · nav · layout · boots |
|---|---:|---:|---:|---:|---:|---|
| glm53-flash-exl3 | 12/12 | 3/3 | 5/5 | 4/4 | 8/8 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ |
| qwen38-flash-next-nvfp4 | 12/12 | 3/3 | 5/5 | 4/4 | 8/8 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ |
| dsv4-flash-vision-exp | 12/12 | 3/3 | 5/5 | 4/4 | 8/8 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ |

### Speed

| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | app tool calls | app TTFT (s) | app completion tok/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 405 | 13 | 363 | 27 | 30 | 2 | 11.3 |
| qwen38-flash-next-nvfp4 | 257 | 18 | 430 | 43 | 44 | 9 | 29.1 |
| dsv4-flash-vision-exp | 509 | 51 | 496 | 59 | 64 | 6 | 35.1 |

### Spend (tokens)

| model | fixtures uncached prompt | fixtures completion | app prompt | app cached | app uncached prompt | app completion |
|---|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 509,202 | 7,613 | 631,918 | — | 631,918 | 4,112 |
| qwen38-flash-next-nvfp4 | 317,425 | 9,279 | 1,085,334 | — | 1,085,334 | 12,490 |
| dsv4-flash-vision-exp | 24,882 | 14,058 | 2,152,625 | 2,091,008 | 61,617 | 17,414 |

### Failures and tool mix

| model | fixtures refused/failed | fixtures capped/timed out | app outcome | app refused/failed | app tools | app failures |
|---|---:|---:|---|---:|---|---|
| glm53-flash-exl3 | 1/19 | 1/0 | done | 0/0 | bash 10, read 8, edit 5, preview 2, write 2, grep 1, read_artifact 1, tree 1 | — |
| qwen38-flash-next-nvfp4 | 0/3 | 0/0 | done | 0/1 | bash 30, edit 6, preview 3, write 2, job 1, read 1, read_artifact 1 | bash (failed): exit 1 heroicons |
| dsv4-flash-vision-exp | 0/7 | 0/0 | done | 0/2 | bash 31, edit 14, read 12, preview 4, read_artifact 2, write 1 | edit (failed): old_string not found in file; bash (failed): exit 1 sed: 1: "lib/benchapp_web/live/h ...": extra characte |

Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.


## Notes

- **dsv4-flash-vision-exp**: 256/2048 c=1 and 256/8192 c=4 cases replaced by a warm re-run (raw/dsv4-rerun.json): the first request per prompt/batch shape after a cold start pays FlashInfer autotune (8-12 s TTFT), which the recipe documents. GLM and Qwen rows were not re-run this way.
- **Thinking control**: decode rows send `chat_template_kwargs {thinking:false, enable_thinking:false}`; the probe sends `{thinking:true, enable_thinking:true}` with no reasoning_effort, so DSv4 ran at its template default rather than the server's `low`.
- **Load path**: GLM was the pre-existing agent load; Qwen3.8 and DSv4 Vision-Exp were loaded through airo_agent `POST /load` with `deploy/payloads/qwen38-flash-next.json` and `deploy/payloads/dsv4-vision-exp.json`.

Raw JSON per run (full per-request records, reasoning and answer text): `raw/<label>.json`.


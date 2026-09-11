# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-10-throughput`

Rendered by `design/make_report.py` from `results/2026-09-10-throughput/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Throughput (helm agent)

Harness: `Helm.Evals.Throughput` through helm and airo. Arms: **prose**, **ingest** (the pinned corpus, summarised), **json** (schema enforced), **json_free** (same body, no schema), **synthetic** (repeated filler, `ignore_eos`), **recipe** (sparkDash DecodeBench ×1 prose cell, verbatim) and **spark_bench** (`priv/bench/spark_bench.py` first cell, verbatim). Every constant, prompt and sampling value is in each record's `harness` block.

Column definitions. **decode tok/s** = (completion tokens − 1) / (last generated delta − first generated delta); the case's `window_ms`. **prefill tok/s** = prompt tokens / TTFT, only for cases with no prefix-cache hit and a prompt at or above the harness's `prefill_floor_tokens`; other cases are blank and not counted in **n**. **acceptance** = accepted draft tokens / draft tokens offered for that case, a delta between two reads of `/v1/serving?speculative=1`; **(n)** is the cases that got one. **shared slot** = cases whose decode steps + accepted tokens differ from their completion count by more than the harness's `gap_tolerance` (another client generated on the deployment during the case). **hit cap** = cases whose completion reached `max_tokens`. **cached** = cases with a prefix-cache hit. Medians are over the arm's counted cases; ranges are min–max.

### Records

| record | model | helm SHA | dirty | started (UTC) | finished (UTC) | warm-up ms | cases | rejected | thinking leaks | json parse failures |
|---|---|---|---|---|---|---:|---:|---:|---:|---:|
| [throughput-glm53-flash-exl3.json](raw/throughput-glm53-flash-exl3.json) | Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3 | 9ed7c56 | True | 2026-09-10T17:57:38Z | 2026-09-10T18:06:11Z | 2522 | 21 | 0 | 0 | 0 |
| [throughput-qwen38-flash-next-nvfp4.json](raw/throughput-qwen38-flash-next-nvfp4.json) | RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt | 9ed7c56 | True | 2026-09-10T16:33:35Z | 2026-09-10T16:38:21Z | 1970 | 21 | 0 | 0 | 0 |
| [throughput-dsv4-flash-vision-exp.json](raw/throughput-dsv4-flash-vision-exp.json) | deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8 | 9ed7c56 | True | 2026-09-10T17:34:45Z | 2026-09-10T17:41:15Z | 3256 | 21 | 0 | 0 | 1 |

Harness constants (first record): temperature 0.0, max_tokens 900, repeats 3 (cells —), prefill floor 200 tokens, gap tolerance —, ingest corpus rev 1373402144 (61562 chars), decode window: first delta to stream end.

### Ratios of arm medians (from each record's `summary`)

| model | structured / prose | guided / free | synthetic / prose | recipe / prose | spark_bench / prose |
|---|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 0.942 | 0.961 | 1.687 | 1.152 | 1.849 |
| qwen38-flash-next-nvfp4 | 1.057 | 0.991 | 1.188 | 1.123 | 1.328 |
| dsv4-flash-vision-exp | 1.037 | 1.041 | 1.123 | 1.148 | 1.589 |

### Per arm

| model | arm | n | decode tok/s | decode range | acceptance (n) | shared slot | hit cap | cached | TTFT ms (median) | prefill tok/s (n) | prompt Σ | cached Σ | uncached Σ | completion Σ |
|---|---|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | prose | 3 | 27.0 | 24.4–27.9 | 0.291 (3) | 0 | 1 | 0 | 271 | — (0) | 95 | 0 | 95 | 2,528 |
| glm53-flash-exl3 | ingest | 3 | 29.0 | 28.7–30.9 | 0.321 (3) | 0 | 3 | 2 | 3013 | 815.7 (3) | 39,558 | 21,504 | 18,054 | 2,700 |
| glm53-flash-exl3 | json | 3 | 25.4 | 20.7–26.0 | 0.277 (3) | 0 | 0 | 0 | 412 | — (0) | 171 | 0 | 171 | 1,885 |
| glm53-flash-exl3 | json_free | 3 | 26.4 | 21.4–26.5 | 0.269 (3) | 0 | 0 | 0 | 320 | — (0) | 186 | 0 | 186 | 1,899 |
| glm53-flash-exl3 | synthetic | 3 | 45.5 | 23.3–54.4 | 0.579 (3) | 0 | 3 | 0 | 1506 | 812.1 (3) | 3,669 | 0 | 3,669 | 2,700 |
| glm53-flash-exl3 | recipe | 3 | 31.1 | 30.6–33.0 | 0.361 (3) | 0 | 3 | 0 | 288 | — (0) | 120 | 0 | 120 | 1,200 |
| glm53-flash-exl3 | spark_bench | 3 | 49.9 | 29.9–50.8 | 0.695 (3) | 0 | 3 | 0 | 774 | 363.0 (3) | 842 | 0 | 842 | 384 |
| qwen38-flash-next-nvfp4 | prose | 3 | 46.7 | 46.1–48.8 | 0.597 (3) | 0 | 0 | 0 | 182 | — (0) | 99 | 0 | 99 | 2,149 |
| qwen38-flash-next-nvfp4 | ingest | 3 | 42.1 | 40.5–43.0 | 0.511 (3) | 0 | 0 | 2 | 1732 | 2,149.5 (3) | 41,154 | 20,800 | 20,354 | 2,095 |
| qwen38-flash-next-nvfp4 | json | 3 | 49.3 | 47.3–50.4 | 0.647 (3) | 0 | 0 | 0 | 268 | — (0) | 177 | 0 | 177 | 2,296 |
| qwen38-flash-next-nvfp4 | json_free | 3 | 49.8 | 48.7–50.5 | 0.653 (3) | 0 | 0 | 0 | 202 | — (0) | 192 | 0 | 192 | 2,233 |
| qwen38-flash-next-nvfp4 | synthetic | 3 | 55.5 | 53.9–57.3 | 0.767 (3) | 0 | 3 | 0 | 605 | 2,021.5 (3) | 3,669 | 0 | 3,669 | 2,700 |
| qwen38-flash-next-nvfp4 | recipe | 3 | 52.4 | 51.5–54.0 | 0.717 (3) | 0 | 3 | 0 | 216 | — (0) | 117 | 0 | 117 | 1,200 |
| qwen38-flash-next-nvfp4 | spark_bench | 3 | 62.0 | 59.4–62.6 | 0.912 (3) | 0 | 3 | 0 | 313 | 907.3 (3) | 852 | 0 | 852 | 384 |
| dsv4-flash-vision-exp | prose | 3 | 35.9 | 34.4–36.5 | 0.241 (3) | 0 | 1 | 0 | 143 | — (0) | 62 | 0 | 62 | 2,580 |
| dsv4-flash-vision-exp | ingest | 3 | 36.2 | 35.8–38.8 | 0.272 (3) | 0 | 0 | 2 | 472 | 944.9 (3) | 38,202 | 24,576 | 13,626 | 2,169 |
| dsv4-flash-vision-exp | json | 3 | 37.2 | 35.9–37.7 | 0.264 (3) | 0 | 0 | 0 | 218 | — (0) | 140 | 0 | 140 | 1,914 |
| dsv4-flash-vision-exp | json_free | 3 | 35.7 | 34.7–37.3 | 0.243 (3) | 0 | 0 | 0 | 193 | — (0) | 155 | 0 | 155 | 1,906 |
| dsv4-flash-vision-exp | synthetic | 3 | 40.3 | 37.5–50.2 | 0.307 (3) | 0 | 3 | 0 | 870 | 1,393.1 (3) | 3,638 | 0 | 3,638 | 2,700 |
| dsv4-flash-vision-exp | recipe | 3 | 41.2 | 37.7–43.3 | 0.337 (3) | 0 | 3 | 0 | 183 | — (0) | 96 | 0 | 96 | 1,200 |
| dsv4-flash-vision-exp | spark_bench | 3 | 57.0 | 53.5–57.4 | 0.480 (3) | 0 | 3 | 0 | 282 | 961.0 (3) | 812 | 0 | 812 | 384 |

Raw JSON per record, one row per case (decode, TTFT, window, prompt/cached/completion tokens, the acceptance delta with draft and accepted counts, `acceptance_gap`, `bracket_ms`, `cache_intent`), the warm-up, and any rejected attempts: `raw/throughput-<label>.json`.


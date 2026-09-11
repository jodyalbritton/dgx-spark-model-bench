# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-10-baseline`

Rendered by `design/make_report.py` from `results/2026-09-10-baseline/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Throughput (helm agent)

Harness: `Helm.Evals.Throughput` through helm and airo. Arms: **prose**, **ingest** (the pinned corpus, summarised), **json** (schema enforced), **json_free** (same body, no schema), **synthetic** (repeated filler, `ignore_eos`), **recipe** (sparkDash DecodeBench ×1 prose cell, verbatim) and **spark_bench** (`priv/bench/spark_bench.py` first cell, verbatim). Every constant, prompt and sampling value is in each record's `harness` block.

Column definitions. **decode tok/s** = (completion tokens − 1) / (last generated delta − first generated delta); the case's `window_ms`. **prefill tok/s** = prompt tokens / TTFT, only for cases with no prefix-cache hit and a prompt at or above the harness's `prefill_floor_tokens`; other cases are blank and not counted in **n**. **acceptance** = accepted draft tokens / draft tokens offered for that case, a delta between two reads of `/v1/serving?speculative=1`; **(n)** is the cases that got one. **shared slot** = cases whose decode steps + accepted tokens differ from their completion count by more than the harness's `gap_tolerance` (another client generated on the deployment during the case). **hit cap** = cases whose completion reached `max_tokens`. **cached** = cases with a prefix-cache hit. Medians are over the arm's counted cases; ranges are min–max.

### Records

| record | model | helm SHA | dirty | started (UTC) | finished (UTC) | warm-up ms | cases | rejected | thinking leaks | json parse failures |
|---|---|---|---|---|---|---:|---:|---:|---:|---:|
| [throughput-dsv4-flash-vision-exp-r1.json](raw/throughput-dsv4-flash-vision-exp-r1.json) | deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8 | 8e15c3a | False | 2026-09-11T06:29:33Z | 2026-09-11T06:36:21Z | 30028 | 25 | 0 | 0 | 1 |
| [throughput-dsv4-flash-vision-exp-r2.json](raw/throughput-dsv4-flash-vision-exp-r2.json) | deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8 | 8e15c3a | False | 2026-09-11T06:36:22Z | 2026-09-11T06:42:35Z | 1148 | 25 | 0 | 0 | 1 |
| [throughput-dsv4-flash-vision-exp-r3.json](raw/throughput-dsv4-flash-vision-exp-r3.json) | deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8 | 8e15c3a | False | 2026-09-11T06:42:36Z | 2026-09-11T06:48:54Z | 1259 | 25 | 0 | 0 | 0 |
| [throughput-glm53-flash-exl3-r1.json](raw/throughput-glm53-flash-exl3-r1.json) | Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3 | 8e15c3a | False | 2026-09-11T05:50:49Z | 2026-09-11T05:59:53Z | 14385 | 25 | 0 | 0 | 0 |
| [throughput-glm53-flash-exl3-r2.json](raw/throughput-glm53-flash-exl3-r2.json) | Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3 | 8e15c3a | False | 2026-09-11T05:59:54Z | 2026-09-11T06:08:59Z | 3812 | 25 | 0 | 0 | 0 |
| [throughput-glm53-flash-exl3-r3.json](raw/throughput-glm53-flash-exl3-r3.json) | Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3 | 8e15c3a | False | 2026-09-11T06:09:01Z | 2026-09-11T06:17:46Z | 3797 | 25 | 0 | 0 | 0 |
| [throughput-qwen38-flash-next-nvfp4-r1.json](raw/throughput-qwen38-flash-next-nvfp4-r1.json) | RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt | 8e15c3a | True | 2026-09-11T07:04:58Z | 2026-09-11T07:10:07Z | 7984 | 25 | 0 | 0 | 0 |
| [throughput-qwen38-flash-next-nvfp4-r2.json](raw/throughput-qwen38-flash-next-nvfp4-r2.json) | RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt | 8e15c3a | True | 2026-09-11T07:10:08Z | 2026-09-11T07:15:19Z | 1815 | 25 | 0 | 0 | 0 |
| [throughput-qwen38-flash-next-nvfp4-r3.json](raw/throughput-qwen38-flash-next-nvfp4-r3.json) | RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt | 8e15c3a | True | 2026-09-11T07:15:21Z | 2026-09-11T07:20:29Z | 1924 | 25 | 0 | 0 | 0 |

Harness constants (first record): temperature 0.0, max_tokens 900, repeats 3 (cells 5), prefill floor 1000 tokens, gap tolerance 10, ingest corpus rev 1373402144 (61562 chars), decode window: first content/reasoning delta to last content/reasoning delta.


### Per run

One column per record of a model (`<model>-r<N>`); a cell is that record's median over the arm's counted cases, the same figure as the per-arm table below. **spread** = (max − min) / min of the run medians; blank where fewer than two runs have a figure. Rows sort by spread, steadiest first. **TTFT ms** is the median over all of the arm's cases, so an arm that alternates cached and uncached prompts (ingest) shows the median of both kinds; **prefill tok/s** counts only its uncached cases at or above the floor, so the arms that send short prompts are absent from that table.

#### glm53-flash-exl3 — decode tok/s

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| prose | 25.9 | 25.9 | 26.2 | 1% |
| json | 25.4 | 25.9 | 25.9 | 2% |
| ingest | 29.8 | 29.4 | 28.4 | 5% |
| recipe | 32.0 | 32.1 | 30.4 | 5% |
| spark_bench | 54.9 | 52.9 | 56.9 | 8% |
| json_free | 24.9 | 30.4 | 25.2 | 22% |
| synthetic | 32.0 | 25.6 | 43.7 | 71% |

#### glm53-flash-exl3 — TTFT ms

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| synthetic | 1,461 | 1,453 | 1,461 | 1% |
| ingest | 13,544 | 13,560 | 13,679 | 1% |
| spark_bench | 727 | 726 | 717 | 1% |
| prose | 270 | 276 | 273 | 2% |
| recipe | 282 | 276 | 271 | 4% |
| json_free | 346 | 318 | 330 | 9% |
| json | 356 | 326 | 335 | 9% |

#### glm53-flash-exl3 — prefill tok/s

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| synthetic | 836 | 841 | 836 | 1% |
| ingest | 974 | 973 | 964 | 1% |

#### glm53-flash-exl3 — acceptance

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| prose | 0.271 | 0.272 | 0.276 | 2% |
| recipe | 0.371 | 0.371 | 0.359 | 3% |
| ingest | 0.332 | 0.331 | 0.308 | 8% |
| json | 0.264 | 0.285 | 0.286 | 8% |
| spark_bench | 0.814 | 0.721 | 0.827 | 15% |
| json_free | 0.244 | 0.330 | 0.250 | 35% |
| synthetic | 0.381 | 0.269 | 0.582 | 116% |

#### qwen38-flash-next-nvfp4 — decode tok/s

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| ingest | 43.6 | 42.9 | 43.4 | 1% |
| spark_bench | 59.4 | 60.2 | 59.1 | 2% |
| recipe | 51.6 | 50.5 | 51.4 | 2% |
| json | 49.0 | 49.8 | 50.2 | 2% |
| json_free | 50.5 | 50.8 | 49.5 | 3% |
| prose | 48.5 | 46.7 | 47.2 | 4% |
| synthetic | 54.8 | 41.9 | 47.5 | 31% |

#### qwen38-flash-next-nvfp4 — TTFT ms

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| ingest | 4,780 | 4,779 | 4,783 | 0% |
| spark_bench | 281 | 279 | 280 | 1% |
| synthetic | 534 | 536 | 530 | 1% |
| prose | 176 | 174 | 174 | 1% |
| recipe | 185 | 183 | 186 | 2% |
| json | 221 | 222 | 218 | 2% |
| json_free | 200 | 202 | 210 | 5% |

#### qwen38-flash-next-nvfp4 — prefill tok/s

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| ingest | 2,872 | 2,873 | 2,870 | 0% |
| synthetic | 2,290 | 2,282 | 2,306 | 1% |

#### qwen38-flash-next-nvfp4 — acceptance

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| json | 0.653 | 0.659 | 0.664 | 2% |
| spark_bench | 0.886 | 0.912 | 0.905 | 3% |
| ingest | 0.552 | 0.531 | 0.547 | 4% |
| recipe | 0.705 | 0.677 | 0.690 | 4% |
| json_free | 0.675 | 0.683 | 0.653 | 5% |
| prose | 0.629 | 0.595 | 0.593 | 6% |
| synthetic | 0.749 | 0.506 | 0.613 | 48% |

#### dsv4-flash-vision-exp — decode tok/s

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| json_free | 35.6 | 35.0 | 34.9 | 2% |
| prose | 36.9 | 36.1 | 36.7 | 2% |
| recipe | 40.4 | 41.0 | 41.5 | 3% |
| json | 34.4 | 33.6 | 35.3 | 5% |
| spark_bench | 53.6 | 53.6 | 50.8 | 6% |
| synthetic | 41.4 | 44.7 | 43.6 | 8% |
| ingest | 37.9 | 35.1 | 35.2 | 8% |

#### dsv4-flash-vision-exp — TTFT ms

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| ingest | 8,459 | 8,414 | 8,424 | 1% |
| spark_bench | 273 | 274 | 283 | 4% |
| recipe | 159 | 169 | 167 | 6% |
| json_free | 195 | 209 | 208 | 7% |
| synthetic | 852 | 783 | 816 | 9% |
| json | 218 | 199 | 221 | 11% |
| prose | 144 | 170 | 139 | 22% |

#### dsv4-flash-vision-exp — prefill tok/s

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| ingest | 1,506 | 1,514 | 1,512 | 1% |
| synthetic | 1,424 | 1,548 | 1,486 | 9% |

#### dsv4-flash-vision-exp — acceptance

| arm | r1 | r2 | r3 | spread |
|---|---:|---:|---:|---:|
| json_free | 0.242 | 0.249 | 0.244 | 3% |
| spark_bench | 0.448 | 0.443 | 0.456 | 3% |
| json | 0.249 | 0.241 | 0.256 | 6% |
| recipe | 0.295 | 0.315 | 0.314 | 7% |
| prose | 0.270 | 0.243 | 0.272 | 12% |
| synthetic | 0.342 | 0.392 | 0.381 | 15% |
| ingest | 0.307 | 0.282 | 0.253 | 21% |

### Ratios of arm medians (from each record's `summary`)

| model | structured / prose | guided / free | synthetic / prose | recipe / prose | spark_bench / prose |
|---|---:|---:|---:|---:|---:|
| dsv4-flash-vision-exp-r1 | 0.932 | 0.965 | 1.124 | 1.096 | 1.454 |
| dsv4-flash-vision-exp-r2 | 0.931 | 0.960 | 1.239 | 1.138 | 1.486 |
| dsv4-flash-vision-exp-r3 | 0.961 | 1.011 | 1.187 | 1.130 | 1.383 |
| glm53-flash-exl3-r1 | 0.978 | 1.018 | 1.233 | 1.234 | 2.116 |
| glm53-flash-exl3-r2 | 1.002 | 0.854 | 0.990 | 1.239 | 2.042 |
| glm53-flash-exl3-r3 | 0.988 | 1.029 | 1.669 | 1.162 | 2.170 |
| qwen38-flash-next-nvfp4-r1 | 1.010 | 0.972 | 1.129 | 1.062 | 1.222 |
| qwen38-flash-next-nvfp4-r2 | 1.067 | 0.980 | 0.897 | 1.082 | 1.290 |
| qwen38-flash-next-nvfp4-r3 | 1.065 | 1.016 | 1.005 | 1.089 | 1.251 |

### Per arm

| model | arm | n | decode tok/s | decode range | acceptance (n) | shared slot | hit cap | cached | TTFT ms (median) | prefill tok/s (n) | prompt Σ | cached Σ | uncached Σ | completion Σ |
|---|---|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| dsv4-flash-vision-exp-r1 | prose | 3 | 36.9 | 34.5–38.5 | 0.270 (3) | 0 | 0 | 0 | 144 | — (0) | 63 | 0 | 63 | 2,563 |
| dsv4-flash-vision-exp-r1 | ingest | 3 | 37.9 | 34.6–43.9 | 0.307 (3) | 0 | 0 | 1 | 8459 | 1,506.1 (2) | 38,215 | 12,288 | 25,927 | 1,582 |
| dsv4-flash-vision-exp-r1 | json | 3 | 34.4 | 33.8–41.3 | 0.249 (3) | 0 | 0 | 0 | 218 | — (0) | 141 | 0 | 141 | 1,820 |
| dsv4-flash-vision-exp-r1 | json_free | 3 | 35.6 | 34.6–37.4 | 0.242 (3) | 0 | 0 | 0 | 195 | — (0) | 156 | 0 | 156 | 1,856 |
| dsv4-flash-vision-exp-r1 | synthetic | 3 | 41.4 | 38.9–45.7 | 0.342 (3) | 0 | 3 | 0 | 852 | 1,423.7 (3) | 3,639 | 0 | 3,639 | 2,700 |
| dsv4-flash-vision-exp-r1 | recipe | 5 | 40.4 | 39.6–43.8 | 0.295 (5) | 0 | 5 | 0 | 159 | — (0) | 160 | 0 | 160 | 2,000 |
| dsv4-flash-vision-exp-r1 | spark_bench | 5 | 53.6 | 53.4–54.4 | 0.448 (5) | 0 | 5 | 0 | 273 | — (0) | 1,355 | 0 | 1,355 | 640 |
| dsv4-flash-vision-exp-r2 | prose | 3 | 36.1 | 34.8–37.0 | 0.243 (3) | 0 | 1 | 0 | 170 | — (0) | 61 | 0 | 61 | 2,473 |
| dsv4-flash-vision-exp-r2 | ingest | 3 | 35.1 | 32.8–50.6 | 0.282 (3) | 0 | 0 | 1 | 8414 | 1,514.1 (2) | 38,215 | 12,288 | 25,927 | 1,576 |
| dsv4-flash-vision-exp-r2 | json | 3 | 33.6 | 33.1–33.9 | 0.241 (3) | 0 | 0 | 0 | 199 | — (0) | 140 | 0 | 140 | 2,009 |
| dsv4-flash-vision-exp-r2 | json_free | 3 | 35.0 | 33.5–37.5 | 0.249 (3) | 0 | 0 | 0 | 209 | — (0) | 154 | 0 | 154 | 1,937 |
| dsv4-flash-vision-exp-r2 | synthetic | 3 | 44.7 | 37.3–63.8 | 0.392 (3) | 0 | 3 | 0 | 783 | 1,547.9 (3) | 3,637 | 0 | 3,637 | 2,700 |
| dsv4-flash-vision-exp-r2 | recipe | 5 | 41.0 | 38.2–42.2 | 0.315 (5) | 0 | 5 | 0 | 169 | — (0) | 160 | 0 | 160 | 2,000 |
| dsv4-flash-vision-exp-r2 | spark_bench | 5 | 53.6 | 49.3–55.4 | 0.443 (5) | 0 | 5 | 0 | 274 | — (0) | 1,353 | 0 | 1,353 | 640 |
| dsv4-flash-vision-exp-r3 | prose | 3 | 36.7 | 34.2–38.2 | 0.272 (3) | 0 | 2 | 0 | 139 | — (0) | 63 | 0 | 63 | 2,698 |
| dsv4-flash-vision-exp-r3 | ingest | 3 | 35.2 | 32.9–40.8 | 0.253 (3) | 0 | 0 | 1 | 8424 | 1,512.5 (2) | 38,216 | 12,288 | 25,928 | 1,582 |
| dsv4-flash-vision-exp-r3 | json | 3 | 35.3 | 34.7–36.0 | 0.256 (3) | 0 | 0 | 0 | 221 | — (0) | 141 | 0 | 141 | 1,945 |
| dsv4-flash-vision-exp-r3 | json_free | 3 | 34.9 | 34.8–37.7 | 0.244 (3) | 0 | 0 | 0 | 208 | — (0) | 156 | 0 | 156 | 1,954 |
| dsv4-flash-vision-exp-r3 | synthetic | 3 | 43.6 | 42.8–47.9 | 0.381 (3) | 0 | 3 | 0 | 816 | 1,486.5 (3) | 3,639 | 0 | 3,639 | 2,700 |
| dsv4-flash-vision-exp-r3 | recipe | 5 | 41.5 | 39.3–41.8 | 0.314 (5) | 0 | 5 | 0 | 167 | — (0) | 160 | 0 | 160 | 2,000 |
| dsv4-flash-vision-exp-r3 | spark_bench | 5 | 50.8 | 42.5–56.2 | 0.456 (5) | 0 | 5 | 0 | 283 | — (0) | 1,355 | 0 | 1,355 | 640 |
| glm53-flash-exl3-r1 | prose | 3 | 25.9 | 25.9–26.6 | 0.271 (3) | 0 | 2 | 0 | 270 | — (0) | 93 | 0 | 93 | 2,535 |
| glm53-flash-exl3-r1 | ingest | 3 | 29.8 | 29.4–31.8 | 0.332 (3) | 0 | 0 | 1 | 13544 | 974.1 (2) | 39,572 | 10,752 | 28,820 | 2,135 |
| glm53-flash-exl3-r1 | json | 3 | 25.4 | 22.7–25.7 | 0.264 (3) | 0 | 0 | 0 | 356 | — (0) | 168 | 0 | 168 | 2,007 |
| glm53-flash-exl3-r1 | json_free | 3 | 24.9 | 22.8–27.2 | 0.244 (3) | 0 | 0 | 0 | 346 | — (0) | 183 | 0 | 183 | 1,995 |
| glm53-flash-exl3-r1 | synthetic | 3 | 32.0 | 30.7–36.8 | 0.381 (3) | 0 | 3 | 0 | 1461 | 836.4 (3) | 3,666 | 0 | 3,666 | 2,700 |
| glm53-flash-exl3-r1 | recipe | 5 | 32.0 | 30.5–34.6 | 0.371 (5) | 0 | 5 | 0 | 282 | — (0) | 200 | 0 | 200 | 2,000 |
| glm53-flash-exl3-r1 | spark_bench | 5 | 54.9 | 54.7–62.1 | 0.814 (5) | 0 | 5 | 0 | 727 | — (0) | 1,399 | 0 | 1,399 | 640 |
| glm53-flash-exl3-r2 | prose | 3 | 25.9 | 25.4–26.1 | 0.272 (3) | 0 | 1 | 0 | 276 | — (0) | 93 | 0 | 93 | 2,516 |
| glm53-flash-exl3-r2 | ingest | 3 | 29.4 | 29.3–31.1 | 0.331 (3) | 0 | 0 | 1 | 13560 | 972.9 (2) | 39,572 | 10,752 | 28,820 | 1,937 |
| glm53-flash-exl3-r2 | json | 3 | 25.9 | 20.9–27.6 | 0.285 (3) | 0 | 0 | 0 | 326 | — (0) | 168 | 0 | 168 | 2,105 |
| glm53-flash-exl3-r2 | json_free | 3 | 30.4 | 25.8–31.2 | 0.330 (3) | 0 | 0 | 0 | 318 | — (0) | 183 | 0 | 183 | 2,180 |
| glm53-flash-exl3-r2 | synthetic | 3 | 25.6 | 22.2–41.6 | 0.269 (3) | 0 | 3 | 0 | 1453 | 841.0 (3) | 3,666 | 0 | 3,666 | 2,700 |
| glm53-flash-exl3-r2 | recipe | 5 | 32.1 | 27.7–32.5 | 0.371 (5) | 0 | 5 | 0 | 276 | — (0) | 200 | 0 | 200 | 2,000 |
| glm53-flash-exl3-r2 | spark_bench | 5 | 52.9 | 46.6–58.0 | 0.721 (5) | 0 | 5 | 0 | 726 | — (0) | 1,400 | 0 | 1,400 | 640 |
| glm53-flash-exl3-r3 | prose | 3 | 26.2 | 26.0–26.7 | 0.276 (3) | 0 | 2 | 0 | 273 | — (0) | 93 | 0 | 93 | 2,579 |
| glm53-flash-exl3-r3 | ingest | 3 | 28.4 | 27.0–30.0 | 0.308 (3) | 0 | 0 | 1 | 13679 | 964.5 (2) | 39,572 | 10,752 | 28,820 | 2,200 |
| glm53-flash-exl3-r3 | json | 3 | 25.9 | 22.5–26.2 | 0.286 (3) | 0 | 0 | 0 | 335 | — (0) | 168 | 0 | 168 | 2,143 |
| glm53-flash-exl3-r3 | json_free | 3 | 25.2 | 23.1–25.8 | 0.250 (3) | 0 | 0 | 0 | 330 | — (0) | 183 | 0 | 183 | 1,894 |
| glm53-flash-exl3-r3 | synthetic | 3 | 43.7 | 39.9–47.0 | 0.582 (3) | 0 | 3 | 0 | 1461 | 836.4 (3) | 3,666 | 0 | 3,666 | 2,700 |
| glm53-flash-exl3-r3 | recipe | 5 | 30.4 | 28.9–32.7 | 0.359 (5) | 0 | 5 | 0 | 271 | — (0) | 200 | 0 | 200 | 2,000 |
| glm53-flash-exl3-r3 | spark_bench | 5 | 56.9 | 50.7–62.5 | 0.827 (5) | 0 | 5 | 0 | 717 | — (0) | 1,400 | 0 | 1,400 | 640 |
| qwen38-flash-next-nvfp4-r1 | prose | 3 | 48.5 | 47.0–48.7 | 0.629 (3) | 0 | 0 | 0 | 176 | — (0) | 99 | 0 | 99 | 2,348 |
| qwen38-flash-next-nvfp4-r1 | ingest | 3 | 43.6 | 41.0–46.6 | 0.552 (3) | 0 | 0 | 1 | 4780 | 2,871.5 (2) | 41,172 | 9,600 | 31,572 | 1,781 |
| qwen38-flash-next-nvfp4-r1 | json | 3 | 49.0 | 47.6–51.8 | 0.653 (3) | 0 | 0 | 0 | 221 | — (0) | 177 | 0 | 177 | 2,215 |
| qwen38-flash-next-nvfp4-r1 | json_free | 3 | 50.5 | 50.1–51.9 | 0.675 (3) | 0 | 0 | 0 | 200 | — (0) | 192 | 0 | 192 | 2,085 |
| qwen38-flash-next-nvfp4-r1 | synthetic | 3 | 54.8 | 45.9–55.9 | 0.749 (3) | 0 | 3 | 0 | 534 | 2,290.3 (3) | 3,669 | 0 | 3,669 | 2,700 |
| qwen38-flash-next-nvfp4-r1 | recipe | 5 | 51.6 | 48.2–52.4 | 0.705 (5) | 0 | 5 | 0 | 185 | — (0) | 195 | 0 | 195 | 2,000 |
| qwen38-flash-next-nvfp4-r1 | spark_bench | 5 | 59.4 | 53.7–60.4 | 0.886 (5) | 0 | 5 | 0 | 281 | — (0) | 1,420 | 0 | 1,420 | 640 |
| qwen38-flash-next-nvfp4-r2 | prose | 3 | 46.7 | 45.5–47.5 | 0.595 (3) | 0 | 0 | 0 | 174 | — (0) | 99 | 0 | 99 | 2,257 |
| qwen38-flash-next-nvfp4-r2 | ingest | 3 | 42.9 | 39.9–44.7 | 0.531 (3) | 0 | 0 | 1 | 4779 | 2,872.6 (2) | 41,174 | 11,200 | 29,974 | 1,815 |
| qwen38-flash-next-nvfp4-r2 | json | 3 | 49.8 | 49.1–51.0 | 0.659 (3) | 0 | 0 | 0 | 222 | — (0) | 177 | 0 | 177 | 2,249 |
| qwen38-flash-next-nvfp4-r2 | json_free | 3 | 50.8 | 50.0–53.6 | 0.683 (3) | 0 | 0 | 0 | 202 | — (0) | 192 | 0 | 192 | 2,132 |
| qwen38-flash-next-nvfp4-r2 | synthetic | 3 | 41.9 | 38.0–52.1 | 0.506 (3) | 0 | 3 | 0 | 536 | 2,281.7 (3) | 3,669 | 0 | 3,669 | 2,700 |
| qwen38-flash-next-nvfp4-r2 | recipe | 5 | 50.5 | 48.6–51.5 | 0.677 (5) | 0 | 5 | 0 | 183 | — (0) | 195 | 0 | 195 | 2,000 |
| qwen38-flash-next-nvfp4-r2 | spark_bench | 5 | 60.2 | 55.9–61.8 | 0.912 (5) | 0 | 5 | 0 | 279 | — (0) | 1,420 | 0 | 1,420 | 640 |
| qwen38-flash-next-nvfp4-r3 | prose | 3 | 47.2 | 45.9–47.3 | 0.593 (3) | 0 | 0 | 0 | 174 | — (0) | 96 | 0 | 96 | 2,435 |
| qwen38-flash-next-nvfp4-r3 | ingest | 3 | 43.4 | 42.9–45.5 | 0.547 (3) | 0 | 0 | 1 | 4783 | 2,870.0 (2) | 41,172 | 11,200 | 29,972 | 1,772 |
| qwen38-flash-next-nvfp4-r3 | json | 3 | 50.2 | 48.8–50.3 | 0.664 (3) | 0 | 0 | 0 | 218 | — (0) | 174 | 0 | 174 | 2,270 |
| qwen38-flash-next-nvfp4-r3 | json_free | 3 | 49.5 | 49.1–51.8 | 0.653 (3) | 0 | 0 | 0 | 210 | — (0) | 189 | 0 | 189 | 2,247 |
| qwen38-flash-next-nvfp4-r3 | synthetic | 3 | 47.5 | 44.7–55.6 | 0.613 (3) | 0 | 3 | 0 | 530 | 2,305.7 (3) | 3,666 | 0 | 3,666 | 2,700 |
| qwen38-flash-next-nvfp4-r3 | recipe | 5 | 51.4 | 49.8–52.7 | 0.690 (5) | 0 | 5 | 0 | 186 | — (0) | 195 | 0 | 195 | 2,000 |
| qwen38-flash-next-nvfp4-r3 | spark_bench | 5 | 59.1 | 57.5–61.5 | 0.905 (5) | 0 | 5 | 0 | 280 | — (0) | 1,415 | 0 | 1,415 | 640 |

Raw JSON per record, one row per case (decode, TTFT, window, prompt/cached/completion tokens, the acceptance delta with draft and accepted counts, `acceptance_gap`, `bracket_ms`, `cache_intent`), the warm-up, and any rejected attempts: `raw/throughput-<label>.json`.


# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-09-throughput-r2`

Rendered by `design/make_report.py` from `results/2026-09-09-throughput-r2/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Throughput (helm agent) — the four-arm bench

Harness: `Helm.Evals.Throughput` through helm and airo, the same path the agent benches use. Output *kind* is the variable, not output length: **prose**, **ingest + summarise** over a pinned corpus, **json** with the schema enforced, **json_free** (same body, no schema), and **synthetic** — the degenerate `ignore_eos` workload round 1 used, kept as a labelled upper bound. Temperature 0 and `max_tokens` pinned across every arm on every model.

**Decode** = completion tokens over the window after first token, so prefill is excluded. **Prefill** = uncached prompt tokens over TTFT, reported only above a 200-token floor because below it TTFT is round-trip overhead rather than prefill work. **Acceptance** = draft tokens accepted over draft tokens offered for that request, a delta between two scrapes of `/v1/serving?speculative=1`; a case whose request fell inside one scrape window reports no rate rather than a zero.

Constants: temperature 0.0, max_tokens 900, 3 repeats/arm, ingest corpus rev 1373402144 (61562 chars).

> **Absolute decode is not stable on this cluster.** Re-measuring one model on one arm at one length inside an hour gave 31.9–59.6 tok/s (2026-09-09). That spread is wider than the differences between arms, so read the **ratios** below, and read a decode figure as this session's snapshot with its range beside it. Rows for different models were also measured at different times — the cluster serves one model at a time.

### Ratios — the numbers that survive a serving change

| model | structured / prose | guided / free | synthetic / prose |
|---|---:|---:|---:|
| glm53-flash-exl3 | 0.888 | 0.903 | 1.103 |
| qwen38-flash-next-nvfp4 | 0.985 | 0.922 | 1.193 |
| dsv4-flash-vision-exp | 0.955 | 0.976 | 1.208 |

*structured / prose* < 1 means a schema-enforced JSON body decodes slower than prose. *guided / free* isolates what enforcing the schema costs, against the same body asked for in words.

### Per arm — decode, prefill, acceptance, tokens

| model | arm | decode tok/s | decode range | acceptance (n) | TTFT ms | prefill tok/s | prompt Σ | cached Σ | uncached Σ | completion Σ |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | prose | 23.4 | 22.9–25.7 | 0.276 (3) | 287 | — | 96 | 0 | 96 | 2,635 |
| glm53-flash-exl3 | ingest | 26.2 | 25.8–26.4 | 0.342 (3) | 2993 | 813.2 | 39,558 | 32,256 | 7,302 | 2,700 |
| glm53-flash-exl3 | json | 20.8 | 18.8–22.2 | 0.261 (3) | 425 | — | 170 | 0 | 170 | 2,048 |
| glm53-flash-exl3 | json_free | 23.0 | 18.8–23.7 | 0.286 (3) | 416 | — | 186 | 0 | 186 | 2,141 |
| glm53-flash-exl3 | synthetic | 25.8 | 22.5–30.6 | 0.344 (3) | 1451 | 842.9 | 3,669 | 0 | 3,669 | 2,700 |
| qwen38-flash-next-nvfp4 | prose | 35.7 | 34.3–36.5 | 0.594 (3) | 293 | — | 181 | 0 | 181 | 2,341 |
| qwen38-flash-next-nvfp4 | ingest | 37.5 | 37.2–37.9 | 0.642 (3) | 2040 | 2,177.4 | 41,238 | 20,800 | 20,438 | 2,700 |
| qwen38-flash-next-nvfp4 | json | 35.1 | 34.6–35.8 | 0.607 (3) | 382 | — | 261 | 0 | 261 | 2,279 |
| qwen38-flash-next-nvfp4 | json_free | 38.1 | 38.1–40.0 | 0.654 (3) | 233 | — | 276 | 0 | 276 | 2,641 |
| qwen38-flash-next-nvfp4 | synthetic | 42.6 | 31.9–43.9 | 0.807 (3) | 632 | 1,979.4 | 3,753 | 0 | 3,753 | 2,700 |
| dsv4-flash-vision-exp | prose | 28.3 | 28.1–29.5 | 0.238 (3) | 161 | — | 63 | 0 | 63 | 2,639 |
| dsv4-flash-vision-exp | ingest | 31.4 | 30.1–34.9 | 0.336 (3) | 491 | 908.4 | 38,202 | 24,576 | 13,626 | 2,292 |
| dsv4-flash-vision-exp | json | 27.0 | 25.4–27.7 | 0.252 (3) | 203 | — | 141 | 0 | 141 | 1,923 |
| dsv4-flash-vision-exp | json_free | 27.7 | 26.8–28.5 | 0.248 (3) | 208 | — | 156 | 0 | 156 | 1,916 |
| dsv4-flash-vision-exp | synthetic | 34.1 | 31.5–36.4 | 0.350 (3) | 945 | 1,283.6 | 3,639 | 0 | 3,639 | 2,700 |

Token columns are sums over the arm's repeats. Prefill is blank where the arm's prompt sits under the 200-token floor — prose and both JSON arms send short prompts, so only **ingest** and **synthetic** carry a meaningful prefill rate.

Raw JSON per run (per-case decode, TTFT, cached/uncached prompt, and the acceptance delta with its draft/accepted counts): `raw/throughput-<label>.json`.


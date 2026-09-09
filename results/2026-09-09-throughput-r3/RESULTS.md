# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-09-throughput-r3`

Rendered by `design/make_report.py` from `results/2026-09-09-throughput-r3/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Throughput (helm agent) — the four-arm bench

Harness: `Helm.Evals.Throughput` through helm and airo, the same path the agent benches use. Output *kind* is the variable, not output length: **prose**, **ingest + summarise** over a pinned corpus, **json** with the schema enforced, **json_free** (same body, no schema), and **synthetic** — the degenerate `ignore_eos` workload round 1 used, kept as a labelled upper bound. Temperature 0 and `max_tokens` pinned across every arm on every model.

**Decode** = completion tokens over the window after first token, so prefill is excluded. **Prefill** = uncached prompt tokens over TTFT, reported only above a 200-token floor because below it TTFT is round-trip overhead rather than prefill work. **Acceptance** = draft tokens accepted over draft tokens offered for that request, a delta between two scrapes of `/v1/serving?speculative=1`; a case whose request fell inside one scrape window reports no rate rather than a zero.

Constants: temperature 0.0, max_tokens 900, 3 repeats/arm, ingest corpus rev 1373402144 (61562 chars).

> **Absolute decode is not stable on this cluster.** Re-measuring one model on one arm at one length inside an hour gave 31.9–59.6 tok/s (2026-09-09). That spread is wider than the differences between arms, so read the **ratios** below, and read a decode figure as this session's snapshot with its range beside it. Rows for different models were also measured at different times — the cluster serves one model at a time.

### Ratios — the numbers that survive a serving change

| model | structured / prose | guided / free | synthetic / prose |
|---|---:|---:|---:|
| glm53-flash-exl3 | 0.748 | 0.777 | 1.740 |
| qwen38-flash-next-nvfp4 | 1.062 | 1.004 | 1.149 |
| dsv4-flash-vision-exp | 0.880 | 0.900 | 1.034 |

*structured / prose* < 1 means a schema-enforced JSON body decodes slower than prose. *guided / free* isolates what enforcing the schema costs, against the same body asked for in words.

### Per arm — decode, prefill, acceptance, tokens

| model | arm | decode tok/s | decode range | acceptance (n) | TTFT ms | prefill tok/s | prompt Σ | cached Σ | uncached Σ | completion Σ |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | prose | 22.9 | 18.9–23.4 | 0.294 (3) | 282 | — | 93 | 0 | 93 | 2,122 |
| glm53-flash-exl3 | ingest | 27.1 | 23.3–27.5 | 0.368 (3) | 3090 | 818.7 | 39,558 | 21,504 | 18,054 | 2,700 |
| glm53-flash-exl3 | json | 17.1 | 12.2–19.0 | 0.240 (3) | 367 | — | 168 | 0 | 168 | 1,858 |
| glm53-flash-exl3 | json_free | 22.1 | 21.5–22.1 | 0.268 (3) | 334 | — | 183 | 0 | 183 | 2,043 |
| glm53-flash-exl3 | synthetic | 39.9 | 34.6–40.8 | 0.676 (3) | 1510 | 809.3 | 3,666 | 0 | 3,666 | 2,700 |
| qwen38-flash-next-nvfp4 | prose | 34.4 | 33.0–37.6 | 0.616 (3) | 180 | — | 99 | 0 | 99 | 2,039 |
| qwen38-flash-next-nvfp4 | ingest | 33.3 | 31.9–33.9 | 0.528 (3) | 1753 | 2,357.7 | 41,154 | 20,800 | 20,354 | 2,309 |
| qwen38-flash-next-nvfp4 | json | 36.5 | 36.0–36.7 | 0.664 (3) | 241 | — | 177 | 0 | 177 | 2,170 |
| qwen38-flash-next-nvfp4 | json_free | 36.4 | 34.9–36.5 | 0.646 (3) | 212 | — | 192 | 0 | 192 | 2,243 |
| qwen38-flash-next-nvfp4 | synthetic | 39.5 | 37.7–45.1 | 0.696 (3) | 549 | 2,227.7 | 3,669 | 0 | 3,669 | 2,700 |
| dsv4-flash-vision-exp | prose | 30.5 | 30.1–30.7 | 0.253 (3) | 171 | — | 63 | 0 | 63 | 2,611 |
| dsv4-flash-vision-exp | ingest | 30.8 | 30.2–32.6 | 0.298 (3) | 556 | 802.2 | 38,202 | 24,576 | 13,626 | 2,155 |
| dsv4-flash-vision-exp | json | 26.9 | 26.4–28.5 | 0.250 (3) | 225 | — | 141 | 0 | 141 | 1,893 |
| dsv4-flash-vision-exp | json_free | 29.8 | 27.5–30.3 | 0.266 (3) | 211 | — | 156 | 0 | 156 | 2,005 |
| dsv4-flash-vision-exp | synthetic | 31.6 | 31.4–39.8 | 0.295 (3) | 788 | 1,539.3 | 3,638 | 0 | 3,638 | 2,700 |

Token columns are sums over the arm's repeats. Prefill is blank where the arm's prompt sits under the 200-token floor — prose and both JSON arms send short prompts, so only **ingest** and **synthetic** carry a meaningful prefill rate.

Raw JSON per run (per-case decode, TTFT, cached/uncached prompt, and the acceptance delta with its draft/accepted counts): `raw/throughput-<label>.json`.


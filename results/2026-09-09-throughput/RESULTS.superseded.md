# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-09-throughput`

Rendered by `design/make_report.py` from `results/2026-09-09-throughput/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Throughput (helm agent) — the four-arm bench

Harness: `Helm.Evals.Throughput` through helm and airo, the same path the agent benches use. Output *kind* is the variable, not output length: **prose**, **ingest + summarise** over a pinned corpus, **json** with the schema enforced, **json_free** (same body, no schema), and **synthetic** — the degenerate `ignore_eos` workload round 1 used, kept as a labelled upper bound. Temperature 0 and `max_tokens` pinned across every arm on every model.

**Decode** = completion tokens over the window after first token, so prefill is excluded. **Prefill** = uncached prompt tokens over TTFT, reported only above a 200-token floor because below it TTFT is round-trip overhead rather than prefill work. **Acceptance** = draft tokens accepted over draft tokens offered for that request, a delta between two scrapes of `/v1/serving?speculative=1`; a case whose request fell inside one scrape window reports no rate rather than a zero.

Constants: temperature 0.0, max_tokens 900, 3 repeats/arm, ingest corpus rev 1373402144 (61562 chars).

> **Absolute decode is not stable on this cluster.** Re-measuring one model on one arm at one length inside an hour gave 31.9–59.6 tok/s (2026-09-09). That spread is wider than the differences between arms, so read the **ratios** below, and read a decode figure as this session's snapshot with its range beside it. Rows for different models were also measured at different times — the cluster serves one model at a time.

### Ratios — the numbers that survive a serving change

| model | structured / prose | guided / free | synthetic / prose |
|---|---:|---:|---:|
| glm53-flash-exl3 | 0.897 | — | 1.082 |

*structured / prose* < 1 means a schema-enforced JSON body decodes slower than prose. *guided / free* isolates what enforcing the schema costs, against the same body asked for in words.

### Per arm — decode, prefill, acceptance, tokens

| model | arm | decode tok/s | decode range | acceptance (n) | TTFT ms | prefill tok/s | prompt Σ | cached Σ | uncached Σ | completion Σ |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | prose | 27.1 | 25.6–27.6 | — (0) | 403 | — | 93 | 0 | 93 | 2,647 |
| glm53-flash-exl3 | ingest | 30.6 | 29.1–31.1 | — (0) | 2947 | 831.0 | 39,558 | 21,504 | 18,054 | 2,700 |
| glm53-flash-exl3 | json | 24.3 | 22.9–26.6 | — (0) | 513 | — | 168 | 0 | 168 | 2,147 |
| glm53-flash-exl3 | synthetic | 29.3 | 29.2–61.1 | — (0) | 1518 | 805.0 | 3,666 | 0 | 3,666 | 2,700 |

Token columns are sums over the arm's repeats. Prefill is blank where the arm's prompt sits under the 200-token floor — prose and both JSON arms send short prompts, so only **ingest** and **synthetic** carry a meaningful prefill rate.

Raw JSON per run (per-case decode, TTFT, cached/uncached prompt, and the acceptance delta with its draft/accepted counts): `raw/throughput-<label>.json`.


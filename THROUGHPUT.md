# Throughput: three models, one method, three runs each

**GLM-5.3-Flash (EXL3 4 bpw) · Qwen3.8-Flash-Next (NVFP4) · DeepSeek-V4-Flash-Vision-Exp (fp8)**,
served one at a time on the same two DGX Sparks (TP=2), measured through
the same gateway path the coding agents use.

Round `2026-09-10-baseline`: seven arms, three runs per model back to
back on one helm commit, 225 cases, every case reconciled against the
engine's own draft counters. Thinking off, temperature 0, one stream
(c=1). The rendered record is
[`results/2026-09-10-baseline/RESULTS.md`](results/2026-09-10-baseline/RESULTS.md);
what was run and what held is its `RUNLOG.md`. A cell below is the
median of the three run medians; the bracket is the range of the three
run medians.

## The number to quote

| | GLM 5.3 | Qwen 3.8 | DeepSeek V4 |
|---|---:|---:|---:|
| **prose** to a natural stop, tok/s | 25.9 (25.9–26.2) | **47.2** (46.7–48.5) | 36.7 (36.1–36.9) |
| json, schema enforced | 25.9 (25.4–25.9) | **49.8** (49.0–50.2) | 34.4 (33.6–35.3) |
| ingest: summarise a 13k-token document | 29.4 (28.4–29.8) | **43.4** (42.9–43.6) | 35.2 (35.1–37.9) |
| prefill, 13k tokens uncached, tok/s | 973 | **2,872** | 1,512 |
| time to first token, 13k uncached | 13.6 s | **4.8 s** | 8.4 s |
| time to first token, short prompt | 273 ms | 174 ms | **144 ms** |

**Qwen writes at 1.3× DeepSeek and 1.8× GLM, and prefills at 1.9× and
3.0×.** The order is the same on every realistic arm and in every run.
Prose repeats within 1–4 % across the three runs on all three models.

Structured output costs nothing measurable on Qwen or GLM (json/prose
1.01–1.07 and 0.98–1.00 across runs). On DeepSeek it costs 4–7 %
(0.93–0.96), in every run. Enforcing the schema against asking for the
same body in words (guided/free) is within noise on all three.

## The published cells, beside the real ones

The two methods behind the numbers people post were run verbatim in the
same sessions: sparkDash's ×1 prose cell (**recipe**: one hash-map
prompt, 400 tokens forced, greedy) and this project's own first script
cell (**spark_bench**: ~270 filler tokens in, 128 numbered words forced).

| | GLM 5.3 | Qwen 3.8 | DeepSeek V4 |
|---|---:|---:|---:|
| recipe cell, tok/s | 32.0 (30.4–32.1) | 51.4 (50.5–51.6) | 41.0 (40.4–41.5) |
| script cell, tok/s | 54.9 (52.9–56.9) | 59.4 (59.1–60.2) | 53.6 (50.8–53.6) |
| recipe / prose | 1.16–1.24 | 1.06–1.09 | 1.10–1.14 |
| script / prose | **2.04–2.17** | 1.22–1.29 | 1.38–1.49 |

The script cell says the three models are within 10 % of each other.
Prose says Qwen is 1.8× GLM. Both are real measurements; only one is
throughput. A forced list of numbered words is the easiest text a draft
head can predict, and it lifts every model's acceptance to 0.45–0.91
regardless of where the model started, so the cell ranks models by how
well they draft filler. The recipe cell is a milder flatterer, 6–24 %,
and evenly enough that dividing a sparkDash ×1 prose number by 1.1–1.2
lands near real prose.

## Why the order is what it is

Every engine here runs multi-token prediction: each decode step verifies
a handful of drafted tokens and keeps the accepted prefix. Decode tok/s
is therefore steps per second times tokens per step, and the record
carries both (`tokens_per_step` in each case's acceptance block).

| on prose | GLM 5.3 | Qwen 3.8 | DeepSeek V4 |
|---|---:|---:|---:|
| draft positions | 7 | 3 | 6 |
| steps per second | 8.9 | **16.7** | 14.7 |
| tokens per step | 2.9 | 2.8 | 2.5 |
| tokens per step on the script cell | 6.7 | 3.7 | 3.7 |

Steps per second is a constant of each deployment: it does not move
between arms, runs, or content. Tokens per step is what content changes.
On real prose all three get 2.5–2.9 tokens a step, so the ranking is the
step rate, and GLM's EXL3 build takes 112 ms a step against Qwen's 60 ms.
GLM's seven draft positions are what make the script cell flatter it
most: on filler they pay out 6.7 tokens a step, on prose 2.9.

## What does not repeat

The **synthetic** arm (repeated filler, `ignore_eos`) does not reproduce
on GLM or Qwen: run medians of 25.6–43.7 and 41.9–54.8 with acceptance
0.27–0.58 and 0.51–0.75 on identical input at temperature 0. The
measurement reconciles; the engine's drafting on that content varies.
Its figures are excluded from every claim above. DeepSeek's held
(41.4–44.7). One GLM `json_free` run (30.4 against 24.9 and 25.2) moved
the same way, with its acceptance.

## Caveats

- One stream. Concurrency and long-context decode are in the raw
  inference round (`design/spark_bench.py`, 2026-09-04), not here.
- One deployment per model, on one day; the models were measured in
  turn, not side by side. Different quantizations on different engines:
  the stack is part of the number.
- Thinking off throughout. What a session costs with reasoning on, round
  by round, is `REALWORLD.md`.
- Prose reached the 900-token cap in some cases on GLM and DeepSeek
  (5 of 9 and 3 of 9); those cases decode at the same rate as the rest.

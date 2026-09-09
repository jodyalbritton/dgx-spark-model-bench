# Run log — 2026-09-09 throughput, round 1

**Status: COMPLETE** (2026-09-09T15:53:32Z). The first run of `Helm.Evals.Throughput` (T35 task
7a), and the first throughput measurement since round 1 on 2026-09-04.

## What this is, and is not

It is **not** comparable to round 1. That round's decode figures came
from `spark_bench.py` on a workload that over-reports — a nonce plus
`"benchmark context datum "` repeated, forced past the natural stop with
`ignore_eos`, so draft acceptance approaches 1.0 and the number measures
the speculator. Round 1 put GLM at 44.9–58.2 tok/s where rounds 7–10 of
real agent work put it at 22.2–30.9. This bench exists because of that
gap.

It is also a **new baseline** on the serving side: jody ran speculative
decode work on the airo agent immediately before this, so nothing here
extends the round 7–10 fits either.

## Pre-flight (2026-09-09T15:46Z)

- helm `dbe2d65`, clean tree.
- **GLM 5.3 Flash is the only model loaded.** DeepSeek V4 Flash Vision
  Exp and Qwen 3.8 Flash Next both 404 — listed in the catalogue, not
  resident. So this is a one-model run, and the headline claim it is
  meant to test (structured decode against prose, *across models*) does
  not resolve until jody loads the other two.
- **Acceptance rate is still unavailable.** `/metrics` and `/v1/serving`
  are both 403 `insufficient_scope` for helm's key, unchanged from the
  2026-09-09 check. Every row carries `acceptance_reported: false` and
  the arm ratios are the measurement. This is T37's airo half.

## Harness

Four arms — prose, ingest + summarise, schema-enforced JSON, synthetic —
3 repeats each, temperature 0 and `max_tokens` 900 pinned across all of
them, ingest corpus pinned to Wikipedia revision 1373402144. Run through
`mix bench.throughput`, the same entry point any harness would use.

## GLM 5.3 Flash — `glm53-flash-exl3`

Started 2026-09-09T15:47:14Z, finished 15:53:32Z, helm `dbe2d65`. Four
arms, 3 repeats, no failures.

| arm | decode tok/s (median) | range | completion (median) | hit cap |
|---|---:|---|---:|---:|
| ingest | 30.65 | 29.1 – 31.15 | 900 | 3/3 |
| synthetic | 29.33 | 29.16 – **61.08** | 900 | 3/3 |
| prose | 27.10 | 25.6 – 27.55 | 878 | 1/3 |
| json (schema enforced) | 24.31 | 22.89 – 26.61 | 696 | 0/3 |

**structured/prose = 0.897. The hypothesis is not supported by this run.**
The expectation, stated before the run, was that a large JSON body would
decode *faster* than prose on GLM because braces, quotes and commas are
near-deterministic. It came out 10 % slower, and the predicted ordering
(synthetic ≥ structured ≥ prose ≥ real agent work) is broken in two
places: ingest is fastest and structured is last.

## The obvious suspect, tested rather than argued

The `:json` arm enforces its schema, so it pays guided decoding's
grammar-masking cost. That confounds "structured tokens are predictable"
with "the grammar is expensive". A `:json_free` arm — the same body asked
for in words, no `response_format` — separates them. Three cases, same
model, same session:

| arm | decode tok/s (median) | range |
|---|---:|---|
| prose | 27.10 | 25.6 – 27.55 |
| json_free | 26.45 | 25.75 – 27.98 |
| json (guided) | 24.31 | 22.89 – 26.61 |

- **json_free / prose = 0.976.** Unconstrained JSON decodes like prose.
  The two ranges overlap completely at n=3, so read this as "no
  difference detected", not as a measured equality.
- **guided / free = 0.919.** Enforcing the schema costs roughly 8 % of
  decode. The ranges overlap slightly, so this is suggestive, not
  established.

So on GLM, structured output is not faster than prose, and enforcing a
schema makes it slower. That is worth knowing precisely because it was
predicted the other way.

## The finding this round did not go looking for

**Synthetic case 2 decoded at 61.08 tok/s. Cases 1 and 3 decoded at 29.16
and 29.33.** Identical prompt but for a nonce, identical settings,
temperature 0. A 2× swing on deterministic input, and the median hides
it entirely.

That number sits inside round 1's synthetic range (44.9–58.2 tok/s). So
round 1's inflation is reproducible — *intermittently*. Which is what
speculative-decode acceptance variance looks like from the outside, and
it is exactly the quantity this bench cannot read: `/metrics` is still
403 for helm's key. A run that reports only medians would have shown
29.33 and said nothing.

**This is the argument for T37's airo scope**, more than the power and
thermal work is. Without the acceptance counter, a 2× decode swing on
identical input is unattributable.

## Prefill

Reported only above a 200-token floor, since TTFT on a 31-token prompt is
round-trip overhead rather than prefill work.

| case | prefill tok/s | uncached |
|---|---:|---:|
| ingest 1 (cold) | 973.9 | 13,186 |
| ingest 2 | 825.9 | 2,434 |
| ingest 3 | 831.0 | 2,434 |
| synthetic 1–3 | 769 – 812 | 1,222 |

Ingest 1 paid a 13.5 s TTFT on a cold cache; 2 and 3 drew 10,752 of
13,186 prompt tokens from it. Prefill is fitted on the uncached
remainder, which is the whole reason the record carries both.

## What this round does not establish

- **One model.** DeepSeek and Qwen were not loaded. "Structured against
  prose, across models" is the claim, and one model cannot carry it.
- **n = 3 per arm**, with overlapping ranges nearly everywhere.
- **Acceptance is unmeasured**, so the mechanism behind every number here
  is inferred rather than observed.

## Cleanup

No server, no port. `mix bench.throughput` writes only the record.

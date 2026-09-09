# Prefill note — a controlled uncached ladder on the round-10 serve

`SERVING.md` reports that prefill did not move across rounds 7 to 10 and
that the in-run estimator could not have seen it if it had. That is correct
about the harness data. This note adds an off-harness measurement that the
in-run estimator cannot make, and it does find a difference: **dense FP8
costs about 13% of raw prefill throughput.**

The two findings are compatible. In-run prefill is measured on prompts that
were 87.8% prefix-cache hits, under live concurrency, over whatever prompt
sizes the round happened to contain. A 13% penalty applied to an eighth of
prompt tokens is under 2% of prompt handling, well inside the intervals in
`SERVING.md`.

## Method

`prefill-ladder-fp8-only.json`, taken on the round-10 serve
(`glm53-flash-exl3-e3-fp8.json`, airo_agent `f52e354`) with no other traffic.
Each request carries unique random content sized through `/tokenize`, so the
prefix cache cannot serve any of it; every response's `cached_tokens` is
recorded and was zero throughout. One output token, temperature 0, thinking
off, so time to first token is the prefill. Rate is uncached prompt tokens
over that time. Two passes per size, after a warm-up that absorbed the
one-time allocation.

## Round 10 (E3 grouped MoE + dense FP8)

| prompt tokens | median tok/s | both passes |
|---:|---:|---|
| 8k | 1,051 | 1,047 – 1,054 |
| 16k | 1,072 | 1,068 – 1,075 |
| 32k | 1,087 | 1,086 – 1,088 |
| 64k | 1,098 | 1,096 – 1,099 |
| 128k | 1,103 | 1,099 – 1,106 |

Passes agree within 1% at every size, and the rate rises gently with prompt
size to a plateau near 1,100.

## Against the two earlier serves, same method

The comparison rows are cold probes taken the same way on this kit when each
image was resident: the E3 serve without FP8 on 2026-09-07, and the E2 image
`eb0469fb` on 2026-09-04.

| prompt | E2 (`eb0469fb`) | E3, no FP8 | E3 + FP8 (round 10) | FP8 vs E3 | FP8 vs E2 |
|---:|---:|---:|---:|---:|---:|
| 32k | 1,121 | 1,252, 1,251, 1,265 | 1,087 | −13% | −3% |
| 64k | 1,130 | 1,253, 1,259 | 1,098 | −12% | −3% |

The E3 grouped-MoE kernels bought about 12% of prefill on this kit. Dense FP8
returns slightly more than all of it, leaving raw prefill a little below the
pre-E3 image.

This is the expected shape rather than a surprise. Weight-only FP8 through
Marlin wins where decode lives, at small batch and memory-bound steps, and
loses at prefill, where 2048-token chunks are compute-bound and the
dequantisation is pure overhead. It is the same mechanism that produces the
decode gain `SERVING.md` measures.

## What this changes

Nothing about the recommendation, given this workload. Using the round-10
decode medians and these prefill rates, FP8 is the faster serve while
uncached prompt tokens stay under roughly 93 times output tokens on the app
set, or 37 times on fixtures. The rounds averaged about 2,600 uncached
prompt tokens against 211 generated, a ratio near 12, far inside the winning
range on both sets. FP8 only loses on genuinely cold work: a first pass over
a large unseen codebase answered briefly.

## Caveat

The comparison column is historical rather than same-session: the E3 and E2
rows were taken on earlier days, though on the same kit, the same images and
the same method. A same-session control would need one reload of
`glm53-flash-exl3-e3.json` and about ten minutes of measurement. Given the
separation between 1,087 and 1,252 at 32k and how tightly the passes repeat,
it is unlikely to change the number.

# Serving note — what moved decode across GLM rounds 7 to 10

Rounds 7 (`results/2026-09-08/`), 8 (`-r2`), 9 (`-r3`) and 10 (this
folder) ran GLM 5.3 Flash on one unchanged helm SHA (`1f72e76`), one
unchanged app prompt (`39413706`), effort `low`, same caps, same clocks.
Helm did not change. The airo agent's GLM deployment did, and the four
rounds turn out to be a complete two-by-two of the two decode patches
shipped in `airo_agent` `e1f3e9f` from recipe `9c0794b`, both opt-in and
both default off:

- **Adaptive verification length** (`GLM53_ADAPTIVE_K=ema`), lossless at
  temperature 0, which needs a wider CUDA-graph capture list.
- **FP8 weight-only dense projections** (`GLM53_DENSE_FP8`), about
  −11 ms per step, with numerics the recipe marks provisional.

## The two-by-two

| round | adaptive-k | dense FP8 | app decode, median tok/s | fixtures decode | decode slope, tok/s per 10k context |
|---|:---:|:---:|---:|---:|---:|
| 7 | — | — | 23.2 | 32.2 | −1.88 |
| 8 | ✅ | ✅ | 30.6 | 37.1 | +0.08 |
| 9 | ✅ | — | 23.5 | 30.6 | −2.77 |
| 10 | — | ✅ | 29.6 | 37.1 | +0.93 |

Main effects on app decode: **dense FP8 +6.75 tok/s (+28.9%)**,
adaptive-k +0.65, interaction +0.35. The two rounds with FP8 are
statistically indistinguishable from each other (app p = 0.17, fixtures
p = 0.60) and so are the two without it (app p = 0.32, fixtures p = 0.94).
Every cross-pair separates, the weakest at p = 0.010.

**The gain is entirely dense FP8.** Adaptive-k alone (round 9) is
indistinguishable from no patch at all (round 7), on both task sets. This
is the conclusion `airo_agent` `f52e354` acted on when it kept FP8, dropped
adaptive-k and its wider capture list, and shipped
`glm53-flash-exl3-e3-fp8.json`. Round 10 is that payload, and it reproduces
round 8's decode without adaptive-k present.

## FP8 also flattens decode against context

A run-level median hides the shape. Below 40k tokens of context the four
rounds are the same; the patch only shows above it.

| context in that round | r7 | r8 | r9 | r10 |
|---|---:|---:|---:|---:|
| under 40k | 26.8 | 30.0 | 27.7 | 26.6 |
| 40k to 60k | 22.0 | **32.6** | 18.7 | **31.7** |

Without FP8, decode decays as the KV cache grows (slopes −1.88 and −2.77
tok/s per 10k, round 9's excluding zero). With it, decode holds flat
(+0.08 and +0.93, both intervals crossing zero). Since the app task's
context runs from about 6k to 60k tokens, the run-level median is really a
readout of how much of the run sat above the crossover. Report decode at
matched context, not as a run median.

## Prefill did not move, and could not have been seen if it had

| set | r7 | r8 | r9 | r10 | r10 95% CI |
|---|---:|---:|---:|---:|---|
| app | 1,092 | 953 | 996 | 984 | 947 – 1,024 |
| fixtures | 950 | 901 | 862 | 704 | 451 – 1,608 |

Round 10 is the first of the four with a usable interval, and its value
sits inside all three earlier ones. Rounds 7 to 9 had intervals wide enough
to swallow a thirty percent change, which is why round 8's log briefly
reported a "prefill regression" that round 9's log then retired: the
estimator was the finding. The monotone fixtures decline is not a trend
either; those four intervals overlap completely.

## Quality: no change detected, and what that means

All four rounds scored 17/17 on the fixtures and 19/19 on the app. Two of
them ran FP8 dense projections and two did not, and the bench cannot tell
them apart. That is not evidence that the provisional numerics are exact.
It is evidence that any effect is below this bench's floor, which has been
saturated since round 7. A numerics check belongs somewhere with more
resolution than a pass/fail checklist.

## Method

Prefill: least-squares fit of time to first token against uncached prompt
tokens, per round, rate as the inverse slope, with the 95% interval on that
slope. Decode: completion tokens over the window after first token, median
across rounds with at least 64 output tokens, compared with a rank-sum
test. Context slope: least squares of that decode rate against the round's
prompt tokens. Ruled out as confounds: reasoning share (38.8, 36.4, 35.0,
33.0 percent, uncorrelated with the split), completion size (identical at
200 tokens for rounds 8, 9 and 10, which straddle both arms), and prefill
or cache effects, which are excluded by construction since decode is
measured only after first token. Source is `turn_usage.round_metrics` in
the helm ledger.

## Still open

- **The numerics.** FP8 dense projections are provisional in the recipe and
  unmeasured here beyond a saturated pass/fail.
- **The helm image bound.** `@images_on_wire` is still the constant 8
  rather than the model's declared capability. Raising the GLM deployment's
  cap from 4 to 10 put it out of reach for this model, but any deployment
  capped below 8 still reproduces round 9's HTTP 400. A T29 follow-up.

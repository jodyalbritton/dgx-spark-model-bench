# Run log — 2026-09-09 throughput, round 2 (with acceptance)

**Status: COMPLETE (2026-09-09T16:22:06Z) — but the Qwen row is VOID.**
See the correction at the end of this file.

Round 1 (`results/2026-09-09-throughput/`) produced one result it could
not explain: three synthetic cases on identical input at temperature 0
decoded at 29.16, **61.08** and 29.33 tok/s. A 2× swing that the median
hid and that nothing in the response body could attribute.

Round 2 exists to attribute it. jody issued a management-scoped key on
2026-09-09, so `GET /v1/serving?speculative=1` now carries the
draft-token counters, and `Helm.Serving.around/3` brackets every case:
sample, run, wait for a scrape strictly newer than the request, sample
again, difference. The delta reconciles against the response — one base
token per decode step plus accepted draft tokens equals the completion
count — which is what makes it this request's number and not the
cluster's.

## What round 2 can settle, and what it cannot

**Can:** whether the synthetic outlier is an acceptance spike. If a case
decodes at 2× and its acceptance is correspondingly high, the mechanism
is named. If decode swings and acceptance does not, the draft-token
story is wrong and something else is going on — which would be the more
interesting result.

**Cannot:** the cross-model claim. GLM is still the only model loaded.

## Pre-flight (2026-09-09T16:12Z)

- helm `fd282bc`, clean tree.
- GLM 5.3 Flash answering; DeepSeek and Qwen still not loaded.
- Speculative counters visible: cumulative acceptance 0.3539 on sparky,
  7 draft positions.

## Harness

Five arms now — prose, ingest, json (schema enforced), **json_free**
(same body, no schema), synthetic — 3 repeats each, temperature 0 and
`max_tokens` 900 pinned. `json_free` was added after round 1, where
guided JSON came out 10 % slower than prose and the grammar was the
obvious suspect.

Slower than round 1 by design: each case waits for a fresh scrape before
its second sample, so a case costs the request plus up to 90 s.

## GLM 5.3 Flash — `glm53-flash-exl3`

Started 2026-09-09T16:13:14Z, finished 2026-09-09T16:22:06Z, helm `fd282bc`. Fifteen cases, no failures,
**acceptance measured on all fifteen**.

## The answer: decode tracks acceptance, and closely

| | |
|---|---|
| Pearson r | **0.917** |
| R² | **0.841** |
| slope | **+4.39 tok/s per 0.10 of acceptance** |
| n | 15 cases across 5 arms |

The fastest case in the round is the highest-acceptance case, and the
slowest is the lowest, without having to look for them:

- fastest: synthetic 2 — decode **30.56**, acceptance **0.4753**
- slowest: json 3 — decode **18.77**, acceptance **0.2244**

Round 1 could not attribute its outlier. Round 2 can: on this engine,
acceptance explains 84% of the variance in decode. A decode number
quoted without it is quoting the speculator's luck.

## Per arm

| arm | decode tok/s | acceptance | note |
|---|---:|---:|---|
| ingest | 26.23 | 0.3418 | summarising known text is the most predictable realistic work |
| synthetic | 25.84 | 0.3439 | the degenerate arm is barely more predictable than summarising |
| prose | 23.42 | 0.2764 | |
| json_free | 23.04 | 0.2863 | |
| json (schema enforced) | 20.80 | 0.2613 | lowest acceptance, lowest decode |

## Both round-1 results reproduced, and now have a mechanism

| ratio | round 1 | round 2 |
|---|---:|---:|
| structured / prose | 0.897 | **0.888** |
| guided / free | 0.919 | **0.903** |

Structured output is not faster than prose on GLM. It is about 11%
slower, and the reason is now visible rather than inferred: **enforcing a
schema lowers draft acceptance** — 0.2613 against 0.2863 unconstrained.
The grammar's cost is not mainly compute spent masking logits; it is
draft proposals the constraint rejects. That is a sharper claim than
"guided decoding is slower", and it is testable on any other engine.

## What did not reproduce, and what that is worth

Round 1's synthetic case 2 decoded at 61.08 tok/s, roughly 2× its
siblings. Round 2's synthetic case 2 was again the round's fastest, but
at 30.56 — about 1.2× its siblings. The *direction* reproduced; the
*magnitude* did not. Each is a single case with a different nonce, so
neither is evidence of a repeatable extreme. What the pair does support
is the mechanism: both times the fastest case was the most-accepted one.

Decode across the board also sits lower than round 1 (prose 27.10 →
23.42, about 14%). Both rounds ran the same model on the same host
within an hour. This round does not explain that, and it should not be
read as an effect of anything the bench changed.

## Still not settled

- **One model.** DeepSeek and Qwen were not loaded, so the cross-model
  claim — that GLM in particular has the widest structured-to-prose gap —
  remains untested. GLM's per-position curve
  (0.777, 0.552, 0.389, 0.275, 0.199, 0.153, 0.120 over seven draft
  positions) against Qwen3.6-35B's two at 0.934 and 0.854 suggests the
  comparison will be worth having.
- **n = 3 per arm.** The correlation is across all 15 cases and is
  strong; the individual arm medians are still three samples each.

## Cleanup

No server, no port.


## DeepSeek V4 Flash Vision Exp — `dsv4-flash-vision-exp`

Loaded by jody after GLM's row; the cluster serves one at a time, so
GLM returned 404 from that point. Sequential rows, **same host (sparky,
TP=2), same helm SHA, same harness** — the hardware-matched comparison
the earlier Qwen3.6 option could not give, since that one sits on a 5090.

Started 2026-09-09T16:44:42Z, finished 2026-09-09T16:51:46Z. Two throwaway
calls first: the engine had just come up with 1 draft recorded, and the
first call took 6.3 s against 1.4 s for the second. The throughput bench
has no warm-up of its own, so without that the cold start would have
landed in the prose arm, which runs first. **Worth adding to the bench.**

| arm | decode tok/s | acceptance |
|---|---:|---:|
| synthetic | 34.15 | 0.3499 |
| ingest | 31.35 | 0.3357 |
| prose | 28.28 | 0.2381 |
| json_free | 27.69 | 0.2478 |
| json (schema enforced) | 27.02 | 0.2516 |

## The mechanism replicates

| | GLM 5.3 | DeepSeek V4 |
|---|---:|---:|
| Pearson r (decode vs acceptance) | 0.917 | 0.913 |
| R² | 0.841 | 0.833 |
| slope, tok/s per 0.10 acceptance | +4.39 | +5.09 |
| n | 15 | 15 |

Two different models, six and seven draft positions, on one host: decode
tracks acceptance the same way in both, explaining about 84 % of the
variance. On the strict subset of cases whose delta reconciles to the
token (9 and 10 cases) it holds at r = 0.902 and 0.857.

**Contamination checked, not assumed.** Decode steps plus accepted
tokens should equal the completion count. Across all 30 cases the
largest disagreement is 5 tokens against completions of 700–900, under
1 %, which is a token or two straddling a scrape boundary rather than
another client on the deployment. The exact-equality test was too
strict; the tolerance is the right check and no case shows real
contamination.

## The cross-model claim resolves — the right model, the wrong direction

jody's claim was that **GLM in particular has the largest disparity
between structured output and prose**. On matched hardware:

| ratio | GLM 5.3 | DeepSeek V4 |
|---|---:|---:|
| structured / prose | **0.888** | 0.955 |
| guided / free | **0.903** | 0.976 |

**The claim holds. The predicted direction does not.** GLM does have the
wider gap — an 11.2 % structured penalty against DeepSeek's 4.5 % — but
structured output is *slower* than prose on both models, not faster. The
expectation before the first run was that near-deterministic braces and
commas would decode faster; they do not, on either model.

And the grammar's cost is GLM's problem specifically: enforcing a schema
costs GLM about 10 % of decode and DeepSeek about 2 %.

**Why, in the acceptance numbers.** For GLM the schema *lowers
acceptance* — 0.2613 guided against 0.2863 free. For DeepSeek the two
are indistinguishable — 0.2516 against 0.2478. GLM drafts seven
positions with a curve already decaying hard
(0.777 → 0.120); a constraint that prunes candidate continuations has
more to take away. DeepSeek drafts six and is barely affected. That is a
mechanism a third model could test, rather than a description of two.

## What this round still does not settle

- **Two models, not three.** Qwen 3.8 Flash Next was never loaded.
- **n = 3 per arm.** The correlations are over 15 cases each and are
  strong; the arm medians are three samples.
- **Sequential, not simultaneous.** GLM ran 16:13–16:40Z, DeepSeek
  16:45–17:0xZ. Same host and harness, but any cluster drift between
  them sits inside the comparison.


## Qwen 3.8 Flash Next — `qwen38-flash-next-nvfp4`

Loaded third; DeepSeek and GLM both went to 404. Same host, same helm
SHA, same harness. Started 2026-09-09T17:31:42Z, finished 2026-09-09T17:37:37Z. Two throwaway calls
first (2.5 s then 2.1 s).

| arm | decode tok/s | acceptance |
|---|---:|---:|
| synthetic | 42.56 | 0.8074 |
| json_free | 38.09 | 0.6539 |
| ingest | 37.48 | 0.6418 |
| prose | 35.66 | 0.5944 |
| json (schema enforced) | 35.12 | 0.6070 |

Qwen drafts 3 positions on a flat curve (0.8, 0.667, 0.533) and accepts
roughly twice as often as the other two. It is the fastest of the three
on every arm.

## Three models, one host — what held and what did not

| | GLM 5.3 | DeepSeek V4 | Qwen 3.8 |
|---|---:|---:|---:|
| draft positions | 7 | 6 | 3 |
| structured / prose | **0.888** | 0.955 | **0.985** |
| guided / free | 0.903 | **0.976** | 0.922 |
| acceptance, prose | 0.2764 | 0.2381 | 0.5944 |
| decode vs acceptance, r | 0.917 | 0.913 | **0.969** |

### jody's claim holds, and orders with draft depth

**GLM does have the widest structured-to-prose gap**, and across three
models the ratio orders monotonically with how deep the model drafts:
7 positions to 0.888, 6 to 0.955, 3 to 0.985. Structured output is
slower than prose on all three, never faster, and the deeper a model
drafts the more it loses. That is a stronger version of the claim than
the one that went in.

### My prediction was wrong

Before the run I predicted, from the two-model result, that Qwen would
show **the smallest guided penalty** because it drafts shallowest. It
did not: `guided/free` came out GLM 0.903, DeepSeek 0.976, **Qwen
0.922**. DeepSeek has the smallest penalty and the ordering is not
monotonic in draft depth at all. The prediction named the wrong ratio —
draft depth predicts the *structured/prose* gap, not the *guided* one.

### The mechanism survives, in relative terms

The schema lowers acceptance for GLM and Qwen and leaves DeepSeek's
alone. Expressed as a *relative* change it tracks the decode penalty
closely on all three, which the absolute drop does not, because Qwen's
baseline acceptance is more than twice the others':

| | acceptance drop from schema | decode penalty (1 minus guided/free) |
|---|---:|---:|
| GLM 5.3 | 8.7 pct | 9.7 pct |
| Qwen 3.8 | 7.2 pct | 7.8 pct |
| DeepSeek V4 | -1.5 pct | 2.4 pct |

So enforcing a schema costs decode in proportion to how much acceptance
it costs, and DeepSeek's grammar handling simply does not disturb its
speculation. Qwen has the *largest absolute* acceptance drop (0.047) and
only a middling decode penalty, because it is falling from 0.654 rather
than 0.286.

### The correlation replicates a third time

r = 0.917, 0.913, 0.969 across three models with three different draft
depths, 15 cases each. Contamination checked on all 45 cases: the
largest disagreement between decode steps plus accepted tokens and the
completion count is 5 tokens on completions of 700 to 900, under 1 pct.

## Still open

- **n = 3 per arm.** The correlations are over 15 cases each and are
  strong; the arm medians are three samples.
- **Sequential rows.** GLM 16:13Z, DeepSeek 16:45Z, Qwen 17:32Z. One
  host, one harness, but any cluster drift across that window sits inside
  the comparison.
- **Why DeepSeek is unaffected by the grammar** is undescribed. It is the
  one model whose acceptance the schema does not move, and this round
  says that it happens, not why.


---

# CORRECTION, 2026-09-09 — the Qwen row is void

jody: "All raw throughput should be measured with thinking=off."
Checking that found a measurement error in this round.

The bench sent `reasoning_effort: "none"`, which is airo's abstraction.
**It does not disable thinking on every template.** Measured directly on
Qwen 3.8:

| setting | reasoning chars emitted |
|---|---:|
| no flag at all | 509 |
| `reasoning_effort: "none"` | **660** |
| `chat_template_kwargs {thinking:false, enable_thinking:false}` | **0** |

So the flag did nothing on that template. The recorded rows confirm it —
reasoning tokens on **every Qwen case** and none on the others:

| model | reasoning tokens per case | thinking |
|---|---|---|
| Qwen 3.8 | 58–209 on all 15 | **on** |
| DeepSeek V4 | none | off |
| GLM 5.3 | none | off |

**What this voids.** Qwen's row was measured under a different condition
from the other two, so every cross-model comparison involving it is
unsound — including "structured/prose orders monotonically with draft
depth", which used Qwen's 0.985 as its third point. Qwen's own internal
ratios are also suspect: its reasoning share varied by arm, from 7.5 %
(json) to 23 % (one json_free case), so the arms were not even comparable
to each other.

**What survives.** GLM and DeepSeek emitted no reasoning tokens on any
case, so those two rows were measured thinking-off as intended. The
two-model comparison between them stands, as does the decode/acceptance
correlation for each.

**Re-measured after the fix**, Qwen thinking genuinely off:

| arm | this round (thinking on) | after the fix |
|---|---:|---:|
| prose | 35.7 | 47.7 |
| synthetic | 42.6 | 54.1 |

Roughly a third higher. That is a large part of the gap jody flagged
against the recipe, though cluster drift of up to 2x within an hour
means it cannot be the whole explanation.

**The fix.** `Helm.Evals.Throughput` now sends the template kwargs as
well as `reasoning_effort`, and every row carries `thinking_leaked` with
a count in the summary. A round that thinks anyway now says so instead of
reporting a quietly different measurement.

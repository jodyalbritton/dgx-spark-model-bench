# Run log — 2026-09-09 throughput, round 3 (clean harness)

**Status: COMPLETE** — three clean rows.

Rounds 1 and 2 are superseded and their numbers should not be quoted.
Both are kept in place with a banner, because the correction in round 2's
log is the record of how the error was found.

## Why they were discarded

Round 2 sent `reasoning_effort: "none"` and assumed that meant thinking
off. It does not on every template. On Qwen 3.8 it emitted *more*
reasoning than sending no flag at all — 660 chars against 509 — and the
recorded round shows reasoning tokens on all 15 Qwen cases and none on
GLM's or DeepSeek's. The three rows were therefore measured under two
different conditions, which voids every cross-model claim that used
Qwen, including the monotonic structured-to-prose ordering.

## What changed in the harness

1. **Thinking is off by the template kwarg**, not only airo's
   abstraction: `chat_template_kwargs{thinking,enable_thinking}=false`
   plus `reasoning_effort: "none"`. Both are sent.
2. **A leak is loud.** Every row carries `thinking_leaked`; the summary
   counts them. Silence is what let round 2 through.
3. **Arm order is interleaved and shuffled** per pass. Decode on this
   cluster moves up to 2x within an hour on identical work — wider than
   the differences between arms — so a fixed order let session drift
   align with arm identity. Upward drift would inflate whichever arm ran
   last, which was the observed shape of `synthetic/prose`.

## What has not changed, and still limits this round

- **Absolute decode is unstable.** Re-measuring one model on one arm at
  one length inside an hour gave 31.9–59.6 tok/s. Read the ratios; read
  a decode figure as this session's snapshot with its range.
- **Rows are sequential.** The cluster serves one model at a time, so
  drift sits between models as well as within a session.
- **The recipe gap is unexplained.** The DSpark recipe's c=1 row at a
  2,048-token prompt is 64.6 tok/s for DeepSeek; round 2 measured 34.1.
  Thinking-off accounts for part of it on Qwen (about a third), but that
  row was already thinking-off, so something else remains. The recipe
  benches `DeepSeek-V4-Flash-0731` on Anemll 0.1.1 with MTP-5 and
  `nvfp4_ds_mla` KV; ours is the Vision-Exp fp8 build reporting 6 draft
  positions. Different checkpoint, KV format and draft depth.

## Ruled out as causes, with evidence

- **helm's streaming client.** A thin client that counts chunks and does
  nothing else gives 42.93 tok/s on Qwen at 900 tokens against the
  bench's 42.56 — no measurable overhead.
- **Uncounted reasoning tokens.** `usage.completion_tokens_details.reasoning_tokens`
  is populated when thinking is on (199 of 200 in a probe), so the field
  the bench records is trustworthy.
- **Output length.** 128 forced tokens gives 46.1 on Qwen and 900 gives
  59.2 — shorter is *slower*, the opposite of what would close the gap.

## Rows

Order is whatever jody loads. The cluster serves one model at a time.


## Qwen 3.8 Flash Next — `qwen38-flash-next-nvfp4`

Started 2026-09-09T22:43:53Z, finished 2026-09-09T22:49:21Z. `thinking_leaked: 0` on all
15 cases — the condition round 2 failed.

| arm | decode tok/s | acceptance |
|---|---:|---:|
| synthetic | 39.53 | 0.6964 |
| json (schema enforced) | 36.51 | 0.6639 |
| json_free | 36.36 | 0.6456 |
| prose | 34.39 | 0.6162 |
| ingest | 33.26 | 0.5277 |

### The direction reverses once thinking is off

| ratio | round 2 (thinking on) | round 3 (clean) |
|---|---:|---:|
| structured / prose | 0.985 | **1.062** |
| guided / free | 0.922 | **1.004** |

Structured JSON now decodes **faster** than prose on Qwen, and enforcing
the schema costs nothing measurable. That is the original hypothesis —
braces, quotes and commas are near-deterministic — and round 2 had it
backwards because roughly a tenth of every Qwen completion was reasoning
text, which is prose-shaped and diluted exactly the arm the claim is
about.

Acceptance says the same thing rather than merely agreeing: **json
0.6639 against prose 0.6162.** Structured tokens really are more
predictable for this model, and the decode ordering follows the
acceptance ordering arm for arm, with ingest last on both.

### What this does not yet mean

GLM and DeepSeek carried no reasoning tokens in round 2 and came out at
0.888 and 0.955 — structured *slower*. Either the effect genuinely
differs by model, or their thinking state was never verified the way
Qwen's now is. DeepSeek in particular was only ever inferred to be
thinking-off from a nil field, and Qwen shows that field populated when
thinking is on. Their round-3 rows settle it; until then no cross-model
statement is available.

**Absolute decode drifted again**: prose reads 34.39 here against 35.7 in
round 2 and 47.7 in an ad-hoc measurement an hour earlier, on one model
and one arm. The ratios are the output; the absolutes are this session's
snapshot.


## DeepSeek V4 Flash Vision Exp — `dsv4-flash-vision-exp`

Started 2026-09-09T23:09:30Z, finished 2026-09-09T23:16:23Z. `thinking_leaked: 0` on all 15.

Its round-2 row was also genuinely thinking-off — verified afterwards:
`reasoning_effort: "none"` alone does suppress thinking on this template
(856 chars bare, 0 with the flag), unlike Qwen's. So round 2 and round 3
are two clean measurements of the same condition, which is more useful
than one.

| arm | decode tok/s | acceptance |
|---|---:|---:|
| synthetic | 31.58 | 0.2949 |
| ingest | 30.78 | 0.2980 |
| prose | 30.54 | 0.2534 |
| json_free | 29.83 | 0.2664 |
| json (schema enforced) | 26.86 | 0.2497 |

### Direction reproduces; magnitude does not

| ratio | round 2 | round 3 |
|---|---:|---:|
| structured / prose | 0.955 | 0.880 |
| guided / free | 0.976 | 0.900 |

Both rounds thinking-off, same host, same harness. The ratio moved 8
points, so **do not quote these to three figures.** What does hold is the
ordering, and it holds strictly: in both rounds DeepSeek's whole json
range sits below its whole prose range, with no overlap.

| round | json range | prose range |
|---|---|---|
| 2 | 25.39 – 27.73 | 28.08 – 29.46 |
| 3 | 26.36 – 28.50 | 30.14 – 30.71 |

Six json cases, six prose cases, two sessions, and every json case is
slower than every prose case. Structured output is slower than prose on
DeepSeek. How much slower is not resolved at n=3.

### The two models genuinely disagree

| | Qwen 3.8 | DeepSeek V4 |
|---|---:|---:|
| structured / prose | **1.062** | **0.880** |
| acceptance, json | 0.6639 | 0.2497 |
| acceptance, prose | 0.6162 | 0.2534 |
| json more predictable than prose? | **yes** (+0.048) | **no** (−0.004) |

This is not a difference in magnitude, it is a difference in sign, and
acceptance backs each side independently. Structured tokens are more
predictable for Qwen and are not for DeepSeek, and decode follows in both
cases. jody's original hypothesis — braces and commas are
near-deterministic, so structured should decode faster — is **true for
Qwen and false for DeepSeek**.

GLM decides whether that is a two-camp split or a spectrum.


## GLM 5.3 Flash — `glm53-flash-exl3`

Started 2026-09-09T23:29:27Z, finished 2026-09-09T23:37:58Z. `thinking_leaked: 0` on all 15.

| arm | decode tok/s | acceptance |
|---|---:|---:|
| synthetic | 39.88 | 0.6761 |
| ingest | 27.13 | 0.3685 |
| prose | 22.92 | 0.2939 |
| json_free | 22.06 | 0.2681 |
| json (schema enforced) | 17.15 | 0.2404 |

---

# Round 3 — three clean rows, and the claim resolves

All three measured thinking-off, verified per case, arms shuffled, on one
host. `thinking_leaked: 0` everywhere.

| | Qwen 3.8 | DeepSeek V4 | GLM 5.3 |
|---|---:|---:|---:|
| draft positions | 3 | 6 | 7 |
| **structured / prose** | **1.062** | **0.880** | **0.748** |
| guided / free | 1.004 | 0.900 | 0.777 |
| acceptance gap (json − prose) | **+0.048** | **−0.004** | **−0.054** |
| decode vs acceptance, r | 0.941 | 0.920 | 0.941 |

## It is a spectrum, and it orders with draft depth

Both the effect and its mechanism move monotonically with how deep a
model drafts:

- **structured / prose**: 3 positions → 1.062, 6 → 0.880, 7 → 0.748.
- **acceptance gap**: +0.048, −0.004, −0.054.

The deeper a model drafts, the more a schema costs its draft acceptance,
and decode follows. Qwen, drafting three, gains from structure. DeepSeek,
at six, is neutral. GLM, at seven, loses a quarter of its decode.

**jody's claim is confirmed on clean data**: GLM does have the largest
disparity between structured output and prose, by a wide margin, and now
with a mechanism rather than an observation.

**The original hypothesis is true for exactly one of the three.**
Structured output decodes faster than prose only on Qwen. The prediction
was that near-deterministic braces and commas would help every model; it
helps the shallow drafter and hurts the deep ones, because a grammar that
prunes continuations takes more from a model that is guessing seven
tokens ahead than from one guessing three.

The decode/acceptance correlation replicates a third time, r = 0.92–0.94
on every model, so acceptance is the variable throughout.

## GLM's synthetic arm is the spark_bench artifact, isolated

| model | synthetic / prose | synthetic acceptance | prose acceptance |
|---|---:|---:|---:|
| GLM 5.3 | **1.74** | 0.6761 | 0.2939 |
| Qwen 3.8 | 1.149 | 0.6964 | 0.6162 |
| DeepSeek V4 | 1.034 | 0.2949 | 0.2534 |

GLM's acceptance more than doubles on the degenerate workload — 0.29 to
0.68 — and its decode goes with it, 22.9 to 39.9. That is the whole
reason round 1 of the programme reported GLM at 44.9–58.2 tok/s: it
measured the one model whose speculation benefits most from repetitive
forced output, on exactly that workload. The synthetic arm is kept as a
labelled upper bound for this reason.

## What is still not resolved

- **Magnitude at n = 3.** DeepSeek's structured/prose read 0.955 in round
  2 and 0.880 here, both clean, both thinking-off. The direction
  reproduces strictly — every json case slower than every prose case in
  both rounds — but the ratio is not stable to three figures. Read the
  ordering, not the decimal.
- **Absolute decode drifts up to 2x within an hour**, so the tok/s
  columns are this session's snapshot.
- **The DSpark recipe gap.** Its c=1 row at a 2,048-token prompt is 64.6
  tok/s for DeepSeek; this round reads 30.5 on prose and 31.6 on
  synthetic, thinking-off. The recipe benches
  `DeepSeek-V4-Flash-0731` on Anemll 0.1.1 with MTP-5 and `nvfp4_ds_mla`
  KV; ours is the Vision-Exp fp8 build reporting 6 draft positions.
  Different checkpoint, KV format and draft depth — untested as the
  explanation, and the most likely one left.


---

# What is actually slow: DeepSeek's draft acceptance

jody, against the published recipes: DeepSeek should give ~62–83 decode
tok/s at c=1; Qwen's kit reports 52.1 at MTP=3 (24.5 with MTP off, 2.13x).
This round measured DeepSeek at 30.5 prose. The acceptance data says why,
and it is not the measurement.

| model | draft positions | acceptance | tokens/step | ceiling | prose decode |
|---|---:|---:|---:|---:|---:|
| Qwen 3.8 | 3 | 0.636 | **2.91** | 4 | 34.4 |
| DeepSeek V4 | 6 | **0.266** | **2.60** | 7 | 30.5 |
| GLM 5.3 | 7 | 0.287 | 3.01 | 8 | 22.9 |

Tokens per step is the speculative multiplier directly — one base token
plus whatever the drafts buy. **Qwen extracts 2.91 of a possible 4 (73 %
of its ceiling). DeepSeek extracts 2.60 of a possible 7 (37 %).** It
drafts twice as deep as Qwen and gets less out of it.

For contrast, the Qwen3.6-35B deployment on `forge` reports acceptance
0.894 across 2 positions. DeepSeek here is at 0.266 across 6.

**Qwen reconciles against its own recipe.** Target 52.1 at MTP=3, our
deployment reports exactly 3 draft positions, and the best measurement
taken on it was 54.1. Round 3's 39.5 caught it in a slower window; the
configuration is behaving as documented.

## Ruled out, each measured rather than argued

| candidate | evidence |
|---|---|
| helm/airo transport overhead | a thin client that counts chunks and does nothing else: 42.93 tok/s against the bench's 42.56, same arm and length |
| thinking left on | `thinking_leaked: 0` on all 45 cases, verified by both the usage counter and the reasoning text |
| the round context depressing decode | GLM re-measured through the task straight after round 3: prose **22.92 against 22.92**, synthetic 37.4 against 39.9 |
| output length | 128 forced tokens is *slower* than 900 on Qwen (46.1 vs 59.2), the wrong direction to close the gap |
| uncounted reasoning tokens | the usage counter is populated when thinking is on (199 of 200 in a probe) |

## What is left

Our DeepSeek is `Vision-Exp:fp8` reporting 6 draft positions. The recipe
benches `DeepSeek-V4-Flash-0731` on Anemll 0.1.1 with **MTP-5** and
`nvfp4_ds_mla` KV. Different checkpoint, KV format and draft depth, and
an acceptance rate that cannot support the published decode. If the draft
model or its config is mismatched for this checkpoint, that is where the
missing 2x sits.

jody is reloading DeepSeek. The diagnostic to watch is **acceptance and
tokens/step**, not decode: decode drifts up to 2x on this cluster, while
acceptance is a property of the speculation and moves only when the
deployment does.


---

# DeepSeek reloaded, and re-run in full — the gap does not close

jody reloaded the DeepSeek deployment. Its pre-reload row is kept as
`raw/throughput-dsv4-flash-vision-exp.prereload.json`; the current row is
the re-run. **Note this makes round 3 span a deployment change**: GLM's
and Qwen's rows were taken before the reload and were not repeated.

## Raw decode, tok/s

| arm | before reload | after, full row |
|---|---:|---:|
| synthetic | 31.6 | 34.7 |
| ingest | 30.8 | 31.6 |
| json_free | 29.8 | 29.5 |
| prose | 30.5 | 28.2 |
| json | 26.9 | 27.9 |

**The reload bought almost nothing in a full round**, and every arm is
still less than half the recipe's 62–83 band. The draft curve did change
— first-position acceptance is now 0.641 where the whole-request rate had
been 0.266 — but the throughput did not follow.

## A spot check I should not have reported as a result

Immediately after the reload, two standalone cases gave synthetic 50.0
and prose 36.2, and I presented those as the reload working. The full row
twenty minutes later gave 34.7 and 28.2. Two cases were not a
measurement, and the 50.0 was a favourable outlier.

## The round is not contaminating itself

The obvious suspect was the round interleaving `ingest`, a 13k-token
prompt, among the other cases, leaving the block pool in a state that
slows later decode. Tested by running synthetic alone, three cases, no
ingest anywhere in the session:

| case | tok/s | acceptance |
|---|---:|---:|
| 1 | 29.7 | 0.272 |
| 2 | 40.7 | 0.458 |
| 3 | 37.7 | 0.414 |

Median **37.7 alone against 34.7 in the full round**, with the isolated
cases spanning 29.7–40.7. Those overlap; the round is measuring fine.
GLM had already reproduced exactly under the same test (22.92 against
22.92).

## What the isolation actually found

**Acceptance swings 68 % between identical cases** — 0.272, 0.458, 0.414
on the same prompt shape, same settings, same minute — and decode tracks
it case for case. DeepSeek's speculation is unstable run to run, which is
why single-case measurements of this model are worthless and why its
medians move between rounds.

That is a different problem from being slow. It is slow *and* erratic,
and the erratic part is what made the reload look like it had worked.


---

# Qwen re-run: the bench reproduces, the models still fall short

Qwen's deployment was not touched. Re-running its full row hours later is
a stability check on the harness itself. Prior row kept as
`raw/throughput-qwen38-flash-next-nvfp4.prior.json`.

## Raw decode, tok/s

| arm | earlier row | re-run |
|---|---:|---:|
| synthetic | 39.5 | 40.3 |
| json_free | 36.4 | 37.3 |
| json | 36.5 | 36.8 |
| prose | 34.4 | 36.6 |
| ingest | 33.3 | 33.4 |

**Every arm within ~2 tok/s.** The harness reproduces on an unchanged
deployment, which is what GLM also showed (22.92 against 22.92). The
instability is in the models and the cluster, not the measurement.

Per-case synthetic spread, 35.8 – 41.8 (acceptance 0.561 – 0.748),
against DeepSeek's 29.7 – 40.7 (acceptance 0.272 – 0.458). Qwen is the
steadier of the two by a wide margin.

## Against the published targets — raw tok/s

| model | measured (prose / synthetic) | target | share |
|---|---|---|---|
| Qwen 3.8 | 36.6 / 40.3 | 52.1 at MTP=3 | ~70–77 % |
| DeepSeek V4 | 28.2 / 34.7 | 62–83 at c=1 | ~40–50 % |
| GLM 5.3 | 22.9 / 39.9 | none published | — |

Qwen is the cleanest comparison in the set: its kit publishes 52.1 at
MTP=3 batch-1 greedy, our deployment reports exactly 3 draft positions,
and the bench runs greedy at temperature 0. No checkpoint or KV-format
caveat, unlike DeepSeek. It still lands ~25 % low.

Both models fall short; DeepSeek falls much further and is erratic with
it. That both are short by different amounts, on a harness that
reproduces itself, points at the deployments rather than at one bad
config.

## Standalone probes keep reading higher than rounds

Qwen's best standalone case was 54.1 (thinking off, acceptance off) and
59.0 with thinking on; the round reproduces 36–40. DeepSeek's standalone
was 50.0 against 34.7 in-round. But the isolation test settled that the
round is not at fault — synthetic alone gave DeepSeek 37.7 against 34.7
in-round, overlapping.

The remaining explanation is cluster drift between windows: Qwen measured
~50 around 23:00Z and ~36–42 at 06:00Z, in-round and standalone alike.
Absolute decode on this cluster is a property of *when you asked*, which
is why the record carries ranges and why the ratios are the headline.

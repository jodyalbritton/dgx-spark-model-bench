# 2026-09-10-throughput — the published cells inside the bench, Qwen 3.8

Qwen 3.8 Flash Next NVFP4 on sparky (`airo-slot-8081`, TP=2, MTP=3,
fp8 KV, no draft vocabulary), freshly reloaded; run 16:33–16:38 UTC from
helm at a dirty tree over `9ed7c56` (the timing fix, the freshness fix
and the two replica arms, uncommitted at run time — see
`docs/sprints/T35-bench-coverage.md`). Seven arms, three repeats,
interleaved and shuffled, a 32-token warm-up (1,970 ms) before the plan.

The question this round exists to answer (jody, 2026-09-10): the
recipes advertise 52–54 tok/s for this model and the bench read 36; the
gateway is a pass-through; so is the gap method, and if so, why is the
bench's number the more correct one?

## Decode, median tok/s, with acceptance

| arm | decode | range | acceptance | completion (median) | forced |
|---|---:|---|---:|---:|---|
| prose | **46.7** | 46.1–48.8 | 0.597 | 665 | no |
| ingest | 42.1 | 40.6–43.0 | 0.511 | 683 | no |
| json | 49.3 | 47.3–50.4 | 0.647 | 757 | no |
| json_free | 49.8 | 48.7–50.5 | 0.654 | 750 | no |
| synthetic | 55.5 | 53.9–57.3 | 0.767 | 900 | yes |
| **recipe** (sparkDash ×1 prose) | **52.4** | 51.5–54.0 | 0.717 | 400 | yes |
| **spark_bench** (script cell, T=0.6) | **62.0** | 59.4–62.6 | 0.912 | 128 | yes |

Ratios: structured/prose 1.057, guided/free 0.991, synthetic/prose
1.188, **recipe/prose 1.123**, **spark_bench/prose 1.328**.

Every acceptance delta reconciles: drafts + accepted − completion is
within ±2 tokens on all 21 cases, so no other client touched the slot.
`bracket_ms` is 86–136 ms per case — the 5 s sleep is gone.

## The answer

**The recipe's number reproduces.** sparkDash's ×1 prose cell, sent
verbatim through helm and airo, decodes at 52.4 tok/s against the Qwen
kit README's 52.1 (MTP table) and 54.4 (sparkDash capture, which also
had a balanced draft vocabulary this slot does not run). The gateway
costs nothing measurable on decode. The earlier "36 tok/s" was the
bench timing its own acceptance bracket, not the stack. Those rounds
(`2026-09-09-throughput`, `-r2`, `-r3`) were deleted on 2026-09-10
rather than kept repaired; the repair's before/after table lives in
helm's `docs/sprints/T35-bench-coverage.md`.

**What the cell measures, in this session's own numbers.** The same
model, minutes apart, decodes prose it was asked for at 46.7 and the
recipe cell at 52.4 — 12 % higher — and the script cell at 62.0 — 33 %
higher. The acceptance column is the whole explanation: 0.597 for real
prose, 0.717 for the recipe cell, 0.912 for 128 forced tokens of a
numbered word list. On an MTP engine acceptance *is* decode, and the
cells are built to raise it:

1. **Forced past the natural stop.** `ignore_eos` with `min_tokens =
   max_tokens`: once the answer is done the model emits filler, and
   filler drafts almost perfectly. The script cell's 0.91 is what
   "1. apple 2. banana …" accepts at.
2. **The draft head's best-case content.** The hash-map explanation is
   the most-trained prompt on the internet; a numbered list is a
   template. Neither resembles code, tool JSON or a report.
3. **A short window.** 128–400 tokens, 2–8 s. Nothing decays, nothing
   amortises.
4. **A warm prefix.** The recipe cell sends one prompt with no nonce;
   its 181–216 ms TTFT on repeats is a cache hit, which is where the
   README's "160 ms" comes from.

**Which number to quote.** The prose arm — real output to a natural
stop, at temperature 0, with acceptance beside it — is what an operator
gets on a single stream of ordinary work: **~47 tok/s**, with structured
JSON a little faster (49–50) and a 13k-token ingest a little slower
(42). The recipe's own `bench/decodebench.py` prose row (40.0–42.5,
bf16 KV, earlier container) is the honest number in the README, and this
slot beats it. The 52–54 headline is a real measurement of a
best-case cell; it is not a lie, and it is not throughput.

## Prediction, stated before the run, against the outcome

| predicted | outcome |
|---|---|
| recipe/prose 1.2–1.5 | **1.123** — below the band; the cell is less inflated than I expected |
| recipe acceptance > 0.8 against prose ~0.6 | **0.717** against 0.597 — direction right, magnitude wrong |
| corrected prose within 10 % of the kit's decodebench prose (40–42.5) | **46.7** — 10–17 % *above* it; this slot (fp8 KV, newer container) is faster than that capture |
| if the cell misses 52–54, the gap is deployment | the cell hit 52.4; nothing to attribute |

Two of three magnitudes were wrong in the flattering direction: the
published method is *less* degenerate than the bench's moduledoc
argued, and the script cell — ours — is the one that really flatters.

## Still open

- GLM and DeepSeek have not run the seven-arm row; their earlier
  rounds were deleted, so this directory is the baseline from here.
- n = 3 per arm. The recipe cell's range (51.5–54.0) already spans the
  README's two numbers.


---

# DeepSeek V4 Flash Vision Exp — `dsv4-flash-vision-exp` (17:34–17:41 UTC)

Same seven arms, same tree, loaded by jody after the Qwen row. Bracket
83–134 ms per case; every acceptance delta reconciles within ±5 tokens.

## Decode, median tok/s, with acceptance

| arm | decode | range | acceptance | completion (median) | forced |
|---|---:|---|---:|---:|---|
| prose | **35.9** | 34.4–36.6 | 0.241 | 873 | no |
| ingest | 36.3 | 35.8–38.8 | 0.272 | 738 | no |
| json | 37.2 | 35.9–37.7 | 0.264 | 638 | no |
| json_free | 35.7 | 34.7–37.3 | 0.243 | 634 | no |
| synthetic | 40.3 | 37.5–50.2 | 0.307 | 900 | yes |
| **recipe** (sparkDash ×1 prose) | **41.2** | 37.7–43.3 | 0.337 | 400 | yes |
| **spark_bench** (script cell, T=0.6) | **57.0** | 53.5–57.4 | 0.480 | 128 | yes |

Ratios: structured/prose 1.037, guided/free 1.041, synthetic/prose
1.123, **recipe/prose 1.148**, **spark_bench/prose 1.589**.

## Against the DeepSeek kit's own numbers

The kit's README (`~/dsv4-recipe`) advertises "~62–83 decode tok/s after
first token" from 2026-08-14 and, further down, its *current* live
figure: **256 × c=1 = 56 tok/s** (8-trial median, 51–67, 2026-09-02,
`scripts/bench-miaai.py`), with the note that decode is 15–25 % under
the August figures and no knob accounts for it. That cell is a 256-token
prompt with a forced numbered-word output — the same shape as our
`spark_bench` arm, which reads **57.0** here. The kit's A/B log also
reports "natural" acceptance of 24.7–26.7 % against 47–54 % on the
numbered-word cell; this row reads **0.241** on prose and **0.480** on
the script cell. Both the rate and the acceptance of the kit's own cell
reproduce through helm and airo; the August 62–83 is the kit's "best
seen, not the norm", in its own words.

sparkDash's prose cell (`recipe`) is not the DeepSeek kit's method — it
is the Qwen kit's — and here it lands at 41.2, between real prose and
the numbered-word cell, which is where its 0.34 acceptance puts it.

## What the two rows say together

| | Qwen 3.8 | DeepSeek V4 |
|---|---:|---:|
| prose (acceptance) | 46.7 (0.60) | 35.9 (0.24) |
| recipe / prose | 1.123 | 1.148 |
| spark_bench / prose | 1.328 | 1.589 |
| structured / prose | 1.057 | 1.037 |
| guided / free | 0.991 | 1.041 |

The script cell flatters DeepSeek more than Qwen (1.59 against 1.33)
because DeepSeek's natural acceptance is so much lower: the forced
numbered list doubles its acceptance (0.24 → 0.48) where Qwen's rises by
half (0.60 → 0.91). A published c=1 number on a low-acceptance model is
further from what an operator gets than the same cell on a
high-acceptance one — which is the argument for reporting the cell
beside prose on every model rather than quoting either alone.

Structured output is *not* slower than prose on either model here
(1.057 and 1.037), and the grammar costs nothing measurable (0.991,
1.041). The earlier "slower on all three" finding was the bracket.

## Two things the run itself showed

- **A 32-token warm-up does not warm prefill at size.** Despite the
  3.3 s warm-up, the first cases ran cold: `ingest 1` took 28.96 s to
  first token on 12,734 uncached tokens (≈ 440 tok/s prefill) where
  later uncached prefill reads ≈ 1,390 (synthetic) and cached ingest
  turns around in 0.47 s; `spark_bench 1` and `synthetic 1` had 5.8 s
  and 6.2 s TTFTs against 0.3 s and 0.8 s on their repeats. Decode on
  those cases was normal. The shuffle put them first by chance; the
  medians absorb it, but the prefill column for this row should be read
  from cases 2–3. The warm-up should send one prompt at size — a bench
  change, noted in T35.
- **One `json_free` body did not parse** (`json_free 3`, 601 tokens,
  natural stop). Recorded as `json_parse_failures: 1`; its decode still
  counts, as the design says.


---

# GLM 5.3 Flash EXL3 — `glm53-flash-exl3` (17:57–18:06 UTC)

Same seven arms, same tree, loaded by jody after DeepSeek. Bracket
90–156 ms per case.

## Decode, median tok/s, with acceptance

| arm | decode | range | acceptance | completion (median) | forced |
|---|---:|---|---:|---:|---|
| prose | **27.0** | 24.4–27.9 | 0.291 | 894 | no |
| ingest | 29.0 | 28.7–30.9 | 0.321 | 900 | no (hit cap ×3) |
| json | 25.4 | 20.7–26.0 | 0.277 | 604 | no |
| json_free | 26.4 | 21.4–26.5 | 0.269 | 647 | no |
| synthetic | 45.5 | 23.3†–54.4 | 0.579 | 900 | yes |
| **recipe** (sparkDash ×1 prose) | **31.1** | 30.6–33.0 | 0.361 | 400 | yes |
| **spark_bench** (script cell, T=0.6) | **49.9** | 30.0†–50.8 | 0.695 | 128 | yes |

Ratios: structured/prose **0.942**, guided/free 0.961, synthetic/prose
1.687, **recipe/prose 1.152**, **spark_bench/prose 1.849**.

† **Two cases were contaminated, and the record says so.** `spark_bench 1`
and `synthetic 1` carry `acceptance_gap` 124 and 424 — decode steps plus
accepted drafts exceed their own completion counts, which means another
client was generating on the slot. airo's ledger attributes it: the
**incogito-prod** key sent two GLM chats at 17:57:01–17:58:23 (433 and
748 output tokens, 65 s and 82 s), overlapping the warm-up and those two
cases. Their TTFTs (7.2 s and 7.8 s against 0.7–1.5 s on the repeats)
and decode (30.0 and 23.3 against 50–54) are shared-slot numbers, not
cold-start ones. Every other case reconciles within ±5. The medians
stand — the contaminated case is the low one in both arms — but the
synthetic range is wide for that reason, not because the arm is
unstable. This is the check the `acceptance_gap` field was added for
this morning, doing its job on its second outing.

## GLM is the exception on structured output, and it is real

On the repaired 2026-09-09 records GLM's structured/prose was 0.750
against 1.05 and 1.07 for the other two. Here it is **0.942** — still
the only model under 1, but the penalty is 6 %, not 25 %. The old rows
were at the end of that session and its json arm caught GLM's worst
acceptance (0.240); today's json acceptance is 0.277 against prose's
0.291, a smaller gap, and the decode follows it. The grammar costs ~4 %
(guided/free 0.961). The claim survives in direction only: GLM is the
model whose structured output does not come free.

## Three models, one method, one day

| | GLM 5.3 | Qwen 3.8 | DeepSeek V4 |
|---|---:|---:|---:|
| draft positions | 7 | 3 | 6 |
| prose tok/s (acceptance) | 27.0 (0.29) | 46.7 (0.60) | 35.9 (0.24) |
| ingest, 13k prompt | 29.0 | 42.1 | 36.3 |
| json, schema | 25.4 | 49.3 | 37.2 |
| recipe cell (acceptance) | 31.1 (0.36) | 52.4 (0.72) | 41.2 (0.34) |
| script cell (acceptance) | 49.9 (0.69) | 62.0 (0.91) | 57.0 (0.48) |
| structured / prose | 0.942 | 1.057 | 1.037 |
| guided / free | 0.961 | 0.991 | 1.041 |
| recipe / prose | 1.152 | 1.123 | 1.148 |
| script / prose | 1.849 | 1.328 | 1.589 |

Three things the table settles:

1. **The recipe cell inflates every model by the same ~12–15 %.**
   sparkDash's prose cell is a mild flatterer, and evenly so; a reader
   can divide any sparkDash ×1 prose number by ~1.13 and land near what
   real prose gets.
2. **The forced numbered-word cell is not even.** 1.33 on Qwen, 1.59 on
   DeepSeek, 1.85 on GLM — the lower a model's natural acceptance, the
   more a forced list flatters it, because the list lifts acceptance to
   0.7–0.9 regardless of where the model started. That is the cell that
   produces the numbers people compare across models, and it ranks them
   by how well they draft filler, not by how fast they write.
3. **Qwen's lead is acceptance.** At 0.60 natural acceptance on three
   draft positions it gets ~2.2 tokens a step; GLM at 0.29 on seven and
   DeepSeek at 0.24 on six get ~1.9 and ~1.6. The prose column orders
   the models the way an operator experiences them, and the acceptance
   column says why.

## Cold prefill, again

GLM's first `ingest` case (uncached, 13,186 tokens) took 13.7 s to
first token (≈ 960 tok/s) against ≈ 815 tok/s on the synthetic arm
later — so *not* cold on this model; the 32-token warm-up was enough
for exl3 where it was not for DeepSeek's vLLM. The warm-up-at-size item
stays open on DeepSeek's evidence.

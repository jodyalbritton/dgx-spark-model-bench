# Run log — 2026-09-09 throughput, round 3 (clean harness)

**Status: RUNNING.**

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

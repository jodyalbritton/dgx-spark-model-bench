# What real-world throughput looks like

Headline tokens-per-second numbers come from a short prompt and a long,
predictable generation with thinking off. That is the best case for a decode
loop and it is a fair way to compare serving configs. It is not what you wait
on when a model is doing work.

This page shows the same three models on the same two DGX Sparks doing the
application task from `COMPARISON.md`: 77 to 102 tool-calling rounds each,
thinking on, context growing every round as the model reads, edits, builds,
and tests. Every number is read from the agent's per-round ledger for the
round-4 sessions; the CSVs are in `results/2026-09-05-r2/raw/rounds/`.

## The shape of a working session

![prompt tokens per round](docs/realworld-context-per-round.svg)

Every round re-reads everything that came before: the system prompt, the
task, every file the model has read, every edit, every test result, and
(for these three) its own reasoning from earlier in the turn. The context
grows from about 5k tokens on round 1 to 60k (GLM), 91k (DeepSeek), or
116k (Qwen) by the end. The median round in each session already carries
40k to 75k tokens of context.

That is the number a serving benchmark's prefill row should be read
against: not "how fast is a 16k cold prefill," but "how fast is a 75k
warm one, every ten seconds, for half an hour."

## What you wait on

![output tok/s per round against context](docs/realworld-toks-vs-context.svg)

| per round, application task | DeepSeek-V4-Flash | Qwen3.8-Flash-Next | GLM-5.3-Flash |
|---|---:|---:|---:|
| rounds | 77 | 102 | 93 |
| context, median / final | 64k / 91k | 76k / 116k | 41k / 60k |
| prefix-cache hit rate over the turn | **97.8%** | 95.2% | 94.9% |
| new (uncached) prompt tokens per round, median | **753** | 3,125 | 1,888 |
| time to first token, median | **1.0 s** | 1.6 s | 3.0 s |
| output tok/s per round, end to end, median | **40** | 35 | 19 |
| same, on rounds under 20k context | 37 | 27 | 14 |
| same, on rounds over 50k context | **40** | 36 | 15 |
| seconds per round, median / p90 | 8.6 / 41 | 8.0 / 33 | **6.2 / 27** |
| rounds longer than a minute | 5 | 2 | 3 |
| output tokens per round, median | 335 | 257 | 71 |
| whole task | 24.0 min | 27.6 min | **18.4 min** |

Three things this table says that a decode benchmark cannot:

**Context size stopped mattering, because of the cache.** DeepSeek's rounds
over 50k tokens of context were no slower than its rounds under 20k, and
Qwen's were faster. With 95 to 98 percent of every prompt served from the
prefix cache, a 91k-token round costs about one second before the first
token, and the rest is generation. This is the single most important
property of these engines for agent work, and it is invisible in a
cold-prefill ladder. The one place it breaks is a round that adds a lot of
new context at once: DeepSeek's slowest round read three large files
(11k new tokens) and took two minutes.

**End-to-end rate is well below the decode headline, and the gap is
model-shaped.** DeepSeek's raw decode peaks near 75 tok/s and its median
working round runs at 40. Qwen's engine is the fastest on this hardware and
its median round is 35, because a fifth of every round is prefill of its
own new reasoning. GLM's median round is 19 tok/s: it produces the fewest
tokens per round (a median of 71), so per-request overhead and prefill
dominate, and its engine's prefill is the slowest of the three. GLM still
finished first, because 93 short rounds beat 77 long ones.

**The long rounds are thinking, not reading.** Each model's slowest rounds
were its planning rounds: Qwen's round 29, 293 seconds and 11k output
tokens, is the one where it laid out the entire application; DeepSeek's
round 29, 116 seconds and 5.5k tokens, is where it designed the main page.
Those rounds are what a "reasoning tok/s" figure would describe, and they
are a handful per session. The other ninety rounds are five to ten
seconds each: a short thought, a tool call, a result.

## How to read a headline number after this

- A single-stream decode figure (55 to 75 tok/s here) is the ceiling for
  one round's generation phase. Multiply the round's output by that and
  add the prefill of whatever is new; on a warm cache the second term is
  small.
- A cold-prefill figure tells you what the first round of a fresh
  conversation costs, or what a round costs after the cache is evicted.
  Under load with several users, that matters more than it does here.
- An aggregate figure across 4 or 16 streams tells you how many such
  sessions the box can carry at once, not how any one of them feels.
- What a session feels like is seconds per round: six to nine at the
  median for all three, with a tail of long rounds where the model
  thinks, and a wall of 18 to 28 minutes for a task of about a hundred
  rounds.

## Method

Source: `turn_usage.round_metrics` in the helm ledger, one entry per
model call, with the backend's usage counts (`prompt_tokens`,
`cached_tokens`, `completion_tokens`, `reasoning_tokens` where reported)
and helm's client-side `duration_ms` and `ttft_ms`. Output tok/s per round
is `completion_tokens / duration_ms`, which includes prefill, network, and
the gateway; it is the rate you experience, not the engine's decode rate.
Rounds with fewer than 64 output tokens are excluded from the tok/s
medians. Time to first token is recorded on every Qwen round and on about
half of the others (the ledger drops it on some tool-call rounds), so the
TTFT medians for DeepSeek and GLM are over the rounds that have it. The
charts are static SVG; the CSVs carry every value.

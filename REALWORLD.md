# What real-world throughput looks like

Headline tokens-per-second numbers come from a short prompt and a long
generation with thinking off. That is a fair way to compare serving
configs (`THROUGHPUT.md` does it three times per model). It is not what
you wait on when a model is doing work.

This page shows the same three models on the same two DGX Sparks doing the
Phoenix application task from `COMPARISON.md`: 90 to 104 tool-calling
rounds each, thinking on at `low`, context growing every round as the
model reads, edits, builds, and tests. Every number is read from the
agent's per-round ledger for the baseline sessions
(`results/2026-09-10-baseline/raw/rounds/`), exported by
`design/tools/export_rounds.py`.

## The shape of a working session

![prompt tokens per round](docs/realworld-context-per-round.svg)

Every round re-reads everything that came before: the system prompt, the
task, every file the model has read, every tool result, every edit, and
its own reasoning from earlier in the turn. The context grows from about
6k tokens on round 1 to 59k (GLM), 117k (DeepSeek) or 131k (Qwen) by the
end. The median round already carries 46k, 86k or 104k tokens.

That is the number a serving benchmark's prefill row should be read
against: not "how fast is a 13k cold prefill," but "how fast is a 100k
warm one, every seven seconds, for half an hour."

## What you wait on

![output tok/s per round against context](docs/realworld-toks-vs-context.svg)

| per round, Phoenix application | GLM-5.3-Flash | Qwen3.8-Flash-Next | DeepSeek-V4-Flash |
|---|---:|---:|---:|
| rounds | **90** | 103 | 104 |
| context, median / final | 46k / 59k | 104k / 131k | 86k / 117k |
| prefix-cache hit rate over the turn | 93.5 % | 94.7 % | **98.1 %** |
| new (uncached) prompt tokens per round, median | 2,497 | 3,625 | **653** |
| time to first token, median | 3.5 s | 2.1 s | **1.2 s** |
| decode tok/s per round, median | 27.3 | 43.2 | **49.8** |
| output tok/s per round, end to end, median | 18.3 | 30.2 | **39.7** |
| same, on rounds over 50k context | 14.8 | 30.2 | **40.5** |
| seconds per round, median / p90 | **5.7 / 26** | 7.7 / 38 | 6.5 / 31 |
| rounds longer than a minute | 3 | 8 | 5 |
| output tokens per round, median | 68 | 194 | 227 |
| reasoning share of output | 35 % | 66 % | 60 % |
| whole task | **17.0 min** | 32.9 min | 28.4 min |

Three things this table says that a decode benchmark cannot:

**A 100k-token context costs almost nothing per round.** Prefill alone
would say a round carrying 117k tokens is many times more expensive than
one carrying 20k. It is not, because 93 to 98 percent of every prompt is
served from the prefix cache and only the new tokens are prefilled:
DeepSeek's median round adds 653 tokens to an 86k context and reaches
first token in 1.2 seconds. Its rounds over 50k context run at 40.5 tok/s
end to end, no slower than the whole. The cost of context is invisible in
a cold-prefill ladder, which measures the case the cache exists to avoid,
and it is nearly invisible here too.

**Per-round decode is not the prose headline, and the gap runs both
ways.** DeepSeek decodes prose at 37 tok/s on the throughput bench and its
agent rounds at 50, because code and tool JSON accept better on its draft
head than prose does. Qwen decodes prose at 47 and its rounds at 43. GLM is
at 27 either way. End to end, with prefill and the round's overhead on
the clock, the three land at 40, 30 and 18. Qwen has the fastest engine
here and the middle end-to-end rate because it carries the largest
per-round prompt (3.6k new tokens on a 104k context) and thinks on every
round. GLM's 18 is its engine: the slowest prefill of the three on 2.5k
new tokens a round, and the fewest output tokens to amortise it over.

**The long rounds are thinking, not reading.** Each model's slowest rounds
were its planning rounds: Qwen's round 30, 360 seconds and 14.9k output
tokens, is where it laid out the application; DeepSeek's rounds 11 and
59, 168 and 205 seconds, are its two plans; GLM's longest round is 82
seconds. Those rounds are what a "reasoning tok/s" figure would describe,
and there are three to eight of them per session. Most of the other rounds
are five to eight seconds: a short thought, a tool call, a result.

## The same sessions on the other two tasks

| | GLM | Qwen | DeepSeek |
|---|---:|---:|---:|
| **design site**: rounds · wall | 106 · 18.7 min | 85 · 29.0 min | 95 · 26.3 min |
| context, median / final | 56k / 85k | 130k / 154k | 111k / 134k |
| prefix-cache hit rate | 95.2 % | 95.0 % | **97.9 %** |
| end-to-end tok/s, median | 21.9 | 29.6 | **36.8** |
| seconds per round, median | 6.2 | 8.0 | **6.0** |
| **JavaScript app**: rounds · wall | 42 · 7.6 min | 30 · **6.2 min** | 33 · 6.7 min |
| context, median / final | 22k / 32k | 22k / 29k | 24k / 30k |
| prefix-cache hit rate | 86.8 % | 81.4 % | **93.6 %** |
| end-to-end tok/s, median | 19.5 | 36.3 | **49.1** |
| seconds per round, median | 5.4 | 8.6 | **4.9** |

The order holds on every task. The JavaScript app is a short session with
a small context, and the cache-hit rate falls to 81 to 94 percent because
each round is a larger share of a small prompt; the end-to-end rates rise
for the same reason.

## How to read a headline number after this

- A single-stream decode figure is the ceiling for one round's generation
  phase, and only for the kind of text it was measured on. Prose (26, 47
  and 37 tok/s here) is the honest one for writing; agent rounds run above
  it on DeepSeek and below it on Qwen.
- A cold-prefill figure tells you what the first round of a fresh
  conversation costs, or what a round costs after the cache is evicted:
  13.6, 4.8 and 8.4 seconds for 13k tokens here. Under load with several
  users, that matters more than it does for one seat.
- What a session feels like is seconds per round: six to eight at the
  median for all three, with a tail of long rounds where the model thinks,
  and a wall of 17 to 33 minutes for a task of 90 to 104 rounds.

## Method

Source: `turn_usage.round_metrics` in the helm ledger, one entry per
model call, with the backend's usage counts (`prompt_tokens`,
`cached_tokens`, `completion_tokens`, `reasoning_tokens` where reported)
and helm's client-side `duration_ms` and `ttft_ms`. Output tok/s per round
is `completion_tokens / duration_ms`, which includes prefill, network, and
the gateway; it is the rate you experience. Decode tok/s per round is
`(completion_tokens − 1) / (duration_ms − ttft_ms)`, the same formula as
the throughput bench. Rounds with fewer than 64 output tokens are excluded
from the tok/s medians. Time to first token is recorded on every Qwen
round and on most of the others (the ledger drops it on some tool-call
rounds), so the TTFT medians for DeepSeek and GLM are over the rounds that
have it. `design/tools/export_rounds.py <round>` writes the CSVs from
helm's dev database; `design/tools/realworld_charts.py <round>`
regenerates the charts; the CSVs carry every value.

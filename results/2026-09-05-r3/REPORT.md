# Round 2026-09-05-r3 (round 5) — report: all three models at their maximum effort

Written 2026-09-06 from this round's `RUNLOG.md`, `RESULTS.md`, the raw
rows and per-round reasoning sidecars, the per-round ledger exports under
`raw/rounds/`, the generated apps, and the harness screenshots. Round 4
(`results/2026-09-05-r2/`) is the same task at effort `low` and is the
comparison throughout.

**Protocol.** Same 17 fixtures and the same application task as round 4,
with four changes: effort `max` (Qwen's template has no `max`; the gateway
clamps to its ceiling `xhigh`), the app cap raised from 128 rounds / 60 min
to 150 / 90, a "last call" of up to four rounds when the cap is hit so a
finished model can write its summary, and one sentence added to the app
prompt: when your own tests and `mix precommit` pass, reply; do not
re-verify. The reasoning echo from round 4 stays on.

## 1. Results

| | GLM-5.3-Flash | Qwen3.8-Flash-Next | DeepSeek-V4-Flash |
|---|---:|---:|---:|
| effort on the wire | `max` | `xhigh` (its ceiling) | `max` |
| fixtures | 17/17 ¹ | 16/17 | 17/17 |
| fixture rounds / wall | 92 / 1,372 s | 120 / 932 s ² | 92 / **906 s** |
| fixture reasoning tokens | 18.8k | 15.9k | 24k |
| app | 19/19 done | 19/19, cap + last call | 19/19 done |
| app rounds | **90** | 152 | 137 |
| app wall | **39.0 min** | 62.7 min | 44.6 min |
| app output / reasoning tokens | **49k / 31k** | 141k / 69k | 98k / 59k |
| uncached prompt tokens | 199k | 677k | **162k** |
| prefix-cache hit | 96.7% | 96.7% | **98.8%** |
| context, median / final | 75k / 100k | 147k / 156k (peak 223k) | 112k / 158k |
| tests written / composites | 21 / 2 | **43 / 7** | 17 / 3 |
| failed tool calls | **3** | 4 | 22 |
| product | Windrose, trail maps | Lodestar, pipeline launches | Hearth, family lists |

¹ One of GLM's 17 passes (`visible_test_lies`) read a reference solution
that a staging bug had left beside the buggy file since round 1; the bug
was found and fixed during this round, DeepSeek was re-run from scratch on
the fixed staging, Qwen ran on it, and GLM's one fixture is re-run when it
is next loaded. No other pass in rounds 4 or 5 shows such a read.
² Qwen's `percentile` row is a clean re-run after the original session's
first response contained text from a different session six minutes
earlier on the same server: a serving incident, not a model result.

All three complete the application at their ceiling, as all three did at
`low`. The checklist is saturated; what `max` changed is how they work.

## 2. What effort bought each model

Same task, same model, `low` (round 4) → `max` (round 5):

| | GLM | Qwen | DeepSeek |
|---|---|---|---|
| app rounds | 93 → 90 | 102 → 152 | 77 → 137 |
| app wall | 18.4 → 39.0 min (2.1×) | 27.6 → 62.7 min (2.3×) | 24.0 → 44.6 min (1.9×) |
| output tokens | 20k → 49k | 59k → 141k | 51k → 98k |
| tests written | 9 → 21 | 18 → 43 | 10 → 17 |
| composites | 2 → 2 | 2 → 7 | 2 → 3 |
| failed tool calls | 9 → 3 | 2 → 4 | 5 → 22 |
| fixture misses | 0 → 0 | 1 → 1 (same fixture) | 0 → 0 |

**Effort bought thoroughness and identity, not correctness.** Every score
that the bench grades was the same at both settings for every model. What
moved: two to five times the tests, more registered composites, and pages
with a distinct visual identity where the `low` pages were closer to the
template's look. What it cost: about twice the wall for everyone, and two
to two and a half times the output tokens.

**GLM** converted effort into fewer mistakes rather than more rounds. It
planned once, in a single 38k-character reasoning pass on round 15, wrote
files within two rounds of that, and made three failed tool calls in 118.
Its rounds are the slowest individually (11 s median; its engine's prefill
is half the others') but there are only 90 of them and they carry half the
output. It finished first by a wide margin and was the only model whose
`max` run did not need the raised cap.

**DeepSeek** converted effort into planning and doubt. Two reasoning
blocks of 31k and 25k characters before its first file write on round 50
(round 24 at `low`); fifteen rounds polling background jobs; twelve failed
`todo` calls setting items that did not exist; three foreground timeouts;
one refused read outside the sandbox. Its per-round cost stayed flat (6.5 s
median, 98.8% cache at a 158k context), so the doubling of wall is
entirely a doubling of rounds. Your marker count from the sidecars puts
its "wait / actually / hmm" density at 27 per 10k characters against 18
for GLM at either effort: a trait, not an effort effect; `max` doubled the
volume and left the density alone.

**Qwen** converted effort into verification. The app and its 43-test suite
were done by about round 110. It then spent 30 rounds building its own
browser rig: a puppeteer script it tried to write to `/tmp` (refused by
the sandbox), then installed through bash, to drive the signup form itself
rather than through the `preview` tool it had already used seven times. It
never ran `mix precommit` before starting that work, so the stopping
instruction never fired; the cap did, and the last call closed the turn
properly with a summary. Its rounds are the heaviest of the three: 13 s
median, 147k median context, 3k new tokens per round, one 11.6k-token
reasoning block on round 20 that took 323 s. Its output for the task was
141k tokens, nearly three times GLM's.

## 3. Fixtures at `max`

Same 92 rounds for GLM and DeepSeek, 120 for Qwen; wall up for everyone
because every round now thinks. Effort landed unevenly on small tasks:

- GLM spent 4.2k reasoning tokens and 216 s on `visible_test_lies` (a
  one-regex fix) and 3.8k on `split_bill`; at `low` those took 16 and 28 s.
- DeepSeek spent 5.1k tokens and 11 rounds on `safe_echo`, exploring shell
  escape behaviour at length before writing the quoting, and 3.6k on
  `nth_one_based`, a one-line off-by-one.
- Qwen spent 4.6k tokens and 232 s on `lru_cache`, which it had solved in
  20 s at `low`.
- Qwen's one miss, `safe_echo_exact`, is the same miss as round 4 at `low`:
  `String.trim_trailing` removes every trailing newline where the spec
  keeps all but one. Its reasoning asked "removes only ONE?" and answered
  wrong. Two efforts, same answer: a stable trait, and the fixture exists
  to catch exactly it.

Nobody was wrong anywhere else. On the fixtures, `max` is mostly overhead.

## 4. What the round says about each model

**GLM-5.3-Flash at `max` is the best agent result on the board for this
task**: same checklist as the others in the fewest rounds, least wall,
half the tokens, and a tenth of the tool failures, with 21 tests and a
page with a strong identity. Two caveats. It is one run. And its
`visible_test_lies` pass is awaiting a clean re-run.

**DeepSeek-V4-Flash at `max` finishes, which its `high` run in round 3 did
not**, and finishes with more tests and one more composite than at `low`,
at twice the price. The cheapest way to run DeepSeek is still `low`: 24
minutes, 5 failed calls, 19/19. At `max` it is a faster engine driven with
less discipline than GLM's.

**Qwen3.8-Flash-Next at `xhigh` is the most thorough and the most
expensive**: 43 tests and 7 composites, the only run to build its own
browser verification, and the only run to reach the cap. Its context peaked
at 223k tokens, which the engine handled at 36 tok/s end to end, and it
still repeated its one fixture miss. If the stopping instruction had fired
(it needed `mix precommit` to run first) the app was done at about round
110 and 45 minutes.

## 5. Harness notes from this round

Three things surfaced that affect how earlier rows should be read:

1. **The `reference.ex` staging leak.** Every fixture directory since
   round 1 carried the control solution next to the buggy file. Sidecars
   (rounds 4 and 5) show one contaminated pass, GLM's round-5
   `visible_test_lies`; rounds 1 to 3 have no sidecars and cannot be
   audited. Fixed mid-round; DeepSeek and Qwen ran on the fix.
2. **Qwen's cross-session contamination** on `percentile`: the first
   response continued a conversation from a different session on the same
   vLLM, once in about 120 requests, with prefix caching on. Re-run clean.
   Worth a note in the serving config's history.
3. **Effort vocabulary.** Qwen's template rejects anything but `low`,
   `medium`, `xhigh` with a 400. The gateway now clamps to the highest
   accepted grade at or below the request, so `max` reaches Qwen as
   `xhigh` and is recorded as such.

Two helm items: `read` crashed twice on a malformed argument shape from
Qwen (a tool should return an error), and `read_artifact` was handed an id
from another session (refused correctly).

## 6. Where the data is

Raw rows and the v3 re-grade for GLM under `raw/`; per-round reasoning
sidecars under `raw/reasoning/`; per-round ledger exports (context, cache,
TTFT, tok/s, seconds per round) under `raw/rounds/`; the superseded first
GLM `max` attempt (no stopping instruction, 128-round cap) under
`raw/superseded/`; the three apps under `work/`; screenshots under
`screenshots/`. `DESIGN_REVIEW.md` in this folder describes the three
pages without ranking them.

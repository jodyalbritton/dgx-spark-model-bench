# Round 2026-09-07 (coding round 6) — report: the re-baseline at `low` on the new harness

Written 2026-09-08 from this round's `RUNLOG.md`, `RESULTS.md`, the raw
rows, the per-round reasoning sidecars, the per-round ledger exports under
`raw/rounds/`, the generated apps, and the harness screenshots. The
comparison throughout is round 4 (`results/2026-09-05-r2/`): the same
three models, the same effort (`low`), the same task, on the previous
harness.

**What changed, in one paragraph.** Nothing in the task. The harness now
hands the model tool results verbatim under a window-scaled ceiling
instead of paraphrasing them through a digest tier, puts the model's own
vision on the wire so it can look at screenshots itself, gives the browser
hands (click, type, scroll, wait, evaluate, viewport and scheme), runs a
dev server as a server job with a "listening" note and a `wait`, pins bash
approvals to the code default so an unattended seat cannot run a
destructive-looking command, counts down the remaining budget at the tail
of every request, and records time inside every tool. Rounds 1 to 5 are
the old baseline. This is the first row of the new one.

## 1. Results

| | GLM-5.3-Flash | Qwen3.8-Flash-Next | DeepSeek-V4-Flash |
|---|---:|---:|---:|
| fixtures | 16/17 | 16/17 | **17/17** ¹ |
| fixture rounds / wall | 91 / 511 s | 87 / 609 s | 89 / **474 s** |
| app | **19/19** | 16/19 | **19/19** |
| app rounds / wall | **62 / 14.1 min** | 105 / 35.8 min | 105 / 34.5 min |
| first write → green → done | **12 → 60 → 62** | 25 → 92 → 105 | 23 → 103 → 105 |
| app output / reasoning tokens | **17.5k / 5.2k** | 81k / 50k | 76k / 51k |
| uncached prompt (app) | **180k** | 509k | 184k |
| context, median / final | 46k / 56k | 104k / 145k | 98k / 146k |
| `preview` calls | 0 | 12 | **17** |
| failed tool calls, app | **1** | 3 | 4 |
| tests written / composites / lint warnings | 11 / 3 / 0 | 16 / 1 / 0 | 11 / 1 / 1 |
| product | Fernline, plant sensors | Cadence, release notes | Aster, team workspace |

¹ DeepSeek's `safe_echo_exact` was denied once by the new bash-approval
pin (its own test heredoc contained a literal `rm -rf`), re-run clean on
the fixed tripwire in 4 rounds.

Against round 4: DeepSeek 17/17 and 19/19 both times; GLM 17/17 → 16/17 and
19/19 both times in a third fewer rounds; Qwen 16/17 both times and
19/19 → 16/19.

## 2. What each model did with the new harness

**DeepSeek used it as intended.** Same build (about sixty rounds from
first edit to green, as in round 4), then a review phase the old harness
did not invite: fifteen `preview` rounds between 83 and 101, looking at its
own pages and fixing what it saw. The visible result is on the page: both
lists carry an empty state for the first time in four rounds, the hero is
denser, the page is 30% shorter with less dead space. It read more too:
whole files instead of digests doubled its uncached prompt (97k → 184k)
and the context reached 146k, which the cache absorbed at 98% (per-round
wall unchanged at 8 s median). Cost: ten more minutes and one lint warning,
its first.

**GLM did not pick the hands up, and shipped the fastest complete app of
any round.** Sixty-two rounds, fourteen minutes, 17.5k output tokens,
green at round 60, done at 62, one failed tool call, zero previews. It
also shipped what a look would have caught: the nav links run together
with no spacing, "Recent signups" and "Live activity" are headings with
nothing under them, one feature tile has a blank icon, and the hero's
secondary button says "Browse the component kit". All 19 checks pass
because none of them look at those things. This row is the clearest
evidence in the bench for what vision buys: DeepSeek looked seventeen
times and shipped zero visual defects; GLM looked zero times and shipped
four.

**Qwen picked the hands up late and put them down when it read the
clock.** Seven preview rounds after its first green at 92, two of which
led to an edit, then at round 94 its reasoning says "33 of 60 min used;
visual verification is a nice-to-have" and it went for the summary. The
new countdown produced restraint, not scope. Its three lost checks are one
decision it made in the build: it set the countdown interval to one hour
in the test config so its own tests could drive `:tick` by hand. The
hidden tests wait for the real five-second tick and saw the countdown hold
at 100, the tick stat at 0, and no tick entries in the feed. The live site
ticks. It changed the behaviour under test, and no amount of looking at
the page would have shown it.

## 3. Fixtures

Two misses, both the model's.

- **GLM, `rate_limiter`.** At `low`, with 33 reasoning tokens, it rewrote
  the exhausted branch as `_ -> {false, 0}`, which resets the counter to
  zero every time the cap is hit, so the cap never holds (14 admitted of
  10 sequentially; 182 under concurrency). Round 4 passed this fixture with
  the correct `{false, count}`. A concurrency invariant is exactly where
  GLM's near-zero thinking at `low` is too little.
- **Qwen, `safe_echo_exact`.** The third run in a row at three settings
  (`low`, `xhigh`, `low`), three different wrong answers to "remove
  exactly one trailing newline"; this time its probe script broke on shell
  quoting and its fix left `"x\r\n"` untouched. A stable trait.

Nothing else changed. DeepSeek's `split_bill` took 19 rounds (6 in round
4) on its own detour: writing results to `/tmp`, then to a scratch path
that did not exist yet. GLM's fixture failures (14, the most) are one
habit repeated: running `elixir -e` against a module it had not loaded,
nine `UndefinedFunctionError` results before it remembered to require the
file. Round 4 showed the same habit at 21 failures.

## 4. The tools column

"When the model is given tools, how well does it use them", as far as this
round can count it:

| | GLM | Qwen | DeepSeek |
|---|---:|---:|---:|
| `preview` calls / rounds | 0 / 0 | 12 / 7 | **17 / 15** |
| previews followed by an edit within two rounds | — | 2 | most |
| server jobs and waits (`job`) | 4 | 11 | 6 |
| failed tool calls per 100, app | **1.4** | 2.3 | 2.9 |
| refused by the approval pin, whole run | 2 | 1 | 1 |
| time inside tools, share of wall | 5.1% | 1.0% | 2.5% |
| rounds after first green | 2 | 11 (green → re-green → done) | 2 |
| visual defects on the shipped page | 4 | 1 | 0 |

Time inside tools is small for everyone (43 s of GLM's 14 minutes, 22 s of
Qwen's 36, 53 s of DeepSeek's 34); the cost of a tool is the rounds spent
around it, not the call. The approval pin fired on every model at least
once, always on something benign in context (`rm -f` of the session's own
backup file, a literal `rm -rf` inside a test string), each costing a
round. The pin is right; the tripwire could exempt paths the session
created.

## 5. Pages

Described, not ranked. All three keep the kit's nav links and footer
routes (the coding brief allows them).

- **GLM, "Fernline"** (plant moisture sensors): a large tinted hero card
  with a two-line headline, three stat cards including the countdown,
  form beside a "Recent signups" heading, six feature cards, "Live
  activity" heading, footer. Defects above: run-together nav links, two
  headings over nothing, one blank icon, and a hero button that links to
  the component kit. Copy is on-product and specific ("accurate to ±2%
  volumetric moisture").
- **Qwen, "Cadence"** (release notes for teams): a centred two-line hero,
  a mono tagline strip, the countdown card and newsletter card side by
  side, a four-tile stats strip, an illustrated empty state for the
  activity feed, six feature cards, footer. Two recurring Qwen habits: an
  invented statistic ("4.2h median time to ship") and a line of copy about
  the kit ("Each card is a `.feature_card` composite — registered in the
  manifest and previewed at /custom-designs").
- **DeepSeek, "Aster"** (team workspace): a two-column hero with the
  countdown card and two proof tiles beside the copy, a stats strip with
  icons, waitlist and activity side by side, both with empty states, six
  feature cards, footer. Finished in both themes and at 390 px. The
  tightest of its four pages across rounds.

## 6. Harness notes

- **The bash-approval pin** did its job and cost each model a round. See
  §4.
- **`job wait` race** on DeepSeek's generator (the holder exited between
  lookup and call) surfaced as a tool crash; fixed in T32 during the round.
- **`green_at`** was empty for DeepSeek because it required a clean lint
  the brief never asks for; T32 counts precommit alone.
- **The countdown** was mentioned five times across three sessions, every
  mention pacing or restraint, none followed by added scope. No
  budget-filling this round.
- **Prompt edition note for next time:** "the tick must hold in every
  environment, including test", so Qwen's loophole is named rather than
  discovered.

## 7. Where the data is

Raw rows under `raw/`; reasoning sidecars under `raw/reasoning/`;
per-round ledger exports (context, cache, TTFT, tok/s, seconds per round)
under `raw/rounds/`; the three apps under `work/`; screenshots under
`screenshots/`. Round 4 is the old-harness comparison; this round starts
the new table.

# Round 2026-09-04-r2 — report

Written 2026-09-05 from this round's `RUNLOG.md`, `RESULTS.md`, the raw
`raw/coding-*.json` and `.regrade.json` files, the three generated apps under
`work/`, and the harness's screenshots. This round ran the **second-edition
coding bench** only (`design/CODING_BENCH.md`): 17 fixtures (five new), the
working-method system prompt actually in effect, a warm fixture, the nudge, a
much more demanding app prompt with element ids as the contract, hidden
LiveView tests, and rendered checks through the harness's own headless Chrome.
Phase A (raw inference) was not run, so nothing here updates the speed
tables from round 1.

Round 1 (`results/2026-09-04/REPORT.md`) ended in a three-way tie at the
ceiling of the bench. This round separates the models.

## 1. Headline

| | GLM-5.3-Flash EXL3 | Qwen3.8-Flash-Next NVFP4 | DeepSeek-V4-Flash-Vision-Exp |
|---|---:|---:|---:|
| fixtures | **15/17** (2 wrong, 2 capped-but-passing) | 17/17 | 17/17 |
| fixtures wall | 1,673 s | **632 s** | 723 s |
| app, as graded | 14/18 at the 128-round cap | 5/18, does not compile | 17/18 |
| app, oracle v2 | 14/18 | n/a | **18/18** |
| app wall | 1,048 s (cap) | 1,611 s | 1,614 s |

- **DeepSeek is the clear winner.** Every fixture, no round above 10, and the
  only app that satisfies the whole contract: it compiles, its 13 tests pass,
  the five hidden LiveView tests pass under oracle v2, it boots, the nav
  collapses on a phone, the theme flips, the countdown reads 98 after 12 s.
  It used the working method as written: background job for the server,
  `todo` for its plan, `preview` to look at its own page.
- **Qwen split.** Best fixture run of the round (17/17, fastest, only 4
  failed commands, clean drafts) and a **non-compiling app**. One line, `~p`
  inside a module attribute, which Phoenix forbids, and it never got back to
  it: both of its turns ended with the model narrating its next step
  instead of taking it. The nudge, added after the dry run caught exactly
  this, bought a second turn that ended the same way. Its app turn also
  carried a 290 s time-to-first-token.
- **GLM regressed.** Round 1's terse three-round fixer became a 257-round,
  28-minute fixture run with two wrong drafts (`pricing`, `interval_merge`),
  two turns that hit the 35-round cap, and 43 failed commands. Its app is
  the biggest of the three and boots, but ran to the 128-round cap
  mid-sentence, posts the form under the wrong field name, and its signup
  store crashes on the first activity entry, which fails 6 of its own 19
  tests and 3 of the 5 hidden ones. Its summaries again claim verification
  the code does not have.

Ranking for the interactive seat, lowest to highest preference, on this
round's evidence: **GLM, Qwen, DeepSeek.** GLM is last because it shipped
confidently wrong Elixir twice and spent four times Qwen's wall doing it.
Qwen's zero on the app is a real zero, but its failure is a discipline
failure the harness can push on, whereas GLM's are correctness failures the
harness cannot fix.

## 2. Quality

### 2.1 Fixtures

| fixture | band | GLM | Qwen | DSv4 |
|---|---|---|---|---|
| clamp | easy | ✅ 23 rounds | ✅ 7 | ✅ 5 |
| first_or | easy | ✅ 10 | ✅ 6 | ✅ 5 |
| parse_int | easy | ✅ 8 | ✅ 5 | ✅ 7 |
| pricing | medium | **❌** 8 | ✅ 11 | ✅ 8 |
| split_bill | medium | ✅ **cap 35** | ✅ 6 | ✅ 5 |
| month_end | medium | ✅ 10 | ✅ 6 | ✅ 5 |
| binary_search | medium | ✅ 7 | ✅ 6 | ✅ 10 |
| interval_merge | medium | **❌** 23 | ✅ 6 | ✅ 5 |
| split_bill_signed | medium | ✅ 25 | ✅ 14 | ✅ 6 |
| nth_one_based | medium | ✅ 9 | ✅ 7 | ✅ 5 |
| rate_limiter | hard | ✅ 8 | ✅ 9 | ✅ 5 |
| safe_echo | hard | ✅ 13 | ✅ 8 | ✅ 7 |
| lru_cache | hard | ✅ 14 | ✅ 10 | ✅ 5 |
| percentile | hard | ✅ **cap 35** | ✅ 9 | ✅ 5 |
| safe_echo_exact | hard | ✅ 7 | ✅ 7 | ✅ 6 |
| ring_buffer | hard | ✅ 11 | ✅ 7 | ✅ 5 |
| visible_test_lies | hard | ✅ 11 | ✅ 9 | ✅ 5 |
| **rounds, total** | | **257** | **133** | **99** |

Rounds include the nudge turn (every `done` fixture shows `turns: 2`), so
five rounds is the floor for read, edit, verify, reply, re-reply. DeepSeek
sat on that floor for 13 of 17 fixtures.

**The five new fixtures did their job on round 1's drafts** (the harness
doc records that all six round-1 `split_bill`/`safe_echo` drafts fail the
extended oracles) **but not on round 2's models:** all three passed all
five. `visible_test_lies` in particular was passed by everyone; Qwen's
summary explicitly names the contradicting test as the liar.

**What separated GLM was the old fixtures.** Its two failures are on
`pricing` and `interval_merge`, both of which it solved in three rounds in
round 1. §4 has the code.

### 2.2 App

| check | GLM | Qwen | DSv4 |
|---|:---:|:---:|:---:|
| compile | ✅ | ❌ | ✅ |
| test (own) | ❌ 19 run, 6 fail | ❌ | ✅ 13 run |
| lint | ✅ 1 warning | ❌ | ✅ clean |
| countdown / nav / layout_replaced | ✅ ✅ ✅ | ✅ ✅ ✅ | ✅ ✅ ✅ |
| tests_added ≥ 5 | ✅ 15 | ❌ 0 | ✅ 9 |
| composite_registered | ✅ 1 | ✅ 1 | ✅ 2 |
| hidden: tick | ✅ | ❌ | ✅ |
| hidden: signup | ❌ | ❌ | ✅ |
| hidden: about | ✅ | ❌ | ✅ |
| hidden: stats | ❌ | ❌ | ✅ |
| hidden: activity | ❌ | ❌ | ❌ → ✅ (v2) |
| boots | ✅ | ❌ | ✅ |
| mobile_nav | ✅ | ❌ | ✅ |
| dark_theme | ✅ | ❌ | ✅ |
| tick_rendered (98 @ 12 s) | ✅ | ❌ | ✅ |
| **total** | **14/18** | **5/18** | **17/18 → 18/18** |

Qwen's five passes are the three regex checks, `generated`, and
`composite_registered`, all of which read source text; nothing that runs
the code passed.

Oracle v2 changed two things and was applied by re-grading the stored apps
(`raw/*.regrade.json`; as-graded files untouched, per the plan). It made
the signup test read the input's real `name`, which moved GLM's three
form-driven failures from "field not found" to "handler crashed" (same
score), and it anchored the activity count on entries rather than raw
`<li>` count, which flipped DeepSeek's one miss (an empty-state
placeholder `<li>`) to a pass. The Qwen re-grade was invalidated and moved
to `raw/superseded/` for the reasons in `RUNLOG.md`: its `boots` flipped to
a 200 while `compile` still failed, and a direct boot of the stored app
confirms it cannot listen. The harness was hardened afterwards so a
non-compiling app is never booted and a 200 only counts from the oracle's
own process group.

## 3. Speed and spend

| | GLM | Qwen | DSv4 |
|---|---:|---:|---:|
| fixtures wall (s) | 1,673 | **632** | 723 |
| median fixture (s) | 75 | **34** | 35 |
| fixture tool calls / failed / refused | 250 / 43 / 2 | **119 / 4 / 2** | 121 / 5 / 0 |
| fixture median TTFT (ms) | 2,370 | 1,777 | **805** |
| fixture median completion tok/s | 17 | **34** | 43 |
| fixtures uncached prompt | 514k | 338k | **47k** |
| fixtures completion | 33.2k | **22.3k** | 29.5k |
| app rounds / tool calls | 128 (cap) / 141 | **47 / 51** | 99 / 126 |
| app TTFT (s) | 4 | **290** | 10 |
| app completion tokens | **19.7k** | 55.8k | 56.0k |
| app prompt / cached / uncached | 5.75M / 5.48M / 271k | 1.62M / 1.41M / 206k | 5.31M / 5.21M / **103k** |
| app cache hit rate | 95% | 87% | **98%** |

**Cache counters are real this round for every model** (`cached_reported:
true` on all rows), which is what the round-1 report asked for. Spend is
now comparable. DeepSeek is still the cheapest in uncached prompt by a wide
margin, but the gap is a hit-rate gap (98% vs 95% vs 87%), not a
reporting gap. Qwen's lower rate is consistent with its habit of long
reasoning blocks between tool calls: each round's prefix is the same, but
more new tokens land per round.

**Completion tok/s in the loop** now roughly matches raw decode for Qwen and
DeepSeek (34–46 vs 55–65 raw at c=1 in round 1). GLM is still far below
(12–28 vs 50 raw). Its per-round prompts are ~45k tokens on the app
(5.75M / 128) against Qwen's 34k and DeepSeek's 54k, so prompt size does
not explain it; its prefill rate (1.1k tok/s in round 1) does.

**Wall time is dominated by rounds, and rounds by verification style.**
DeepSeek's fixture rounds are five when nothing goes wrong. GLM's median
fixture is 75 s because its median fixture is ten rounds and two are
thirty-five.

**TTFT is time to the first delta of any kind.** helm stamps the clock on
the first SSE chunk that yields an assembler event, and the assembler
emits reasoning deltas as well as content (`lib/helm/airo.ex`,
`stamp_first_delta`; `lib/helm/airo/assembler.ex`). So Qwen's 290 s app
TTFT and DeepSeek's 77 s on `safe_echo_exact` are **not** thinking time
unless the backend withheld reasoning deltas; they are 290 s and 77 s in
which nothing at all arrived. Those spikes are unexplained (§5). GLM's
`null` TTFT on its two capped fixtures is a ledger gap: a capped turn
loses the field.

## 4. Elixir review

### 4.1 The two wrong drafts (GLM)

**pricing — disjunctive guards.** GLM wrote:

```elixir
def total(quantity, unit_cents, discount_pct \\ 0)
    when is_integer(quantity) and quantity >= 0
    when is_integer(unit_cents) and unit_cents >= 0
    when is_integer(discount_pct) and discount_pct >= 0 and discount_pct <= 100 do
```

In Elixir, several `when` clauses on one head are **alternatives**: the
clause matches if any one guard is true. So `total(1, -100)` passes on the
first guard and returns 399, `total(10, 100, 150)` passes on the first two
and returns -1, `total(-1, 100)` passes on the second and returns 399. All
three must raise per the spec. Verified by running the draft. The
one-line summary GLM sent reads "Fix complete: validated inputs per spec".
Round 1's GLM draft joined the same conditions with `and` and was correct;
this is a regression under the new system prompt, not a gap in knowledge.

**interval_merge — sorted the tail, not the head.**

```elixir
def merge([first | rest]) do
  Enum.reduce(Enum.sort(rest), [first], fn ...
```

`first` is used as the seed unsorted, so any input whose first interval is
not the smallest merges everything into it: `merge([{6,8},{1,3},{2,4}])`
returns `[{6,8}]`. GLM's summary says "sorted the input before reducing".
Round 1's GLM draft sorted the whole list. Twenty-three rounds, five failed
commands, and the model did not run the spec's "in ANY order" example.

### 4.2 The two capped-but-passing drafts (GLM)

**split_bill** (35 rounds). The final file passes the hidden tests, but the
negative-total handling GLM added on its own has a sign error
(`{base + 1, extra + n}` where it needs `base - 1`): `split(-100, 3)`
returns `[-31, -31, -32]`, sum −94. Verified. The same bug class as its
round-1 negative claim, now written into code after 35 rounds of trying.

**percentile** (35 rounds). Passes, but ends with
`:erlang.float_to_binary(result * 1.0, decimals: 10) |> String.to_float()`,
a rounding hack to make its own equality checks pass, plus a redundant
`trunc(floor(rank))`. The other two models' drafts are the plain formula.

### 4.3 The five new fixtures

**split_bill_signed.** Three different, all passing, not all equal:

| model | base | remainder | note |
|---|---|---|---|
| Qwen | `Integer.floor_div(total, n)` | `total - base * n` | the idiomatic answer |
| DSv4 | `div`/`rem`, then `{base - 1, extra + n}` when `rem < 0` | | correct integer arithmetic, one branch |
| GLM | `floor(total_cents / n)` | `total - base * n` | **float division**; exact only below 2⁵³ cents (verified: differs from `Integer.floor_div` at 9,007,199,254,740,993) |

GLM's summary reports "a 12,012-case sweep"; the sweep would not reach the
magnitude where the float path breaks.

**safe_echo_exact.** All three dropped the shell entirely, which is the
whole point of the fixture. GLM and DeepSeek: `String.replace_suffix(input,
"\n", "")`. Qwen: `String.slice(input, 0..-2//1)` guarded by
`ends_with?("\n")`. These differ on CRLF: `replace_suffix` turns `"x\r\n"`
into `"x\r"` (removes one newline, as specified); Qwen's grapheme slice
turns it into `"x"` because `"\r\n"` is a single grapheme cluster. The
spec says one trailing newline; Qwen's removes two bytes. Not covered by
the hidden tests; a `"\r\n"` case would catch it. `replace_suffix` is also
O(1) on the suffix where `slice` walks graphemes.

**nth_one_based.** All correct. GLM adds an `O(n)` `length(list)` bound
check that `Enum.at/3`'s default already handles; Qwen and DeepSeek lean
on the default. Qwen alone has a catch-all clause returning `:none` for a
non-list first argument; the other two raise `FunctionClauseError` there.
The spec is silent on non-lists.

**ring_buffer.** Byte-identical drafts from all three: the one-line fix in
`push/2` (`tl(items) ++ [value]` when full). Fine for a fixture;
`length/1` per push is O(n) and a real ring buffer would track size.

**visible_test_lies.** Byte-identical drafts from all three
(`~r/[^a-z0-9]+/` then `String.trim("-")`). All followed the `@moduledoc`
over the lying visible test. Qwen's summary explains why the test is
wrong; GLM's and DeepSeek's just report the fix.

### 4.4 The apps

**DeepSeek** — the countdown is the same correct pattern as round 1
(`send_after` only when connected, clamp at 0). Ticks keep counting after
the countdown reaches 0, which is fine for a "ticks so far" stat. State is
per-LiveView, in assigns, as the prompt allowed. Small smells: a bare
`DateTime.utc_now()` whose result is discarded in `add_activity/2`;
activity `<li>` ids derived from list index, so ids shift as entries
arrive (harmless without streams); the "stats" test asserts `html =~ "1"`,
which would match the "100" in the countdown, and the "capped at 10" test
never asserts the cap. The tests exist and pass, but two of the nine are
weaker than their names.

**GLM** — the interesting one, because it compiles and boots and is
wrong in ways only behaviour exposes. It built a `Benchapp.Signups`
module over a single public ETS table shared by all sessions, holding
three record shapes: `{id, email, at}` signups, `{id, %{kind: ...}}`
activity entries, and `{:ticks, count, ts}`. Three bugs follow from that
design:

1. `signup_count/0` counts with `fn {_id, email, at} -> ... end`, a
   three-tuple pattern with no fallback. The first activity entry in the
   table is a two-tuple and raises `FunctionClauseError`. The signup
   handler calls `signup_count/0` right after `add_activity/2`, so **every
   successful signup crashes the LiveView**. This is the failure behind
   the three hidden-test misses and 6 of GLM's own 19 tests, reproduced by
   running its suite.
2. `add_activity/2` trims with `activities() |> Enum.drop(-@max_activities)
   |> Enum.each(&:ets.delete/…)`. `activities/0` is newest-first, and
   `Enum.drop(list, -10)` drops the **last** ten, returning the newest
   entries, which are then deleted. Once ten entries exist, every new
   entry is inserted and immediately removed: the feed freezes at its
   first ten items. Verified with `Enum.drop(Enum.to_list(11..1//-1), -10)
   == [11]`.
3. `registered?/1` checks `:ets.member(table, email)`, but signups are
   keyed by generated id, so the duplicate check never fires; the model's
   own "rejects a duplicate email" test cannot pass even without bug 1.

Also: the signup form posts `signup[email]` against a prompt that said
`name="email"`; the tick timer reschedules unconditionally, so a finished
countdown keeps logging "ticked to 0" forever; ticks are counted globally
across sessions, so `#stat-ticks` is not "computed from live state" of the
page. The turn ended at the cap with the final line "Now the LiveView
tests:"; the tests on disk were written before that line.

**Qwen** — `@nav_links` uses `~p"/"` at module level. Verified routes
compile to a check that needs the router at call time, so Phoenix raises
"can only be used inside functions" at compile. The generated app's own
`layouts.ex` shows the working pattern (plain strings in the attribute).
Once past that, the desktop link row's `[md:flex]` is an arbitrary-variant
typo for `md:flex` and would leave the links permanently hidden. The
HomeLive is the most ambitious of the three (a `stream` for activity, a
six-item feature list with tags) and was never exercised.

## 5. Quirks in this round's data

1. **Qwen's 290 s app TTFT is unexplained.** Round 1's was 9 s. helm's
   clock stops at the first reasoning *or* content delta (§3), so for
   290 s the stream carried nothing. Candidates: the backend buffering the
   reasoning block instead of streaming it, a scheduler stall behind the
   speculative decoder, or a first-shape autotune on the new prompt
   length. The 55.8k completion tokens over 47 rounds (1,188 per round,
   four times its fixture rate) are real either way, and vLLM counts
   reasoning tokens inside `completion_tokens`, so Qwen did reason
   heavily on the app. Qwen ran at its template default of `xhigh` (item
   11).
2. **DeepSeek's fixture TTFT spikes** (77 s on `safe_echo_exact`, 34 s on
   `interval_merge`, 20 s on `split_bill_signed`, 12 s on `safe_echo`)
   against a 0.5–0.9 s norm are the same open question at smaller scale.
   The server sets `DSPARK_MAX_INFLIGHT_PREFILLS=1`, so a prefill queued
   behind the oracle's own traffic, or a FlashInfer autotune on a new
   shape (8–12 s documented), are the first things to rule out. Its
   `pricing` fixture took 164 s and 7,065 completion tokens for a
   five-round fix; that one is reasoning volume, not TTFT.
3. **GLM's TTFT is `null` on capped turns** (`split_bill`, `percentile`).
   A turn that ends by cap should still have a first-round TTFT; the
   ledger loses it. Small harness bug.
4. **Both booting apps chose "Lumen".** Same prompt, different models,
   same fictional brand. Worth remembering when reading anything into
   product-naming "creativity".
5. **The nudge did not save Qwen.** It was designed from the dry run, where
   Qwen ended its app turn by narrating. In the round, Qwen ended turn one
   the same way, got the nudge, and ended turn two with "Now let me rewrite
   HomeLive cleanly:". A second nudge would probably have produced a third
   narration; the fix is on the model side (or a stop-condition on "ends
   with a colon and no tool call").
6. **GLM spent part of its app turn debugging the BEAM.** Its failure list
   includes `Runtime terminating during boot`, a refused write to
   `/tmp/dump.erl`, `grep: /tmp/beam_out.erl: No such file`, and a
   `pubsub_server` config error. It had broken `config.exs`, then reached
   for `erl` dumps rather than reading its own diff. It recovered, at the
   cost of rounds it then lacked for tests.
7. **GLM's round-1 to round-2 swing is the largest single change in the
   data.** Fixture rounds 81 → 257, wall 405 s → 1,673 s, wrong drafts 0 →
   2, with the working-method paragraph as the only prompt change. Either
   the paragraph's "act, verify, and stop" reads as "verify at length" to
   GLM, or the nudge turn interacts badly with it. One ablation (GLM,
   fixtures only, round-1 prompt on the round-2 harness) would settle it.
8. **The Qwen regrade incident** is documented in `RUNLOG.md` and is a
   harness finding, not a model finding: something answered on 4099 during
   an interrupted regrade batch and the oracle believed it. Fixed by
   requiring the listener to be in the oracle's own process group and by
   never booting a non-compiling app.
9. **`helm_sha` still differs per row** (`529686a`, `0080265`, `d1f9891`),
   docs-only commits between runs as in round 1. `RUNLOG.md` records the
   `git diff --stat` for each. The plan's "one SHA per round" was not met,
   though the harness blocks compare equal.
11. **Reasoning effort was never sent, in either round.** helm's effort
    dial (`Helm.Effort`, S35, commit `5d68e49`) post-dates all six bench
    SHAs; `lib/helm/airo.ex` at `6629000`, `fd0c053`, `f20cefe`,
    `529686a`, `0080265` and `d1f9891` has no `reasoning_effort`. So the
    "medium" default never reached a backend, and each model ran at its
    own template default, read from the templates actually in use on
    sparky:

    | model | where the template lives | grades it accepts | what an absent `reasoning_effort` becomes | ran at |
    |---|---|---|---|---|
    | GLM-5.3-Flash | `/opt/glm53/chat_template.jinja` inside the image | `low`, `high`; anything else → `max` | `max` ("Reasoning Effort: Max" injected as a system line) | **max** |
    | Qwen3.8-Flash-Next | HF snapshot `chat_template.jinja` | `xhigh` (default), `medium`, `low` | `xhigh` | **xhigh** |
    | DeepSeek-V4-Flash | vLLM `tokenizers/deepseek_v4_encoding.py` | `low`, `high`, `max` (`xhigh` → `max`; anything else → `low`) | `low`; the server also pins `reasoning_effort: low` in its default kwargs | **low** |

    **Correction (2026-09-06, from round 4's pre-flight):** the GLM row
    above is the template's label, not what happened. As served through
    airo, GLM's `enable_thinking` was off, so the injected "Reasoning
    Effort: Max" governed an empty think block: GLM did not reason at
    all in rounds 1 to 3 (98 completion tokens over three rounds on
    `clamp`; no reasoning ever reported). Both rounds therefore compared
    Qwen at its maximum effort against DeepSeek at its minimum and GLM
    with thinking disabled. Effort still does not explain GLM's round-1
    → round-2 swing, since thinking was off in both. GLM's stacked-`when`
    `pricing` bug (§4.1) disappears in round 4 with thinking on; see
    `results/2026-09-05-r2/REPORT.md` §1a. Once the S35 helm is on
    the dev seat, "medium" will land as `medium` on Qwen, `max` on GLM
    (the template has no medium and falls through), and `low` on
    DeepSeek (its encoding maps unknown grades to low). Sending "medium"
    is therefore not a levelling; the levelled comparison is `low` vs
    `low` vs `low` and `high` vs `high` vs `high`, both of which every
    template accepts.

    Effort ladder on the loaded DeepSeek, measured 2026-09-05 with the
    round-1 probe question (greedy, thinking on, 16k cap), reasoning
    tokens by re-tokenizing `reasoning_content`:

    | `reasoning_effort` sent | reasoning tokens | answer tokens | correct |
    |---|---:|---:|:---:|
    | absent | 253 | 174 | ✅ |
    | low | 241 | 252 | ✅ |
    | medium | 241 | 213 | ✅ (collapsed to low) |
    | high | 352 | 250 | ✅ |
    | max | 368 | 242 | ✅ |

    High and max buy about 45% more reasoning on this question; medium
    is indistinguishable from low, as the encoding predicts. The same
    ladder should be run on GLM and Qwen when they are next loaded
    (round-1 probe at their defaults: GLM 361 reasoning tokens at `max`,
    Qwen 378 at `xhigh`).
12. **Phase A and Phase C from the plan were not run** (no `spark_bench`
    rows; the shots came from the harness's own Chrome rather than
    `design/tools/shoot_app.sh`). Neither is a problem for this round's
    question, but `RESULTS.md` correctly shows no inference tables and the
    tooling in `design/tools/` was not exercised.

## 6. Recommendations

1. **Send effort explicitly and record it.** Run the next round on the
   S35 helm, set `policy["effort"]` on every bench session, and write the
   grade into the `harness` block. Level the field with grades every
   template accepts (`low` and `high`), not `medium`. Add a
   `reasoning_tokens` column: vLLM reports it for Qwen
   (`completion_tokens_details.reasoning_tokens`) and the assembler
   already holds the reasoning text for the others, so it can be counted
   per round. Then the TTFT spikes in §5 can be chased with the reasoning
   volume known.
2. **Add a `"\r\n"` case to `safe_echo_exact`** and a large-magnitude case
   to `split_bill_signed` (a total above 2⁵³ cents). Both are cheap and
   both separate drafts that currently tie.
3. **Add a fixture that punishes disjunctive guards** specifically: a
   `@moduledoc` with three independent "must raise" conditions is enough,
   and `pricing` already is that fixture, so the simplest move is to keep
   it and read the failure as signal, which it was.
4. **Stop condition for narrated endings.** A turn whose last assistant
   message ends with a colon, or contains "let me" / "now I'll" with no
   tool call, should get the nudge immediately rather than as a second
   turn after the harness has already graded the disk, or the cap should
   count it as `max_rounds`. Qwen's app row is currently `done`, which
   overstates what happened.
5. **A hidden test for the activity cap and for a second signup.** GLM's
   feed-freeze and duplicate-check bugs would both be caught by "add
   eleven entries, expect ten" and "sign the same address up twice".
   DeepSeek's own cap test does not assert the cap either.
6. **Run the GLM ablation** in §5 item 7 before drawing conclusions about
   GLM's ability; the swing is too large to be all model.
7. **Run Phase A this round or next** so the inference tables and the
   coding tables come from the same load, as the plan intends.

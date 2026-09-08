# Run log — round 2026-09-07 (coding round 6: the re-baseline at `low`)

The first coding round on the T29–T31 harness (helm `docs/sprints/T29-the-primary-sees.md`, `T30-server-jobs-and-browser-hands.md`, `T31-bench-hygiene.md`; the research behind them in `docs/research/bench-sessions-review.md`). Per T31 decision 4, rounds 1–5 stand as the pre-T29 baseline and this round starts a new one: the harness changed what every model sees and can do, so its rows are not a continuation of the old tables.

What is new for the models since round 5, in one breath: results arrive verbatim under a window-scaled ceiling instead of paraphrased by the digest tier (DeepSeek's ceiling here: 52k tokens); images ride the model's own wire; `AGENTS.md` lands whole; `todo` infers add; `proc` is off the wire for an unbound session; `edit` tolerates indentation; a dev server is a server job with no deadline and a `listening on :PORT` note; `job wait`; the browser's hands (click, type, scroll, wait_for, evaluate) and a state line on every preview result; a countdown at the tail of every request; the bench pins bash approvals to the code default on any seat; a scratch dir; every tool result carries its duration; the record carries `green_at`, tool time and the model's diff.

Protocol otherwise as round 4 (`results/2026-09-05-r2/`): effort `low` for every session, fixtures (17) then the app task, one warm session before the app prompt, round caps 35 (fixture) / 128 (app), clocks 10 / 60 min, last call at the cap, one helm SHA per row. Order: DeepSeek (loaded), then the others as jody loads them.

`results/current` → this folder.

## DeepSeek — `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8`, label `dsv4-flash-vision-exp`, effort `low`

Started 2026-09-07T21:21:48Z on helm `e6eb549` (main: T29 + T30 + T31 merged), fixtures then the app task, warm session first. DeepSeek sees natively (airo `capabilities: vision`; the harness block records `vision: native`), digest ceiling 52k tokens on its 1M window.

Finished 2026-09-07T22:06:40Z.

- **Fixtures 16/17** in 490 s (round 4 at `low`: 17/17 in 496 s). The miss is `safe_echo_exact`, and it is **the harness's**: the model wrote its own test script as a heredoc whose test strings included the literal `$(rm -rf /)`; the destructive-bash tripwire matched the literal, the call asked, nobody was at the conn, and the T31 pin denied it (round 4 passed the same fixture only because this seat's operator row allowed all bash). Denied its test run, the model guessed and removed the `\r` with the `\n`. Follow-up T32: the tripwire reads the command with heredoc bodies removed; the fixture is re-run on that SHA below. `split_bill` took 19 rounds (round 4: 6) — the model's own back-and-forth, done.
- **App 19/19, done at 105 rounds** (round 4: 77), 2071 s (34.5 min; round 4: 24 min), ending `summary`, no nudge, no last call. Tokens: 184k uncached prompt, 76k completion, 51k reasoning (round 4: 97k / 51k / 28k). Tools: bash 46, read 29, edit 20, preview 17, todo 13, job 6, write 6 (round 4: preview 3, todo 3). Tool time 52.7 s of the 34.5 min — bash 50.9 s, preview 1.1 s for 17 native screenshots.
- **Phases.** Survey rounds 1–22 (the generator at round 2, then the generated app and the kit read whole — round 4 read the same files through the digest and `sed` windows; eight rounds went into `to_form` internals across phoenix_html and phoenix_ecto), build 23–82, then a review pass the old harness did not invite: fifteen `preview` rounds between 83 and 101, looking at its own pages with its own eyes, fixing what it saw until round 94, precommit green at 103, the summary at 105. Round 4 looked three times. The extra 28 rounds are the review; the build itself was 60 rounds in both.
- **Failures in the row (4):** the tripwire denial above (in a fixture); one `job wait` crash — **the harness's**: the generator finished while `wait` was tailing its output, the holder exited between the lookup and the call, and the executor turned it into "tool task exited" (one round; T32 catches it); two of the model's own (a `grep` on a file that did not exist, a python one-liner that raised).
- `green_at` in the record is empty because it required a clean lint the coding brief never asks for; T32 counts precommit alone when lint never ran. Read from the transcript: precommit green at round 103, two rounds before the summary.
- Cleanup verified: port 4099 free.

**`safe_echo_exact` re-run 2026-09-07T22:11Z on helm `d258872`** (T32: the tripwire reads the command with heredoc bodies removed; the `job wait` race caught; `green_at` on precommit alone — nothing else changed): **pass** in 4 rounds, 29 s, no refusal — the model's test script ran, and it fixed the module to return the input unchanged with one trailing newline removed. The row is **17/17 + 19/19**. Provenance: the app and the other sixteen fixtures ran on `e6eb549`; the record's `helm_sha` reads `d258872` because the re-run rewrote it; this line is the record of which is which.

| model | fixtures | app | app rounds | app wall | reasoning | preview calls |
|---|---|---|---|---|---|---|
| DeepSeek V4 Flash Vision Exp (low) | 17/17 (one re-run on T32) | 19/19, done, summary | 105 / 128 | 34.5 min | 51k | 17 (native) |

Next: the other two models as jody loads them, on helm `f103bad` (main, T32 merged).

**Watch (jody, 2026-09-07): does the countdown let a model fill its budget?** Measured the same way on every row of this round, from the reasoning sidecar and the transcript: (1) how often the model names its budget (`round N of 128`, `M of 60 min`) and what it says next; (2) the phases — first write, last write, precommit green, done — against round 4's; (3) the review pass — preview rounds after the last write. DeepSeek: 3 mentions (rounds 15, 41, 95 — "need to plan well", "keep an eye on time", "be efficient"; no added scope after any), first write 23 / last write 94 / green 103 / done 105 (round 4: 24 / — / — / 77), fifteen preview rounds between 83 and 101. Confounded with native screenshots costing a second each; an A/B (countdown off, same SHA, app only) after the round if the other rows show the same shape.

## GLM — `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`, label `glm53-flash-exl3`, effort `low`

Started 2026-09-07T23:36:13Z on helm `93ba25a` (main: `f103bad` T32 + the board line — same code), fixtures then the app task, warm session first. GLM sees natively (airo `capabilities: vision`), digest ceiling 26k tokens on its 524k window. Thinking enabled in the airo deployment as since round 4; `low` on this template is close to no thinking (the round-5 probe).

Finished 2026-09-08T00:01:03Z.

- **Fixtures 16/17** in 511 s (round 4 at `low`: 17/17 in a similar wall). The miss is `rate_limiter`, and it is **the model's**: it declared the check-then-increment race fixed with an `Agent.get_and_update` after 4 rounds, and the hidden tests admit 14 of a limit of 10 sequentially and 182 under concurrency — no refusal, no harness failure in the row. Round 4 took 8 rounds on it and passed. `safe_echo_exact` passed in 10 rounds on the fixed tripwire; `split_bill_signed` 8; nothing capped.
- **App 19/19, done at 62 rounds** (round 4: 93), 844 s (14.1 min; round 4: 18.4 min), ending `summary`, no nudge, no last call. Precommit green at round 60, two rounds before the summary — the shortest finish of the round so far. Tokens: 180k uncached prompt, 17.5k completion, 5.2k reasoning (`low` on this template is almost no thinking; round 4: 193k / 20k / 5.9k). Tools: edit 34, bash 14, read 13, write 5, job 4, grep 2, tree 1, todo 1 — **no preview call at all** (round 4: 4). Tool time 42.7 s — 21 s waiting on the generator with `job wait`, 21.5 s of bash.
- **Phases.** Generator at round 1, first write at round 12 (DeepSeek: 23), build 12–55, green at 60, summary at 62. No review pass. Round 4's 93 rounds carried nine failures (edit anchors, mostly); this row has one, an edit miss whose error now names the line ("line 134 equals old_string's first line ignoring whitespace, but the lines after it differ") — fixed the next round.
- **Watch — the countdown:** 0 mentions in 62 rounds of reasoning or content; first write 12 / last write 55 / green 60 / done 62 against round 4's 93; no preview rounds after the last write. The shape is the opposite of DeepSeek's: shorter than its own round 4, with no review pass. On these two rows the long review is DeepSeek's habit plus a cheap screenshot, not the countdown.
- Cleanup verified: port 4099 free.

| model | fixtures | app | app rounds | app wall | reasoning | preview calls |
|---|---|---|---|---|---|---|
| DeepSeek V4 Flash Vision Exp (low) | 17/17 (one re-run on T32) | 19/19, done, summary | 105 / 128 | 34.5 min | 51k | 17 (native) |
| GLM 5.3 Flash (low) | 16/17 (`rate_limiter`, the model's) | 19/19, done, summary | 62 / 128 | 14.1 min | 5k | 0 |

Next: Qwen as jody loads it, on helm `93ba25a`.

**Serving vs. rounds (jody's question, 2026-09-08).** From the per-round ledger (`turn_usage.round_metrics`: uncached prompt, completion, wall per round), a least-squares fit `round = overhead + uncached/prefill + completion/decode` over each app session:

| row | rounds | model time | prefill (fit) | first-token rate, cold rounds | decode | per-round overhead | uncached prompt | completion |
|---|---|---|---|---|---|---|---|---|
| GLM r4 | 93 | 18.4 min | 702 tok/s | 745 tok/s | 28.9 tok/s | 1.33 s | 193k | 20.3k |
| GLM r6 | 62 | 14.1 min | 915 tok/s | 893 tok/s | 28.1 tok/s | 0.36 s | 180k | 17.5k |
| DeepSeek r4 | 77 | 24.0 min | ~2,760 tok/s (R² 0.67) | 1,298 tok/s | 44.2 tok/s | 3.4 s | 97k | 50.6k |
| DeepSeek r6 | 105 | 34.5 min | 1,753 tok/s (R² 0.98) | 1,136 tok/s | 38.7 tok/s | 0.14 s | 184k | 75.6k |

GLM's prefill is ~20–30 % faster than in round 4 (the serving tweak) and its decode is unchanged; decode is where GLM's time goes (17.5k tokens at 28 tok/s ≈ 10 of the 14 min), so the prefill gain is worth about a minute. Round 6's work at round 4's rates would have taken ~15.7 min: of the 4.3 min saved, ~2.7 min is fewer rounds and tokens, ~1.6 min is serving (prefill and the per-round overhead). DeepSeek's serving is slightly slower than in round 4 (first-token rate −12 %, decode −13 %); its extra 10.5 min is work — twice the uncached prompt (verbatim reads, the review pass) and half again the completion.

## Qwen — `RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt`, label `qwen38-flash-next-nvfp4`, effort `low`

Started 2026-09-08T00:20:04Z on helm `93ba25a` (the same code as GLM's row), fixtures then the app task, warm session first. Qwen sees natively (airo `capabilities: vision`), digest ceiling 50k tokens on its 1M window. `low` goes to the template as `low` (airo's clamp lists low/medium/xhigh for this deployment).

Finished 2026-09-08T01:08:14Z.

- **Fixtures 16/17** in 609 s (round 4 at `low`: 16/17). The miss is `safe_echo_exact` again — **the model's**, as in round 4: its probe script broke on shell quoting (exit 2, "unexpected EOF while looking for matching quote"), and its fix left `"x\r\n"` untouched where the hidden test wants `"x\r"`. No refusal in the fixture row. `safe_echo_exact` 9 rounds, `month_end` 8, `binary_search` 7; nothing capped.
- **App 16/19, done at 105 rounds** (round 4: 19/19 at 102), 2148 s (35.8 min; round 4: 27.6 min), ending `summary`, no nudge, no last call. **The three misses are the model's, and they are one decision:** it parked the countdown timer in the test environment (`config/test.exs`: `tick_interval_ms: 3_600_000`) so its own tests could drive `:tick` by hand, and the hidden tests — which wait for the real five-second tick — saw the countdown stay at 100, `stat-ticks` stay 0 and no tick in the activity feed. The live site ticks (the render check saw 98 after 12 s). The spec says "every 5 seconds, updating live"; the hidden tests are the contract, and the model changed the behaviour under test. Worth a line in the app prompt's next edition ("the tick must hold in every environment, including test"), so the loophole is named rather than discovered; not a harness fault in this round. Tokens: 509k uncached prompt, 81k completion, 50k reasoning (round 4: 343k / 59k / 38k). Tools: bash 54, edit 21, write 14, read 13, preview 12, job 11, todo 2, tree 2. Tool time 21.6 s — 11.6 s of it `job wait` on the generator.
- **Failures in the row (3):** one `rm -f` of its own `.bak` file refused by the tripwire under the T31 pin (a round lost; the model went on without it — the pin working as designed, and a pattern to watch: `rm -f` of a file the session itself made is benign and asks anyway); a `tar` of a hex package that did not exist (the model's); a `todo set` on a number it had not added (the model's).
- **Phases.** Generator at round 2, first write at 25 (DeepSeek 23, GLM 12), precommit green first at 92, a review pass of seven `preview` rounds between 95 and 102, fixes until 101, green again at 103, the summary at 105.
- **Watch — the countdown:** 2 mentions, both restraint — round 82 "time is a factor (30 min used, round 82/128). Let me be efficient", round 94 "careful about time: 33 of 60 min used, round 94/128. Remaining must-haves: precommit green + a one-line summary. Visual verification is a nice-to-have". First write 25 / last write 101 / green 92→103 / done 105 against round 4's 102; seven preview rounds after the first green. It used the budget to cut scope, not to fill it.
- **Serving.** Fit: prefill 1,604 → 2,131 tok/s (first-token rate on cold rounds 2,010 → 1,851), decode 39.3 → 43.3 tok/s, overhead −0.6 → 0.35 s — within the noise of the two fits; call the serving unchanged. The extra 8 min are work: 48 % more uncached prompt (509k vs 343k — verbatim reads) and 37 % more completion.
- Cleanup verified: port 4099 free.

## Round 6 — all three rows in (2026-09-08T01:08Z)

| model | fixtures | app | app rounds | app wall | reasoning | preview calls | first write / last write / green / done |
|---|---|---|---|---|---|---|---|
| DeepSeek V4 Flash Vision Exp (low) | 17/17 (one re-run on T32) | 19/19, done | 105 / 128 | 34.5 min | 51k | 17 | 23 / 94 / 103 / 105 |
| GLM 5.3 Flash (low) | 16/17 (`rate_limiter`, the model's) | 19/19, done | 62 / 128 | 14.1 min | 5k | 0 | 12 / 55 / 60 / 62 |
| Qwen 3.8 Flash Next (low) | 16/17 (`safe_echo_exact`, the model's, as in round 4) | 16/19, done (the parked test timer) | 105 / 128 | 35.8 min | 50k | 12 | 25 / 101 / 92→103 / 105 |

Protocol held: helm `93ba25a`/`f103bad` code for all three rows (DeepSeek's app and sixteen fixtures on `e6eb549`, its `safe_echo_exact` re-run on T32), effort `low`, native vision, ceiling by window, the pinned approvals, the countdown. Against round 4: DeepSeek 17/17 + 19/19 both times; GLM 17/17 → 16/17 and 19/19 both times, 93 → 62 rounds; Qwen 16/17 both times and 19/19 → 16/19.

**The countdown, across the round:** 5 mentions in three sessions, every one pacing or restraint, none followed by added scope; one model ran longer than its round 4 (DeepSeek, a review pass), one shorter (GLM), one the same (Qwen, which cut "visual verification" to a nice-to-have when it read the clock). No sign of budget-filling in this round; the A/B stays available if a later round shows it.

**Diffs (T33, 2026-09-08, backfilled).** The round's reference generation (`reference/benchapp`, `mix joby_kit.new` alone, groomed) and each model's tree diffed against it — files / lines, the patches in `raw/diff-<label>.patch`, the counts in each record's `app.diff` (marked backfilled: computed after the run from the work tree, the same pure function the harness now runs at grading): DeepSeek 18 files +665/−157, GLM 18 files +672/−170, Qwen 20 files +996/−186.

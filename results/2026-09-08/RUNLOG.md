# Run log — round 2026-09-08 (coding round 7 at `low`)

The second coding round on the re-baselined harness, on helm main with T32 and T33 merged: heredoc bodies are data to the approval tripwire and `rm -f` of the session's own relative files passes; `read`/`grep` take several paths and a whole read of an unchanged file answers short; the coding rows get a diff against the round's reference generation; the app prompt is at its sixth edition (the tick rule holds in every environment, including test — round 6's Qwen parked the timer in `config/test.exs` and lost three gates), so `prompt_sha` changes from round 6.

Protocol otherwise as round 6 (`results/2026-09-07/`): effort `low`, fixtures (17) then the app task, a warm session before the app prompt, caps 35 / 128, clocks 10 / 60 min, last call at the cap, one helm SHA per row, the countdown watch and the serving fit in each readout. Order: Qwen (loaded), then the others as jody loads them.

`results/current` → this folder.

## Qwen — `RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt`, label `qwen38-flash-next-nvfp4`, effort `low`

Started 2026-09-08T08:24:33Z on helm `351f8a8` (main: T33 `452a58a` + the board line — same code), app prompt `39413706` (sixth edition), fixtures then the app task, warm session first. Native vision, ceiling 50k tokens on the 1M window; `low` at the template.

Finished 2026-09-08T08:40:46Z — **the app row is void, the harness's fault.** Fixtures 16/17 in 674 s (`safe_echo_exact` again, the model's, as in rounds 4 and 6). The app task ended at round 24 with 7/19 (the untouched generated app): the T31 countdown rode the request as a trailing `user` message, and at round 24 Qwen read it as an empty operator turn — its reply: "No actionable input arrived this turn — the round advanced without a message, so there's nothing new to work on… Ready for the next instruction." The harness took the reply as a summary and graded. Round 6's three sessions had read the same line as pacing; this one did not, and the shape was the flaw. T34 moves the countdown inside the round's last tool result (harness state, never a message of its own); the app task is re-run on that SHA below, the fixtures stand.

**App task re-run** started 2026-09-08T08:42:58Z on helm `1f72e76` (main: T34 `8100b3a` + the board line — the countdown inside the last tool result), `only: [:app]`, warm session first; the fixture rows from `351f8a8` stand. The record's `helm_sha` will read the re-run's; this line is the record of which is which.

Finished 2026-09-08T09:40:03Z (the app re-run on `1f72e76`).

- **App 19/19, `max_rounds` at 128 + 2 (the last call answered with a summary: `done`)**, 3331 s (55.5 min; round 6: 105 rounds, 35.8 min, 16/19 with the parked timer). Precommit green at rounds 126 and 127 — one round before the cap; the last call stopped the server and summarised. The sixth-edition tick rule held: the countdown runs on a real `Process.send_after` in every environment, including test, and all three tick gates passed. Tokens: 755k uncached prompt, 118k completion, 75k reasoning (round 6: 509k / 81k / 50k). Tools: bash 61, write 27, read 19, edit 16, job 3, tree 2, todo 1 — **no preview call** (round 6: 12). Tool time 140 s. Diff: 27 files +1628/−177 (round 6: 20 files +996/−186) — more code, most of it tests.
- **Phases.** First write at round 42 (round 6: 25), last write 120, nine `mix test` runs, green at 126. The build was long: a LazyHTML detour in the tests ("round 109 — I'm spending too long on LazyHTML"), then test files written one per round until the model batched them ("write the remaining 4 test files in ONE message"). No review pass — it skipped the browser on purpose ("skip browser verification if rounds run out").
- **Failures in the row (2):** one edit miss (the new message named line 35 and the differing tail; fixed next round), one `curl` against a server still booting (503) — both the model's. No refusal.
- **Watch — the countdown, in its new place:** read correctly as harness state every time — 15 mentions from round 63 on, none mistaken for a turn, all pacing: "round budget is getting tight (86/128, 41/60 min)", "I must be surgical", "batch writes in one message", "only 17 rounds left". It paced itself to the cap with green one round before it. No budget-filling; if anything the opposite — it cut the browser.
- **Serving.** Fit: prefill 2,131 → 2,626 tok/s, decode 43.3 → 38.9 tok/s, overhead 0.35 → 0.10 s — within the noise of the two fits. The extra 20 minutes are work: 48 % more uncached prompt and 46 % more completion, most of it tests.
- Cleanup verified: port 4099 free.

| model | fixtures | app | app rounds | app wall | reasoning | preview calls | first write / last write / green / done | diff |
|---|---|---|---|---|---|---|---|---|
| Qwen 3.8 Flash Next (low) | 16/17 (`safe_echo_exact`, the model's, as in rounds 4 and 6) | 19/19, max_rounds → last call, summary | 130 / 128 | 55.5 min | 75k | 0 | 42 / 120 / 126 / cap | 27 files +1628/−177 |

Provenance: fixtures on `351f8a8` (T33), the app on `1f72e76` (T34 — the countdown inside the last tool result); the first app attempt on `351f8a8` is void (the countdown read as an empty turn) and its record was replaced by the re-run.

Next: the other two models as jody loads them, on helm `1f72e76`.

## GLM — `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`, label `glm53-flash-exl3`, effort `low`

Started 2026-09-08T09:57:07Z on helm `1f72e76` (main, T34 — the same code as Qwen's app re-run), app prompt `39413706`, fixtures then the app task, warm session first. Native vision, ceiling 26k tokens on the 524k window; thinking enabled in the deployment, `low` ≈ no thinking on this template.

Finished 2026-09-08T10:25:30Z.

- **Fixtures 17/17** in 666 s (round 6: 16/17 — `rate_limiter` passed this time in 6 rounds). `interval_merge` took 21 rounds (round 6: 5), `lru_cache` 9, `pricing` 8; nothing capped.
- **App 19/19, done at 61 rounds** (round 6: 62), 892 s (14.9 min; round 6: 14.1), ending `summary`, no nudge, no last call. Precommit green at 46, then fifteen more rounds — a review pass of six `preview` rounds between 55 and 60 (round 6: none) — and the summary at 61. Tokens: 163k uncached prompt, 16.6k completion, 6.5k reasoning (round 6: 180k / 17.5k / 5.2k). Tools: bash 30, edit 15, preview 7, read 7, write 5, job 4, todo 1. Tool time 78 s. Diff: 18 files +628/−168 (round 6: 18 files +672/−170).
- **Failures in the row (3), all the model's:** an edit miss (the message named line 75 — "contains old_string's first line — read from there"; fixed next round), a `sed` with a malformed label, a `job` call on a number that did not exist.
- **Phases.** Generator at round 1, first write at 13 (round 6: 12), last write 44, green 46, review 55–60, done 61. The same shape as round 6 up to green; the review pass after green is new for GLM and against the brief's "do not re-verify" — fifteen rounds, five minutes.
- **Watch — the countdown:** 0 mentions (as in round 6). Read, if at all, silently; no budget-filling, no early stop.
- **Serving.** Fit: prefill 915 → 1,134 tok/s, decode 28.1 → 28.4 tok/s (R² 0.84 against 0.89; the overhead term moved 0.4 → 2.7 s, so read the prefill gain with care). The run did slightly less work than round 6 (163k vs 180k uncached) in slightly more time; the review pass is where the minutes went.
- Cleanup verified: port 4099 free.

| model | fixtures | app | app rounds | app wall | reasoning | preview calls | first write / last write / green / done | diff |
|---|---|---|---|---|---|---|---|---|
| Qwen 3.8 Flash Next (low) | 16/17 (`safe_echo_exact`, the model's, as in rounds 4 and 6) | 19/19, max_rounds → last call, summary | 130 / 128 | 55.5 min | 75k | 0 | 42 / 120 / 126 / cap | 27 files +1628/−177 |
| GLM 5.3 Flash (low) | 17/17 | 19/19, done, summary | 61 / 128 | 14.9 min | 6k | 7 | 13 / 44 / 46 / 61 | 18 files +628/−168 |

Next: DeepSeek as jody loads it, on helm `1f72e76`.

## DeepSeek — `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8`, label `dsv4-flash-vision-exp`, effort `low`

Started 2026-09-08T11:01:26Z on helm `1f72e76` (main, T34 — the same code as the other two rows), app prompt `39413706`, fixtures then the app task, warm session first. Native vision, ceiling 52k tokens on the 1M window.

Finished 2026-09-08T11:36:28Z.

- **Fixtures 17/17** in 482 s (round 6: 17/17 in 474 s with one re-run; this time no re-run needed — `safe_echo_exact` in 4 rounds, its test script ran under the T32 tripwire). `binary_search` 9 rounds; nothing capped.
- **App 19/19, done at 94 rounds** (round 6: 105), 1455 s (24.2 min; round 6: 34.5), ending `summary`, no nudge, no last call. Precommit green first at round 52, then a lint fix, a twenty-round review pass of `preview` between 67 and 86 (round 6: fifteen), green again at 87, the summary at 94. Tokens: 174k uncached prompt, 49k completion, 30k reasoning (round 6: 184k / 76k / 51k). Tools: bash 37, preview 20, edit 16, read 11, todo 6, write 6, glob 4, job 2, grep 1, tree 1. Tool time 94 s. Diff: 18 files +627/−166 (round 6: 18 files +665/−157).
- **Phases.** First write at round 13 (round 6: 23 — ten rounds less survey: 11 reads against 29, and `glob` used for the first time), last write 59, green 52 → 87, done 94. The review pass is DeepSeek's habit, seen in both rounds and in the design round; native screenshots make it cheap (20 shots inside the 94 s of tool time).
- **Failures in the row (4), all the model's:** the generator run in the foreground — twice — and killed at the 30 s limit (once without an app name; the prompt's setup step says to background it), a `cp` from `scratch/` with the wrong cwd, a `sed` with a malformed label.
- **Watch — the countdown, in its new place:** 3 mentions, all in rounds 53–55, and the model named the mechanism — "the `[round 54 of 128 · 18 of 60 min]` line is appended by the harness" — after one round of wondering whether precommit had run for an hour. Read as harness state, never as a turn; no pacing change, no budget-filling.
- **Serving.** Fit: prefill 1,753 → 1,611 tok/s, decode 38.7 → 39.3 tok/s — unchanged within noise. The ten minutes saved are work: 35 % less completion (half the reasoning) and eleven fewer rounds.
- Cleanup verified: port 4099 free.

## Round 7 — all three rows in (2026-09-08T11:36Z)

| model | fixtures | app | app rounds | app wall | reasoning | preview calls | first write / last write / green / done | diff |
|---|---|---|---|---|---|---|---|---|
| Qwen 3.8 Flash Next (low) | 16/17 (`safe_echo_exact`, the model's, as in rounds 4 and 6) | 19/19, max_rounds → last call, summary | 130 / 128 | 55.5 min | 75k | 0 | 42 / 120 / 126 / cap | 27 files +1628/−177 |
| GLM 5.3 Flash (low) | 17/17 | 19/19, done, summary | 61 / 128 | 14.9 min | 6k | 7 | 13 / 44 / 46 / 61 | 18 files +628/−168 |
| DeepSeek V4 Flash Vision Exp (low) | 17/17 | 19/19, done, summary | 94 / 128 | 24.2 min | 30k | 20 | 13 / 59 / 52→87 / 94 | 18 files +627/−166 |

Protocol held: helm `1f72e76` (T34) for every app row and for GLM's and DeepSeek's fixtures; Qwen's fixtures on `351f8a8` (T33; the countdown fix touched nothing they used). Effort `low`, native vision, the ceiling by window, pinned approvals, the countdown inside the last tool result, the sixth-edition prompt (`39413706`). Against round 6: DeepSeek 17/17 + 19/19 both rounds, 105 → 94 rounds; GLM 16/17 → 17/17 and 19/19 both, 62 → 61; Qwen 16/17 both and 16/19 → 19/19 (the tick rule named), 105 → 130 (the cap). Every app row is 19/19 — the first round where all three sites pass every gate.

**The countdown, across the round:** in its new place it was read as harness state by all three — Qwen paced on it (15 mentions, "I must be surgical"), DeepSeek named the mechanism (3 mentions), GLM never mentioned it. No budget-filling in either round; the one model that ran to the cap did so writing tests, with green one round before it.

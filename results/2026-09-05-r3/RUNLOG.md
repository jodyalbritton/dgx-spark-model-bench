# Run log — round 2026-09-05-r3 (round 5: GLM at `max`)

Per `docs/sprints/T26-effort-max.md` (helm): round 4 (`results/2026-09-05-r2/`) found that GLM 5.3's served template reasons ~30× more at `max` than at `high`, and that `low` leaves it almost no thinking. Round 5 re-runs the round-4 harness (same prompts `6fb75d99`, hidden tests `6ccd80bc`, caps, deadlines, thinking enabled in the airo deployment) with the effort dial at `max` — the only change. helm gains the `max` grade and a per-run `effort:` option for it; the harness block records the value.

Order: GLM (loaded), then the next model as jody loads it. helm SHA recorded in each raw file.

GLM effort probe, thinking on (reasoning bytes on two coding prompts): `low` 13 / 0 · `high` 45 / 125 · `medium` 3,342 / 1,962 · `max` 3,184 / 4,646 / 2,935 · no field 2,053. On this template `medium` and `max` are the same regime (unknown grades fall to the top), and `high` is a *lower* setting than `medium`; `max` is the honest name for what round 5 runs.

## GLM — `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`, label `glm53-flash-exl3`, effort `max`

Started 2026-09-06T02:22:57Z on helm `3f4cd74` (T26: `max` grade + `effort:` option; otherwise the round-4 harness), thinking enabled in the airo deployment as in round 4.

Finished 2026-09-06T03:36:31Z.

- **Fixtures 17/17** in 1117 s (round 4 at `low`: 17/17 in 654 s). All endings `summary`, 0 nudges. Rounds 114 → 90 in total: the two fixtures that took 16 rounds at `low` (`pricing`, `interval_merge`) took 4 and 5; `safe_echo_exact` 9 → 4. Wall time rose on every fixture because every round now thinks — reasoning per fixture 225–3,104 tokens against 0–1,389 at `low`. Fewer rounds, more seconds: the thinking replaced the trial-and-error.
- **App 19/19, outcome `max_rounds`, ending blank** — the cap, not the clock: 128 rounds in 3157 s of the 3600 s deadline. The app was complete well before that. Its own suite was green (16 tests, 12 added), precommit green, and the last rounds were extra live verification ("Final live check — fresh mount should start at 100 and tick down"); the cap ended the turn before it wrote the one-line summary, so no nudge fired (the cap is not a narrated/blank ending). Tools: bash 63, edit 34, read 31, grep 9, preview 6, write 6, todo 2, read_artifact 2, outline 1, tree 1. Tokens: 278k uncached prompt (10.0M with cache — the reasoning echo rides in every request), 67k completion, 44k reasoning (round 4: 20k / 5.9k). 1 composite registered (round 4: 2), lint clean, page 2128 px.
- **Where the rounds went.** ~35 rounds reading and building the layout and composite (it verified the LiveView JS helper signature and every heroicon name against the installed sources before using them), HomeLive written as one 17k-character-reasoning round, then ~50 rounds on its own tests: LiveView streams with a `limit:` in the test DOM, then LazyHTML `filter/2` not descending into children. It read LiveView and LazyHTML source and ran probe scripts until both were understood, fixed the helpers, and the suite passed. Costly, but it never guessed.
- **Product: "Driftlight"**, a dawn-simulating lamp — GLM's second lamp in two rounds (round 4: "Solstice", a desk lamp). The main nav carries only Home and About; the kit pages moved to the footer. The theme control is a single moon button rather than the kit's three-way toggle (the rendered check only asks for `#theme-toggle` present and visible at 390 px, and it toggles). Empty states on both lists. The feature-section lede names the composite ("Rendered with the `<.feature_grid>` composite"), meta copy like Qwen's in round 4.
- Cleanup verified: port 4099 free, no processes under the work dir; 18 reasoning sidecars.

## Round 5 so far

| model | effort | fixtures | app | app rounds | app wall | reasoning (app) |
|---|---|---|---|---|---|---|
| GLM 5.3 Flash | max | 17/17 | 19/19 (`max_rounds`, app complete) | 128 / 128 | 52.6 min | 44k |
| GLM 5.3 Flash (round 4) | low | 17/17 | 19/19 done | 93 / 128 | 18.4 min | 5.9k |

Next model as jody loads it.

## Protocol change (jody, 2026-09-06 ~04:00Z) — before any other model runs

After the first GLM `max` row finished the app and still ended on the 128-round cap without a summary, the round's app protocol becomes **150 rounds / 90 minutes**, and a turn that ends on the cap gets **the last call**: one short turn (cap 4, 3 min grace past the deadline) — "stop anything you started, then the one-line summary" — whose reply is the ending the row records (outcome stays `max_rounds`). helm `b89233d` (T26 tasks 3–4; `Helm.Evals.Coding.run/1` takes `app_rounds:` / `app_deadline_ms:`, the harness block records them and the last-call text). Smoke-tested live on GLM: a cap-1 session got the call and replied with an honest one-line summary in one round, no tool calls.

The first GLM `max` record (128 / 60 min, no last call) moved to `raw/superseded/coding-glm53-flash-exl3.max-128r-60m.json`, its screenshots to `screenshots/superseded/`, its reasoning sidecars to `raw/reasoning/superseded/`. GLM is re-run under the new protocol below; every later model in round 5 runs under it too.

## GLM — re-run under the round-5 protocol: effort `max`, app 150 rounds / 90 min, last call

Started 2026-09-06T04:47:25Z on helm `b89233d`. Harness block: effort `max`, app_rounds_cap 150, app_deadline_ms 5,400,000, last_call_rounds 4.

**Stopped at ~04:48Z after two fixtures** (jody's call): the app prompt gains a stopping instruction — "When your own tests and `mix precommit` pass, reply with a one-line summary. Do not re-verify: a green suite and a green precommit are the finish line." GLM's first `max` run had a green suite at round 102 and green precommit at 126; the tail to the cap was discretionary re-verification, and the model follows every instruction it is given. Fourth edition of the app prompt, new `prompt_sha`; fixture prompt unchanged. The two partial rows were discarded (not superseded — same protocol, just incomplete). helm `6e0f0f1`.

## GLM — re-run under the round-5 protocol (effort `max`, app 150 rounds / 90 min, last call, stopping instruction)

Started 2026-09-06T04:49:12Z on helm `6e0f0f1`, prompt `60276f47`, hidden tests `6ccd80bc`. Harness block: effort `max`, app_rounds_cap 150, app_deadline_ms 5,400,000, last_call_rounds 4.

Finished 2026-09-06T05:53:12Z.

- **Fixtures 17/17** in 1372 s. All endings `summary`, 0 nudges, 4–8 rounds (95 in total; 90 in the superseded `max` run, 114 at `low`). Reasoning 123–4,232 tokens per fixture.
- **App 19/19, `done` at 90 rounds** of 150, 2342 s (39 min) of the 90-minute deadline, ending `summary`, no nudge, **no last call**. The stopping instruction worked: the transcript's last rounds are `mix precommit` (green, 21/21 tests) → lint clean → the summary, where the superseded run spent 26 more rounds re-verifying. Tools: bash 47, edit 27, read 26, write 10, preview 3, todo 2, tree 2, read_artifact 1. Tokens: 199k uncached prompt, 49k completion, 31k reasoning. 21 tests (17 added), 2 composites, lint clean, page 2424 px.
- **The run-time oracle mis-graded two checks — the harness's mistake, not the model's. Fixed as oracle v3 (helm `a2b0d51`, hidden tests `6ed2e858`), under which the row is graded:**
  - `nav` (static): the check grepped only `layouts.ex` and `home_live.ex`; GLM put the nav in its own `nav_components.ex`, and the rendered checks (`boots` "GET / 200 with a nav", `mobile_nav`, `theme_toggle_mobile`) and the hidden `about` test all passed. v3 reads every source under `lib/benchapp_web`.
  - `activity` (hidden): GLM's list carries a hidden empty-state `<li id="activity-empty" class="hidden only:block">` — the stream idiom, since a stream container needs an id on every child. v2 took `li:first-child` as the newest entry and counted every `li` for the cap of ten (11). v3 judges "newest first" and "at most 10" among the entries that *arrived*, ignoring any `<li>` already present at mount.
  - The v3 grade is in `raw/coding-glm53-flash-exl3.regrade.json` and is the row's score; the run-time file is untouched for provenance. Round 4's three apps re-graded under v3 (after `mix deps.get` — their `deps/` had been cleared): GLM 19/19, DeepSeek 19/19, Qwen 19/19 — v3 flips nothing that passed.
- **Product: "Windrose"**, offline-first trail maps — GLM's first non-lamp. The strongest page of any round: an illustrated trail-map hero card, the countdown as "early-access keys remaining" with a progress bar, waitlist with empty state, two stat cards with icons, activity with empty state, six features, a closing CTA, footer. The nav keeps the kit pages and the kit's three-way theme control, and collapses to a hamburger at 390 px. Vision tier was down for its own screenshot (the gateway's vision route still names the unloaded DeepSeek model); it verified the live countdown by reading the preview DOM instead (89 after 11 ticks).
- Cleanup verified: port 4099 free, no processes under the work dir; 18 reasoning sidecars.

## Round 5 protocol, settled (for every model after GLM)

helm `a2b0d51`; app prompt `60276f47` (fourth edition: the stopping instruction); hidden tests `6ed2e858` (oracle v3); effort `max`; app 150 rounds / 90 min; last call (cap 4, 3 min grace); fixtures unchanged (35 rounds / 10 min). Later models are graded under v3 as they run; GLM's row is its v3 grade.

| model | effort | fixtures | app | app rounds | app wall | reasoning (app) | last call |
|---|---|---|---|---|---|---|---|
| GLM 5.3 Flash | max | 17/17 | **19/19** | 90 / 150 | 39.0 min | 31k | not needed |

## DeepSeek — `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8`, label `dsv4-flash-vision-exp`, effort `max`

Loaded by jody 2026-09-06; DeepSeek is also the gateway's vision model again, so `read_artifact` on screenshots works for this run (it 404'd for Qwen and GLM).

Effort probe before launch (one coding prompt, reasoning bytes / completion tokens): `low` 2,643 / 810 · `high` 3,595 / 1,055 · `max` 21,821 / 6,000 — at `max` the reply hit the probe's 6,000-token cap with no answer yet. On a trivial arithmetic prompt `max` answered in 19 tokens. helm sends no completion cap on real turns, so bench rounds will complete, slowly. Expectation going in: DeepSeek thinks ~8× more at `max` than at `low` on the same prompt; the 90-minute app deadline is the risk, not the 150-round cap.

Started 2026-09-06T06:25:31Z on helm `5153b63`, prompt `60276f47`, hidden tests `6ed2e858`, effort `max`, app 150 rounds / 90 min, last call.

**Stopped at ~06:33Z after nine fixtures — a harness leak (jody's screen, 2026-09-06).** `stage_fixture` copied every file in the fixture directory except `hidden_test.exs`, so **`reference.ex` — the control solution — sat beside the buggy `solution.ex` in every fixture of every round since round 1.** DeepSeek listed the directory on `interval_merge` and read it (the session transcript shows the `read`), and its `pricing` reasoning says "There's a reference.ex file… reading it might give me the intended behavior. Let me read it." The nine rows are discarded (not superseded: incomplete and contaminated). Fixed in helm `7d2c4ec`: a fixture stages only `solution.ex` and, where one ships, `solution_test.exs`; a test pins the staged set and checks every fixture directory holds nothing else.

**What the record shows for earlier rows.** Bench sessions are cleaned up after grading, so the transcript survives only for the 15 most recent; the per-round reasoning sidecars (rounds 4 and 5) carry the model's text and tool *names*, not tool arguments. Searching all of it for `reference.ex`:
- Round 1 (`2026-09-04`): GLM `percentile` read `reference.ex` (session transcript). Round 2 (`2026-09-04-r2`): GLM `interval_merge` mentions it in its final line (and failed anyway). Rounds 1–3 have no sidecars; nothing more can be said about them.
- Round 4 (`2026-09-05-r2`): DeepSeek `nth_one_based` noticed it and decided not to read ("Not needed. Done."); GLM `pricing` noticed it mid-debug and moved on. No round-4 sidecar shows a read or a citation of its contents.
- Round 5 GLM (this round, final run): **`visible_test_lies` is contaminated** — GLM read `reference.ex` "for context on intended behavior", and its reasoning says "The reference.ex shows a correct implementation matching the moduledoc… Matching reference behavior exactly is the safest." That pass counts as the reference's, not the model's: GLM round 5 fixtures are **16/17 clean + 1 contaminated** until that one fixture is re-run under the fixed staging when GLM is next loaded. No other GLM round-5 fixture mentions the file.

## DeepSeek — re-run from the start under the fixed staging (helm `7d2c4ec`), same protocol

Started 2026-09-06T06:34:42Z on helm `7d2c4ec` (staging fix; otherwise the round-5 protocol: prompt `60276f47`, hidden tests `6ed2e858`, effort `max`, app 150 rounds / 90 min, last call). A re-run of one fixture replaces its row by name (`run/1` with `only: [:fixtures], fixtures: [...]`), which is how GLM's `visible_test_lies` gets its clean row later.

Finished 2026-09-06T07:36:36Z.

- **Fixtures 17/17** in 906 s on the fixed staging (round 4 at `low`: 17/17 in 496 s). All endings `summary`, 0 nudges, 3–11 rounds; 92 rounds in total against 71 at `low`, reasoning 24k against 8.7k. `visible_test_lies` passed in 4 rounds with no reference to read.
- **App 19/19, `done` at 137 rounds** of 150, 2674 s (44.6 min) of 90, ending `summary`, no nudge, **no last call**. The stopping instruction held: the transcript ends precommit green → summary. Round 4 at `low`: 19/19 at 77 rounds, 24.0 min. Tools: bash 66, edit 22, read 21, job 15, todo 14, preview 9, write 6, read_artifact 1. Tokens: 162k uncached prompt (13.0M with cache — every round re-sends its reasoning), 98k completion, 59k reasoning (round 4: 51k / 28k). 17 tests (13 added), 3 composites, lint clean, page 2250 px.
- **Where the extra 60 rounds went.** Two reasoning rounds of 31k and 25k characters before the first write; ~15 rounds polling background jobs and sleeping while the test suite and the dev server came up; 12 failed `todo` calls (setting items by ids that were not there — the tool's message says the list is already in context); three foreground bash timeouts; one `read` outside the session roots (it tried to read the kit generator's source under `~/Work/joby_kit_new`, and helm refused — the sandbox held). None of it was re-verification.
- **Second-guessing, measured** (jody's observation from the folds): markers per 10k characters of app reasoning — "wait", "actually", "hmm", "let me re-check", "or maybe" — DeepSeek `max` 27.4 (274 "actually", 126 "wait", 110 "hmm" in 238 KB); DeepSeek `low` (round 4) 31.5; Qwen `low` (round 4) 19.9; GLM `max` 18.2. DeepSeek doubts about half again as often as the other two at either effort — a trait, not an effort effect; `max` doubled the volume, not the density. GLM's marker is "hmm", DeepSeek's is "actually".
- **Product: "Hearth"**, a family's shared lists, with a custom warm daisyUI theme named for it. Centered hero, countdown card beside two stat cards, a signup band, six features, the activity feed with an empty state, footer. The recent-signups heading has no empty-state line (as in round 4). Vision tier worked this run (DeepSeek is the vision model); it used `preview` nine times.
- Cleanup verified: port 4099 free, no processes under the work dir; 18 reasoning sidecars.

| model | effort | fixtures | app | app rounds | app wall | reasoning (app) | last call |
|---|---|---|---|---|---|---|---|
| GLM 5.3 Flash | max | 16/17 clean + 1 contaminated (re-run pending) | 19/19 | 90 / 150 | 39.0 min | 31k | not needed |
| DeepSeek V4 Flash Vision Exp | max | 17/17 | 19/19 | 137 / 150 | 44.6 min | 59k | not needed |

Next: Qwen as jody loads it; then GLM's `visible_test_lies` re-run when GLM is next loaded.

**Closed 2026-09-07 (jody):** the GLM `visible_test_lies` re-run is dropped. Round 5 stands as the pre-T29 baseline; the benches re-baseline on the T29–T31 harness (helm `docs/sprints/T31-bench-hygiene.md`, decision 4).

## Qwen — `RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt`, label `qwen38-flash-next-nvfp4`, effort `max` → template `xhigh`

Loaded by jody 2026-09-06. **Qwen3.8's chat template accepts only `low`, `medium`, `xhigh` (its default and ceiling) and 400s on anything else** — a helm-shaped request at `max` or `high` fails outright ("Unexpected reasoning effort max. Supported types are xhigh (default), medium, and low."). Probe at `xhigh`: 4,899 bytes reasoning / 1,347 reasoning tokens on the coding prompt.

The mapping belongs to airo (design: helm speaks one vocabulary, airo owns each backend's spelling). Added to airo (`ac636b6`, jody's call — "the list/clamp is the call my other coding agent suggested"): a deployment lists the values its template accepts in its request defaults (`"reasoning_effort_levels": ["low", "medium", "xhigh"]`), and an unlisted request clamps to the highest listed level at or below it on `none < minimal < low < medium < high < xhigh < max` — never above what was asked; the key is stripped before dispatch. So helm's `max` reaches Qwen as `xhigh`, its ceiling; the row records helm's grade (`max`) and this note records the wire value. Deployed by claude at jody's instruction ("deploy it"), 2026-09-06.

airo `ac636b6` deployed by claude 2026-09-06T08:23Z (jody: "deploy it"); pushed to origin. Qwen deployment (id 37) request defaults set on prod by claude via SQL: `{"reasoning_effort_levels": ["low", "medium", "xhigh"]}`. Verified through `Helm.Airo.stream`: `max` → 200 with 89 reasoning tokens (xhigh), `high` → 57 (medium), `low` → 36; before the clamp `max` and `high` were 400s.

Started 2026-09-06T08:24:29Z on helm `f003182` (round-5 protocol: prompt `60276f47`, hidden tests `6ed2e858`, effort `max` → template `xhigh`, app 150 rounds / 90 min, last call, fixed staging).

Finished 2026-09-06T09:44:43Z (app); `percentile` re-run 09:44:57Z → 09:45:40Z.

- **Fixtures 16/17** in 918 s + the re-run (round 4 at `low`: 16/17 in 465 s). One honest miss, the same as round 4: `safe_echo_exact`, `String.trim_trailing` strips every trailing newline; its reasoning asked "removes only ONE?" and answered wrong. Two rounds, two efforts, same trap — a stable trait.
- **`percentile` — a serving incident, not a model failure, re-run clean.** The as-run session's first response continued a conversation that never happened in it (a test file, escape sequences, helm's write-sandbox message — text from Qwen's `rate_limiter` session six minutes earlier on the same server); it then "fixed" functions the module does not have and failed. airo's ledger shows helm-dev as the only client of Qwen today and the session's first request as a normal fresh 5,232-token prompt. Prefix caching is on for this vLLM (jody). One incident in ~120 requests; nothing like it in ~500 each for GLM and DeepSeek on the same gateway. Re-run alone under the same serving: PASS in 8 rounds, 40 s, 703 reasoning tokens — the row now carries the clean run (`session c9701e21`).
- **App 19/19, outcome `max_rounds` at 152 rounds, ending `summary` via the last call** (2 rounds, `done`), 3760 s (62.7 min) of 90, 0 nudges. Round 4 at `low`: 19/19 done at 102 rounds, 27.6 min. Tokens: 677k uncached prompt (20.8M with cache), 141k completion, 69k reasoning (round 4: 59k / 38k). 43 tests (39 added — the most of any run), 7 composites (also the most), lint clean, page 2827 px. Tools: bash 63, edit 59, read 32, write 27, preview 7, tree 2, glob/job/outline/todo/read_artifact 1 each.
- **Where the rounds went.** The app and its suite were done by ~round 110. Then ~30 rounds building its own browser verification: it tried to write a puppeteer script to `/tmp/pptest` (helm's write sandbox refused: "path escapes the session roots"), installed puppeteer there through bash instead, and drove the signup form itself rather than through the `preview` tool it had used seven times. The stopping instruction says "when your own tests and `mix precommit` pass, reply" — it never ran precommit before starting on the browser work, so the instruction never fired; the cap did, and the last call closed it properly. `/tmp/pptest` removed after the run.
- **helm follow-ups seen in this run:** `read` crashed twice ("no function clause matching in Helm.Tools.Read.run/2") when Qwen passed `{"artifact": …, "query": …}` instead of `path` — a tool should return an error, never crash; and `read_artifact` was asked for an artifact id that belonged to a digested output in a different session (Qwen reused an id from earlier context — no harm, refused correctly).
- **Product: "Lodestar"**, data pipelines on a launch schedule, with a monospace flight-deck theme: illustrated hero stats, the countdown as "manifest closes in N beats" with a progress bar, a seats-left panel, a four-tile stats strip, signup and activity with illustrated empty states, six numbered feature panels, a boarding-procedure list, a closing CTA, footer. The most distinctive page of the round. The nav's theme control is a single sun button; the kit pages stay in the nav.
- Cleanup verified: port 4099 free, no processes under the work dir; 18 reasoning sidecars (percentile's re-run overwrote the contaminated one — the contaminated text is quoted above).

## Round 5 complete (pending one GLM fixture re-run) — 2026-09-06

Protocol: helm `f003182`/`7d2c4ec` (T26), prompt `60276f47`, hidden tests `6ed2e858`, effort `max` (Qwen: airo clamps to `xhigh`), app 150 rounds / 90 min, last call, stopping instruction, fixed staging.

| model | fixtures | app | app rounds | app wall | reasoning (app) | tests added | last call |
|---|---|---|---|---|---|---|---|
| GLM 5.3 Flash | 16/17 clean + 1 contaminated by the staging leak (re-run when GLM is loaded) | 19/19 | 90 / 150 | 39.0 min | 31k | 17 | not needed |
| DeepSeek V4 Flash Vision Exp | 17/17 | 19/19 | 137 / 150 | 44.6 min | 59k | 13 | not needed |
| Qwen 3.8 Flash Next (xhigh) | 16/17 | 19/19 | 152 / 150 (cap) | 62.7 min | 69k | 39 | 2 rounds, summary |

All three complete the app at their ceiling. Round 4 at `low` had the same three 19/19s in 93 / 77 / 102 rounds — `max` bought no score, cost 0–50 more rounds, and roughly doubled reasoning. Effort's visible effect is on *how* they work (GLM: fewer, longer rounds; DeepSeek: more planning and more doubt; Qwen: more tests, more composites, and a self-built browser rig) rather than on whether they finish.

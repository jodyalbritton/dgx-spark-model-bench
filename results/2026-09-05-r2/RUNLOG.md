# Run log — round 2026-09-05-r2 (round 4: the round-3 harness on the T25 helm)

Per `docs/sprints/T25-reasoning-content.md` (helm): the only change from round 3 (`results/2026-09-05/`) is helm itself — reasoning is now persisted on the assistant message, shown collapsed in the pane, and echoed as `reasoning_content` on the current turn's rounds (never across turns). Harness, prompts (`6fb75d99`), hidden tests (`6ccd80bc`), effort `low`, caps and deadlines are unchanged. Each task also writes a per-round reasoning sidecar to `raw/reasoning/<label>-<task>.jsonl`.

Acceptance case for the sprint: Qwen's app row — round 3's was abandoned at 42 rounds with nothing written because the plan lived in reasoning helm discarded.

Order: Qwen (loaded), then the other two as jody loads them. helm SHA recorded in each raw file.

## Qwen — `RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt`, label `qwen38-flash-next-nvfp4`

Started 2026-09-05T22:39:25Z, finished 2026-09-05T23:16:57Z. helm `7c3f879` clean, effort `low`, prompt `6fb75d99`, hidden tests `6ccd80bc`.

- **Fixtures 16/17** in 465 s (round 3: 17/17 in 600 s). All endings `summary`, 0 nudges, 0 capped, 0 timeouts, 4–9 rounds each. The one miss is `safe_echo_exact`: `String.trim_trailing(input, "\n")` strips every trailing newline; the spec's own example (`"x\n\n" => "x\n"`) is the failing hidden test. Round 3 sliced one byte with `binary_part` and passed. Same model, same prompt, same effort — variance on the fixture built to catch exactly that.
- **App 19/19, `done`** at 102 of 128 rounds, 1655 s of the 3600 s deadline, 0 nudges, ending `summary`. Round 3's app row was abandoned by the operator at 42 rounds with nothing written. Tools: bash 41, read 21, edit 18, write 9, preview 3, read_artifact 3, todo 2, job 2, outline 1, tree 1. Tokens: 342k uncached prompt (7.1M with cache), 59k completion, 38k reasoning. 22 tests (18 added), 2 composites registered, lint clean, page 1387 px.
- **Shape of the run.** ~30 rounds reading (generator output, layouts, HomeLive, manifest, kit `core_components.ex` in four slices, manifest and lint sources), then one 43k-char reasoning block holding the whole plan, then edits on the very next rounds. No re-planning. The only self-inflicted detour was its own signup test (params shape), which it debugged with a temporary print and fixed.
- **Product: "Lumen"** — the third app across rounds to pick that name (DeepSeek and GLM both did in round 2). Feature-card copy describes the kit itself ("Built from `<.feature_grid>`, a registered composite…"), which is meta rather than benchmark-themed; the prompt forbids the latter.
- **Failures recorded in the row** (both non-fatal): one `read` of `deps/joby_kit/...` at the wrong relative path (retried under `benchapp/`), and `read_artifact` reporting "vision tier unavailable" — airo's vision route still points at `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8`, which is not loaded while Qwen is. Not a harness issue; noted for the gateway.
- Cleanup verified: port 4099 free, no processes under the work dir, 18 reasoning sidecars in `raw/reasoning/` (app sidecar 166 KB).

Note: runs after Qwen are on a docs-only descendant of `7c3f879` (`9b75ff3`, sprint readout commit); no code differs.

## DeepSeek — `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8`, label `dsv4-flash-vision-exp`

Started 2026-09-05T23:32:02Z on helm `9b75ff3` (docs-only descendant of `7c3f879`), effort `low`. Pre-flight probe: a one-shot chat at `low` returned `reasoning` (79 bytes) alongside the answer, finish `stop`, so reasoning is surfaced on this load.

Finished 2026-09-06T00:06:56Z.

- **Fixtures 17/17** in 496 s (round 3: 17/17 in 438 s). All endings `summary`, 0 nudges, 3–6 rounds each; 29 rounds across the first seven fixtures in both rounds. Passed `safe_echo_exact`, the one Qwen missed this round.
- **App 19/19, `done`** at 77 of 128 rounds (round 3: 92), 1440 s (round 3: 1451 s), 0 nudges. Tools: bash 33, edit 20, read 16, write 8, job 7, preview 3, todo 3, outline 1, tree 1. Tokens: 97k uncached prompt (4.35M with cache; round 3: 95k / 4.77M), 51k completion, 28k reasoning (round 3: 54k / 31k). 14 tests (10 added; round 3: 20 / 16), 2 composites, lint clean, page 2539 px.
- **The first 12 rounds went to the generator.** `mix joby_kit.new benchapp` was run in the foreground at the 30 s default, killed; again at the 120 s max, killed; then in the background. The two killed attempts left generators writing into the same directory; the model found them with `pstree`, killed them, and waited for the background job before reading anything. Round 3 ran the generator in the background from the start. The bash description states both limits, so this is the model's call, but a fresh generate is longer than the foreground max on this machine — worth a sentence in the prompt if it recurs.
- **Product: "Lumen"** again — round 3's was "Nimbus"; that is four Lumens across rounds 2–4. Copy is product-appropriate, not kit- or benchmark-themed. Recent-signups heading has no empty-state line (activity does).
- Cleanup verified: port 4099 free, no processes under the work dir.

## GLM — `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`, label `glm53-flash-exl3`

**Pre-flight finding (2026-09-06, before launch): GLM had been running with thinking off in every previous round.** As served, the GLM chat template defaults `enable_thinking` to off, and `reasoning_effort` alone does not turn it on: a helm-shaped request returned 2–4 completion tokens and no reasoning at either `low` or `high`, and answered a bat-and-ball arithmetic question wrong both times. Round 3's rows confirm the history — 98 completion tokens across three rounds on `clamp`, 17,800 across 128 rounds on the app, reasoning never reported (rounds 1 and 2 likewise). Adding `chat_template_kwargs.enable_thinking: true` to the request turns thinking on (reasoning streams on both `reasoning` and `reasoning_content`; answer correct).

The fix belongs in airo, whose param layer deep-merges a deployment's `default_params` under every request: jody set `chat_template_kwargs.enable_thinking: true` on the GLM deployment. Re-probed through `Helm.Airo.stream` (the bench's exact wire) afterwards: reasoning present at `low` (73 bytes) and `high` (89 bytes), both answers correct. Note for airo: the admin "reasoning traces" toggle drops the key when set to on, which on an off-by-default template still means off; the value has to be in the deployment's request-defaults JSON explicitly.

Effort once thinking is on (three prompts each, reasoning bytes): no effort field 3,617; `low` 13 / 0 / 0; `high` 85 / 168 / 88. `low` collapses GLM's thinking to almost nothing on this template, unlike Qwen and DeepSeek at `low`. The round runs at `low` anyway, for protocol; read GLM's reasoning column with this table in mind.

Started 2026-09-06T00:49:53Z on helm `170dc2b` (docs-only descendant of `7c3f879`), effort `low`.

Finished 2026-09-06T01:21:36Z.

- **Fixtures 17/17** in 654 s (round 3, no thinking: 15/17 in 512 s). All endings `summary`, 0 nudges, 3–16 rounds. `pricing` (3 rounds, fail → 16 rounds, pass) and `safe_echo_exact` (fail → pass) both flipped; `split_bill` 17 → 6 rounds, `split_bill_signed` 21 → 5. Reasoning per fixture is small at `low` — 0 on five of them, 20–155 on most, 419 and 1,389 on the two that needed diagnosis — and it lands on the diagnosis rounds, not the read/edit rounds.
- **App 19/19, `done`** at 93 of 128 rounds, 1103 s (18.4 min — the fastest app of the round), 0 nudges. Round 3 hit the 128-round cap at 15/19 in 992 s. Tools: bash 53, edit 38, read 9, write 5, preview 4, grep 1, read_artifact 1. Tokens: 193k uncached prompt (3.79M with cache; round 3: 266k / 4.97M), 20k completion, 5.9k reasoning. 13 tests (9 added), 2 composites, lint clean, page 1560 px. Nine tool failures in the row, all self-corrected: an edit anchor missed four times, one duplicate anchor, a `sed` typo, one killed 30 s foreground command, one 56k-token tool output digested.
- **Product: "Solstice"**, a desk lamp — the only non-Lumen product of the round and the most product-like copy. The countdown is reframed as "early-bird places remaining… one spot opens up every five seconds", which makes the 5 s tick read as intentional. Both lists have empty states. One feature tile ("Built to last") renders a blank icon.
- **Comparability caveat.** This is GLM's first thinking run; its round-3 row was a non-thinking model. The round-3 → round-4 delta for GLM is thinking on + T25, not T25 alone. For Qwen and DeepSeek the delta is T25 alone.
- Cleanup verified: port 4099 free, no processes under the work dir; 54 reasoning sidecars in `raw/reasoning/`.

## Round 4 complete — 2026-09-06T01:21:36Z

| model | fixtures | app | app rounds | app wall | uncached prompt | completion | reasoning | tests added |
|---|---|---|---|---|---|---|---|---|
| Qwen 3.8 Flash Next | 16/17 | 19/19 done | 102 | 27:34 | 342k | 59k | 38k | 18 |
| DeepSeek V4 Flash Vision Exp | 17/17 | 19/19 done | 77 | 24:00 | 97k | 50k | 28k | 10 |
| GLM 5.3 Flash | 17/17 | 19/19 done | 93 | 18:23 | 193k | 20k | 5.9k | 9 |

All three complete the app at `low` on the T25 helm. `RESULTS.md` rendered via `design/make_report.py`.

## Re-graded under oracle v3 (2026-09-06, helm `a2b0d51`, hidden tests `6ed2e858`)

Round 5 changed the oracle (nav check reads every web source; activity "newest first" and "at most 10" ignore `<li>` present at mount). All three round-4 apps re-graded under v3 after `mix deps.get` (their `deps/` had been cleared): GLM 19/19, DeepSeek 19/19, Qwen 19/19 — unchanged. Files: `raw/coding-<label>.regrade.json`.

# Run log — round 2026-09-04-r2 (second edition harness)

Started 2026-09-04 by claude from helm dev seat. helm SHA: see each raw/coding-*.json `helm_sha`; TESTPLAN pre-flight items (engine flags, host state) are the operator's and are not recorded here unless they say so.

## Qwen3.8-Flash-Next NVFP4 — label qwen38-flash-next-nvfp4

- airo id `RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt`; loaded by jody ("Qwen is loaded", ~17:55Z); engine flags not recorded here (operator's pre-flight).
- helm `529686a` (clean tree), prompt sha `025cf1ec`, harness block in `raw/coding-qwen38-flash-next-nvfp4.json`; system prompt verified to carry the working-method paragraph and the stdin sentence after the dev-server restart at ~18:10Z.
- Phase B (coding): 18:34:08Z → 19:14:03Z. Warm fixture `clamp` discarded; 17 fixtures 18:35–18:45Z; app 18:45:39Z → 19:12Z + oracle.
- Dry run before the round (`results/dryrun/`, 18:14–18:32Z, not scored) found the early-yield case and added the nudge (helm 529686a); the round ran after that commit.
- Deviations: none. Phase A (spark_bench) and Phase C shots for a non-booting app: none (the app did not boot; rendered checks failed with "app did not boot").
- Cache counters reported on every round (`cached_reported: true`) — the first Qwen rows with a real uncached number.

## GLM-5.3-Flash EXL3 — label glm53-flash-exl3

- airo id `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`; loaded by jody ("glm is loaded", ~22:53Z).
- helm `0080265` (clean tree). Differs from Qwen's `529686a` by one docs-only commit (the Qwen readout in `docs/sprints/T23-coding-bench-2.md`); `lib/`, `priv/`, `config/` identical — `git diff 529686a 0080265 --stat` shows the sprint doc alone. Prompt sha `025cf1ec`, same harness block.
- Phase B started 22:54:02Z.
- Phase B finished 23:41:36Z. Fixtures 15/17 (pricing, interval_merge missed; split_bill and percentile capped at 35 with passing files); app 14/18 at the 128-round cap (compiles, boots, ticks, mobile nav, dark theme; signup input named `signup[email]` so the three form-driven hidden tests failed; 6 of its own 19 tests fail on the same path). Screenshots written. Port 4099 free after.

## DeepSeek-V4-Flash-Vision-Exp fp8 — label dsv4-flash-vision-exp

- airo id `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8`; loaded by jody ("deepseek is up", ~02:30Z 2026-09-05).
- helm `d1f9891` (clean tree) = `529686a` + two docs-only commits (the Qwen and GLM readouts); harness code identical, prompt sha `025cf1ec`.
- Phase B started 02:30:29Z.
- Phase B finished 03:11:20Z (2026-09-05). Fixtures 17/17 (no round above 10); app 17/18 `done` in 99 rounds over 2 turns — the one miss (`activity`) is an oracle flaw: the hidden test's list-item count delta breaks on an empty-state placeholder `<li>`. Screenshots written. Port 4099 free after.

## Re-grade under oracle v2 (2026-09-05 ~03:30–03:50Z, helm ed0c6d8, hidden tests 2924139b)

The round's three apps re-graded from disk after two oracle flaws surfaced during the round (the email-field name assumption; the activity count-delta assumption). Sibling files raw/coding-<label>.regrade.json; as-graded files untouched. GLM 14/18 → 14/18 (the form tests now reach its signup code, which crashes: FunctionClauseError in Benchapp.Signups.signup_count/0 — its own 6 failing tests say the same); Qwen 5/18 → 6/18 (boots False→True (GET / 200 with a nav)); DeepSeek 17/18 → 18/18 (the activity check).
- Correction (2026-09-05): the Qwen re-grade is invalid and moved to `raw/superseded/`. Its `boots` flipped to a 200 while `compile` still failed; a direct `PORT=4099 mix phx.server` of the stored app aborts on the same compile error and nothing listens after 60 s, so whatever answered the oracle's poll during that regrade was not Qwen's app (the regrade batch had been interrupted by an eval timeout minutes earlier). Its rendered checks also errored on a bench-Chrome launch failure. A non-compiling app has nothing to re-grade: the as-graded 5/18 stands. Harness hardened after this (helm c67df6d): no boot for an app that failed `compile`; the 4099 listener must be in the oracle's own process group before a 200 counts. GLM's and DeepSeek's boots are their own — the screenshots show LumenLab and Lumen respectively.

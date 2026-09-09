# Run log — round 2026-09-09 (coding round 10 at `low`)

**Status: COMPLETE** (2026-09-09T11:51:13Z). Written as the round went.

GLM 5.3 Flash, a fourth sample of one configuration, same protocol as
round 9. One thing outside helm changed: **jody raised the GLM
deployment's image cap from 4 to 10.** Nothing in helm changed — still
`1f72e76`, still `@images_on_wire 8` (`lib/helm/turn.ex:778`).

## Why this round exists

Round 9 (`results/2026-09-08-r3/`) ended at round 89 on an HTTP 400 —
"At most 4 image(s) may be provided in one prompt" — when the model's
twenty-round review pass produced a fifth screenshot. The row graded
19/19 because the app was already green at round 65, but the turn was cut
mid-work, so its round count is a floor rather than a completion.

With the cap at 10 and helm bounded at 8, that failure is now structurally
impossible: helm cannot send an eleventh image. This round therefore
gives the first uncut GLM app row since round 8, and a fourth point on the
round-count spread — 61, 108, and at least 89 so far, on a configuration
that has not changed.

**The underlying helm defect is not fixed, only out of reach here.** The
bound is still a constant rather than the model's declared capability, so
any deployment capped below 8 will reproduce round 9 exactly. That remains
a T29 follow-up.

## Pre-flight (2026-09-09T11:18Z)

- helm at `1f72e76`, clean tree — the same code as rounds 7, 8 and 9.
- Port 4099 free.
- helm runtime up 28.8 h.
- **Image cap re-measured against airo, not assumed:** 4 → 200, 5 → 200,
  8 → 200, 10 → 200, **11 → 400** ("At most 10 image(s) may be provided in
  one prompt"). Exactly ten, and helm's ceiling of eight sits under it.
  Round 9's same probe returned 400 at five.

## Protocol

Unchanged from rounds 7, 8 and 9: app prompt `39413706` (sixth edition),
effort `low`, fixtures (17) then the app task, a warm session before each,
caps 35 / 128 rounds, clocks 10 / 60 min, PORT=4099, memory off, MCP off,
consult denied. `results/current` → this folder; earlier rounds untouched.

## GLM — `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`, label `glm53-flash-exl3`, effort `low`

Started 2026-09-09T11:19:24Z, spawned inside the helm dev runtime.
Native vision, thinking enabled in the deployment, `low` ≈ no thinking on
this template.

### Fixtures — done 2026-09-09T11:28Z

**17/17 in 496 s**, zero refusals, six tool failures (all the model's).
Tokens 188k uncached prompt, 8.2k completion. Nothing capped. Slowest:
`interval_merge` 68 s / 8 rounds, `rate_limiter` 49 s, `binary_search` 40 s.

| round | fixtures | wall | refused |
|---|---|---:|---:|
| 7 | 17/17 | 666 s | 0 |
| 8 | 17/17 | 592 s | 2 |
| 9 | 17/17 | 565 s | 0 |
| 10 | 17/17 | 496 s | 0 |

Four rounds, **68 of 68**. The fixture half has not distinguished a run
since round 7 and is now purely a cost measurement; the wall time has
fallen every round (666 → 592 → 565 → 496 s) with the same code and the
same prompts, which is worth reading against the serving numbers at the
end rather than as a model result.

Round 8's two tripwire refusals remain the only ones in four rounds.

### App task — 19/19, done, 102 rounds

Clean completion: `outcome=done`, `ending=summary`, no nudge, no last
call, no error. 1,213 s (20.2 min). Precommit green at round 88, then
fourteen more rounds — a review pass of six `preview` rounds, 96 to 101 —
and the summary at 102.

- **The image ceiling was never approached.** Eight `preview` calls
  produced **2** image artifacts, peak 2 on the wire against a deployment
  cap of 10 and helm's own bound of 8. Round 9's failure needed five, and
  this run never took a third. The raised cap therefore did not change
  this row's behaviour — it removed a risk that did not materialise.
- **Phases.** Generator at round 1, first write 21, last write 47, green
  88, review 96–101, summary 102.
- **Failures in the row (7), all the model's:** two edit misses, a
  `ripgrep` exit 2, a `mix run` against a `scratch/t.exs` that did not
  exist, and three failing shell commands — one of them a Postgres
  connection error from a test run. Zero refusals.
- **Watch — the countdown:** 0 mentions across 102 rounds. Four rounds
  now, and GLM has never once mentioned it.
- Tokens: 255k uncached prompt, 24.9k completion, 8.2k reasoning. Tools:
  bash 60, edit 34, preview 8, write 5, job 3, grep 3, read 3, glob 2,
  tree 1, todo 1. TTFT 3.1 s. Diff: 18 files +612/−153.

### Serving — four rounds, still no step change

TTFT split (the round-9 method: prefill from a two-parameter fit of TTFT
against uncached prompt, decode as median completion tokens over the
post-TTFT window). The three-parameter latency fit used in round 8's log
is not used here; it was retired in round 9 for producing a negative
overhead term.

| set | round 7 | round 8 | round 9 | round 10 |
|---|---:|---:|---:|---:|
| app prefill tok/s | 1,092 | 953 | 996 | 985 |
| app decode tok/s | 23.4 | 30.9 | 22.2 | 29.6 |
| fixtures prefill tok/s | 950 | 901 | 862 | 704 |
| fixtures decode tok/s | 31.3 | 34.6 | 29.6 | 33.2 |

**App prefill is flat** across four rounds (953–1,092), which is the
clearest refutation yet of round 8's retired "30 % prefill regression".
**Decode has no trend** — it alternates, rounds 8 and 10 fast, 7 and 9
slow, in both sets. With four samples that is as likely to be coincidence
as structure; it is recorded, not explained, and it is not worth acting on
until there are more rounds.

The one monotonic line is fixtures prefill, 950 → 704 over four rounds.
Worth watching, not yet worth a claim.

**The falling fixture wall time is work, not speed.** It dropped every
round, and so did the rounds spent and the tokens produced:

| round | fixture rounds | completion tokens | wall |
|---|---:|---:|---:|
| 7 | 103 | 11,836 | 666 s |
| 8 | 102 | 10,111 | 592 s |
| 9 | 91 | 9,242 | 565 s |
| 10 | 84 | 8,186 | 496 s |

GLM is solving the same 17 fixtures in fewer rounds with less output. The
serving numbers do not need to explain it.


## Round summary — four samples of one configuration

| round | fixtures | app | app rounds | app wall | ending | preview / images | green |
|---|---|---|---:|---:|---|---|---:|
| 7 | 17/17 | 19/19 | 61 / 128 | 14.9 min | summary | 7 / — | 46 |
| 8 | 17/17 | 19/19 | 108 / 128 | 18.7 min | summary | 15 / 2 | 89 |
| 9 | 17/17 | 19/19 on disk | 89 (cut) | 19.0 min | HTTP 400, blank | 20 / 5 | 65 |
| 10 | 17/17 | 19/19 | 102 / 128 | 20.2 min | summary | 8 / 2 | 88 |

**On the image cap.** Raising the GLM deployment from 4 to 10 did what it
was meant to do — the ceiling is now unreachable, since helm sends at most
8 — but this round did not exercise it. Peak was 2 images. The change is
verified at the deployment (11 images still 400s, 10 does not) and untested
in a real run, because the model did not take enough screenshots. That is
worth stating plainly rather than reading round 10's clean finish as
evidence the fix works under load.

**The helm defect is unchanged.** `@images_on_wire` is still the constant 8
(`lib/helm/turn.ex:778`) rather than the model's declared capability. Any
deployment capped below 8 still reproduces round 9. T29 follow-up.

**On round-count spread.** 61, 108, 102, and one cut at 89 — with green at
round 46, 89, 65 and 88. Three uncut rounds spanning 61 to 108 on code that
has not changed since round 7. A single row's round count is not a property
of the model.

**Score, four rounds:** 68/68 fixtures, and every app row 19/19.

## Cleanup

Verified 2026-09-09T11:53Z: port 4099 free.

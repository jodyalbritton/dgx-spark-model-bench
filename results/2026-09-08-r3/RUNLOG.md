# Run log — round 2026-09-08-r3 (coding round 9 at `low`)

**Status: COMPLETE** (2026-09-09T03:12:19Z). Written as the round went.

GLM 5.3 Flash alone again, a third sample of one configuration. Round 7
(`results/2026-09-08/`) and round 8 (`results/2026-09-08-r2/`) are the
first two, both on helm `1f72e76`, both 17/17 + 19/19, and they differed
by 77 % in rounds (61 against 108). Two questions this round is meant to
answer:

1. **Is the round count really that variable at `low`?** Two samples cannot
   tell a wide distribution from one outlier. A third gives a range.
2. **Does the serving shift hold?** Round 8's fits showed decode up
   (28.4 → 33.2 tok/s on the app, 27.7 → 35.7 on the fixtures) and prefill
   down (1,134 → 861, 1,108 → 756) against round 7, on identical helm and
   near-identical prompt sizes. If round 9 sits with round 8, the serving
   changed between 2026-09-09T10:25Z and 01:03Z. If it sits with round 7,
   round 8 was the anomaly.

Protocol unchanged from rounds 7 and 8: helm `1f72e76` (T34), app prompt
`39413706` (sixth edition), effort `low`, fixtures (17) then the app task,
a warm session before each, caps 35 / 128, clocks 10 / 60 min, PORT=4099,
memory off, MCP off, consult denied. Nothing in helm has changed since
round 7, so all three rows are the same configuration.

`results/current` → this folder. Rounds 7 and 8 are untouched.

## Pre-flight (2026-09-09T02:40Z)

- helm at `1f72e76`, clean tree.
- Port 4099 free, no leftover `benchapp` process.
- GLM 5.3 Flash loaded and answering: 200 in 1.07 s on a 5-token probe.
- helm runtime up 20.1 h — the same BEAM that served rounds 7 and 8.

## GLM — `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`, label `glm53-flash-exl3`, effort `low`

Started 2026-09-09T02:40:58Z, spawned inside the helm dev runtime (the
same BEAM as rounds 7 and 8). Native vision, thinking enabled in the
deployment, `low` ≈ no thinking on this template.

### Fixtures — done 2026-09-09T02:50Z

**17/17 in 565 s** (round 7: 17/17 in 666 s; round 8: 17/17 in 592 s).
Tokens 209k uncached prompt, 9.2k completion. Nothing capped.

- **Zero refusals** (round 8: two). Round 8's two denials were the bash
  approval tripwire firing on test data — `rm -rf /` inside a quoted
  Elixir string in `safe_echo`, and `rm -rf scratch` on the session's own
  relative directory in `interval_merge`. Neither recurred here, on
  identical helm code, which settles that they were the model's choice of
  command and not a harness change. The tripwire gaps they exposed are
  still real and still worth a sprint; they simply are not deterministic.
- **`interval_merge` cost 46 s / 7 rounds** against round 8's 122 s / 17
  and round 7's 21 rounds. The rounds round 8 spent were recovery from its
  denied command, so this is the same fixture without that detour.
- Ten tool failures, all the model's, none fatal to a score.

| round | fixtures | wall | refused | slowest fixture |
|---|---|---:|---:|---|
| 7 | 17/17 | 666 s | 0 | `interval_merge` 21 rounds |
| 8 | 17/17 | 592 s | 2 | `interval_merge` 122 s / 17 rounds |
| 9 | 17/17 | 565 s | 0 | `split_bill_signed` 80 s / 7 rounds |

The fixture half is saturated: three runs, 51 of 51. It discriminates on
cost and on which tripwire edges a model happens to touch, not on score.

### App task — ended on a backend 400, not a summary

**The row is 19/19 on disk, but the turn did not finish.** At round 89 the
request returned

```
HTTP 400
{"error":{"code":400,"message":"At most 4 image(s) may be provided in one
prompt. (parameter=image)","param":"image","type":"BadRequestError"}}
```

That is the whole body as helm received it, not an excerpt: `Helm.Airo`
accumulates the error body across stream chunks without truncating
(`lib/helm/airo.ex:156`) and the stored string parses as complete JSON.
It came within 26 characters of being clipped, though — the record writes
the outcome through `outcome_word/1`, which is
`String.slice(inspect(reason), 0, 200)` (`lib/helm/evals/harness.ex:410`),
and this reason is 175 characters. A longer backend error would be cut in
the record with no marker, and the raw JSON is the only place it is kept.
Worth widening, or marking the cut, alongside the image fix.

and the turn ended with `outcome=error`, `ending=blank`. The model's last
words were mid-work — "Duplicate handling works live. Now dark mode, mobile
nav, and /about:" — so it believed it had more to do. The grader is
mechanical against disk state, precommit had been green since round 65, and
all nineteen gates passed anyway. Read the 89 rounds as a floor, not a
completion, and do not compare it to round 7's 61 or round 8's 108 as if
the three ended the same way.

**Cause — helm keeps eight images on the wire, this deployment accepts
four.** `Helm.Turn` pins `@images_on_wire 8` (`lib/helm/turn.ex:778`) and
re-attaches the last eight by id each round. The GLM 5.3 Flash deployment
caps a prompt at four. The counts settle it:

| session | preview calls | image artifacts | outcome |
|---|---:|---:|---|
| round 8 app | 15 | 2 | done, summary |
| round 9 app | 20 | 5 | HTTP 400 at round 89 |

Round 8 never crossed four, so it never saw this. Round 9's fifth
screenshot landed at 03:11:02Z and the next request carrying all five was
rejected; the run finished 03:12:19Z. Not every `preview` call yields an
image — click, type, scroll and wait_for do not — which is why 20 calls
made 5 artifacts and 15 made 2.

**How long has this been live? Three days, and this is the first time it
could bite.** Images only ride the main wire from T29 (`7e87114`, merged
2026-09-06 20:11:41 -0700 = 2026-09-07 03:11 UTC); before that every
screenshot reached the model as a marker through the digest gate, so the
count was irrelevant. Since T29 exactly two sessions have held more than
four images:

| session | when | model | images | result |
|---|---|---|---:|---|
| aster landing site | 2026-09-07 21:31 | DeepSeek V4 Flash Vision Exp | 7 | no error |
| bench:coding:app (round 9) | 2026-09-09 02:52 | GLM 5.3 Flash | 5 | HTTP 400 |

One image-cap error exists in the whole message store, and it is round 9's.
Earlier GLM sessions carrying 5, 6 and 13 artifacts (2026-09-06 02:43,
05:13 and 14:09 local) all predate the T29 merge, so their images were
never sent as parts.

The cap is GLM's deployment, measured directly against airo on
2026-09-09: 1 image 200, 4 images 200, 5 images 400, 8 images 400 —
exactly four. DeepSeek's tolerates at least seven, from the 2026-09-07
session above; its and Qwen's exact limits were not measured because
neither is loaded on the cluster right now (both return 404).

This is a T29 follow-up, not a bench-content issue: **the image bound has
to come from the model's capability, not a constant.** Until it does, any
vision-native model on a deployment with a cap below eight will lose a turn
the moment it takes a fifth screenshot. It cost nothing here only because
the app was already green.

- **Phases.** First write at round 27 (round 7: 13, round 8: 17), last
  write 44, precommit green at 65 (round 7: 46, round 8: 89), then a review
  pass of twenty consecutive `preview` rounds from 69 to 89 — which is what
  produced the fifth image and killed the turn.
- **Failures in the row (2), both the model's:** two edit misses (line 65
  matched ignoring whitespace with a differing tail; a pattern matching six
  times without `replace_all`). Zero refusals.
- **Watch — the countdown:** 0 mentions across 89 rounds, as in rounds 6,
  7 and 8. GLM has now never once mentioned it.
- Tokens: 237k uncached prompt, 18.9k completion, 6.6k reasoning. Tools:
  bash 41, preview 20, edit 19, write 5, job 2, read 1, todo 1. TTFT 2.8 s.

### Serving — round 8's "serving changed" reading does not survive

**Round 9 retires the claim made in round 8's log.** That log fitted round
latency against uncached prompt and completion tokens with one three-
parameter regression and read a shift out of it: decode up, prefill down
about 30 %, "something in the serving changed". Fitting round 9 the same
way produces nonsense — a prefill of 2,091 tok/s on the app set against
674 on the fixture set of the same round, and a **negative** overhead term
on the fixtures. Two coefficients competing for one intercept, nothing
more. The estimator was the finding, not the cluster.

Time-to-first-token separates the phases directly instead of asking one fit
to split them: prefill from a two-parameter fit of TTFT against uncached
prompt, decode as median completion tokens over the post-TTFT window.

| set | prefill tok/s | decode tok/s (median) |
|---|---:|---:|
| round 7 app | 1,092 | 23.4 |
| round 8 app | 953 | 30.9 |
| round 9 app | 996 | 22.2 |
| round 7 fixtures | 950 | 31.3 |
| round 8 fixtures | 901 | 34.6 |
| round 9 fixtures | 862 | 29.6 |

**Prefill is flat** — every value between 862 and 1,092 tok/s, drifting
down by a few per cent a round at most. The 1,134 → 861 "regression"
reported in round 8's log was an artifact. **Decode wanders**: round 8 is
the fastest in both sets, rounds 7 and 9 sit together below it. One
round-8-shaped bump, not a step change.

There is nothing to investigate on sparky. Round 8's log has been corrected
in place rather than left to send someone chasing it.

Method note for future rounds: prefer the TTFT split. The three-parameter
fit was inherited from earlier logs and it is not stable enough to support
a claim about serving — it agreed with itself for two rounds and then
produced a negative overhead on the third.


## Round summary

| round | fixtures | app | app rounds | app wall | ending | preview / images | green |
|---|---|---|---:|---:|---|---|---:|
| 7 | 17/17 | 19/19 | 61 / 128 | 14.9 min | summary | 7 / — | 46 |
| 8 | 17/17 | 19/19 | 108 / 128 | 18.7 min | summary | 15 / 2 | 89 |
| 9 | 17/17 | 19/19 on disk | 89 (cut) | 19.0 min | **HTTP 400, blank** | 20 / 5 | 65 |

**Question 1 — is the round count that variable at `low`?** Yes, though
round 9 answers it less cleanly than hoped. 61, 108, and at least 89 on
one unchanged configuration: the spread is real and wide, and green
arrived at round 46, 89 and 65. Anyone reading a single row's round count
as a property of the model is reading noise. The score does not move —
57 of 57 fixtures and three 19/19 app rows.

**Question 2 — does the serving shift hold?** No. It was never there; see
the Serving section. Round 8's log has been corrected.

**What this round actually bought** is the image finding: helm's
`@images_on_wire 8` against a deployment cap of 4, latent since T29 and
first triggered here. That is worth a sprint.

## Cleanup

Verified 2026-09-09T03:22Z: port 4099 free, no `benchapp` process left.

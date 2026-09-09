# Run log — round 2026-09-08-r2 (coding round 8 at `low`)

A re-run of GLM 5.3 Flash alone, on the same helm SHA as round 7
(`1f72e76`, T34 — the countdown inside the round's last tool result) and
the same sixth-edition app prompt (`39413706`). Nothing in helm changed
between the two rounds: this row is a second sample of the same
configuration, not a new one. Protocol as round 7: effort `low`, fixtures
(17) then the app task, a warm session before each, caps 35 / 128, clocks
10 / 60 min, PORT=4099, memory off, consult denied.

`results/current` → this folder. Round 7's records under
`results/2026-09-08/` are untouched.

## GLM — `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3`, label `glm53-flash-exl3`, effort `low`

Started 2026-09-09T01:03:30Z on helm `1f72e76`, clean tree. Native
vision, thinking enabled in the deployment, `low` ≈ no thinking on this
template.

Finished 2026-09-09T01:35:32Z.

- **Fixtures 17/17** in 592 s (round 7: 17/17 in 666 s). `interval_merge`
  took 17 rounds / 122 s (round 7: 21), `split_bill_signed` 10, nothing
  capped. Tokens 228k uncached prompt, 10.1k completion, ~2.3k reasoning.
- **App 19/19, done at 108 rounds**, 1,120 s (18.7 min; round 7: 61
  rounds, 14.9 min), ending `summary`, no nudge, no last call. Tokens:
  264k uncached prompt, 23.3k completion, ~8.5k reasoning (round 7: 163k
  / 16.6k / 6.5k). Tools: bash 44, edit 34, read 21, preview 15, write 10,
  grep 5, job 2, glob 1, todo 1. Tool time 88 s. Diff: 22 files
  +692/−171 (round 7: 18 files +628/−168), tests +13, one composite.
- **Phases.** Generator at round 1, first write at 17 (round 7: 13), last
  write 53, precommit green at 89 (round 7: 46), then nineteen rounds after
  green (round 7: fifteen) — fifteen of them a consecutive `preview` review
  pass, rounds 93 to 107 — and the summary at 108. The same shape as round
  7 but longer at every stage; the review pass after green is again against
  the brief's "do not re-verify", and it was three times the size of round
  7's (fifteen preview rounds against six).
- **Failures in the row (3), all the model's:** a `read` of
  `test/support/root.html.heex`, a file that did not exist, and two edit
  misses (lines 19 and 52 — the first line matched ignoring whitespace and
  the tail differed). No refusal in the app task.
- **Two fixture refusals — the approval tripwire on test data.** Round 7's
  GLM row had none; the code is identical, so this is the model's choice of
  command, not a change in helm. Both are worth reading:
  - `safe_echo`: the model ran

    ```
    elixir -e 'IO.inspect SafeEcho.run("hi; rm -rf / | `id` $(whoami)")' -r solution.ex
    ```

    The `rm -rf /` is **argument data inside a single-quoted Elixir string
    literal** — it is the fixture's own subject matter, shell-escaping —
    and the tripwire read it as a command. T32 made heredoc bodies data;
    a quoted `-e` argument is not a heredoc and is still read as code.
  - `interval_merge`: `mkdir -p scratch && cp solution.ex scratch/ && cd
    scratch && elixir -e '…' && cd .. && rm -rf scratch`. T33 established
    that `rm -f` on the session's own relative files passes; `rm -rf` on
    the session's own relative *directory* does not.
  Both denials read "denied by the operator (or approval timed out)" — the
  bench runs unattended, so a prompt that reaches an operator is a refusal.
  Neither cost a score: both fixtures passed, `interval_merge` after
  spending rounds recovering.
- **Watch — the countdown:** 0 mentions across the app session's 108
  rounds, as in rounds 6 and 7. GLM reads it silently or not at all; no
  budget-filling, no early stop.
- **Serving — CORRECTED 2026-09-09T03:20Z, after round 9.** This bullet
  originally reported a three-parameter fit of round latency against
  uncached prompt and completion tokens, read a ~30 % prefill regression
  and ~20 % decode gain out of it, and concluded that "something in the
  serving changed between 10:25Z and 01:03Z". **That conclusion was
  wrong.** Fitting round 9 (`results/2026-09-08-r3/`) the same way gives a
  prefill of 2,091 tok/s on its app set against 674 on its own fixture set,
  and a negative overhead term — the three parameters trade off against one
  another and the split is not identifiable from that regression. Using
  TTFT to separate the phases instead, prefill is flat across all three
  rounds (862–1,092 tok/s) and decode wanders with round 8 the fastest
  sample. There is no serving change to chase. Round 9's log carries the
  three-round table and the method note.
- TTFT 3.1 s (round 7: 2.9 s), app blended completion 20.8 tok/s (round 7:
  18.7).
- Cleanup verified 2026-09-09T02:20Z: port 4099 free, no `benchapp` process left.

| model | fixtures | app | app rounds | app wall | reasoning | preview calls | first write / last write / green / done | diff |
|---|---|---|---|---|---|---|---|---|
| GLM 5.3 Flash (low) | 17/17 (2 bash calls refused by the tripwire, both fixtures still passed) | 19/19, done, summary | 108 / 128 | 18.7 min | ~8k | 15 | 17 / 53 / 89 / 108 | 22 files +692/−171 |

**Against round 7, same SHA and same prompt.** Both rows are 17/17 +
19/19. The spread is in the path, not the result: 61 → 108 rounds, 14.9 →
18.7 min, 163k → 264k uncached prompt, green at 46 → 89. Two runs of one
configuration differing by 77 % in rounds is the useful number here — the
score saturates at this cap and the cost does not.

Open, for a sprint rather than this log: the tripwire reads a quoted
`elixir -e` argument as a command (`safe_echo`), and `rm -rf <relative
dir>` inside the session is not covered by T33's `rm -f` allowance
(`interval_merge`).

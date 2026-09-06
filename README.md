# benchmarks

Model benchmarks for the DGX Spark cluster (sparky + sparky2). **Start with
`COMPARISON.md`**, the cross-round comparison of the three models written
for people deciding what to run. Test design and test results are kept
apart:

```
design/      what a round IS — stable across rounds
  TESTPLAN.md        the repeatable protocol (read this first)
  CODING_BENCH.md    the helm coding bench: prompts, policy, oracle, checklist
  spark_bench.py     inference harness (TTFT, prefill, decode, concurrency, probe)
  make_report.py     renders a round's RESULTS.md from its raw/ JSON
  tools/             shoot_app.sh + cdp_shoot.py: boot a generated app, screenshot it
  corpus/            natural-text prompt filler (added per TESTPLAN §3.2)
results/
  current -> <round> symlink; every harness writes into results/current/
  <round>/           one directory per round, dated
    RUNLOG.md        what was loaded, paused, decided, and when (UTC)
    RESULTS.md       rendered tables
    REPORT.md        analysis; DESIGN_REVIEW.md  app screenshots review
    raw/  work/  screenshots/
```

A round, in one paragraph: make `results/<round>`, point `results/current` at
it, load one model, run `design/spark_bench.py` (Phase A), run
`Helm.Evals.Coding` from helm's dev seat (Phase B), run
`design/tools/shoot_app.sh <label>` (Phase C), unload, repeat for the next
model, then `python3 design/make_report.py` and write the two reports. Every
step, its acceptance criteria and the open decisions are in
`design/TESTPLAN.md`.

Rounds so far:

| round | models | notes |
|---|---|---|
| `2026-09-04` | glm53-flash-exl3, qwen38-flash-next-nvfp4, dsv4-flash-vision-exp | first round; improvised inference prompts, cached-token column missing for GLM/Qwen; see its `REPORT.md` §5 |
| `2026-09-04-r2` | same three | second-edition coding bench only (17 fixtures, hidden LiveView tests, rendered checks); DeepSeek 17/17 + 18/18 (oracle v2), Qwen 17/17 but app does not compile, GLM 15/17 + 14/18 at the cap; see its `REPORT.md` |
| `2026-09-05` | same three | round 3: effort explicit (`low`), endings classified, reasoning counted; DeepSeek 17/17 + 19/19, GLM 15/17 + 15/19 at the cap, Qwen 17/17 and app abandoned (helm discarded reasoning between rounds); DeepSeek `high` row superseded |
| `2026-09-05-r2` | same three | round 4: T25 helm echoes reasoning within the turn; GLM's thinking turned on for the first time; all three 19/19 on the app, GLM and DeepSeek 17/17, Qwen 16/17; see its `REPORT.md` and `DESIGN_REVIEW.md` |
| `dryrun` | qwen38-flash-next-nvfp4 | unscored harness dry run before r2; found the narrated-ending case that led to the nudge |

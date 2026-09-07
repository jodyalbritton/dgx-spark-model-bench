# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `2026-09-06-design`

Rendered by `design/make_report.py` from `results/2026-09-06-design/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.

_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._


## Front-end design (helm design bench)

Harness: `Helm.Evals.Design` — one brief (the JobyCorp website), one `DESIGN.md`, a prepared JobyKit base per round, one session per model at its ceiling effort. Two layers, never blended: **gates** are mechanical, pass/fail, decided by the harness; **ranking** is the rubric scored by the reviewer from anonymised composites (three shuffled passes, mean), and the public vote on the same images. Protocol: `design/DESIGN_BENCH.md`.

Every row ran on one harness:

- **glm53-flash-exl3** — helm `980a9f1`, brief `b0ff216c`, DESIGN.md `896b5475`, base `65eeaf1baa98` (joby_kit 0.3.3), effort max, vision Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3, cap 150 rounds / 5,400 s, 2026-09-06T14:08:59Z → 2026-09-06T14:59:45Z
- **qwen38-flash-next-nvfp4** — helm `5df7f09`, brief `b0ff216c`, DESIGN.md `896b5475`, base `65eeaf1baa98` (joby_kit 0.3.3), effort max, vision RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt, cap 150 rounds / 5,400 s, 2026-09-06T12:45:11Z → 2026-09-06T13:49:05Z
- **dsv4-flash-vision-exp** — helm `f667027`, brief `b0ff216c`, DESIGN.md `896b5475`, base `65eeaf1baa98` (joby_kit 0.3.3), effort max, vision deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8, cap 150 rounds / 5,400 s, 2026-09-06T23:18:29Z → 2026-09-07T00:19:47Z

### Gates

| model | gates | static (8) | rendered (11) | scores |
|---|---:|---|---|---|
| glm53-flash-exl3 | 18/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ❌ · ✅ · ✅ · ✅ · ✅ · ✅ | tests +6 · components +4 · reused 4 · lint warnings 0 |
| qwen38-flash-next-nvfp4 | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | tests +19 · components +6 · reused 6 · lint warnings 0 |
| dsv4-flash-vision-exp | 19/19 | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ · ✅ | tests +3 · components +1 · reused 1 · lint warnings 0 |

Static gates, in order: compile, test, lint, layout_replaced, page_tests, composite_registered, composite_reused, theme_pair. Rendered gates, in order: boots, routes, demo_gone, nav_current, no_overflow, contrast, icons_resolve, copy_clean, mobile_nav, theme_toggle_mobile, dark_theme.

Failed gates, as the harness saw them:

- **glm53-flash-exl3** `contrast`: about/light/desktop: 2 — th 4.24<4.5 "part"; th 4.24<4.5 "what that means" · about/light/phone: 2 — th 4.24<4.5 "part"; th 4.24<4.5 "what that means" · research/light/desktop: 3 — th 4.24<4.5 "measure"; th 4.24<4.5 "unit"; th 4.24<4.5 "what

### Ranking

| model | Identity | Hierarchy and rhythm | Type | Colour and themes | Phone | Copy | Restraint | Composite | mean | X vote |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| glm53-flash-exl3 | 3.3 | 3.0 | 4.0 | 4.3 | 4.3 | 4.0 | 3.7 | 3.3 | 3.75 | — |
| qwen38-flash-next-nvfp4 | 5.0 | 4.0 | 4.3 | 5.0 | 4.0 | 4.0 | 5.0 | 5.0 | 4.54 | — |
| dsv4-flash-vision-exp | 4.3 | 3.3 | 4.3 | 4.3 | 4.0 | 4.3 | 4.0 | 4.0 | 4.08 | — |

Rubric 1–5 per line, three shuffled passes, mean; the reviewer's prose is `DESIGN_REVIEW.md`. The X vote is recorded when it closes (`raw/review/vote.json`).

### Speed and tokens

| model | outcome (ending, nudges) | rounds | wall (s) | tool calls | uncached prompt | completion | reasoning | tools |
|---|---|---:|---:|---:|---:|---:|---:|---|
| glm53-flash-exl3 | done (summary, 0 nudges) | 103 | 2,990 | 140 | 240669 | 64663 | 39549 | edit 38, bash 29, read 28, preview 16, write 11, grep 8, glob 3, outline 2, todo 2, proc 1, read_artifact 1, tree 1 |
| qwen38-flash-next-nvfp4 | max_rounds (summary, 0 nudges); last call done in 2 rounds | 152 | 3,799 | 171 | 660020 | 137405 | 91748 | bash 63, edit 32, read 26, preview 19, write 18, job 4, todo 4, read_artifact 3, outline 1, proc 1 |
| dsv4-flash-vision-exp | done (summary, 0 nudges) | 139 | 3,627 | 158 | 220847 | 126406 | 93963 | bash 54, read 37, preview 28, edit 19, write 12, read_artifact 2, todo 2, tree 2, grep 1, proc 1 |

Screenshots per site: `screenshots/<label>-{home,research,about}-{light,dark}-{desktop,phone}.png`; the anonymised composites in `screenshots/review/`.

# The front-end design bench — protocol

Companion to `CODING_BENCH.md`. The helm sprint doc
(`helm/docs/sprints/T28-design-bench.md`) is the source of truth for the
harness; this file is what a reader of a round's results needs.

## What is measured

One brief (the JobyCorp website), one `DESIGN.md` (this folder's, copied
into the base), one prepared JobyKit base per round, three models at
their ceiling effort (`max`; Qwen's template ceiling is `xhigh`, airo
clamps). Each model sees with its own eyes: the operator points airo's
vision route at the loaded model for its run, and the harness refuses to
start if the route does not answer.

Two layers, never blended:

1. **Gates** — mechanical, pass/fail, decided by the harness: compile,
   the app's own tests, lint, routes, demo gone, nav current, no overflow
   at 390 px, contrast (WCAG AA, both themes, all pages), icons resolve,
   copy clean of kit/framework/task words, the DESIGN.md theme pair in
   place and default, a composite registered with a preview and used on
   two pages, boots, mobile nav, theme toggle at 390, dark theme.
2. **Ranking** — the rubric below, scored by Claude from anonymised
   composites (A/B/C), each set scored before any is compared, three
   passes with the order shuffled, mean. The key is sealed until the
   review is written. The X vote on the same three images is recorded
   beside the rubric when it closes.

## The rubric

Scored 1–5 per line.

| line | what 5 looks like |
|---|---|
| Identity | Reads as JobyCorp's own; a careful research company, not a template. |
| Hierarchy and rhythm | One glance finds the hero, the sections, the action; spacing is even and unhurried. |
| Type | The scale in DESIGN.md, used with restraint; measure and leading comfortable at both widths. |
| Colour and themes | Paper, ink, one accent; dark is finished, not inverted; nothing decorative. |
| Phone | 390 px is a design, not a collapse: nav, hero, sections, footer all considered. |
| Copy | Specific to JobyCorp, sentence case, short, nothing invented, nothing about the kit or task. |
| Restraint | Nothing from DESIGN.md's "what to avoid"; nothing that is there to decorate. |
| Composite | The registered composite is a real design element, used well on two pages. |

The review (`results/<round>/DESIGN_REVIEW.md`) names the three best and
worst decisions per set in prose, then ranks, then the key is opened.

## Round protocol

As the coding bench: one helm SHA per round (a dirty tree refuses), one
`RUNLOG.md` per round, raw files append-only, `superseded/` for
off-protocol runs, the operator swaps models (and the vision route)
between runs. Caps: 150 rounds / 90 minutes, the last call, the stopping
line in the brief. Memory off, MCP off, consult denied, `preview` on.

## Files per round

- `raw/design-<label>.json` — the run record (harness block: effort,
  caps, prompt sha, `DESIGN.md` sha, base tree hash, joby_kit version,
  vision model).
- `raw/reasoning/<label>-site.jsonl` — per-round reasoning sidecar.
- `screenshots/<label>-<page>-<theme>-<width>.png` — 12 per model.
- `screenshots/review/<A|B|C>.png` — the anonymised composites;
  `raw/review/key.json` — the shuffle, sealed until the review.
- `DESIGN_REVIEW.md`, `RESULTS.md`, `RUNLOG.md`.

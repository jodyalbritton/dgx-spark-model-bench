# Design review — round 2026-09-06-design (design bench, round 1)

Reviewed 2026-09-07 by Claude, blind: three fresh reviewer sessions each saw only
`screenshots/review/{A,B,C}.png` (twelve shots per site: home / research / about
× desktop light / phone light / desktop dark / phone dark), `design/DESIGN.md`,
and the rubric in `design/DESIGN_BENCH.md` — never the model labels, never the
transcripts. Each pass saw the sets in a different order (A B C · B C A · C A B),
scored each set fully before opening the next, then ranked. The key
(`raw/review/key.json`) was opened after all three passes were in.

## Result

| set | model | Identity | Hierarchy | Type | Colour | Phone | Copy | Restraint | Composite | mean | ranks by pass |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A | **Qwen 3.8 Flash Next** | 5.0 | 4.0 | 4.33 | 5.0 | 4.0 | 4.0 | 5.0 | 5.0 | **4.54** | 1 · 2 · 2 |
| C | **DeepSeek V4 Flash Vision Exp** | 4.33 | 3.33 | 4.33 | 4.33 | 4.0 | 4.33 | 4.0 | 4.0 | **4.08** | 2 · 3 · 1 |
| B | **GLM 5.3 Flash** | 3.33 | 3.0 | 4.0 | 4.33 | 4.33 | 4.0 | 3.67 | 3.33 | **3.75** | 3 · 1 · 3 |

**Ranking by mean: Qwen, DeepSeek, GLM.** Qwen is the only set no pass ranked
below second, and it leads on identity, restraint, and the record card — the
direction's one bold object, which it alone *developed* (an eight-field card on
the landing page, a fuller sibling with `run id` / `prompt set` / `repeats` on
research) rather than repeating.

## What the shuffle caught

Every pass ranked first the set it saw first (A in pass 1, B in pass 2, C in
pass 3), and the two other passes each put that set second or third. That is
primacy in the reviewer, not a property of the sites; three shuffled passes
and a mean are exactly the instrument for it, and the mean ranking is stable
under it. Two passes agreed on every pairwise order except where primacy
intervened. Treat any single-pass review of this kind as unreliable.

## The sets, in the reviewers' words

**A — Qwen.** "The record card is the best decision on any of the three: a
full-height plotting-paper specimen with eight fields, units right-aligned,
hairlines between rows, a teal frame and a caption set beneath it — and a
genuine sibling on /research." "The full-width measures table with a 'how to
read it' column is the most useful figure in the set." Against it: "a table of
five under the words 'six quantities'" — a real copy slip — and a caption that
says "a sibling of the card on the landing page", the site describing itself;
body, sub-headings and the button set a notch small beneath a very large hero;
a seven-line phone hero; the numbered method block tighter than its
surroundings; the phone table clipping its last column inside its scroller.

**C — DeepSeek.** "The best desktop composition of the three — prose paired
with a figure in the right column on every page"; "the 01 / monospace step /
prose method block is the single most instrument-like element in the whole
set"; and "the single best line in the benchmark: 'Measured on the hardware
that ran the model, never carried over from a vendor's spec sheet.'" Against
it: the same six-field list four times across two pages (hero card, home
table, research table, research card), which dilutes the object; a
fourteen-word hero at display size, six lines on desktop and eight on phone,
swamping its own card; a section hairline flush against the lead paragraph on
every page; card field names and step labels set lighter than DESIGN.md's
`/70` floor (one pass); nav links close to the theme icons; the closing
section's link text repeating its heading.

**B — GLM.** "The shortest, best-proportioned headline of the three — 'Local
LLMs, measured on our own hardware.'"; "executes the direction end to end
without a single error … its fault is under-spending, not misspending" (the
pass that saw it first). Against it, from all three: the whole site hugs the
left half of the column with a dead right half on every desktop page; type a
size down from the direction; a squat five-field record card with its caption
inside the frame, "a widget rather than the direction's one bold object"; an
inline mono string standing in for a figure on home; copy that repeats across
pages and talks about the site ("This page is that method"); two identical
primary buttons per view.

## Read together with the gates

Gates: Qwen 19/19, DeepSeek 19/19, GLM 18/19 (table headers at 4.24:1 in the
light theme). The gates and the rubric agree on the order, for different
reasons: the gate GLM missed is the floor the direction names, and what the
reviewers held against it is what it did not spend. DeepSeek caught its own
version of that miss before the gate could. Qwen's faults are the faults of the
most ambitious set — one wrong number, one self-referential caption, a scale
notch — and the reviewers said so in every pass.

The X vote on the same three images is recorded in `raw/review/vote.json`
when it closes.

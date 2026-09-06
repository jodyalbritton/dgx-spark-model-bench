# Design review — round 2026-09-05-r2 (round 4, third-edition prompt)

Reviewed 2026-09-06 from the harness captures in `screenshots/` (1440×900
desktop, 390×844 phone, light and dark emulated). All three apps pass all
19 checks, so this is a record of how they differ, not a score. The prompt
is the third edition (markdown, numbered requirements): a fictional
product, mobile and desktop, light and dark, `#main-nav` with a phone menu
and a theme toggle usable at both widths, hero, live countdown, signup
form with error and duplicate handling, stats strip, activity feed capped
at ten, a registered feature-grid composite, `/about`.

## Ranking

| rank | model | product | verdict |
|---|---|---|---|
| 1 | **glm53-flash-exl3** | "Solstice", a desk lamp | The only page that reads as a product rather than a demo of the kit. The countdown copy makes the five-second tick make sense. One blank icon. |
| 2 | **dsv4-flash-vision-exp** | "Lumen", a launch platform | The most conventional marketing page: full-width bands, generous whitespace, product copy throughout. Missing one empty state. Tall. |
| 3 | **qwen38-flash-next-nvfp4** | "Lumen", realtime product surfaces | The most engineered and most compact: everything live sits in one card beside the hero. Copy describes the kit, not a product. No dark shot captured. |

The gaps are small. Any of the three would pass as a launch page. GLM
places first on copy and framing, DeepSeek on layout convention, Qwen on
interaction design.

---

## glm53-flash-exl3 — "Solstice"

**Nav.** Sticky bar, bolt-in-circle brand mark, four links with a soft
active pill, the kit theme toggle carrying `#theme-toggle`, hamburger at
phone widths. Footer with a tagline and the two kit routes.

**Hero.** Two columns: eyebrow "SOLSTICE · EARLY ACCESS", a three-line
headline ("The desk lamp that keeps pace with your rhythm."), product
copy that is actually about a lamp, primary + ghost CTAs. On the right,
the countdown in a card with a warm gradient wash: "EARLY-BIRD PLACES
REMAINING", the number in primary, "one spot opens up every five
seconds". That reframing is the best single piece of copy in four rounds
of this bench; every other app says "seconds" under a number that moves
every five.

**Below.** A three-stat strip (signups, countdown ticks, and a decorative
"60k hours of light"), six feature cards under "Everything a desk lamp
should be" with lamp-specific copy (wind-down mode, zero flicker), then
newsletter and live activity side by side, both with empty states.

**Mobile.** Theme toggle and hamburger both visible. Hero, card, stats
(stacked), six cards, form, activity, footer. Nothing overflows.

**Dark.** Good; the countdown card's gradient goes to a deep navy.

**Nits.** The "Built to last" tile renders an empty icon square: the
heroicon name is not one the kit ships. "Read the story" is styled as a
bare link rather than a ghost button, which reads as an afterthought
next to the primary CTA.

---

## dsv4-flash-vision-exp — "Lumen"

**Nav.** Sticky, bolt brand, four links (the fourth relabelled
"Components"), theme toggle with the id on the kit component, hamburger
on phones. Footer with copyright and the two kit routes.

**Page.** A stack of full-width bands: a peach-washed hero ("Launch like
the future depends on it.", primary + arrow-link CTAs), a countdown band
(eyebrow, 8xl number, "seconds", caption), "Join the waitlist" with a
labelled input and orange button, a stats strip of two large numbers,
"Live activity" with an empty-state line, six feature cards under "Why
Lumen", footer. 2,539 px tall, the tallest of the three.

**Mobile.** Toggle and hamburger visible. Bands stack cleanly; the stat
strip becomes two side-by-side numbers.

**Dark.** Good; the hero wash fades into a dark violet-grey.

**Nits.** "Recent signups" is a heading with nothing under it before the
first signup; the activity section has an empty state, the signups list
does not. The waitlist band centres its copy but left-aligns the
"Recent signups" heading, so the band looks unbalanced when empty.

---

## qwen38-flash-next-nvfp4 — "Lumen"

**Nav.** Sticky, text-only brand, four links with an active pill, theme
toggle, hamburger. Footer with a tagline, About, and the three kit
routes.

**Page.** Two-column hero: badge "Live demo", a three-line headline
("Ship realtime product surfaces without the wiring."), copy, primary +
ghost CTAs, and a two-stat card under the copy. On the right, one card
holds the countdown ("LAUNCHING IN 100 seconds · −1 / 5s", an "updating
live" badge), the signup form, a "Recent signups" list with a count badge
and empty state, and the activity feed with an empty state. Below, six
feature cards with eyebrow tags (ENGINE, SAFETY, CRAFT…), footer.
1,387 px, the shortest of the three.

**Mobile.** Toggle and hamburger visible; hero copy, stats card, the
live card, six features, footer. Compact and clean.

**Dark.** Not captured; the harness saved five shots for Qwen and six
for the others. The `dark_theme` check passed on the DOM probe.

**Nits.** The feature-grid intro reads "Built from `<.feature_grid>`, a
registered composite that lays out one `<.card>` per feature", and the
cards are about typed contracts and agent-readable manifests: this is
the kit describing itself, not a fictional product. The prompt forbids
benchmark-themed copy, and this is a near relative. The hero's live
card is dense; on desktop it works, on a phone the form sits a long way
below the CTA that points at it.

## Cross-cutting

- **Empty states are now universal** except DeepSeek's signups list;
  round 2's GLM had none, round 4's GLM has both.
- **All three theme toggles are visible on phones**, the check added
  after round 2 caught GLM's hidden one.
- **Copy is where the models still differ.** GLM wrote a product. Qwen
  wrote about the kit. DeepSeek wrote a launch platform, which is a
  product, but a generic one.
- **Four Lumens in three rounds** (Qwen, DeepSeek ×2, GLM's LumenLab in
  round 2). GLM's thinking-on run is the only one to break the pattern.

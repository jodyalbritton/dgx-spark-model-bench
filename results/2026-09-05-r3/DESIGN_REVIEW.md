# Design review — round 2026-09-05-r3 (round 5, all three at maximum effort)

Reviewed 2026-09-06 from the harness captures in `screenshots/` (1440×900
desktop light and dark, 390×844 phone, full-page). All three pages pass the
19 checks. This review does not rank them: at maximum effort all three
produced pages with a distinct identity, and which identity is better is a
matter of taste. A separate design-only round with a shared design brief
and blind pairwise judging is planned to answer that question properly.
What follows is what each page is, and the objective differences.

## Objective checklist

| | GLM "Windrose" | Qwen "Lodestar" | DeepSeek "Hearth" |
|---|:---:|:---:|:---:|
| empty state on the signups list | ✅ | ✅ | ❌ (heading with nothing under it) |
| empty state on the activity feed | ✅ | ✅ | ✅ |
| broken icons or images | none | none | none |
| horizontal overflow at 390 px | none | none | none |
| theme toggle visible at 390 px | ✅ | ✅ | ✅ |
| theme control | kit's three-way | single sun button | kit's three-way |
| kit pages (`/design`, `/custom-designs`) reachable | nav + footer | nav + footer | nav + footer |
| countdown copy consistent with a 5 s tick | "early-access keys… each pulse" | "one beat = 5s" | "steps down every 5 seconds" |
| desktop page height | 2,424 px | 2,827 px | 2,250 px |
| phone page height | 3,646 px | 5,414 px | 3,540 px |
| closing call to action | ✅ | ✅ | ❌ |
| custom theme colours | no (kit orange) | no (kit orange, monospace type) | yes (warm red/amber) |

## GLM — "Windrose", offline-first trail maps

Centred hero with a beta badge, two-line headline ("The map in your pack.
No bars required."), lede, primary + link CTAs, then an illustrated card:
a dotted trail across a faint grid with waypoints and a coordinate caption.
Below, a two-column band: the countdown as "early-access keys remaining"
with a progress bar and a warm gradient, and the waitlist form with its
empty state. A two-tile stats strip with icons. The activity panel with an
empty state. Six feature cards with tinted icon tiles and trail-specific
copy. A closing "Ready when you are" CTA. Footer with the kit routes. On a
phone everything stacks in the same order; the hero illustration scales
down cleanly.

## Qwen — "Lodestar", data pipelines on a launch schedule

A flight-deck theme in monospace type. Two-column hero: headline ("Put
your data pipelines on a launch schedule."), lede, primary + link CTAs,
three inline proof stats; on the right a panel with the countdown as
"manifest closes in 100 beats", a progress bar, and a seats-left readout.
A four-tile stats strip. Two side-by-side cards: the crew-manifest signup
with an illustrated empty state, and the flight-log activity feed with
its own. Six numbered feature panels, one highlighted. A two-column
"boarding procedure" list and a cohort card. A closing "Final call" band.
Footer with all four kit routes. The tallest page of the three and the
densest; on a phone it is 5,414 px, with the hero panel, the four stats,
and both cards each taking a full screen.

## DeepSeek — "Hearth", a family's shared lists

A custom warm theme (red primary, amber accent, cream surface). Centred
hero with a beta badge, two-tone headline ("A calmer home, one list at a
time."), lede, primary + soft CTAs. A countdown card with a gradient wash
beside two stat cards. A tinted "early access" band with the form inside
it and a "Recent signups" heading that has nothing under it before the
first signup. Six feature cards, the first highlighted. A "live feed"
section with an empty state. Footer. No closing CTA. On a phone the band
and cards stack in order and the custom theme reads well in both schemes.

## Observations that are not taste

- **At maximum effort every page has an identity.** At `low` (round 4) the
  same three models produced pages that looked like the template with the
  demo content swapped; here each one chose a register (trail, flight deck,
  hearth) and carried it through copy, icons, and layout.
- **Completeness still separates them.** DeepSeek's missing empty state is
  the same gap it has carried since round 4. Qwen's single-button theme
  control drops the kit's "system" option. GLM's page has no such gaps this
  round; its round-4 page had a blank icon.
- **Copy is on-product for all three.** No kit-themed or benchmark-themed
  copy this round.
- **Density is a choice, not a defect.** Qwen's page is twice the height
  of the others on a phone. Whether that is thorough or long is exactly
  the kind of question the design round should put to blind judges.

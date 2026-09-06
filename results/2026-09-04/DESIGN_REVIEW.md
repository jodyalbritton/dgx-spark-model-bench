# Design review — the three generated `benchapp` landing pages

Reviewed 2026-09-04. Each app under `work/<label>/benchapp` was booted one at a
time on port 4099 (`PORT=4099 mix phx.server`, dev env, fresh `mix ecto.create`),
captured with headless Chrome over the DevTools protocol, and stopped before the
next one started. Screenshots live in `screenshots/`:

| file suffix | viewport | notes |
|---|---|---|
| `-desktop-light.png` / `-desktop-dark.png` | 1440×900 | above the fold, `prefers-color-scheme` emulated |
| `-full-light.png` | 1440 × full page | whole landing page |
| `-mobile-light.png` / `-mobile-full-light.png` | 390×844 | phone viewport, above the fold and full page |
| `-desktop-light-after-11s.png` | 1440×900 | same page held open 11 s to prove the countdown ticks |

Runtime facts, identical for all three: the page returns 200, the LiveView socket
connects (`phx-connected`), and the countdown reads **100** on mount and **98**
after 11 seconds, so the 5-second server tick is real, not a static number. The
prompt asked for: a new top nav in `Layouts.app` with the stock `simple_nav` and
the "built with" footer removed, a modern landing page in `HomeLive`, and a
countdown from 100 stepping down by 1 every 5 s. All three met the letter of the
prompt. The differences are in polish, responsiveness, and code hygiene.

## Ranking

| rank | model | one-line verdict |
|---|---|---|
| 1 | **dsv4-flash-vision-exp** | The only page that is actually responsive: a real mobile menu, a two-column hero with a "live" countdown card, six tinted feature cards. Cleanest code. |
| 2 | **glm53-flash-exl3** | The most complete page (hero, features, closing CTA) and the nicest countdown card, but the nav does not collapse on mobile and the page-level classes tripped the lint. |
| 3 | **qwen38-flash-next-nvfp4** | Clean and coherent, but the nav simply disappears below `md` with no menu, there is no closing section, and the countdown card carries dead space. |

All three are plausibly "modern": sticky translucent header with backdrop blur,
gradient brand tile, gradient headline word, tabular-nums monospace countdown,
feature grid on cards. They read like the same design brief executed by three
people who all follow the same Tailwind/daisyUI idiom, which is what the JobyKit
`AGENTS.md` steers toward.

---

## dsv4-flash-vision-exp (DeepSeek-V4-Flash-Vision-Exp fp8)

**Layout / nav.** Sticky header, brand tile with a bolt icon, three links whose
active state is a soft primary tint (`bg-primary/10 text-primary`), theme toggle,
and a hamburger button that `JS.toggle`s a stacked mobile menu below `md`. The
links are data-driven (`@default_nav_links` on the module, overridable by a
`nav_links` attr), so adding a page is a one-line change. The stock nav and footer
are gone. This is the only app with a working navigation story on a phone.

**Landing page.** Two-column hero on `lg`: copy on the left (badge, headline with a
gradient "web apps", paragraph, primary + soft buttons, two check-mark
reassurances), countdown card on the right with a pulsing green "live" pill, a
blurred gradient halo behind it, and a 7xl gradient number. Below it a "Why
Benchapp" section with six feature cards in a 3×2 grid, each with a differently
tinted icon tile (primary / secondary / accent / info / warning / success). The
feature card is a registered composite (`CompositeComponents.feature_card`, with a
manifest entry and a `/design` preview), which is exactly what `AGENTS.md` asks
for. No closing CTA section, so the page ends on the grid.

**Mobile.** Stacks cleanly: hero copy, buttons wrap onto two lines, countdown card,
then the six cards in one column. Hamburger present. Nothing overflows.

**Dark mode.** Good. Halo and tints survive the theme switch; the gradient number
reads well in violet.

**Nits.**
- The gradient-filled "100" in light mode blends orange into a dark brown, which
  reads muddier than a flat primary would; in dark mode it is fine.
- `eyebrow` is not a Tailwind or daisyUI class; harmless but dead.
- `assign(assigns, mobile_open: false)` is never read; the mobile menu is toggled
  purely client-side.
- Six feature cards for a scaffold app is a lot of lorem-adjacent copy, though the
  copy is at least specific to JobyKit (`/design.json`, `mix joby_kit.lint`).

**Code hygiene.** Countdown is the textbook pattern: `Process.send_after` only when
`connected?`, `handle_info(:tick)` clamps at 0 with `max/2` and stops rescheduling
at 0. Lint clean. `mix format` was applied.

---

## glm53-flash-exl3 (GLM-5.3-Flash EXL3 4bpw)

**Layout / nav.** Sticky translucent header, brand tile, a pill-style link group
(`rounded-full`, `aria-current="page"` on the active item) in a proper
`<nav><ul><li>` structure, then a "Get started" button (hidden below `md`) and the
theme toggle. Semantically the best-marked-up nav of the three. Stock nav and
footer removed.

**Landing page.** Three sections, the most complete composition:
1. Hero on a subtle dot-grid (`radial-gradient` in inline style) with a "Now in
   open beta" badge, a two-line headline with a gradient tail, paragraph, primary
   + ghost buttons, and the countdown card.
2. "Why Benchapp" with three elevated cards (bolt / chart / clock icon tiles).
3. A closing CTA card ("Ready to measure what matters?") with a primary button.

The countdown card is the best of the three: label, `100 / 100` with the total
shown, a daisyUI `<progress>` bound to the value so the bar drains as it ticks,
and a caption. Copy is on-theme for a benchmarking product.

**Mobile.** This is where it loses to DeepSeek. The nav has no breakpoint logic:
at 390 px "Custom Designs" wraps onto two lines and the theme toggle is pushed off
the right edge of the viewport (visible in `glm53-flash-exl3-mobile-light.png`).
The rest of the page stacks fine.

**Dark mode.** Good; the dot-grid uses `currentColor` so it adapts.

**Nits.**
- The closing CTA uses `variant="ghost"` on the card, which renders as a very
  faint bordered box with generous empty padding; it looks unfinished next to the
  elevated feature cards.
- Badge is hand-rolled daisyUI classes (`badge badge-primary badge-soft badge-sm
  mx-auto badge`, with `badge` duplicated) instead of the `<.badge>` wrapper.
- The three feature cards repeat the same class strings inline. `mix
  joby_kit.lint` flags this as three `duplicated_class_string` warnings (still a
  pass, but the other two models registered a `feature_card` composite and came
  out clean).
- Uses Tailwind v4 names (`bg-linear-to-r`) while the other two use the v3
  `bg-gradient-to-r` aliases; both render, GLM's is the current spelling.

**Code hygiene.** Countdown uses `:timer.seconds(5)` through a public
`countdown_interval_ms/0`, schedules only when connected, clamps at 0 with
`update/3`. Correct and readable; the `if ... else socket` in `handle_info` is a
little verbose.

---

## qwen38-flash-next-nvfp4 (Qwen3.8-Flash-Next NVFP4)

**Layout / nav.** Sticky header, brand link with gradient tile, three links with a
`bg-base-200` active pill, theme toggle and a "Get started" button on the right.
The third link is relabelled "Components" (it still points at `/custom-designs`).
The link group is `hidden md:flex` with **no mobile alternative**, so on a phone
the only navigation is the brand link back to `/`. Stock nav and footer removed.

**Landing page.** Single flowing section: a large blurred primary/secondary blob
behind the hero, an info-toned badge, headline with gradient "invent themselves",
paragraph, primary + ghost buttons, then the countdown card and a three-card
feature grid using a registered `feature_card` composite (icon tile changes to
solid on hover, card lifts). No closing CTA; the page stops after the grid at
1311 px, the shortest of the three.

The countdown card is the boldest (7xl, `font-black`) with a progress bar and a
caption that switches to "Liftoff. 🚀" and turns the number green at zero. Nice
touch, but the card has ~40 px of dead space under the caption on every viewport.

**Mobile.** Content stacks fine, but no nav links and no hamburger.

**Dark mode.** Good.

**Nits.**
- The info-blue badge sits against an orange primary; the two accents fight.
- `"Get started"` wraps a `<.button>` inside a `<.link>`, producing a `<button>`
  inside an `<a>`, which is invalid interactive nesting (the other two pass
  `navigate` to the button itself).
- A catch-all `handle_event(_event, _params, socket)` that silently swallows every
  client event; nothing on the page sends events, so it is dead code that would
  hide future mistakes.
- The `cond` in `handle_info` special-cases `count == 1` to avoid rescheduling;
  correct, but `max(count - 1, 0)` plus a single `if` (as GLM and DeepSeek wrote)
  says the same thing more plainly.

**Code hygiene.** Lint clean, formatted, registered its composite with a preview.
Countdown schedules only when connected.

---

## Cross-cutting observations

- **Nobody added a test.** All three `test/` trees are byte-identical to a fresh
  `mix joby_kit.new`. The harness `test` check passes on the generator's own four
  tests, so it measures "did not break the scaffold", not "tested the feature".
- **Nobody touched the other pages.** `/design` and `/custom-designs` still render
  inside the new layouts but pass no `active_nav`, so the nav highlight only ever
  lights up on Home. That is a generator gap, shared by all three.
- **All three reformatted generated files.** `mix precommit` (from `AGENTS.md`)
  runs `mix format`, which is why `design_manifest.ex`, `design_previews.ex` and
  the two stock LiveViews differ from a fresh generation by parentheses and line
  wraps only. No model edited those files by hand.
- **Only DeepSeek and Qwen registered a composite.** Both added a `feature_card`
  with a manifest entry and a `/design` preview, which is the JobyKit contract.
  GLM inlined the cards and took three lint warnings for it.
- **Responsiveness was the real differentiator.** The prompt never said "mobile",
  and only DeepSeek treated a top nav as something that must collapse.

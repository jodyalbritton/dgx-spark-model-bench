# Design review — round 2026-09-04-r2 (second-edition app prompt)

Reviewed 2026-09-05 from the harness's own captures in `screenshots/`
(`<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`,
1440×900 desktop, 390×844 phone, both colour schemes emulated). The `-regrade-`
shots are byte-for-byte the same apps re-captured under oracle v2 and are not
reviewed separately.

The prompt this round turned "modern" into a contract: a fictional product of
the model's choosing, mobile and desktop views, working light and dark themes,
a `#main-nav` with `aria-current` and a phone-width toggle, a `#theme-toggle`,
a hero, a live `#countdown`, a newsletter form with error and recent-signups
list, a `#stats` strip, an `#activity` feed, a registered feature-grid
composite, and an `/about` page. Two of the three apps boot; the third does
not compile, so there is nothing to look at.

## Ranking

| rank | model | product | verdict |
|---|---|---|---|
| 1 | **dsv4-flash-vision-exp** | "Lumen", a calm note-taking workspace | The most finished page: every required element present and visible on both viewports, empty states written, footer, consistent spacing. Weak brand mark. |
| 2 | **glm53-flash-exl3** | "LumenLab", instruments for curious teams | Bigger, more editorial hero and a six-card grid, but the theme toggle is hidden on phones, the activity box and signups list have no empty state, and the hero copy contradicts the countdown. |
| — | **qwen38-flash-next-nvfp4** | "SIGNAL", realtime analytics | Does not compile (`~p` in a module attribute). Nothing rendered; see the code note at the end. |

Both booting apps independently named their product some form of "Lumen".

---

## dsv4-flash-vision-exp — "Lumen"

**Nav.** Sticky, translucent header with a `<nav id="main-nav">`, a brand
link, a daisyUI horizontal menu on `md+` with `menu-active` and
`aria-current="page"` on the current link, the kit theme toggle carrying
`id="theme-toggle"`, and a square ghost button `#nav-toggle` that
`JS.toggle`s a stacked `#mobile-menu`. Links are data-driven from a module
attribute. Footer with the three kit routes. The stock nav and footer are
gone.

**Hero.** Eyebrow, one-line headline ("Make space for what matters."),
two-line lede, a single primary CTA to `/about`, and the countdown in a
bordered card: eyebrow, 5xl/6xl primary-coloured number, caption. Restrained
and balanced. The caption "seconds — 100 and counting down" is a small lie
(ticks are five seconds apart), shared with GLM.

**Below the fold.** A "Features" section using the kit `<.header>` with
eyebrow and subtitle, then the registered `feature_grid` composite: six
cards with tinted icon tiles. Then a two-column band: newsletter form and
recent-signups list on the left; two registered `stat_card`s (Signups,
Ticks) and the activity panel on the right. Both lists render an
empty-state line ("No signups yet.", "Live activity will appear here."),
which is why the page looks complete before anyone interacts with it.

**Mobile.** Theme toggle and hamburger both visible top-right. Hero, card,
six features, form, two stat cards side by side, activity, footer all
stack without overflow.

**Dark.** Clean. Primary shifts to the theme's violet; card borders hold.

**Nits.**
- The brand mark is a small orange pill with two lighter dots. It reads as a
  toggle switch, not a logo.
- One CTA in the hero, and it leaves the page. The signup form is the
  conversion point and is not linked from the hero.
- The countdown card's caption and the stat card labels are set in very light
  grey at small sizes; contrast is marginal in light mode.

---

## glm53-flash-exl3 — "LumenLab"

**Nav.** Sticky header containing `<nav id="main-nav">` with a beaker-icon
brand, a desktop `<ul>` of links with `aria-current`, a `#theme-toggle`
wrapper around the kit toggle, and a raw `<button id="nav-toggle">` that
toggles `#nav-menu` between two custom classes defined in `app.css`. Footer
with copyright and the two kit routes. Stock chrome gone.

**Hero.** Peach-to-white gradient wash, "SHIPPING SOON" eyebrow, a two-line
headline with the second phrase in primary, lede, primary + ghost CTAs
("Get early access" dispatches a custom JS event meant to focus the form;
nothing listens for it), then the countdown as a bare 7xl/8xl number with
"LAUNCHING IN" above and "seconds remaining" below. The most editorial of
the three heroes.

**Below the fold.** A full-width stats strip (two large zeros), the
registered `feature_grid` composite with six cards, then a two-column band:
"Join the beta" form with a labelled input and joined button, a "RECENT
SIGNUPS" heading, and on the right an "Activity" panel. Footer.

**Mobile.** The nav collapses to the hamburger and the menu works. The
theme toggle wrapper is `hidden sm:block`, so at 390 px there is no theme
control at all; the DOM has the id, the user cannot reach it. Everything
else stacks well; the stats strip becomes two rows.

**Dark.** Good; the gradient wash fades to the dark base.

**Problems visible in the shots.**
- The activity panel is an empty rounded box with nothing in it, and
  "RECENT SIGNUPS" is a heading with nothing under it. No empty states.
- "seconds remaining" under a countdown that ticks every five seconds.
- The hidden-on-phone theme toggle (above).

**Code problems that the shots cannot show but the checks did.** The
signup form posts `signup[email]`, not the `name="email"` the prompt
specified. Under oracle v2 the hidden tests reached the handler anyway and
it crashed: signups and activity entries share one ETS table and the
signup counter pattern-matches only the signup tuple shape, so the first
activity entry in the table raises `FunctionClauseError`. Six of GLM's own
nineteen tests fail on the same line. Details in `REPORT.md` §4.

---

## qwen38-flash-next-nvfp4 — "SIGNAL" (did not compile)

The layout defines its nav links as a module attribute using the `~p`
sigil, which Phoenix's verified routes only allow inside functions, so the
module never compiles and nothing boots. Reading the template anyway: a
`main_nav/1` function component with a bolt-icon brand, a desktop link row
and a `nav-toggle` disclosure. The desktop row's class list contains
`[md:flex]`, an arbitrary-variant typo for `md:flex`, so even after the
compile fix the desktop links would never appear. HomeLive is the largest of
the three (385 lines) with a six-item feature list and a `stream` for the
activity feed. The model ended both of its turns by announcing its next
step ("Now let me rewrite HomeLive cleanly:") instead of taking it.

## Cross-cutting

- **Empty states decide the first impression.** DeepSeek wrote them; GLM
  did not. On a page whose lists are empty until someone acts, that is the
  difference between "finished" and "half-built" in the very first
  screenshot.
- **The theme toggle contract was read two ways.** DeepSeek put the id on
  the kit component; GLM wrapped the component in a div carrying the id and
  then hid the div on phones. The rendered check only asks whether the id
  exists.
- **Both booting apps used the kit correctly** where it mattered: registered
  composites with previews, `<.link navigate>`, kit buttons. GLM's one lint
  warning is the raw `<button>` for the nav toggle.
- **Copy quality was similar** and product-appropriate; nobody wrote
  benchmark-themed copy this round, which the prompt forbade after round 1.

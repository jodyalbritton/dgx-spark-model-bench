# DESIGN.md — JobyCorp

This is the design direction for the JobyCorp site. It is one direction,
shared by everyone who builds the site. Where the brief and this file
differ, the brief wins. Where this file is silent, use judgment and keep
to its spirit: an instrument, not a brochure — and not a document
either.

## Who this is for

JobyCorp runs analysis and benchmarks of local LLMs on its own hardware
and publishes the work in full. The visitor is technical, skeptical, and
short on time. They have seen a hundred AI company sites and trust none
of them. This one earns trust by looking like the work: exact, modern,
and confident — a well-made instrument that someone clearly cared about.
It should feel technical, not clinical. A plain page of paragraphs is a
failure of this brief as much as a page of gradient blobs is.

## The one idea

Measurement is the subject, so measurement is the look. The site has
two voices: a sans for reading and a monospace for anything measured —
field names, units, model identifiers, tables. The monospace voice is
not decoration; it marks the places where a visitor is looking at data.

The memorable object is the **record card** in the hero: beside the
one-sentence statement of what JobyCorp does sits a specimen of a
JobyCorp run record — the fields a record carries and the unit each
quantity is reported in — set in monospace on a plotting-paper surface
(a faint grid drawn in CSS), framed by the accent. Field names and
units only, never invented values. The same card, or a sibling of it,
appears on the research page. That is where the boldness is spent;
everything around it is disciplined.

Every page carries at least one figure — a record card, a table, a
specimen block. Prose alone is not a page.

## What to avoid

These are the marks of generated design. None of them appear.

- Gradient text, gradient headline words, gradient buttons, gradient
  washes as backgrounds. Blurred colour blobs behind a hero.
  Backdrop-blur headers, glassmorphism, glows, soft drop shadows.
- A cream or parchment page with a terracotta accent. A black page with
  an acid-green accent. A tinted near-black (`#0B0B0B`, `#111`) for
  black.
- Content chopped into identical rounded cards with one radius and one
  shadow. A panel exists to hold a figure or a table, not to box prose.
- Three identical items in a row with an icon, a bold title, and two
  lines. Icon tiles. An icon per feature. Emoji, sparkles, rockets.
- A tracked-out ALL-CAPS label above every heading. Meta strings joined
  with middle dots. A `→` appended to link or button text. One word in a
  headline set in another colour or style.
- Numbered markers on content that is not a sequence. JobyCorp's method
  *is* a sequence and may be numbered.
- Badges and pills that announce nothing. Stock illustration, isometric
  scenes, 3D shapes, hero photos of hardware.
- Motion: entrances on scroll, fades, hover lifts. Nothing moves unless
  the visitor did something.
- Copy that could be about any company: "Unleash", "Supercharge",
  "Seamless", "Cutting-edge", "Empower", "Next-generation",
  "Revolutionary", "Effortless", "Elevate", "Robust", "Leverage",
  "Harness", "Delightful", "Blazing", "Trusted by". Exclamation marks.
  Questions as headings.
- Numbers invented to look impressive. Where there is no real number,
  the figure shows the field and its unit, and the sentence does not
  need one.

## Layout

- Content column `max-w-6xl`, centred on the page, contents
  left-aligned. `px-6` at phone width, `px-8` from `md`. Prose inside it
  keeps a reading measure of `max-w-prose`; figures and tables may use
  the full column.
- The hero is two columns from `lg`: the statement on the left (the
  sentence, one paragraph, the primary action), the record card on the
  right, top-aligned. At phone width the card follows the statement.
- Vertical rhythm of 8 px. Section spacing `py-16` at phone width,
  `py-24` from `md`; inside a section `space-y-8`.
- A section that presents data may open with a hairline (`border-t
  border-base-300`) and a short monospace running head naming what is
  measured (`ttft`, `hardware`, `method`) at `text-sm` — the technical
  vernacular, used only where the content is data, never as an
  eyebrow on prose. Prose sections open with their heading and nothing
  else.
- Two-column "spec sheet" layouts are welcome from `md`: a monospace
  label column (`w-44`, `text-sm`, secondary colour) beside a reading
  column. At phone width they stack.
- Tables are figures: `bg-base-200` header row, hairlines under the
  header and between rows, no zebra stripes, numbers right-aligned,
  identifiers in monospace. A table scrolls inside its own container at
  phone width; nothing else may. No horizontal overflow at 390 px.

## Type

Two families, clearly distinct.

- **Reading and headings — the system sans**, as the kit ships it
  (`ui-sans-serif, -apple-system, "Helvetica Neue", Arial, sans-serif`).
  Set large and tight: hero `text-5xl md:text-7xl font-semibold
  tracking-[-0.03em] leading-[1.02]`; section headings `text-3xl
  md:text-4xl font-semibold tracking-tight`; sub-headings `text-xl
  font-semibold`; body `text-base md:text-lg leading-relaxed`; small
  print `text-sm`.
- **Data — the kit's monospace** (`font-mono`): field names, units,
  model identifiers, hardware names, table cells, running heads of data
  sections, the record card. `text-sm` in cards and tables, `text-base`
  in a specimen block. Never for headings or prose.
- Headings are statements in sentence case: "What a record carries",
  "How a run is published". Never labels like "Research" or "About".
- Paragraphs are two or three sentences, one idea each.

## Colour

Two themes, both finished. The generator ships a `light` and a `dark`
theme in `assets/css/app.css` (two `@plugin "daisyui/packages/bundle/
daisyui-theme"` blocks); keep those two names — the kit's theme toggle
and the root layout's theme script switch between `light` and `dark`
by name — and replace their tokens with the palette below. No third
theme.

The palette is a cool page, graphite ink, and one accent: **signal
teal**, the colour of a trace on an instrument. It is used with
confidence — the card's frame and grid, the primary action, links, the
current nav link — and never as a wash.

Light:

| token | value | role |
|---|---|---|
| `--color-base-100` | `oklch(98% 0.004 230)` | the page, cool white |
| `--color-base-200` | `oklch(95% 0.006 230)` | table header rows, specimen blocks |
| `--color-base-300` | `oklch(88% 0.008 230)` | hairlines |
| `--color-base-content` | `oklch(23% 0.014 250)` | ink, graphite |
| `--color-primary` | `oklch(48% 0.11 195)` | the accent — signal teal, dark enough for text |
| `--color-primary-content` | `oklch(97% 0.01 195)` | text on the accent |
| `--color-secondary` | `oklch(62% 0.13 195)` | the trace — the card's frame, grid lines, marks; never text |
| `--color-secondary-content` | `oklch(20% 0.03 195)` | |
| `--color-neutral` | `oklch(30% 0.012 250)` | |
| `--color-neutral-content` | `oklch(96% 0.004 230)` | |

Dark (the instrument at night — deep blue-slate, not black):

| token | value | role |
|---|---|---|
| `--color-base-100` | `oklch(20% 0.018 255)` | the page |
| `--color-base-200` | `oklch(24% 0.02 255)` | header rows, specimens |
| `--color-base-300` | `oklch(31% 0.022 255)` | hairlines |
| `--color-base-content` | `oklch(92% 0.008 230)` | ink |
| `--color-primary` | `oklch(78% 0.12 195)` | the accent, lifted |
| `--color-primary-content` | `oklch(18% 0.03 195)` | |
| `--color-secondary` | `oklch(70% 0.13 195)` | the trace |
| `--color-secondary-content` | `oklch(18% 0.03 195)` | |
| `--color-neutral` | `oklch(92% 0.008 230)` | |
| `--color-neutral-content` | `oklch(20% 0.018 255)` | |

Set `--radius-box: 0.5rem`, `--radius-field: 0.375rem`,
`--radius-selector: 0.375rem`, `--border: 1px`, and `--depth: 0` on both.

The plotting-paper surface for the record card: `bg-base-200` with a
grid of `--color-secondary` at 12% opacity, 24 px cells, drawn with two
`repeating-linear-gradient`s in one CSS class in `app.css`, and a
`1px` border in `--color-secondary`. It is used on the record card and
on nothing else.

Rules:

- `primary` is for text and actions: links, the primary button, the
  current nav link. `secondary` is for the trace: frames, grid lines, a
  rule under the hero, the mark in the wordmark. Neither is a background
  wash.
- Secondary text is `text-base-content/70`. Nothing lighter than `/70`
  carries text: ink at 60% is about 4.2:1, under the 4.5:1 the site is
  checked against. `/50` is for hairlines and marks only.
- Contrast: body text at least 4.5:1 against its background, large text
  at least 3:1, in both themes. The tokens above meet this; if you tint
  them, check again.
- Semantic colours (`success`, `warning`, `error`, `info`) stay at
  daisyUI's defaults; the site has no reason to show them.

## Surfaces and edges

- A panel holds a figure: `bg-base-200`, a `1px` `border-base-300`
  hairline, `rounded-box`. No shadow. Prose is never in a panel.
- The record card: the plotting-paper surface above, `rounded-box`,
  `p-6`, the monospace record inside, a one-line caption under it in
  the secondary text colour.
- Buttons: the kit's `<.button>`. The primary action is solid accent
  with `rounded-field`; a secondary action is a text link. One primary
  action per view, where the brief asks for one.
- Links in running text: accent colour, underlined (`underline
  underline-offset-4 decoration-1`), darker on hover. No arrows, no
  icons after them. Nav links are ink; the current one is the accent.
- The wordmark is text (`font-semibold tracking-tight`) with one small
  mark before it: a 10 px square outlined in `--color-secondary`, drawn
  in CSS. Nothing else.
- Icons: the theme toggle and the nav toggle, both the kit's, and no
  others. Any heroicon name used must exist in the installed set; a
  blank icon is a defect.

## Motion

None, beyond the browser's focus ring and a 150 ms colour transition
on link and button hover. Respect `prefers-reduced-motion` by having
nothing to reduce.

## Navigation and footer

- The header is one row on a hairline: the mark and wordmark on the
  left; the three page links; the kit's theme toggle on the right. At
  phone width the links collapse behind the nav toggle. The current
  page is the accent colour and carries `aria-current="page"`.
- The footer is one row above a hairline: the wordmark, the three page
  links, and one sentence saying what JobyCorp does. No columns, no
  social icons, no newsletter box, no "made with".

## Copy

- Sentence case everywhere, including buttons and nav.
- Say what JobyCorp does in plain words: it runs models on its own
  hardware, measures them, and publishes the results in full.
- Write from the facts in the brief only. Where a section wants a
  number or a name you do not have, write around it. A record card of
  *what* a result contains is honest; a table of results you made up is
  not.
- Active voice; a call to action says what happens: "Read the
  research", not "Learn more".
- The site never talks about itself, its framework, its component kit,
  or the task that produced it.

## The test

As you build each page, look at it at 1440 and at 390, in both themes,
and ask two things. Would a careful person believe this company
measures things carefully? And would they remember the page tomorrow?
If the first is no, remove something. If the second is no, the record
card is not doing its job. This looking is part of the work, not a
step after it: when precommit and lint are green, the work is done.

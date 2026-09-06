<!-- jobykit:start -->
## JobyKit — read this before writing UI

This project uses [JobyKit](https://github.com/jobycorp/joby_kit). Every UI
primitive flows through a registered wrapper. Skipping the wrapper layer is
the failure mode this kit exists to prevent.

### Hard rules

1. **No raw `<button>`, `<input>`, `<textarea>`, `<select>` in `.heex`** unless
   the surrounding `def` is itself a registered wrapper definition. The kit
   ships `<.button>`, `<.input>`, `<.icon>`, `<.card>`, `<.flash>`, etc.;
   reach for those, or register a new wrapper.
2. **Every new component carries the contract**: typed `attr` declarations
   with `values:` enums for variants, `data-component="Module.function"` on
   the root element, `attr :rest, :global` for pass-through. Register it in
   `<App>Web.DesignManifest`.
3. **Run `mix joby_kit.lint` before claiming done.** It checks the contract
   end-to-end; the `:raw_html_primitive` rule will catch step 1 violations.

### Symptoms you skipped step 1

If any of these are true, you bypassed the wrapper contract — stop and
lift the offending markup into a wrapper:

- You wrote `<button class="…">` when `<.button>` exists.
- You styled a private function component as if it were a primitive.
- You added a new component without `data-component`, without
  `attr :rest, :global`, or without a `DesignManifest` entry.
- The same `class="…"` string appears on the same semantic UI element on
  more than one page.

### What the kit ships

Core wrappers (registered against `JobyKit.CoreComponents` in the
manifest):

- `<.button>` — text/link button with variant + size
- `<.card>` — content surface with eyebrow/title/actions slots
- `<.icon>` — Heroicon span (`name="hero-..."`)
- `<.input>` — form input (text/email/select/textarea/checkbox/...)
- `<.flash>`, `<.flash_group>` — toast-style flashes
- `<.header>`, `<.list>`, `<.table>`

The host-shipped scaffold also registers a worked composite example
(`<App>Web.CompositeComponents.empty_state`) so there's a precedent for
"this is how you extend." Pattern-match on it before reaching for raw
markup.

### When you genuinely need raw HTML

Inside a wrapper definition (a `def` whose root carries `data-component`),
raw HTML primitives are the wrapper's body — that's how wrappers work.
For one-off cases outside wrapper territory, append
`<%!-- jobykit:allow-raw-html --%>` on the same or immediately preceding
line to silence the lint rule.

### Discoverability

- `curl http://localhost:PORT/design.json` — machine-readable manifest
- `/design` — kit-curated wrapper previews
- `/custom-designs` — this app's composites and domain components
- `AGENTS.md` → "JobyKit guidelines" — full build order and rationale

### Build order (in order, every time)

1. Domain composite exists? Use it.
2. Generic composite exists? Use it.
3. Core wrapper exists? Use it.
4. daisyUI primitive exists? Wrap it (register in `DesignManifest`), then use.
5. None of the above? Tailwind + theme tokens; expose the result as a
   wrapper or composite and register it.
### When you build a new wrapper: own your box, nothing outside it

The rule the kit follows, and the one your components should:

- **No outer margins on a component root.** Spacing between things
  belongs to the parent — `space-y-*` or `gap-*`. A component that
  ships `mb-2` forces every caller to undo it, and callers usually
  can't: if `class` lands on an inner element, the margin is
  unreachable and people nudge neighbouring elements instead.
- **No typography opinions on slot content.** Wrapping a slot in
  `text-sm text-base-content/70` is right for prose and wrong for a
  table, a form, or a stat. Make it opt-in (`prose`) or expose a hook
  (`body_class`).
- **`class` targets the root**, like every other wrapper. If the inner
  control also needs styling, give it its own attr (`input_class`).
- **Variants carry meaning, not colour.** `tone="danger"` survives a
  theme change; `class="text-red-500"` doesn't.

This isn't style preference. Across three consumer apps, adoption
tracked it exactly: the components with no spacing or typography
opinions got hundreds of uses, and the ones with them got bypassed —
127 hand-rolled panels against 10 uses of `<.card>` in one app.
<!-- jobykit:end -->

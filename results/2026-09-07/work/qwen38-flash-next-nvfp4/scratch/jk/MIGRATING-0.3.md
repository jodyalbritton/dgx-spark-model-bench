# Migrating to JobyKit 0.3

0.3 removes the spacing and typography opinions that host apps were
routing around, and fills in the variants they were hand-rolling. The
changes came from usage data across three consumer apps (orchester,
airo, mem_pal), where the pattern was consistent: **adoption is
inversely proportional to baked-in opinion.** `button` and `input` —
shape and behaviour, no spacing the caller has to undo — got hundreds of
uses. `card`, `header`, and `list` — typography and margin opinions —
got bypassed. One app had 127 hand-rolled panels against 10 `<.card>`
uses; another had zero `<.header>` uses and the same header class string
pasted 10 times.

So this release takes the opinions out. It is visually breaking on
purpose, and the changes are mostly *deletions* of styling you were
already fighting.

## Do this first: delete your compensating hacks

Search your app for workarounds against the old defaults. Left in place,
they now over-correct.

| Look for | Why it existed | Do |
|---|---|---|
| `class="mb-0"` / `mb-0.5` / `-mt-*` next to `<.input>` | the wrapper's unreachable `mb-2` | delete |
| `gap-*` tuned to fight input margins in filter rows | same | re-tune to what you actually want |
| `mb-4` / `mt-1` between `<.card>` body children | the prose wrapper killed `card-body`'s gap | delete; the gap works now |
| `pb-0` / negative margins on `<.header>` | the hardcoded `pb-4` | delete |
| `[data-component="…table"] … { white-space: nowrap }` | no handle on the action cell | delete; use `[data-table-actions]` |
| `btn btn-primary btn-soft btn-sm btn-ghost btn-circle` stacks | no ghost/shape support | `<.button variant="ghost" shape="circle" size="sm">` |
| local `icon_button/1` | no icon mode | `<.button shape="circle">` (or keep yours) |
| local tone→class maps for buttons | no danger/neutral variants | `variant="danger" \| "neutral"` |

## `<.input>` — the big one

**`class` now lands on the root, not the control.** This is the change
most likely to need a look. Previously `class` hit the `<input>`, so the
field group's own box was unreachable — which is why callers ended up
nudging neighbouring elements instead.

```diff
- <.input field={@form[:email]} class="font-mono" />
+ <.input field={@form[:email]} input_class="font-mono" />

  # and now possible for the first time:
+ <.input field={@form[:email]} class="col-span-2" />
```

Global attributes (`placeholder`, `required`, `readonly`, `phx-*`, …)
still go to the control — those are control attributes and would be
meaningless on a fieldset.

**No outer margin.** The wrapper no longer emits `mb-2`. Give the
container `space-y-*` or `gap-*`:

```diff
- <div>
+ <div class="space-y-3">
    <.input field={@form[:name]} label="Name" />
    <.input field={@form[:email]} label="Email" />
  </div>
```

**Width goes through the root.** The control is always `w-full`, so
constrain the root and the control follows:

```diff
- <.form class="w-48"><.input field={@form[:peer]} type="select" … /></.form>
+ <.input field={@form[:peer]} type="select" class="w-48" … />
```

Also in this release: the root is a semantic `<fieldset>`, and errors are
wired to the control with `aria-invalid` / `aria-describedby`.

## `<.card>` — body typography is opt-in

The body no longer sits in a forced `text-sm text-base-content/70`
wrapper. Body content renders as direct children of `card-body`, so the
card's `gap` finally applies.

```diff
  # cards that really are prose:
- <.card>Explanatory copy.</.card>
+ <.card prose>Explanatory copy.</.card>

  # cards holding tables, forms, stats — previously fighting the wrapper:
  <.card body_class="text-base">…</.card>
```

`card-actions` also lost its hardcoded `mt-3`; the body gap spaces it.

## `<.header>`

`pb-4` is gone — the parent owns spacing. New: an `:eyebrow` slot, a
`level` attr so section headers stop emitting a second `<h1>`, a `size`
attr (`page` | `section`), and `title_class` for apps with their own
display face.

```diff
- <header class="mb-6">
-   <p class="text-xs uppercase tracking-widest">Workspace</p>
-   <h1 class="font-display text-3xl">Team settings</h1>
- </header>
+ <.header level="h2" title_class="font-display text-3xl" class="mb-6">
+   Team settings
+   <:eyebrow>Workspace</:eyebrow>
+ </.header>
```

## `<.button>` — new tones, sizes, shapes

`variant` now takes `soft | primary | neutral | ghost | danger`. The
default is unchanged (soft primary), and is nameable as `soft` for
runtime-computed callers. `size` gains `xs`. `shape` (`circle` |
`square`) gives icon-only buttons their box.

```diff
- <.button class="btn-error">Delete workspace</.button>
+ <.button variant="danger">Delete workspace</.button>
```

Destructive actions now read as destructive — previously every
`<.button>` looked the same, so Revoke and Delete were visually
identical to Refresh.

## `<.table>`

Additive; nothing breaks.

* `<:empty>` slot — drop the `:if={@rows != []}` / `<.empty_state>` pair.
* `zebra={false}` — opt out of striping.
* `size` (`xs` | `sm` | `md` | `lg`) — density, instead of leaking
  `table-xs` through `class`.
* The action cell carries `data-table-actions`, so overrides can target
  it precisely rather than guessing with `:last-child` (which hits a data
  column on tables that have no `:action` slot).

```diff
- <.table :if={@rows != []} id="users" rows={@rows} class="table-xs">
+ <.table id="users" rows={@rows} size="xs">
    <:col :let={u} label="Name">{u.name}</:col>
+   <:empty>No users yet.</:empty>
  </.table>
- <.empty_state :if={@rows == []} title="No users yet" />
```

## If you forked a core component

Hosts that do `import JobyKit.CoreComponents, except: [button: 1, ...]`
and substitute their own do **not** get any of this. Apply the changes
to your copy, or drop the fork now that the variants you forked for
exist upstream.

## While you're in there

Two things worth checking during the upgrade, both outside the kit:

* **daisyUI version.** The fleet spans 5.0.35 and 5.5.20; upstream is
  5.7.16, and `DaisyCatalogue` now describes 5.7.16 with a `:since` note
  on anything newer than 5.0. Bump `assets/vendor/daisyui.js` while you
  have the app open.
* **A stale `deps/joby_kit/`.** If you ever switched this app between a
  hex dep and a path dep, the old directory may still be on disk, and
  `app.css`'s `@source "../../deps/joby_kit/lib"` will happily scan that
  stale copy — so new kit classes silently never reach your CSS and
  components render unstyled. Check that the `@source` path resolves to
  the kit you're actually compiling against.

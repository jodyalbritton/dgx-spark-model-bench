defmodule BenchappWeb.CompositeComponents do
  @moduledoc """
  Generic, multi-primitive composites for this app.

  Composites live one layer above core wrappers: they bundle a small set
  of `JobyKit.CoreComponents` primitives into a higher-level pattern that
  appears more than once across the app. Examples: empty states, page
  headers with breadcrumbs, callouts, hero blocks.

  Every composite follows the JobyKit wrapper contract:

    1. Declare every prop with `attr` (use `values:` for variant enums).
    2. Carry `data-component="BenchappWeb.CompositeComponents.<name>"`
       on the root element.
    3. Accept `attr :rest, :global` for id/class/aria-*/phx-* pass-through.
    4. Internals compose `JobyKit.CoreComponents` (or other registered
       wrappers) — never raw `<button>`/`<input>`/`<textarea>`.
    5. Register the composite in `BenchappWeb.DesignManifest`
       (`category: :composite`) so it surfaces on `/custom-designs` and
       in `/design.json`.

  The `empty_state/1` below ships pre-registered as a worked example.
  Use it as a template when you add your own composites: copy the
  attribute / slot / `data-component` shape, then register the new entry
  in the manifest.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @doc """
  An empty-state callout: centered icon, title, supporting text, and an
  optional action slot. Use to fill an otherwise-empty container — an
  unfilled list, a search with no results, a fresh dashboard.

      <.empty_state icon="hero-inbox" title="No messages yet">
        Start a conversation with a teammate to see it here.
        <:action>
          <CoreComponents.button variant="primary">New message</CoreComponents.button>
        </:action>
      </.empty_state>
  """
  attr :icon, :string,
    default: "hero-sparkles",
    doc: "Heroicon name to display above the title."

  attr :title, :string, required: true
  attr :tone, :string, values: ~w(neutral primary), default: "neutral"
  attr :rest, :global

  slot :inner_block, doc: "Supporting copy beneath the title."
  slot :action, doc: "Optional call-to-action (typically a `<.button>`)."

  def empty_state(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.empty_state"
      class={[
        "flex flex-col items-center justify-center gap-3 rounded-2xl border border-dashed px-6 py-10 text-center",
        @tone == "neutral" && "border-base-300 bg-base-100/40 text-base-content/70",
        @tone == "primary" && "border-primary/30 bg-primary/5 text-base-content"
      ]}
      {@rest}
    >
      <span class={[
        "flex size-12 items-center justify-center rounded-full",
        @tone == "neutral" && "bg-base-200 text-base-content/60",
        @tone == "primary" && "bg-primary/10 text-primary"
      ]}>
        <CoreComponents.icon name={@icon} class="size-6" />
      </span>
      <h3 class="text-base font-semibold text-base-content">{@title}</h3>
      <div :if={@inner_block != []} class="max-w-sm text-sm text-base-content/65">
        {render_slot(@inner_block)}
      </div>
      <div :if={@action != []} class="pt-1">
        {render_slot(@action)}
      </div>
    </div>
    """
  end

  @doc """
  A capability panel: mono tag, icon, title, supporting copy, and an
  optional action. The home feature grid is N of these in a responsive
  grid; the about page reuses it for the stack list.

      <.feature_card tag="01" icon="hero-clock" title="Launch windows">
        Schedule a pipeline the way a range schedules a firing: a window,
        a go/no-go, and a hold that everyone can see.
      </.feature_card>

  `tone="primary"` is for the single panel a section wants to stand out —
  variants carry meaning, not colour, so the accent survives a theme flip.
  """
  attr :tag, :string, default: nil, doc: "Short mono label above the title, e.g. a step number."
  attr :icon, :string, default: "hero-sparkles", doc: "Heroicon name for the badge."
  attr :title, :string, required: true
  attr :tone, :string, values: ~w(neutral primary), default: "neutral"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Supporting copy beneath the title."
  slot :action, doc: "Optional trailing action (typically a `<.button>`)."

  def feature_card(assigns) do
    ~H"""
    <article
      data-component="BenchappWeb.CompositeComponents.feature_card"
      class={[
        "group flex h-full flex-col gap-3 rounded-box border p-5 transition-all duration-200 hover:-translate-y-0.5",
        @tone == "neutral" && "border-base-300 bg-base-100 hover:border-primary/50 hover:shadow-lg hover:shadow-base-300/50",
        @tone == "primary" && "border-primary/40 bg-primary/5 hover:border-primary hover:shadow-lg hover:shadow-primary/10"
      ]}
      {@rest}
    >
      <div class="flex items-center gap-3">
        <span class={[
          "flex size-9 shrink-0 items-center justify-center rounded-field transition-transform group-hover:scale-105",
          @tone == "neutral" && "bg-base-200 text-base-content/70 group-hover:bg-primary group-hover:text-primary-content",
          @tone == "primary" && "bg-primary text-primary-content"
        ]}>
          <CoreComponents.icon name={@icon} class="size-4" />
        </span>
        <CoreComponents.eyebrow :if={@tag} class="font-mono">{@tag}</CoreComponents.eyebrow>
      </div>

      <h3 class="text-base font-semibold leading-snug text-base-content">{@title}</h3>

      <div class="text-sm leading-relaxed text-base-content/70">
        {render_slot(@inner_block)}
      </div>

      <div :if={@action != []} class="mt-auto pt-2">
        {render_slot(@action)}
      </div>
    </article>
    """
  end

  @doc """
  One measurement from the flight telemetry: a large mono value, a label
  beneath it, and an optional unit plus caption. The stats strip is a row
  of these; it also reads well as a standalone figure.

      <.stat_tile id="stat-signups" value={@signup_count} label="Crew manifest" unit="signed" />

  Pass `id` through so a strip's tiles stay addressable from tests
  (`#stat-signups`); the reading itself then takes `#stat-signups-value`,
  which is what to assert when you want the number without the label.
  """
  attr :id, :any, default: nil
  attr :value, :any, required: true
  attr :label, :string, required: true
  attr :unit, :string, default: nil
  attr :caption, :string, default: nil
  attr :highlight, :boolean, default: false

  attr :size, :string,
    values: ~w(md sm),
    default: "md",
    doc: "`md` tiles a stats strip; `sm` sits inside a panel without its own gutter."

  attr :class, :any, default: nil
  attr :rest, :global

  def stat_tile(assigns) do
    assigns =
      assign(assigns, :scale, %{
        "md" => %{pad: "px-5 py-4", value: "text-3xl"},
        "sm" => %{pad: "gap-0.5 py-1", value: "text-xl"}
      }[assigns.size])

    ~H"""
    <div
      id={@id}
      data-component="BenchappWeb.CompositeComponents.stat_tile"
      class={["flex flex-col", @scale.pad, @highlight && "bg-primary/5", @class]}
      {@rest}
    >
      <CoreComponents.eyebrow class="font-mono">{@label}</CoreComponents.eyebrow>
      <p class="flex items-baseline gap-1.5">
        <span
          id={@id && "#{@id}-value"}
          class={[
            "font-mono font-semibold leading-none tabular-nums text-base-content",
            @scale.value
          ]}
        >
          {@value}
        </span>
        <span :if={@unit} class="font-mono text-xs uppercase tracking-widest text-base-content/45">
          {@unit}
        </span>
      </p>
      <p :if={@caption} class="text-xs text-base-content/55">{@caption}</p>
    </div>
    """
  end

  @doc """
  The responsive panel grid the feature sections are built on: one gutter,
  one set of breakpoints, wherever a row of cards appears.

      <.card_grid id="feature-grid">
        <.feature_card ... />
        <.feature_card ... />
      </.card_grid>

  Exists because "three cards across, two on a tablet, one on a phone" was
  written out by hand on three pages: the same 40-character class string on
  three different semantic objects is the lint's cue to lift it.
  """
  attr :id, :any, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def card_grid(assigns) do
    ~H"""
    <div
      id={@id}
      data-component="BenchappWeb.CompositeComponents.card_grid"
      class={["grid gap-4 sm:grid-cols-2 lg:grid-cols-3", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  A single row in a telemetry list: status icon, headline, supporting
  detail, and a right-aligned stamp. `#signups` and `#activity` are both
  rows of these, which is the only reason it exists.

      <.feed_row icon="hero-at-symbol" title="ada@flight.dev" detail="joined the manifest" stamp="now" />

  The root is an `<li>`, so callers put it straight inside a `<ul>`.
  """
  attr :icon, :string, default: "hero-bolt"
  attr :title, :string, required: true
  attr :detail, :string, default: nil
  attr :stamp, :string, default: nil, doc: "Right-aligned mono stamp (a time or a counter)."
  attr :tone, :string, values: ~w(neutral primary ok), default: "neutral"
  attr :class, :any, default: nil
  attr :rest, :global

  def feed_row(assigns) do
    ~H"""
    <li
      data-component="BenchappWeb.CompositeComponents.feed_row"
      class={["flex items-start gap-3 px-5 py-3", @class]}
      {@rest}
    >
      <span class={[
        "mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-full",
        @tone == "neutral" && "bg-base-200 text-base-content/60",
        @tone == "primary" && "bg-primary/10 text-primary",
        @tone == "ok" && "bg-success/10 text-success"
      ]}>
        <CoreComponents.icon name={@icon} class="size-3.5" />
      </span>
      <div class="min-w-0 flex-1">
        <p class="truncate text-sm font-medium text-base-content">{@title}</p>
        <p :if={@detail} class="truncate text-xs text-base-content/55">{@detail}</p>
      </div>
      <span :if={@stamp} class="shrink-0 font-mono text-[0.7rem] tabular-nums text-base-content/40">
        {@stamp}
      </span>
    </li>
    """
  end
end

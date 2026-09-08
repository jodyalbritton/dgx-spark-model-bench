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
  A single stat card for a stats strip: a large mono number, a small
  uppercase label, and an accent tone.

      <.stat_card value_id="stat-signups" value="3" label="Signups" tone="secondary" />
  """
  attr :value_id, :string, required: true, doc: "DOM id for the number element."
  attr :value, :string, required: true
  attr :label, :string, required: true
  attr :tone, :string, values: ~w(primary secondary accent), default: "primary"
  attr :class, :any, default: nil
  attr :rest, :global

  def stat_card(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.stat_card"
      class={[
        "rounded-2xl border border-base-300 bg-base-100 p-5 text-center shadow-sm transition-shadow hover:shadow-md",
        @class
      ]}
      {@rest}
    >
      <p
        id={@value_id}
        class={[
          "font-mono text-4xl font-bold tabular-nums",
          @tone == "primary" && "text-primary",
          @tone == "secondary" && "text-secondary",
          @tone == "accent" && "text-accent"
        ]}
      >
        {@value}
      </p>
      <p class="mt-1 text-xs uppercase tracking-wide text-base-content/60">{@label}</p>
    </div>
    """
  end

  @doc """
  A section heading block: an h2 title with an optional supporting
  subtitle.

      <.section_heading title="What's in the box" subtitle="Six reasons." />
  """
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :rest, :global

  def section_heading(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.section_heading"
      class="space-y-1"
      {@rest}
    >
      <h2 class="text-2xl font-bold tracking-tight">{@title}</h2>
      <p :if={@subtitle} class="text-base-content/70">{@subtitle}</p>
    </div>
    """
  end

  @doc """
  A responsive feature grid: a section heading plus a 1/2/3-column grid
  of icon + title + body cards.

      <.feature_grid title="What's in the box" subtitle="Six reasons to care.">
        <:feature icon="hero-wifi" title="Hub, not cloud">
          Your data lives on the hub in your hallway.
        </:feature>
      </.feature_grid>
  """
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :rest, :global

  slot :feature, required: true do
    attr :icon, :string, doc: "Heroicon name shown above the feature title."
    attr :title, :string
  end

  def feature_grid(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class="space-y-6"
      {@rest}
    >
      <.section_heading title={@title} subtitle={@subtitle} />
      <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div
          :for={feature <- @feature}
          class="group rounded-2xl border border-base-300 bg-base-100 p-5 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-md"
        >
          <span class="mb-3 flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary transition-colors group-hover:bg-primary group-hover:text-primary-content">
            <CoreComponents.icon name={feature.icon || "hero-sparkles"} class="size-5" />
          </span>
          <h3 :if={feature.title} class="mb-1 font-semibold">{feature.title}</h3>
          <div class="text-sm text-base-content/70">{render_slot(feature)}</div>
        </div>
      </div>
    </section>
    """
  end
end

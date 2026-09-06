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
  A responsive grid of feature cards: an icon, title, and supporting
  copy per tile. Used for marketing feature lists.

      <.feature_grid
        features={[
          %{icon: "hero-bolt", title: "Fast", detail: "Sub-second updates."}
        ]}
      />
  """
  attr :features, :list,
    default: [],
    doc: "List of `%{icon:, title:, detail:}` maps to render as feature tiles."

  attr :class, :any, default: nil
  attr :rest, :global

  def feature_grid(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class={["grid gap-4 sm:grid-cols-2 lg:grid-cols-3", @class]}
      {@rest}
    >
      <article
        :for={feature <- @features}
        class="group rounded-2xl border border-base-300 bg-base-100/70 p-6 transition-all duration-200 hover:-translate-y-0.5 hover:border-primary/40 hover:shadow-lg hover:shadow-base-300/40"
      >
        <span class="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary transition-colors group-hover:bg-primary/15">
          <CoreComponents.icon name={feature.icon} class="size-5" />
        </span>
        <h3 class="mt-4 text-base font-semibold text-base-content">{feature.title}</h3>
        <p class="mt-1.5 text-sm leading-relaxed text-base-content/65">{feature.detail}</p>
      </article>
    </div>
    """
  end

  @doc """
  A single metric stat card: a large figure with a supporting label and
  optional detail.

      <.stat_card value="40k" label="sensors" detail="Feeding models every minute." />
  """
  attr :value, :string, required: true
  attr :label, :string, default: nil
  attr :detail, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def stat_card(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.stat_card"
      class={["card border border-base-300 bg-base-100/70", @class]}
      {@rest}
    >
      <div class="card-body">
        <span class="font-mono text-3xl font-bold text-primary">{@value}</span>
        <p :if={@label} class="text-sm font-medium text-base-content">{@label}</p>
        <p :if={@detail} class="text-sm text-base-content/65">{@detail}</p>
      </div>
    </div>
    """
  end
end

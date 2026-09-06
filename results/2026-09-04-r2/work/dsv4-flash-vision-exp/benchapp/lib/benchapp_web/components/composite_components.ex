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
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @doc """
  A compact stat card: an uppercase label above a large numeric value.
  Used in the stats strip and on the about page.

      <.stat_card label="Signups" value={length(@signups)} />
  """
  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :class, :any, default: nil
  attr :rest, :global

  def stat_card(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.stat_card"
      class={["rounded-2xl border border-base-300 bg-base-100 p-5", @class]}
      {@rest}
    >
      <p class="text-xs uppercase tracking-widest text-base-content/50">{@label}</p>
      <p class="mt-1 text-4xl font-bold tabular-nums text-primary">{@value}</p>
    </div>
    """
  end

  @doc """
  A responsive feature grid. Renders one cell per `items` entry, each with
  a Heroicon, a title, and a description. Used on the landing page.

      <.feature_grid items={@features} />

  Each item is a map with `:icon`, `:title`, and `:desc` keys.
  """
  attr :items, :list, required: true
  attr :class, :any, default: nil
  attr :rest, :global

  def feature_grid(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class={["grid gap-5 sm:grid-cols-2 lg:grid-cols-3", @class]}
      {@rest}
    >
      <div
        :for={item <- @items}
        class="group rounded-2xl border border-base-300 bg-base-100/60 p-6 transition hover:-translate-y-0.5 hover:border-primary/40 hover:shadow-md hover:shadow-base-300/40"
      >
        <span class="inline-flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary transition group-hover:bg-primary group-hover:text-primary-content">
          <CoreComponents.icon name={item.icon} class="size-5" />
        </span>
        <h3 class="mt-4 text-base font-semibold">{item.title}</h3>
        <p class="mt-1 text-sm text-base-content/65">{item.desc}</p>
      </div>
    </div>
    """
  end

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
end

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
  A responsive grid of feature tiles. Each tile is an icon, a title, and
  supporting copy. Use it for capability highlights, value props, or a
  "what's inside" section on a landing page.

      <.feature_grid>
        <:feature icon="hero-bolt" title="Instant sync">
          Changes land everywhere in real time.
        </:feature>
        <:feature icon="hero-sparkles" title="Delightful">
          Small touches that make work feel good.
        </:feature>
      </.feature_grid>

  `cols` picks the tile density; the grid collapses to a single column on
  phone widths.
  """
  attr :class, :any, default: nil
  attr :cols, :string, values: ~w(2 3), default: "3"
  attr :rest, :global

  slot :feature, required: true do
    attr :icon, :string, doc: "Heroicon name."
    attr :title, :string, required: true
  end

  def feature_grid(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class={[
        "grid gap-5 sm:gap-6",
        @cols == "2" && "sm:grid-cols-2",
        @cols == "3" && "sm:grid-cols-2 lg:grid-cols-3",
        @class
      ]}
      {@rest}
    >
      <div
        :for={feature <- @feature}
        class="group rounded-2xl border border-base-300/60 bg-base-100/60 p-6 transition duration-200 hover:border-primary/40 hover:shadow-sm"
      >
        <span class="mb-4 flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <CoreComponents.icon name={feature.icon || "hero-sparkles"} class="size-5" />
        </span>
        <h3 class="text-base font-semibold text-base-content">{feature.title}</h3>
        <div class="mt-1.5 text-sm leading-relaxed text-base-content/65">
          {render_slot(feature)}
        </div>
      </div>
    </div>
    """
  end
end

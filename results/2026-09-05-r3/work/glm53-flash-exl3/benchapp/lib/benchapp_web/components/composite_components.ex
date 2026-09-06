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

  # Standalone like JobyKit.NavComponent: `use Phoenix.Component` rather
  # than `use BenchappWeb, :html`, so html_helpers can import this module
  # app-wide without a compile-time cycle.
  use Phoenix.Component

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
  A responsive grid of feature cards: icon chip, title, and supporting
  text per cell. Use for "what you get" sections on marketing pages.

      <.feature_grid features={[
        %{icon: "hero-map", title: "Offline tiles", text: "…"},
        %{icon: "hero-pencil-square", title: "Field notes", text: "…"}
      ]} />

  Each entry in `features` is a map with `:icon` (a Heroicon name),
  `:title`, and `:text`. Grid density follows `columns`; below `sm`
  the grid is always a single column.
  """
  attr :features, :list,
    required: true,
    doc: "List of maps: `%{icon: \"hero-…\", title: \"…\", text: \"…\"}`."

  attr :columns, :string, values: ~w(2 3), default: "3", doc: "Columns at breakpoint and up."
  attr :class, :any, default: nil
  attr :rest, :global

  def feature_grid(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class={[
        "grid grid-cols-1 gap-4",
        @columns == "2" && "sm:grid-cols-2",
        @columns == "3" && "sm:grid-cols-2 lg:grid-cols-3",
        @class
      ]}
      {@rest}
    >
      <div
        :for={feature <- @features}
        class="group rounded-2xl border border-base-300 bg-base-100 p-5 transition-shadow duration-200 hover:shadow-md"
      >
        <span class="flex size-10 items-center justify-center rounded-box bg-primary/10 text-primary transition-colors duration-200 group-hover:bg-primary group-hover:text-primary-content">
          <CoreComponents.icon name={feature.icon} class="size-5" />
        </span>
        <h3 class="mt-3 text-base font-semibold text-base-content">{feature.title}</h3>
        <p class="mt-1.5 text-sm leading-relaxed text-base-content/70">{feature.text}</p>
      </div>
    </div>
    """
  end
end

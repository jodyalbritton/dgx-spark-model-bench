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
  A page-section heading: small uppercase eyebrow, large bold title, and
  optional supporting copy.

      <.section_heading eyebrow="Features" title="Everything a desk lamp should be" />
  """
  attr :eyebrow, :string, required: true
  attr :title, :string, required: true
  attr :large, :boolean, default: false, doc: "Render the title as an h1 at page-title scale."
  attr :rest, :global

  slot :inner_block, doc: "Optional supporting copy beneath the title."

  def section_heading(assigns) do
    ~H"""
    <div data-component="BenchappWeb.CompositeComponents.section_heading" class="space-y-2" {@rest}>
      <p class="text-sm font-semibold uppercase tracking-widest text-primary">{@eyebrow}</p>
      <h1 :if={@large} class="text-4xl font-bold tracking-tight sm:text-5xl">{@title}</h1>
      <h2 :if={!@large} class="text-3xl font-bold tracking-tight">{@title}</h2>
      <div :if={@inner_block != []} class="text-base-content/70">{render_slot(@inner_block)}</div>
    </div>
    """
  end

  @doc """
  A responsive feature grid: a list of `%{icon:, title:, text:}` maps
  rendered as cards. Used on the Solstice landing page to present the
  product's capabilities.

      <.feature_grid features={[%{icon: "hero-bolt", title: "Instant", text: "…"}]} />
  """
  attr :features, :list, required: true, doc: "List of %{icon:, title:, text:} maps."
  attr :columns, :string, values: ~w(two three), default: "three"
  attr :rest, :global

  def feature_grid(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class={[
        "grid gap-4",
        @columns == "two" && "sm:grid-cols-2",
        @columns == "three" && "sm:grid-cols-2 lg:grid-cols-3"
      ]}
      {@rest}
    >
      <div
        :for={feature <- @features}
        class="card bg-base-100 shadow-sm ring-1 ring-base-300 transition-transform duration-200 hover:-translate-y-0.5"
      >
        <div class="card-body gap-2">
          <span class="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
            <CoreComponents.icon name={feature.icon} class="size-5" />
          </span>
          <h3 class="card-title text-base">{feature.title}</h3>
          <p class="text-sm text-base-content/70">{feature.text}</p>
        </div>
      </div>
    </div>
    """
  end
end

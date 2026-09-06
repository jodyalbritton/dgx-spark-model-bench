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
  A feature grid card: icon in a tinted tile, a title, and supporting
  copy. Lifts the repeated "feature card" layout out of the landing page
  into a reusable, registered composite.

      <.feature_card icon="hero-bolt" title="LiveView-native" tint="info">
        Real-time updates with zero custom JavaScript.
      </.feature_card>
  """
  attr :icon, :string, required: true
  attr :title, :string, required: true

  attr :tint, :string,
    values: ~w(primary secondary accent info warning success neutral),
    default: "primary"

  attr :rest, :global
  slot :inner_block, required: true

  def feature_card(assigns) do
    tints = %{
      "primary" => "bg-primary/10 text-primary",
      "secondary" => "bg-secondary/10 text-secondary",
      "accent" => "bg-accent/10 text-accent",
      "info" => "bg-info/10 text-info",
      "warning" => "bg-warning/10 text-warning",
      "success" => "bg-success/10 text-success",
      "neutral" => "bg-base-200 text-base-content/70"
    }

    assigns = assign(assigns, :tint_class, Map.fetch!(tints, assigns.tint))

    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_card"
      class="rounded-2xl border border-base-300 bg-base-100 p-6 transition-shadow hover:shadow-md"
      {@rest}
    >
      <span class={["flex size-11 items-center justify-center rounded-xl", @tint_class]}>
        <CoreComponents.icon name={@icon} class="size-5" />
      </span>
      <h3 class="mt-4 font-semibold">{@title}</h3>
      <div class="mt-2 text-sm text-base-content/65">
        {render_slot(@inner_block)}
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

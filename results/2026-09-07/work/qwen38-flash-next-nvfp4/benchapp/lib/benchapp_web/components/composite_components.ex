defmodule BenchappWeb.CompositeComponents do
  @moduledoc """
  Generic, multi-primitive composites for this app.

  Composites live one layer above core wrappers: they bundle a small set
  of `JobyKit.CoreComponents` primitives into a higher-level pattern that
  appears more than once across the app.

  Every composite follows the JobyKit wrapper contract: typed `attr`s,
  `data-component` on the root, `attr :rest, :global` pass-through,
  internals composed from `JobyKit.CoreComponents`, and a
  `BenchappWeb.DesignManifest` entry so the component surfaces on
  `/custom-designs` and in `/design.json`.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @doc """
  An empty-state callout: centered icon, title, supporting text, and an
  optional action slot.

      <.empty_state icon="hero-inbox" title="No messages yet">
        Start a conversation with a teammate to see it here.
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
  A feature card: tinted icon, title, and supporting copy. Bundles
  `JobyKit.CoreComponents.icon` with a heading and body copy — stack
  several in a grid to make a feature section, which is exactly what the
  landing page's feature grid does.

      <.feature_card icon="hero-eye" title="One rollup for every repo">
        Cadence reads commits, PRs, and releases across your org.
      </.feature_card>
  """
  attr :icon, :string, default: "hero-sparkles", doc: "Heroicon name for the tile."

  attr :title, :string, required: true

  attr :tone, :string,
    values: ~w(neutral primary),
    default: "primary",
    doc: "Icon tile treatment."

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Supporting copy beneath the title."

  def feature_card(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_card"
      class={[
        "flex flex-col gap-3 rounded-box border border-base-300 bg-base-100 p-5",
        "transition-all duration-200 hover:-translate-y-0.5 hover:border-primary/40 hover:shadow-md",
        @class
      ]}
      {@rest}
    >
      <div class="flex items-center gap-3">
        <span class={[
          "flex size-9 shrink-0 items-center justify-center rounded-xl",
          @tone == "primary" && "bg-primary/10 text-primary",
          @tone == "neutral" && "bg-base-200 text-base-content/70"
        ]}>
          <CoreComponents.icon name={@icon} class="size-5" />
        </span>
        <h3 class="text-base font-semibold leading-snug text-base-content">{@title}</h3>
      </div>
      <p class="text-sm leading-relaxed text-base-content/70">{render_slot(@inner_block)}</p>
    </div>
    """
  end
end

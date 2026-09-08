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

  `feature_grid/1` and `stat_readout/1` are this app's own additions: the
  landing page's capability grid and the tiles in its live stats strip.
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
  Responsive capability grid: one `<.card>` per item, each with an icon
  tile, an eyebrow, a title, body copy, and an optional badge.

      <.feature_grid columns="3" items={[
        %{icon: "hero-signal", eyebrow: "Telemetry", title: "Buoy-grade sampling",
          body: "1 Hz readings from every moored node.", tag: "live"}
      ]} />

  `items` takes maps with `:icon`, `:eyebrow`, `:title`, `:body`, and an
  optional `:tag`. The grid owns the column rhythm; the caller owns the
  copy.
  """
  attr :items, :list,
    required: true,
    doc: "Maps of `%{icon:, eyebrow:, title:, body:, tag:}`. `:tag` is optional."

  attr :columns, :string,
    values: ~w(2 3),
    default: "3",
    doc: "Column count at `lg`. Collapses to two at `md`, one below that."

  attr :class, :any, default: nil
  attr :rest, :global

  def feature_grid(assigns) do
    columns = %{
      "2" => "sm:grid-cols-2 lg:grid-cols-2",
      "3" => "sm:grid-cols-2 lg:grid-cols-3"
    }

    assigns = assign(assigns, :columns_class, Map.fetch!(columns, assigns.columns))

    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class={["grid gap-4 sm:gap-5", @columns_class, @class]}
      {@rest}
    >
      <CoreComponents.card
        :for={item <- @items}
        variant="elevated"
        class="transition-transform duration-200 hover:-translate-y-0.5"
      >
        <:eyebrow>{item.eyebrow}</:eyebrow>
        <:title>
          <span class="flex items-center gap-3">
            <span class="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <CoreComponents.icon name={item.icon} class="size-5" />
            </span>
            {item.title}
          </span>
        </:title>
        <p class="text-sm leading-relaxed text-base-content/70">{item.body}</p>
        <:actions :if={item.tag}>
          <CoreComponents.badge tone="info" size="xs">{item.tag}</CoreComponents.badge>
        </:actions>
      </CoreComponents.card>
    </div>
    """
  end

  @doc """
  One number in a live stats strip: a label, the figure, and a hint line.

      <.stat_readout label="Signups" value={length(@signups)} value_id="stat-signups" />

  `value_id` lands on the figure itself — the thing a test or an agent
  reads — so the label and hint can change wording without moving the id.
  `pulse` marks a figure that is still ticking and gives it a soft ring.
  """
  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :value_id, :string, default: nil, doc: "DOM id for the figure element."
  attr :hint, :string, default: nil
  attr :icon, :string, default: nil
  attr :pulse, :boolean, default: false, doc: "Ring the figure of a still-moving number."
  attr :class, :any, default: nil
  attr :rest, :global

  def stat_readout(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.stat_readout"
      class={[
        "flex items-center gap-3 rounded-2xl border border-base-300/70 bg-base-100 px-4 py-3",
        @class
      ]}
      {@rest}
    >
      <span
        :if={@icon}
        class="flex size-9 shrink-0 items-center justify-center rounded-xl bg-base-200 text-base-content/70"
      >
        <CoreComponents.icon name={@icon} class="size-4" />
      </span>
      <div class="min-w-0">
        <CoreComponents.eyebrow>{@label}</CoreComponents.eyebrow>
        <p
          id={@value_id}
          class={[
            "font-mono text-2xl font-semibold leading-tight tabular-nums",
            @pulse && "text-primary"
          ]}
        >
          {@value}
        </p>
        <p :if={@hint} class="truncate text-xs text-base-content/55">{@hint}</p>
      </div>
    </div>
    """
  end
end

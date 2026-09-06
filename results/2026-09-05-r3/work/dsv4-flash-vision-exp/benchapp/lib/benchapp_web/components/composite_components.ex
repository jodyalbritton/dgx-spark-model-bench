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
  A feature card: icon badge, title, and supporting copy. Cards are
  arranged into a grid by the caller, so this composite owns its own box
  and nothing outside it.

      <.feature_card icon="hero-users" title="Shared everything">
        One list for every errand, plan, and packing run.
      </.feature_card>

  Use `highlighted` to give a single card a primary-tinted emphasis —
  padding, radius, and layout stay identical between the two states.
  """
  attr :icon, :string, default: "hero-sparkles", doc: "Heroicon name displayed in the badge."
  attr :title, :string, required: true
  attr :tone, :string, values: ~w(neutral primary), default: "neutral"
  attr :highlighted, :boolean, default: false
  attr :rest, :global

  slot :inner_block, required: true

  def feature_card(assigns) do
    ~H"""
    <article
      data-component="BenchappWeb.CompositeComponents.feature_card"
      class={[
        "group relative flex flex-col gap-3.5 overflow-hidden rounded-2xl border p-6 transition-all duration-300",
        @highlighted && "border-primary/30 bg-gradient-to-b from-primary/10 to-transparent",
        !@highlighted &&
          "border-base-300 bg-base-100/60 hover:-translate-y-0.5 hover:border-base-content/20 hover:shadow-sm"
      ]}
      {@rest}
    >
      <span class={[
        "flex size-11 items-center justify-center rounded-xl transition-transform duration-300 group-hover:scale-105",
        @tone == "primary" && "bg-primary/12 text-primary",
        @tone == "neutral" && "bg-base-200 text-base-content/70"
      ]}>
        <CoreComponents.icon name={@icon} class="size-5" />
      </span>
      <h3 class="text-base font-semibold tracking-tight text-base-content">{@title}</h3>
      <p class="text-sm leading-relaxed text-base-content/65">
        {render_slot(@inner_block)}
      </p>
    </article>
    """
  end

  @doc """
  Section heading: an eyebrow label, a title, and optional subtitle. One
  definition keeps the headline rhythm consistent across every section.

      <.section_header eyebrow="Why Hearth" title="Everything your household needs">
        Some supporting copy.
      </.section_header>
  """
  attr :eyebrow, :string, default: nil
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :align, :string, values: ~w(left center), default: "left"
  attr :rest, :global

  slot :inner_block

  def section_header(assigns) do
    ~H"""
    <header
      data-component="BenchappWeb.CompositeComponents.section_header"
      class={["max-w-2xl", @align == "center" && "mx-auto text-center"]}
      {@rest}
    >
      <p :if={@eyebrow} class="text-xs font-medium uppercase tracking-widest text-primary">
        {@eyebrow}
      </p>
      <h2 class="mt-3 text-2xl font-bold tracking-tight text-balance sm:text-3xl">
        {@title}
      </h2>
      <p :if={@subtitle} class="mt-3 text-sm leading-relaxed text-base-content/70">
        {@subtitle}
      </p>
      <div :if={@inner_block != []} class="mt-3">
        {render_slot(@inner_block)}
      </div>
    </header>
    """
  end

  @doc """
  A single stat: muted label plus a big, tabular value. Used inside the
  `#stats` strip on the landing page.

      <.stat_card label="Signups" value="12" value_id="stat-signups" />
  """
  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :value_id, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def stat_card(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.stat_card"
      class={["rounded-3xl border border-base-300 bg-base-100/70 p-6", @class]}
      {@rest}
    >
      <p class="text-xs font-medium uppercase tracking-widest text-base-content/50">
        {@label}
      </p>
      <p id={@value_id} class="mt-2 text-4xl font-black tabular-nums tracking-tight">
        {@value}
      </p>
    </div>
    """
  end
end

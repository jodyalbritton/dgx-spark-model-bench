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

  # Standalone like a core-component module: `use BenchappWeb, :html`
  # would import this very module while it is being defined.
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
  A specimen of a JobyCorp run record: the field names a record carries
  and the unit each quantity is reported in, set in monospace on a
  plotting-paper surface. Field names and units only — a record card of
  *what* a result contains, never of values.

      <.record_card
        fields={[
          %{field: "model", unit: "identifier"},
          %{field: "ttft", unit: "ms"}
        ]}
        caption="The fields a run record carries."
      />
  """
  attr :title, :string, default: "run record", doc: "The monospace label above the fields."
  attr :fields, :list, required: true, doc: "Maps of `%{field: name, unit: unit}`."

  attr :caption, :string,
    default: nil,
    doc: "One-line caption under the record, in the secondary text colour."

  attr :class, :any, default: nil
  attr :rest, :global

  def record_card(assigns) do
    ~H"""
    <figure
      data-component="BenchappWeb.CompositeComponents.record_card"
      class={["record-surface rounded-box p-6", @class]}
      {@rest}
    >
      <p class="font-mono text-sm font-semibold text-base-content">{@title}</p>

      <div class="mt-4 space-y-2.5 border-t border-base-300 pt-4 font-mono text-sm">
        <div :for={item <- @fields} class="flex items-baseline gap-3">
          <span class="flex-none text-base-content">{item.field}</span>
          <span class="flex-1 border-b border-dotted border-base-300" aria-hidden="true"></span>
          <span class="flex-none text-base-content/70">{item.unit}</span>
        </div>
      </div>

      <figcaption :if={@caption} class="mt-4 text-sm text-base-content/70">
        {@caption}
      </figcaption>
    </figure>
    """
  end

  @doc """
  A page section: the vertical rhythm every content section keeps —
  `py-16` at phone width, `py-24` from `md`, `space-y-8` inside. A data
  section opens with a hairline (`ruled`); a prose section keeps the
  reading measure (`narrow`).

      <.page_section ruled>
        <.section_heading head="method">How a result is produced</.section_heading>
        ...
      </.page_section>
  """
  attr :ruled, :boolean, default: false, doc: "Open the section with a hairline."
  attr :narrow, :boolean, default: false, doc: "Constrain contents to the reading measure."
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def page_section(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.CompositeComponents.page_section"
      class={[
        "space-y-8 py-16 md:py-24",
        @ruled && "border-t border-base-300",
        @narrow && "max-w-prose",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc """
  A reading paragraph: the site's body text — measured, relaxed, in the
  secondary ink. Every paragraph of prose on the site goes through this.

      <.lead>JobyCorp runs analysis and benchmarks of local LLMs.</.lead>
  """
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def lead(assigns) do
    ~H"""
    <p
      data-component="BenchappWeb.CompositeComponents.lead"
      class={["max-w-prose text-base leading-relaxed text-base-content/70 md:text-lg", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  A section heading, optionally preceded by the monospace running head
  that names what a data section measures (`benchmarks`, `method`).
  Prose sections pass no `head`.

      <.section_heading head="method">How a result is produced</.section_heading>
  """
  attr :head, :string, default: nil, doc: "Monospace running head for a data section."
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def section_heading(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.section_heading"
      class={["space-y-3", @class]}
      {@rest}
    >
      <p :if={@head} class="font-mono text-sm text-base-content/70">{@head}</p>
      <h2 class="max-w-prose text-3xl font-semibold tracking-tight md:text-4xl">
        {render_slot(@inner_block)}
      </h2>
    </div>
    """
  end
end

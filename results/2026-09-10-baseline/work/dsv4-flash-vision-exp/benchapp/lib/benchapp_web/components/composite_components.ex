defmodule BenchappWeb.CompositeComponents do
  @moduledoc """
  Generic, multi-primitive composites for this app.

  Composites live one layer above core wrappers: they bundle a small set
  of `JobyKit.CoreComponents` primitives into a higher-level pattern that
  appears more than once across the app. Some are JobyCorp-page
  scaffolding (`container`, `section`, `mono_label`, `prose`,
  `two_column`) and one is the brand object — `record_card/1`.

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

  @doc """
  The centred content column for a page. `max-w-6xl`, padded `px-6` at
  phone and `px-8` from `md`, top and bottom `py-16` / `py-24`.

      <.container>
        … page content …
      </.container>
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def container(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.container"
      class={["mx-auto max-w-6xl px-6 py-16 md:px-8 md:py-24", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  A full-width data or prose section: a hairline, the centred column,
  an optional monospace running head, an optional heading, and the body.

      <.section running_head="measurements" heading="What a run measures">
        <.prose>Body copy.</.prose>
      </.section>

  The running head (monospace, secondary colour) is the technical
  vernacular used only where the content is data. Omit it for prose
  sections, which open on their heading alone.
  """
  attr :running_head, :string, default: nil
  attr :heading, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.CompositeComponents.section"
      class={["border-t border-base-300", @class]}
      {@rest}
    >
      <.container>
        <div class="space-y-8">
          <.mono_label :if={@running_head}>{@running_head}</.mono_label>
          <h2 :if={@heading} class="text-3xl font-semibold tracking-tight md:text-4xl">
            {@heading}
          </h2>
          {render_slot(@inner_block)}
        </div>
      </.container>
    </section>
    """
  end

  @doc """
  A monospace running head or field label in the secondary text colour.

      <.mono_label>measurements</.mono_label>
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def mono_label(assigns) do
    ~H"""
    <p
      data-component="BenchappWeb.CompositeComponents.mono_label"
      class={["font-mono text-sm text-base-content/70", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  A reading paragraph at prose width, with the site's body measure.

      <.prose>One idea, two or three sentences.</.prose>
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def prose(assigns) do
    ~H"""
    <p
      data-component="BenchappWeb.CompositeComponents.prose"
      class={["max-w-prose text-base leading-relaxed text-base-content/80 md:text-lg", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  A two-column layout used beside a figure: content on the left, an
  object on the right, top-aligned.

      <.two_column>
        <:content>… reading …</:content>
        <:figure><.record_card … /></:figure>
      </.two_column>

  At phone width the figure follows the content.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :content, required: true
  slot :figure, required: true

  def two_column(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.two_column"
      class={["grid items-start gap-12 lg:grid-cols-[minmax(0,1fr)_auto]", @class]}
      {@rest}
    >
      <div>{render_slot(@content)}</div>
      <div class="justify-self-start lg:justify-self-end">{render_slot(@figure)}</div>
    </div>
    """
  end

  @doc """
  A specimen of a JobyCorp run record on the plotting-paper surface.

  The memorable object of the JobyCorp site. It shows the fields a record
  carries and the unit each quantity is reported in — field names and
  units only, never invented values. Set in monospace on a faint grid
  drawn in CSS, framed by the accent.

      <.record_card
        title="run record"
        rows={[
          %{field: "model", unit: "identifier"},
          %{field: "throughput", unit: "tokens / s"}
        ]}
      >
        <:caption>Field names and units only.</:caption>
      </.record_card>

  A `:title` is the short monospace running head that names what the card
  holds; `rows` are `%{field:, unit:}` maps.
  """
  attr :title, :string, default: "run record"
  attr :rows, :list, default: [], doc: "Each row: %{field: string, unit: string}."
  attr :class, :any, default: nil
  attr :rest, :global

  slot :caption, doc: "One-line note under the record, in the secondary text colour."

  def record_card(assigns) do
    ~H"""
    <figure
      data-component="BenchappWeb.CompositeComponents.record_card"
      class={["record-paper max-w-xs rounded-box border border-secondary p-6", @class]}
      {@rest}
    >
      <.mono_label>{@title}</.mono_label>

      <dl class="mt-5 space-y-0">
        <div
          :for={row <- @rows}
          class="flex items-baseline justify-between gap-6 border-b border-base-300/70 py-2 font-mono text-sm"
        >
          <dt>{row.field}</dt>
          <dd class="text-base-content/70">{row.unit}</dd>
        </div>
      </dl>

      <figcaption :if={@caption != []} class="mt-4 text-sm text-base-content/70">
        {render_slot(@caption)}
      </figcaption>
    </figure>
    """
  end
end

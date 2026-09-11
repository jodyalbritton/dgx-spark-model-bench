defmodule BenchappWeb.CompositeComponents do
  @moduledoc """
  Generic, multi-primitive composites for this app.

  Composites live one layer above core wrappers: they bundle a small set
  of `JobyKit.CoreComponents` primitives and theme tokens into a
  higher-level pattern that appears more than once across the site.

  Every composite follows the JobyKit wrapper contract:

    1. Declare every prop with `attr` (use `values:` for variant enums).
    2. Carry `data-component="BenchappWeb.CompositeComponents.<name>"`
       on the root element.
    3. Accept `attr :rest, :global` for id/class/aria-*/phx-* pass-through.
    4. Internals compose theme tokens and the plotting-paper surface —
       never raw `<button>`/`<input>`/`<textarea>`.
    5. Register the composite in `BenchappWeb.DesignManifest`
       (`category: :composite`) so it surfaces on `/custom-designs` and
       in `/design.json`.
  """

  use BenchappWeb, :html

  @doc """
  A JobyCorp run record shown as a specimen: the fields a record carries
  and the unit each quantity is reported in, set in monospace on a
  plotting-paper surface framed by the accent trace. Field names and
  units only — never invented values. An optional caption sits under the
  card in the secondary text colour.

      <.record_card
        title="run record"
        fields={[%{field: "ttft", unit: "ms"}]}
        caption="What every published run carries."
      />
  """
  attr :fields, :list, required: true, doc: "List of `%{field:, unit:}` maps."
  attr :title, :string, default: "run record"
  attr :caption, :string, default: nil, doc: "One-line caption beneath the card."
  attr :class, :any, default: nil
  attr :rest, :global

  def record_card(assigns) do
    ~H"""
    <div data-component="BenchappWeb.CompositeComponents.record_card" class={@class} {@rest}>
      <div class="plotting-paper rounded-box p-6">
        <div class="flex items-baseline justify-between border-b border-secondary/40 pb-2">
          <span class="font-mono text-sm text-base-content">{@title}</span>
          <span class="font-mono text-[0.7rem] uppercase tracking-[0.15em] text-base-content/70">
            record
          </span>
        </div>
        <dl class="pt-1 font-mono text-sm">
          <div
            :for={f <- @fields}
            class="flex items-baseline justify-between gap-4 border-b border-secondary/20 py-1.5 last:border-0"
          >
            <dt class="text-base-content">{f.field}</dt>
            <dd class="text-base-content/70">{f.unit}</dd>
          </div>
        </dl>
      </div>
      <p :if={@caption} class="mt-3 text-sm text-base-content/70">
        {@caption}
      </p>
    </div>
    """
  end

  @doc """
  A spec-sheet row: a monospace label in a fixed column beside a reading
  column. From `md` the two sit side by side; at phone width they stack.
  Use several in a `space-y-*` container to build a spec sheet.

      <.spec_row label="method">Each model is run locally, on hardware we own.</.spec_row>
  """
  attr :label, :string, required: true, doc: "Monospace label in the fixed column."
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true, doc: "Reading column content."

  def spec_row(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.spec_row"
      class={["border-t border-base-300 pt-4 md:flex md:gap-8", @class]}
      {@rest}
    >
      <dt class="w-44 shrink-0 pb-1 font-mono text-sm text-base-content/70 md:pb-0">
        {@label}
      </dt>
      <dd class="text-base md:text-lg leading-relaxed">{render_slot(@inner_block)}</dd>
    </div>
    """
  end

  @doc """
  The centred page column: `max-w-6xl`, `px-6` at phone width, `px-8`
  from `md`. One per page; sections live inside it.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def page_body(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.page_body"
      class={["mx-auto max-w-6xl px-6 md:px-8", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  A lead paragraph — body copy at the reading measure, in the secondary
  ink. Use under a hero statement or as a section's opening line.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def lede(assigns) do
    ~H"""
    <p
      data-component="BenchappWeb.CompositeComponents.lede"
      class={["text-base leading-relaxed text-base-content/70 md:text-lg", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  A content section on the vertical rhythm: a hairline rule, an optional
  monospace running head naming what is measured, a section heading, an
  optional lead, and the section body. `head` is the technical vernacular
  (`ttft`, `method`) shown only where the content is data.
  """
  attr :head, :string, default: nil, doc: "Monospace running head for a data section."
  attr :title, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :lead
  slot :inner_block, required: true, doc: "Section body — a figure, table, or list."

  def section(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.CompositeComponents.section"
      class={["space-y-8 border-t border-base-300 py-16 md:py-24", @class]}
      {@rest}
    >
      <div :if={@head} class="font-mono text-sm text-base-content/70">{@head}</div>
      <div class="max-w-prose space-y-3">
        <h2 class="text-3xl font-semibold tracking-tight md:text-4xl">{@title}</h2>
        <.lede :if={@lead != []}>{render_slot(@lead)}</.lede>
      </div>
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc """
  A table as a figure: `bg-base-200` header row, hairlines, no zebra,
  and horizontal scroll inside its own container at phone width. Pass a
  `JobyKit.CoreComponents.table` as the body.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def figure_table(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.figure_table"
      class={["figure-table overflow-x-auto rounded-box border border-base-300", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Reading-column text inside a table cell, in the secondary ink.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def prose_cell(assigns) do
    ~H"""
    <span
      data-component="BenchappWeb.CompositeComponents.prose_cell"
      class={["text-sm text-base-content/80", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end

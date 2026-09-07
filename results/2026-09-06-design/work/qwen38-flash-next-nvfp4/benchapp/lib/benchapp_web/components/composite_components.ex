defmodule BenchappWeb.CompositeComponents do
  @moduledoc """
  Generic, multi-primitive composites for this app.

  Composites live one layer above core wrappers: they bundle a small set
  of `JobyKit.CoreComponents` primitives into a higher-level pattern that
  appears more than once across the app.

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

  The four here are the site's figures and its section rhythm: the record
  card a run is written on, the spec sheet that sets a field name beside
  its explanation, the running head over a section of data, and the
  section head that opens any section.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @hero_title "text-5xl font-semibold tracking-[-0.03em] leading-[1.02] md:text-7xl"
  @section_title "text-3xl font-semibold tracking-tight md:text-4xl"

  # ---------------------------------------------------------- record_card

  @doc """
  The JobyCorp record card: a specimen of a record, drawn in monospace on
  plotting paper and framed by the trace colour.

  A record carries *fields* and the *unit* each quantity is reported in —
  never values. Pass those and nothing else.

      <.record_card
        id="hero-record"
        label="run record"
        fields={[
          %{name: "ttft", unit: "ms"},
          %{name: "generation", unit: "tokens/s"}
        ]}
        caption="Every field a run record carries, and its unit."
      />
  """
  attr :label, :string, required: true, doc: "What kind of record the specimen is."

  attr :fields, :list,
    required: true,
    doc: ~S|The fields the record carries, as `%{name: "ttft", unit: "ms"}`.|

  attr :caption, :string, default: nil, doc: "One line under the card."
  attr :class, :any, default: nil
  attr :rest, :global

  def record_card(assigns) do
    ~H"""
    <figure data-component="BenchappWeb.CompositeComponents.record_card" class={@class} {@rest}>
      <div class="plot-grid rounded-box p-6">
        <p class="font-mono text-sm text-base-content">{@label}</p>
        <dl class="mt-3 border-t border-secondary/25">
          <div
            :for={field <- @fields}
            class="flex items-baseline justify-between gap-6 border-b border-secondary/25 py-2"
          >
            <dt class="font-mono text-sm text-base-content">{field.name}</dt>
            <dd class="text-right font-mono text-sm text-base-content/70">{field.unit}</dd>
          </div>
        </dl>
      </div>
      <figcaption :if={@caption} class="mt-3 text-sm text-base-content/70">
        {@caption}
      </figcaption>
    </figure>
    """
  end

  # ----------------------------------------------------------- spec_sheet

  @doc """
  A spec sheet: a monospace label column beside a reading column, one
  hairline per row. Stacks at phone width.

      <.spec_sheet>
        <:row label="hardware">Machines JobyCorp owns and runs.</:row>
        <:row label="results">Published in full, fields and units.</:row>
      </.spec_sheet>
  """
  attr :class, :any, default: nil
  attr :rest, :global

  slot :row, required: true, doc: "One row; `label` is the monospace field name." do
    attr :label, :string, required: true
  end

  def spec_sheet(assigns) do
    ~H"""
    <dl
      data-component="BenchappWeb.CompositeComponents.spec_sheet"
      class={["divide-y divide-base-300 border-y border-base-300", @class]}
      {@rest}
    >
      <div
        :for={row <- @row}
        class="grid gap-1 py-5 md:grid-cols-[11rem_minmax(0,1fr)] md:gap-8"
      >
        <dt class="font-mono text-sm text-base-content/70">{row.label}</dt>
        <dd class="max-w-prose">{render_slot(row)}</dd>
      </div>
    </dl>
    """
  end

  # --------------------------------------------------------- running_head

  @doc """
  The running head of a data section: a hairline above, and the short
  monospace name of what is measured below it (`ttft`, `hardware`).

  Use it only where the section's content is data.

      <.running_head>measures</.running_head>
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def running_head(assigns) do
    ~H"""
    <p
      data-component="BenchappWeb.CompositeComponents.running_head"
      class={["border-t border-base-300 pt-6 font-mono text-sm text-base-content/70", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ---------------------------------------------------------- section_head

  @doc """
  Opens a section: an optional running head for data sections, the
  heading, and an optional lead paragraph. The hero takes `size="hero"`
  for the display scale; everything else is the section scale.

      <.section_head running_head="ttft" lead="Four quantities, one run.">
        What a run measures
      </.section_head>
  """
  attr :running_head, :string, default: nil, doc: "Data-section head, set in monospace."
  attr :lead, :string, default: nil, doc: "One paragraph under the heading."
  attr :level, :string, values: ~w(h1 h2 h3), default: "h2"

  attr :size, :string,
    values: ~w(hero section),
    default: "section",
    doc: "Type scale: the hero's display size or a section's."

  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true, doc: "The heading."

  def section_head(assigns) do
    assigns = assign(assigns, :title_class, title_class(assigns.size))

    ~H"""
    <div data-component="BenchappWeb.CompositeComponents.section_head" class={@class} {@rest}>
      <.running_head :if={@running_head}>{@running_head}</.running_head>
      <CoreComponents.header
        level={@level}
        title_class={@title_class}
        class={[@running_head && "mt-5"]}
      >
        {render_slot(@inner_block)}
      </CoreComponents.header>
      <p
        :if={@lead}
        class="mt-4 max-w-prose text-base leading-relaxed text-base-content/70 md:text-lg"
      >
        {@lead}
      </p>
    </div>
    """
  end

  defp title_class("hero"), do: @hero_title
  defp title_class(_), do: @section_title

  # -------------------------------------------------------- content_column

  @doc """
  The site's content column: `max-w-6xl`, centred on the page, contents
  left-aligned, `px-6` at phone width and `px-8` from `md`. Every page and
  both pieces of chrome sit inside one, so the column never drifts.

  `flow` adds the site's section rhythm — `space-y` between sections,
  `py-16` at phone width and `py-24` from `md` — so a page's sections are
  spaced by the site rather than by whoever wrote the page.

      <.content_column flow>
        <section>...</section>
        <section>...</section>
      </.content_column>
  """
  attr :flow, :boolean, default: false, doc: "Add the site's section rhythm."
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def content_column(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.content_column"
      class={[
        "mx-auto w-full max-w-6xl px-6 md:px-8",
        @flow && "space-y-16 py-16 md:space-y-24 md:py-24",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ----------------------------------------------------------- data_table

  @doc """
  The JobyCorp table: a figure, not a layout. `bg-base-200` header row,
  hairlines, no striping, identifiers in monospace, units right-aligned,
  and a container that scrolls on its own at phone width.

  Each `:col` says what kind of content it holds — `id` for a field or
  model name, `unit` for a unit, the default for the sentence that says
  how to read it.

      <.data_table id="measures" rows={@measures}>
        <:col :let={m} kind="id" label="quantity">{m.quantity}</:col>
        <:col :let={m} kind="unit" label="unit">{m.unit}</:col>
        <:col :let={m} label="how to read it">{m.reading}</:col>
      </.data_table>
  """
  attr :id, :string, required: true, doc: "DOM id for the table's row container."
  attr :rows, :list, required: true
  attr :class, :any, default: nil
  attr :rest, :global

  slot :col, required: true do
    attr :label, :string

    attr :kind, :string,
      values: ~w(id unit text),
      doc: "How the cell reads: a monospace identifier, a right-aligned unit, or prose."
  end

  def data_table(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.data_table"
      class={["overflow-x-auto rounded-box border border-base-300 bg-base-100", @class]}
      {@rest}
    >
      <CoreComponents.table
        id={@id}
        rows={@rows}
        zebra={false}
        class={[
          "[&_thead_tr]:bg-base-200 [&_th]:text-sm [&_th]:font-mono [&_th]:text-base-content [&_td]:py-4"
        ]}
      >
        <:col :let={row} :for={col <- @col} label={col[:label]}>
          <span class={[
            col[:kind] == "id" && "font-mono text-sm text-base-content",
            col[:kind] == "unit" && "block text-right font-mono text-sm text-base-content/70",
            col[:kind] in [nil, "text"] && "block max-w-prose text-base-content/70"
          ]}>
            {render_slot(col, row)}
          </span>
        </:col>
      </CoreComponents.table>
    </div>
    """
  end

  # ---------------------------------------------------------- closing_call

  @doc """
  How a page ends: a hairline, a heading, one line of reason, and a text
  link that says what the visitor will find. The link is a secondary
  action — the primary button belongs to the hero.

      <.closing_call
        lead="A result you cannot inspect is a claim."
        href={~p"/research"}
        label="How JobyCorp tests, and what it publishes"
      >
        Read the research
      </.closing_call>
  """
  attr :lead, :string, required: true
  attr :href, :string, required: true
  attr :label, :string, required: true, doc: "The link's text: what happens when it is followed."
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true, doc: "The heading of the closing band."

  def closing_call(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.CompositeComponents.closing_call"
      class={["border-t border-base-300 pt-8", @class]}
      {@rest}
    >
      <.section_head lead={@lead}>{render_slot(@inner_block)}</.section_head>
      <p class="mt-6 text-lg">
        <.link
          navigate={@href}
          class="text-primary underline underline-offset-4 decoration-1 transition-colors duration-150 hover:no-underline"
        >
          {@label}
        </.link>
      </p>
    </section>
    """
  end
end

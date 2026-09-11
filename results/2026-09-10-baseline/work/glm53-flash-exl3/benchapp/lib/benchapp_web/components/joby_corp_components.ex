defmodule BenchappWeb.JobyCorpComponents do
  @moduledoc """
  Domain composites for the JobyCorp site: the recurring page patterns —
  hero grids, data-section heads, spec-sheet rows, and calls to action —
  registered in `BenchappWeb.DesignManifest` so they surface on
  `/custom-designs`.
  """

  use BenchappWeb, :html

  @doc """
  The two-column hero grid: statement on the left, record card on the
  right from `lg`; stacked at phone width.

      <.hero_grid>
        <div>...</div>
        <.record_card ... />
      </.hero_grid>
  """
  attr :rest, :global
  slot :inner_block, required: true

  def hero_grid(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.JobyCorpComponents.hero_grid"
      class="grid items-start gap-12 py-16 md:py-24 lg:grid-cols-[minmax(0,1fr)_minmax(0,26rem)]"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  A data section's opening: a monospace running head naming what is
  measured, then the section heading.

      <.section_head label="hardware" heading="Local models, local hardware" />
  """
  attr :label, :string, required: true
  attr :heading, :string, required: true
  attr :rest, :global

  def section_head(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.JobyCorpComponents.section_head"
      class="space-y-8"
      {@rest}
    >
      <p class="font-mono text-sm text-base-content/70">{@label}</p>
      <h2 class="text-3xl font-semibold tracking-tight md:text-4xl">{@heading}</h2>
    </div>
    """
  end

  @doc """
  A spec-sheet row: monospace term column beside a reading column, from
  `md`. Stacks at phone width.

      <.spec_row term="method">
        The method is fixed before a benchmark starts.
      </.spec_row>
  """
  attr :term, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def spec_row(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.JobyCorpComponents.spec_row"
      class="grid gap-8 md:grid-cols-[10rem_minmax(0,1fr)]"
      {@rest}
    >
      <p class="font-mono text-sm text-base-content/70">{@term}</p>
      <p class="max-w-prose text-base leading-relaxed md:text-lg">
        {render_slot(@inner_block)}
      </p>
    </div>
    """
  end

  @doc """
  A reading paragraph at measure: the site's body-text treatment.

      <.body_text>JobyCorp runs benchmarks of local LLMs.</.body_text>
  """
  attr :rest, :global
  slot :inner_block, required: true

  def body_text(assigns) do
    ~H"""
    <p
      data-component="BenchappWeb.JobyCorpComponents.body_text"
      class="max-w-prose text-base leading-relaxed md:text-lg"
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  A closing call to action: a heading and one primary action.

      <.cta_section heading="The numbers are on the record.">
        <.button navigate={~p"/research"} variant="primary">Read the research</.button>
      </.cta_section>
  """
  attr :heading, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def cta_section(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.JobyCorpComponents.cta_section"
      class="border-t border-base-300 py-16 md:py-24"
      {@rest}
    >
      <div class="space-y-6">
        <h2 class="max-w-xl text-3xl font-semibold tracking-tight md:text-4xl">
          {@heading}
        </h2>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  @doc """
  One row of the "what a run measures" table: quantity, unit, and what
  the quantity shows.

      <.metric_row quantity="ttft" unit="ms">how long until the first token arrives</.metric_row>
  """
  attr :quantity, :string, required: true
  attr :unit, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def metric_row(assigns) do
    ~H"""
    <tr
      data-component="BenchappWeb.JobyCorpComponents.metric_row"
      class="border-t border-base-300"
      {@rest}
    >
      <td class="px-4 py-3">{@quantity}</td>
      <td class="px-4 py-3">{@unit}</td>
      <td class="px-4 py-3 font-sans text-base-content/70">{render_slot(@inner_block)}</td>
    </tr>
    """
  end

  @doc """
  The page column: the site's centred content container.

      <.page_column>sections</.page_column>
  """
  attr :rest, :global
  slot :inner_block, required: true

  def page_column(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.JobyCorpComponents.page_column"
      class="mx-auto max-w-6xl px-6 md:px-8"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  A data section: hairline top, vertical rhythm, inner stack.

      <.data_section>...</.data_section>
  """
  attr :rest, :global
  slot :inner_block, required: true

  def data_section(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.JobyCorpComponents.data_section"
      class="border-t border-base-300 py-16 md:py-24"
      {@rest}
    >
      <div class="space-y-8">{render_slot(@inner_block)}</div>
    </section>
    """
  end

  @doc """
  The hero statement: the page's largest heading.

      <.hero_heading>Benchmarks of local language models, published in full.</.hero_heading>
  """
  attr :rest, :global
  slot :inner_block, required: true

  def hero_heading(assigns) do
    ~H"""
    <h1
      data-component="BenchappWeb.JobyCorpComponents.hero_heading"
      class="max-w-xl text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-7xl"
      {@rest}
    >
      {render_slot(@inner_block)}
    </h1>
    """
  end
end

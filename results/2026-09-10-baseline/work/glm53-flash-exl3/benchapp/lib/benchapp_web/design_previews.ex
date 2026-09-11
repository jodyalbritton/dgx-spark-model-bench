defmodule BenchappWeb.DesignPreviews do
  @moduledoc """
  Preview functions for **this app's** components, referenced by
  `BenchappWeb.DesignManifest`.

  The kit's own components are previewed by `JobyKit.Previews`, so
  `/design` shows the same examples in every JobyKit app. You only write
  previews for what you add.

  Each public function takes `assigns` (typically `%{}`) and returns a
  small HEEx rendering the component with sensible defaults. The
  manifest registers these via `preview: &BenchappWeb.DesignPreviews.X_preview/1`,
  and `JobyKit.SignatureComponent` invokes them inside the per-component
  card's collapsible Preview section.

  Naming convention: every preview function ends in `_preview` so they
  don't collide with the imported component functions of the same name
  (e.g. `button` vs `button_preview`).

  The previews call `JobyKit.CoreComponents` directly via the
  `CoreComponents` alias so the rendered HTML matches what the manifest
  declares — no dependency on the host's `<App>Web.CoreComponents`
  resolution.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents
  alias BenchappWeb.CompositeComponents

  def empty_state_preview(assigns) do
    ~H"""
    <div class="grid gap-4 sm:grid-cols-2">
      <CompositeComponents.empty_state icon="hero-inbox" title="No messages yet">
        Start a conversation with a teammate to see it here.
        <:action>
          <CoreComponents.button variant="primary">New message</CoreComponents.button>
        </:action>
      </CompositeComponents.empty_state>
      <CompositeComponents.empty_state
        icon="hero-sparkles"
        title="Set up your workspace"
        tone="primary"
      >
        Connect your first integration to populate this dashboard.
      </CompositeComponents.empty_state>
    </div>
    """
  end

  def record_card_preview(assigns) do
    ~H"""
    <div class="grid gap-4 sm:grid-cols-2">
      <CompositeComponents.record_card
        title="Run record"
        rows={[
          %{field: "model", unit: "identifier"},
          %{field: "ttft", unit: "ms"},
          %{field: "decode", unit: "tok/s"},
          %{field: "context", unit: "tokens"}
        ]}
      >
        What every published run carries, in the units it reports.
      </CompositeComponents.record_card>

      <CompositeComponents.record_card
        title="Hardware record"
        rows={[
          %{field: "hardware", unit: "name"},
          %{field: "memory", unit: "GB"},
          %{field: "runtime", unit: "version"},
          %{field: "date", unit: "ISO 8601"}
        ]}
      >
        The machine behind each run, stated alongside the numbers.
      </CompositeComponents.record_card>
    </div>
    """
  end

  alias BenchappWeb.JobyCorpComponents

  def hero_grid_preview(assigns) do
    ~H"""
    <JobyCorpComponents.hero_grid>
      <div class="space-y-8">
        <h1 class="max-w-xl text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-7xl">
          Benchmarks of local language models, published in full.
        </h1>
      </div>
      <CompositeComponents.record_card
        title="Run record"
        rows={[
          %{field: "model", unit: "identifier"},
          %{field: "ttft", unit: "ms"}
        ]}
      />
    </JobyCorpComponents.hero_grid>
    """
  end

  def section_head_preview(assigns) do
    ~H"""
    <JobyCorpComponents.section_head label="hardware" heading="Local models, local hardware" />
    """
  end

  def spec_row_preview(assigns) do
    ~H"""
    <JobyCorpComponents.spec_row term="method">
      The method is fixed before a benchmark starts and does not change
      between runs.
    </JobyCorpComponents.spec_row>
    """
  end

  def body_text_preview(assigns) do
    ~H"""
    <JobyCorpComponents.body_text>
      JobyCorp runs benchmarks of local language models on its own hardware.
    </JobyCorpComponents.body_text>
    """
  end

  def cta_section_preview(assigns) do
    ~H"""
    <JobyCorpComponents.cta_section heading="The numbers are on the record.">
      <CoreComponents.button navigate="/" variant="primary">Read the research</CoreComponents.button>
    </JobyCorpComponents.cta_section>
    """
  end

  def metric_row_preview(assigns) do
    ~H"""
    <table class="w-full text-left font-mono text-sm">
      <tbody>
        <JobyCorpComponents.metric_row quantity="ttft" unit="ms">
          how long until the first token arrives
        </JobyCorpComponents.metric_row>
      </tbody>
    </table>
    """
  end

  def page_column_preview(assigns) do
    ~H"""
    <JobyCorpComponents.page_column>
      <p class="font-mono text-sm">section content</p>
    </JobyCorpComponents.page_column>
    """
  end

  def data_section_preview(assigns) do
    ~H"""
    <JobyCorpComponents.data_section>
      <JobyCorpComponents.section_head label="method" heading="The path of a run" />
    </JobyCorpComponents.data_section>
    """
  end

  def hero_heading_preview(assigns) do
    ~H"""
    <JobyCorpComponents.hero_heading>Measurement is the work.</JobyCorpComponents.hero_heading>
    """
  end
end

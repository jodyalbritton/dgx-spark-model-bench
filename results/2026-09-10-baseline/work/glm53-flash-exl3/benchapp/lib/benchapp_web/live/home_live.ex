defmodule BenchappWeb.HomeLive do
  @moduledoc "The JobyCorp landing page."

  use BenchappWeb, :live_view

  import BenchappWeb.CompositeComponents, only: [record_card: 1]
  import BenchappWeb.JobyCorpComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "JobyCorp") |> assign(:active_nav, "home")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav={@active_nav}>
      <.page_column>
        <.hero_grid>
          <div class="space-y-8">
            <.hero_heading>
              Benchmarks of local language models, published in full.
            </.hero_heading>
            <.body_text>
              JobyCorp runs analysis and benchmarks of local LLMs on its own
              hardware, and shares every result with the community. The
              numbers, the method, and the machines behind them are all part
              of the record.
            </.body_text>
            <div>
              <.button navigate={~p"/research"} variant="primary">
                Read the research
              </.button>
            </div>
          </div>

          <.record_card
            title="Run record"
            rows={[
              %{field: "model", unit: "identifier"},
              %{field: "prompt", unit: "tokens"},
              %{field: "ttft", unit: "ms"},
              %{field: "decode", unit: "tok/s"},
              %{field: "context", unit: "tokens"},
              %{field: "hardware", unit: "name"}
            ]}
          >
            Every field of a published run, in the unit it reports.
          </.record_card>
        </.hero_grid>

        <.data_section>
          <.section_head label="what a run measures" heading="What a run measures" />
          <.body_text>
            A run is reported the same way every time, so results can be
            compared across models and across machines. The quantities are
            chosen to answer the questions people actually have about a
            local model: how quickly it starts, how fast it continues, and
            how much text it can hold.
          </.body_text>
          <div class="overflow-x-auto">
            <table class="w-full min-w-md text-left font-mono text-sm">
              <thead class="bg-base-200">
                <tr>
                  <th class="px-4 py-3 font-medium">quantity</th>
                  <th class="px-4 py-3 font-medium">unit</th>
                  <th class="px-4 py-3 font-medium">what it shows</th>
                </tr>
              </thead>
              <tbody>
                <.metric_row quantity="ttft" unit="ms">
                  how long until the first token arrives
                </.metric_row>
                <.metric_row quantity="decode" unit="tok/s">
                  how quickly the model keeps writing
                </.metric_row>
                <.metric_row quantity="context" unit="tokens">
                  how much the model can hold at once
                </.metric_row>
              </tbody>
            </table>
          </div>
        </.data_section>

        <.data_section>
          <.section_head label="hardware" heading="Local models, local hardware" />
          <.spec_row term="hardware">
            Everything runs on JobyCorp's own machines. No rented
            capacity, no shared clusters — the same hardware sits behind
            every number we publish, so results repeat.
          </.spec_row>
          <.spec_row term="method">
            The method is fixed before a benchmark starts and does not
            change between runs. When it changes, the record says so.
          </.spec_row>
          <.spec_row term="results">
            Results are published in full, including the runs that made a
            model look worse. Nothing is summarised away.
          </.spec_row>
        </.data_section>

        <.cta_section heading="The numbers are on the record.">
          <.button navigate={~p"/research"} variant="primary">
            Read the research
          </.button>
        </.cta_section>
      </.page_column>
    </Layouts.app>
    """
  end
end

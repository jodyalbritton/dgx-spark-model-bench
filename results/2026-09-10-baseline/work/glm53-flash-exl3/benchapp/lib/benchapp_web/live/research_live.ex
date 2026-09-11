defmodule BenchappWeb.ResearchLive do
  @moduledoc "What JobyCorp publishes and how it tests."

  use BenchappWeb, :live_view

  import BenchappWeb.CompositeComponents, only: [record_card: 1]
  import BenchappWeb.JobyCorpComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Research") |> assign(:active_nav, "research")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav={@active_nav}>
      <.page_column>
        <.hero_grid>
          <div class="space-y-8">
            <.hero_heading>
              How a run is tested
            </.hero_heading>
            <.body_text>
              Every benchmark follows the same path: a fixed prompt set, a
              fixed runtime, and a record that captures what happened. The
              path is published next to the results, so anyone can see
              exactly how a number was produced.
            </.body_text>
          </div>

          <.record_card
            title="Run record"
            rows={[
              %{field: "model", unit: "identifier"},
              %{field: "prompt", unit: "tokens"},
              %{field: "ttft", unit: "ms"},
              %{field: "decode", unit: "tok/s"},
              %{field: "memory", unit: "GB"},
              %{field: "date", unit: "ISO 8601"}
            ]}
          >
            One record per run, published as produced.
          </.record_card>
        </.hero_grid>

        <.data_section>
          <.section_head label="method" heading="The path of a run" />
          <ol class="max-w-prose list-decimal space-y-4 pl-5 text-base leading-relaxed marker:font-mono marker:text-base-content/70 md:text-lg">
            <li>
              Choose the model and the runtime, and state both in the
              record — the same weights measured through different
              runtimes are not the same result.
            </li>
            <li>
              Fix the prompt set before the run starts. Prompts are not
              adjusted between models, so scores stay comparable.
            </li>
            <li>
              Run the benchmark on JobyCorp's own hardware and record the
              machine alongside the numbers.
            </li>
            <li>
              Publish the record in full — the headline figures and every
              supporting detail, with nothing held back.
            </li>
          </ol>
        </.data_section>

        <.data_section>
          <.section_head label="what a run measures" heading="What a record carries" />
          <.body_text>
            Each record identifies the model, the machine, and the
            conditions of the run, then reports the measured quantities in
            fixed units. A reader can trace any published figure back to
            the run that produced it.
          </.body_text>
          <.spec_row term="identification">
            The model identifier, the hardware name, and the date of the
            run — so a result can always be placed in context.
          </.spec_row>
          <.spec_row term="measurement">
            Time to first token in milliseconds, decode throughput in
            tokens per second, and the context the run used.
          </.spec_row>
        </.data_section>

        <.cta_section heading="Read a record the way we wrote it.">
          <.button navigate={~p"/"} variant="primary">
            Start from the landing page
          </.button>
        </.cta_section>
      </.page_column>
    </Layouts.app>
    """
  end
end

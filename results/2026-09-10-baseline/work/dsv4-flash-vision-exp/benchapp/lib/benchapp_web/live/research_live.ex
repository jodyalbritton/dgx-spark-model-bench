defmodule BenchappWeb.ResearchLive do
  @moduledoc """
  The JobyCorp research page.

  What JobyCorp publishes and how it tests: the method (a sequence), the
  quantities a run reports, and the fact that everything ships in full.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @record_rows [
    %{field: "model", unit: "identifier"},
    %{field: "hardware", unit: "identifier"},
    %{field: "context length", unit: "tokens"},
    %{field: "throughput", unit: "tokens / s"},
    %{field: "latency", unit: "ms / token"},
    %{field: "quality", unit: "score"}
  ]

  @steps [
    "Name the model and the exact build that runs.",
    "Record the hardware, the software, and every setting before a run.",
    "Answer a fixed prompt set on the local machine.",
    "Capture the quantities above into one run record.",
    "Publish the record, the method, and the configuration in full."
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Research", record_rows: @record_rows, steps: @steps)}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="research">
      <CompositeComponents.container>
        <div class="space-y-8">
          <h1 class="max-w-3xl text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-6xl">
            How a run is measured
          </h1>
          <CompositeComponents.prose>
            JobyCorp publishes analysis and benchmarks of local LLMs. Each result is a
            run record — the configuration, the method, and the measured quantities —
            published in full rather than as a summary.
          </CompositeComponents.prose>
        </div>
      </CompositeComponents.container>

      <CompositeComponents.section running_head="method" heading="The test, in order">
        <CompositeComponents.two_column>
          <:content>
            <div class="space-y-6">
              <CompositeComponents.prose>
                The method is a sequence, run the same way every time, so a result
                means the same thing wherever it appears.
              </CompositeComponents.prose>
              <ol class="max-w-prose space-y-4">
                <li :for={{step, i} <- Enum.with_index(@steps, 1)} class="flex gap-4">
                  <span aria-hidden="true" class="font-mono text-sm text-base-content/70">{i}</span>
                  <span class="text-base leading-relaxed text-base-content/80">{step}</span>
                </li>
              </ol>
            </div>
          </:content>
          <:figure>
            <CompositeComponents.record_card title="run record" rows={@record_rows}>
              <:caption>
                The record a run produces — field and unit, no invented values.
              </:caption>
            </CompositeComponents.record_card>
          </:figure>
        </CompositeComponents.two_column>
      </CompositeComponents.section>

      <CompositeComponents.section
        running_head="publication"
        heading="Every result, published in full"
      >
        <CompositeComponents.prose>
          A result is worth little if the reader cannot check it. Each published run
          carries the configuration, the method, and the run record, so anyone can
          reproduce the measurement instead of taking it on faith.
        </CompositeComponents.prose>
      </CompositeComponents.section>
    </Layouts.app>
    """
  end
end

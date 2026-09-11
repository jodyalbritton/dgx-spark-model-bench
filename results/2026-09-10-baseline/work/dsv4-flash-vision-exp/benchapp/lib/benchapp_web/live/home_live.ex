defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The JobyCorp landing page.

  Says what JobyCorp does in one sentence, shows a specimen of a run
  record, and closes with a call to read the research.
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

  @measurements [
    %{quantity: "throughput", unit: "tokens / s"},
    %{quantity: "latency", unit: "ms / token"},
    %{quantity: "quality", unit: "score"},
    %{quantity: "context length", unit: "tokens"}
  ]

  @spec_sheet [
    %{label: "hardware", detail: "Models run on hardware we own and maintain, behind the work."},
    %{label: "models", detail: "Local models only — no remote inference, no leased compute."},
    %{
      label: "method",
      detail: "Each run is measured the same way, and the configuration ships with the result."
    },
    %{
      label: "publication",
      detail: "Results are published in full, configuration and method included."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Home",
       record_rows: @record_rows,
       measurements: @measurements,
       spec_sheet: @spec_sheet
     )}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <CompositeComponents.container>
        <CompositeComponents.two_column>
          <:content>
            <h1 class="max-w-3xl text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-7xl">
              JobyCorp runs local models on its own hardware, measures them, and publishes the results in full.
            </h1>
            <p class="mt-6 max-w-prose text-base leading-relaxed md:text-lg">
              We run language models where the work happens — on hardware we own and
              operate. Every run is measured the same way, and the results are published
              openly, so anyone can check the work and build on it.
            </p>
            <div class="mt-8">
              <.button navigate={~p"/research"} variant="primary">Read the research</.button>
            </div>
          </:content>
          <:figure>
            <CompositeComponents.record_card title="run record" rows={@record_rows}>
              <:caption>
                What a JobyCorp run record carries — the field and the unit, nothing invented.
              </:caption>
            </CompositeComponents.record_card>
          </:figure>
        </CompositeComponents.two_column>
      </CompositeComponents.container>

      <CompositeComponents.section running_head="measurements" heading="What a run measures">
        <CompositeComponents.prose>
          Every run reports the same set of quantities, so results stay comparable
          run to run and machine to machine. The measurement, not the claim, is the
          finding.
        </CompositeComponents.prose>

        <div class="overflow-x-auto rounded-box border border-base-300">
          <table class="w-full text-left text-sm">
            <thead class="bg-base-200 font-mono text-base-content/70">
              <tr>
                <th class="px-5 py-3 font-medium">quantity</th>
                <th class="px-5 py-3 font-medium">reported in</th>
              </tr>
            </thead>
            <tbody class="font-mono">
              <tr :for={{m, _} <- Enum.with_index(@measurements)} class="border-t border-base-300">
                <td class="px-5 py-3">{m.quantity}</td>
                <td class="px-5 py-3 text-base-content/70">{m.unit}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </CompositeComponents.section>

      <CompositeComponents.section
        running_head="hardware & method"
        heading="Local models, local hardware"
      >
        <div class="grid gap-x-12 gap-y-6 md:grid-cols-[11rem_minmax(0,1fr)]">
          <div :for={item <- @spec_sheet} class="contents md:contents">
            <CompositeComponents.mono_label>{item.label}</CompositeComponents.mono_label>
            <CompositeComponents.prose>{item.detail}</CompositeComponents.prose>
          </div>
        </div>
      </CompositeComponents.section>

      <CompositeComponents.section heading="Read the research">
        <CompositeComponents.prose>
          The results, the method, and how the tests are run are published in full.
        </CompositeComponents.prose>
        <div>
          <.button navigate={~p"/research"} variant="primary">Read the research</.button>
        </div>
      </CompositeComponents.section>
    </Layouts.app>
    """
  end
end

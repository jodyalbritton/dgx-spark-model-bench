defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The JobyCorp landing page: what the company does, what its runs
  measure, and the hardware and method behind the numbers.
  """

  use BenchappWeb, :live_view

  @record_fields [
    %{field: "model", unit: "identifier"},
    %{field: "quantization", unit: "format"},
    %{field: "prompt", unit: "tokens"},
    %{field: "ttft", unit: "ms"},
    %{field: "throughput", unit: "tokens/s"}
  ]

  @measures [
    %{field: "ttft", unit: "ms"},
    %{field: "throughput", unit: "tokens/s"},
    %{field: "prompt", unit: "tokens"}
  ]

  @method [
    %{
      term: "models",
      detail:
        "Local LLMs, run on machines we own. If a model is on this site, we ran it ourselves."
    },
    %{
      term: "hardware",
      detail:
        "Our own hardware, the same machines for every run — so one number can be compared with the next."
    },
    %{
      term: "results",
      detail:
        "Published in full: the numbers, the method, and the hardware they were measured on."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Local LLM benchmarks",
       record_fields: @record_fields,
       measures: @measures,
       method: @method
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <section class="grid gap-12 py-16 md:py-24 lg:grid-cols-2 lg:items-start lg:gap-16">
        <div class="max-w-prose space-y-8">
          <h1 class="text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-7xl">
            Local LLMs, measured on our own hardware.
          </h1>
          <.lead>
            JobyCorp runs analysis and benchmarks of local LLMs on hardware we own and shares the
            research openly with the community. Every result is published in full.
          </.lead>
          <div>
            <.button variant="primary" navigate={~p"/research"}>Read the research</.button>
          </div>
        </div>

        <.record_card
          fields={@record_fields}
          caption="The fields a JobyCorp run record carries."
          class="w-full max-w-md justify-self-start lg:justify-self-end"
        />
      </section>

      <.page_section ruled>
        <.section_heading head="benchmarks">What a run measures</.section_heading>
        <.lead>
          A run records how a model behaves, not how it describes itself. The same measures, taken
          the same way on the same machines, so a number can be compared with the next one.
        </.lead>
        <ul class="flex flex-wrap gap-x-10 gap-y-2 font-mono text-sm">
          <li :for={measure <- @measures} class="flex gap-3">
            <span class="text-base-content">{measure.field}</span>
            <span class="text-base-content/70">{measure.unit}</span>
          </li>
        </ul>
        <.lead>
          What each measure means, and how the runs are tested:{" "}
          <.link
            navigate={~p"/research"}
            class="text-primary underline underline-offset-4 decoration-1 transition-colors duration-150 hover:opacity-80"
          >
            the method, in full</.link>.
        </.lead>
      </.page_section>

      <.page_section ruled>
        <.section_heading head="method">Local models, our machines, full results</.section_heading>
        <dl class="space-y-6">
          <div :for={entry <- @method} class="flex flex-col gap-1 md:flex-row md:gap-0">
            <dt class="flex-none font-mono text-sm text-base-content/70 md:w-44">
              {entry.term}
            </dt>
            <dd>
              <.lead>{entry.detail}</.lead>
            </dd>
          </div>
        </dl>
      </.page_section>

      <.page_section ruled>
        <.section_heading>Start with the research</.section_heading>
        <.lead>
          What we measure, how we test, and everything a run records before it is published.
        </.lead>
        <div>
          <.button variant="primary" navigate={~p"/research"}>Read the research</.button>
        </div>
      </.page_section>
    </Layouts.app>
    """
  end
end

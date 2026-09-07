defmodule BenchappWeb.ResearchLive do
  @moduledoc """
  What JobyCorp publishes and how it tests: the measures a run takes,
  the method that produces a result, and the record every result is
  published as.
  """

  use BenchappWeb, :live_view

  @measures [
    %{measure: "ttft", unit: "ms", meaning: "how soon the answer starts"},
    %{measure: "throughput", unit: "tokens/s", meaning: "how fast the answer continues"},
    %{measure: "prompt", unit: "tokens", meaning: "the load each run carries"},
    %{measure: "run time", unit: "s", meaning: "the whole run, end to end"}
  ]

  @record_fields [
    %{field: "model", unit: "identifier"},
    %{field: "hardware", unit: "name"},
    %{field: "prompt", unit: "tokens"},
    %{field: "ttft", unit: "ms"},
    %{field: "throughput", unit: "tokens/s"},
    %{field: "run time", unit: "s"}
  ]

  @steps [
    "A local model is run on our own hardware. Nothing leaves the machines.",
    "The run works through its prompts, and the instruments record each measure.",
    "The measures go into a run record, together with the model, the hardware, and the method.",
    "The record is published in full, so any number can be traced back to the run that produced it."
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Research",
       measures: @measures,
       record_fields: @record_fields,
       steps: @steps
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="research">
      <.page_section narrow>
        <h1 class="text-4xl font-semibold leading-[1.05] tracking-[-0.03em] md:text-6xl">
          What we measure, and how
        </h1>
        <.lead>
          Every benchmark on this site was run on JobyCorp's own hardware, against a method we
          document in full. This page is that method.
        </.lead>
      </.page_section>

      <.page_section ruled>
        <.section_heading head="benchmarks">What a run measures</.section_heading>
        <.lead>
          A run records how a model behaves, not how it describes itself. Each measure is taken
          the same way every time, so a number from one run can be compared with the next.
        </.lead>
        <div class="max-w-2xl overflow-x-auto">
          <.table
            id="measures"
            rows={@measures}
            zebra={false}
            size="sm"
            class="[&_thead_th]:bg-base-200 [&_th]:border-b [&_th]:border-base-300 [&_th]:font-mono [&_thead_th:nth-child(2)]:text-right [&_tbody_tr]:border-b [&_tbody_tr]:border-base-300"
          >
            <:col :let={m} label="measure">
              <span class="font-mono">{m.measure}</span>
            </:col>
            <:col :let={m} label="unit">
              <span class="block text-right font-mono text-base-content/70">{m.unit}</span>
            </:col>
            <:col :let={m} label="what it tells you">
              {m.meaning}
            </:col>
          </.table>
        </div>
      </.page_section>

      <.page_section ruled>
        <.section_heading head="method">How a result is produced</.section_heading>
        <ol class="max-w-prose space-y-5">
          <li :for={{step, index} <- Enum.with_index(@steps, 1)} class="flex gap-4">
            <span class="flex-none pt-0.5 font-mono text-sm text-base-content/70">{index}</span>
            <.lead>{step}</.lead>
          </li>
        </ol>
      </.page_section>

      <.page_section ruled>
        <.section_heading head="record">What a record carries</.section_heading>
        <.lead>
          Every published result is a record like this one — the fields it carries, and the unit
          each quantity is reported in.
        </.lead>
        <.record_card
          fields={@record_fields}
          caption="Field names and units — the shape of every result we publish."
          class="w-full max-w-md"
        />
      </.page_section>

      <.page_section narrow>
        <.section_heading>Why it is published in full</.section_heading>
        <.lead>
          A benchmark is only useful if it can be checked. The method and the hardware sit next to
          every number we publish, so a reader can see exactly where it came from.
        </.lead>
        <div>
          <.button variant="primary" navigate={~p"/about"}>Why we share the work</.button>
        </div>
      </.page_section>
    </Layouts.app>
    """
  end
end

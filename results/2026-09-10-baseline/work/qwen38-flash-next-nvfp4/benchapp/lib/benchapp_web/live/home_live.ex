defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The JobyCorp landing page: what we do, what we measure, how a run is
  done, and where to read it.
  """

  use BenchappWeb, :live_view

  import BenchappWeb.CompositeComponents

  @record_fields [
    %{field: "model", unit: "id"},
    %{field: "quantization", unit: "preset"},
    %{field: "prompt tokens", unit: "count"},
    %{field: "generated tokens", unit: "count"},
    %{field: "ttft", unit: "ms"},
    %{field: "throughput", unit: "tok/s"},
    %{field: "hardware", unit: "device"},
    %{field: "seed", unit: "int"}
  ]

  @measures [
    %{field: "ttft", unit: "ms", note: "Time to the first token, cold."},
    %{field: "decode", unit: "tok/s", note: "Tokens generated per second once decoding starts."},
    %{
      field: "prompt",
      unit: "tok/s",
      note: "Tokens read per second while the prompt is processed."
    },
    %{field: "peak", unit: "MiB", note: "Resident memory held by the running model."}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "JobyCorp",
       record_fields: @record_fields,
       measures: @measures
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <.page_body>
        <section class="grid items-start gap-12 py-16 md:py-24 lg:grid-cols-2">
          <div class="space-y-6">
            <h1 class="text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-7xl">
              Local models, measured on local hardware.
            </h1>
            <.lede>
              JobyCorp runs language models on machines we own, measures what they do, and
              publishes every result in full — fields, units, and method included.
            </.lede>
            <.button navigate={~p"/research"} variant="primary" class="rounded-field">
              Read the research
            </.button>
          </div>
          <div class="lg:pt-2">
            <.record_card
              title="run record"
              fields={@record_fields}
              caption="What every published run carries."
            />
          </div>
        </section>

        <.section head="measure" title="What we measure">
          <:lead>
            Four quantities, measured the same way on every run so results compare across models
            and machines. The table names each field and the unit it is reported in.
          </:lead>
          <.figure_table>
            <.table id="measures" rows={@measures} zebra={false}>
              <:col :let={m} label="field">
                <span class="font-mono text-sm">{m.field}</span>
              </:col>
              <:col :let={m} label="unit">
                <span class="font-mono text-sm text-base-content/70">{m.unit}</span>
              </:col>
              <:col :let={m} label="what it captures">
                <.prose_cell>{m.note}</.prose_cell>
              </:col>
            </.table>
          </.figure_table>
        </.section>

        <.section head="hardware" title="Local by construction">
          <:lead>
            Nothing in this pipeline depends on a provider we do not control. The whole run — load,
            generate, record — happens on hardware we own and can describe exactly.
          </:lead>
          <div class="max-w-prose space-y-4">
            <.spec_row label="models">
              Open-weight models that run locally, each pinned to a specific revision.
            </.spec_row>
            <.spec_row label="hardware">
              Our own machines. Every record names the device it ran on.
            </.spec_row>
            <.spec_row label="method">
              One protocol, fixed before the first run: same prompts, same seeds, same metrics.
            </.spec_row>
            <.spec_row label="results">
              Published in full — the raw record, not a summary of it.
            </.spec_row>
          </div>
        </.section>

        <.section title="Read the research">
          <:lead>The method page sets out what we publish and how each run is tested.</:lead>
          <.button navigate={~p"/research"} variant="primary" class="rounded-field">
            Read the research
          </.button>
        </.section>
      </.page_body>
    </Layouts.app>
    """
  end
end

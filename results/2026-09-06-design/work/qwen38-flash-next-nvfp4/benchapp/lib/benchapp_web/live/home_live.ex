defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The JobyCorp landing page: what the company does, what a run measures,
  what it runs on, and where to read it.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @record_fields [
    %{name: "model", unit: "identifier"},
    %{name: "quantisation", unit: "format"},
    %{name: "context length", unit: "tokens"},
    %{name: "prompt tokens", unit: "count"},
    %{name: "ttft", unit: "ms"},
    %{name: "generation", unit: "tokens/s"},
    %{name: "peak memory", unit: "GiB"},
    %{name: "power at wall", unit: "W"}
  ]

  @measures [
    %{
      quantity: "ttft",
      unit: "ms",
      reading: "Time from prompt to the first token."
    },
    %{
      quantity: "generation",
      unit: "tokens/s",
      reading: "How fast tokens arrive once generation starts."
    },
    %{
      quantity: "prompt processing",
      unit: "tokens/s",
      reading: "How fast the prompt itself is read."
    },
    %{
      quantity: "peak memory",
      unit: "GiB",
      reading: "The high-water mark the run reached on the machine."
    },
    %{
      quantity: "power at wall",
      unit: "W",
      reading: "What the machine draws while the model runs."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Local model benchmarks",
       record_fields: @record_fields,
       measures: @measures
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <CompositeComponents.content_column flow>
        <section class="grid items-start gap-10 lg:grid-cols-[minmax(0,1fr)_25rem] lg:gap-16">
          <div>
            <CompositeComponents.section_head level="h1" size="hero">
              We run local language models on our own hardware and publish every
              measurement.
            </CompositeComponents.section_head>
            <p class="mt-6 max-w-prose text-base leading-relaxed text-base-content/70 md:text-lg">
              JobyCorp is a local AI research company. We analyse and benchmark language
              models that run on machines we own, and we publish the work in full — every
              field, every unit, and the method behind them.
            </p>
            <div class="mt-8">
              <.button variant="primary" navigate={~p"/research"}>
                Read the research
              </.button>
            </div>
          </div>

          <CompositeComponents.record_card
            id="hero-record"
            label="run record"
            fields={@record_fields}
            caption="What a JobyCorp record carries. Fields and units; values come from the run."
          />
        </section>

        <section class="space-y-8">
          <CompositeComponents.section_head
            running_head="measures"
            lead="Six quantities come off every run. Each is read on the machine the model is running on, at the time it is running."
          >
            What a run measures
          </CompositeComponents.section_head>

          <CompositeComponents.data_table id="measures" rows={@measures}>
            <:col :let={m} kind="id" label="quantity">{m.quantity}</:col>
            <:col :let={m} kind="unit" label="unit">{m.unit}</:col>
            <:col :let={m} label="how to read it">{m.reading}</:col>
          </CompositeComponents.data_table>
        </section>

        <section class="space-y-8">
          <CompositeComponents.section_head
            running_head="hardware"
            lead="Nothing in a JobyCorp result is outsourced. The models, the machines, and the measurements all belong to the same room."
          >
            Local models, local hardware
          </CompositeComponents.section_head>

          <CompositeComponents.spec_sheet>
            <:row label="models">
              Run from local disk, on a runtime we control and record.
            </:row>
            <:row label="hardware">
              Machines JobyCorp owns and operates. Every figure is taken on them, not
              reported to us.
            </:row>
            <:row label="method">
              The setup a run used — runtime, version, settings — is written down before
              the run starts.
            </:row>
            <:row label="results">
              Published in full: every field with its unit, the method beside it, free to
              read.
            </:row>
          </CompositeComponents.spec_sheet>
        </section>

        <CompositeComponents.closing_call
          lead="A result you cannot inspect is a claim. Ours arrive with the record, the units, and the method that produced them."
          href={~p"/research"}
          label="How JobyCorp tests, and what it publishes"
        >
          Read the research
        </CompositeComponents.closing_call>
      </CompositeComponents.content_column>
    </Layouts.app>
    """
  end
end

defmodule BenchappWeb.ResearchLive do
  @moduledoc """
  What JobyCorp publishes and how it tests: the shape of a run, from the
  setup that is pinned down to the record that goes out.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @record_fields [
    %{name: "run id", unit: "identifier"},
    %{name: "model", unit: "identifier"},
    %{name: "quantisation", unit: "format"},
    %{name: "context length", unit: "tokens"},
    %{name: "prompt set", unit: "identifier"},
    %{name: "repeats", unit: "count"},
    %{name: "ttft", unit: "ms"},
    %{name: "generation", unit: "tokens/s"},
    %{name: "prompt processing", unit: "tokens/s"},
    %{name: "peak memory", unit: "GiB"},
    %{name: "power at wall", unit: "W"}
  ]

  @method [
    %{
      step: "Pin the setup",
      detail:
        "Machine, runtime, runtime version, context length, and settings are fixed and written down before anything runs."
    },
    %{
      step: "Load the model",
      detail:
        "Weights come off local disk in the quantisation being tested. The model and its format are fields on the record."
    },
    %{
      step: "Repeat the run",
      detail:
        "The same prompt set is run more than once on the same machine, so a single pass is never the result."
    },
    %{
      step: "Read the machine",
      detail:
        "Timing, token rates, memory, and power are taken while the model is running, from the machine it is running on."
    },
    %{
      step: "Publish the record",
      detail:
        "Fields, units, and method go out together, with the limits of the run named alongside them."
    }
  ]

  @publications [
    %{
      name: "run record",
      carries: "Every measured quantity with the unit it is reported in."
    },
    %{
      name: "method",
      carries: "Setup, runtime and version, prompt set, and how many repeats."
    },
    %{
      name: "hardware",
      carries: "The machine the run happened on, its memory, and its draw at the wall."
    },
    %{
      name: "limits",
      carries: "What the run does not cover, and where it should not be trusted."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Research",
       record_fields: @record_fields,
       method: @method,
       publications: @publications
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="research">
      <CompositeComponents.content_column flow>
        <CompositeComponents.section_head
          level="h1"
          lead="A JobyCorp result is a record before it is a sentence. This is the shape it takes and the order it is made in."
        >
          How we test, and what we publish
        </CompositeComponents.section_head>

        <section class="grid items-start gap-10 lg:grid-cols-[minmax(0,1fr)_25rem] lg:gap-16">
          <div>
            <CompositeComponents.section_head running_head="record">
              What a record carries
            </CompositeComponents.section_head>
            <p class="mt-6 max-w-prose text-base leading-relaxed text-base-content/70">
              A record is a fixed set of fields, each with the unit it is reported in. The
              identifiers say which model, which format, and which machine; the quantities
              say what the run did. A value appears only once a run has happened.
            </p>
          </div>
          <CompositeComponents.record_card
            id="research-record"
            label="run record"
            fields={@record_fields}
            caption="A sibling of the card on the landing page — the fields a published run carries."
          />
        </section>

        <section class="space-y-8">
          <CompositeComponents.section_head
            running_head="method"
            lead="Every run follows the same five steps, in this order."
          >
            How a run is made
          </CompositeComponents.section_head>

          <.list title_class="text-base font-semibold">
            <:item
              :for={{step, index} <- Enum.with_index(@method, 1)}
              title={"#{index}. #{step.step}"}
            >
              <span class="block max-w-prose text-base-content/70">{step.detail}</span>
            </:item>
          </.list>
        </section>

        <section class="space-y-8">
          <CompositeComponents.section_head
            running_head="publication"
            lead="A publication is more than the numbers. These four parts travel together."
          >
            What goes out
          </CompositeComponents.section_head>

          <CompositeComponents.data_table id="publications" rows={@publications}>
            <:col :let={p} kind="id" label="part">{p.name}</:col>
            <:col :let={p} label="what it holds">{p.carries}</:col>
          </CompositeComponents.data_table>
        </section>

        <CompositeComponents.closing_call
          lead="The method is what lets a record be read at all. Who stands behind it is on the next page."
          href={~p"/about"}
          label="About JobyCorp"
        >
          Who publishes it
        </CompositeComponents.closing_call>
      </CompositeComponents.content_column>
    </Layouts.app>
    """
  end
end

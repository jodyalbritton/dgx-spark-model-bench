defmodule BenchappWeb.ResearchLive do
  @moduledoc """
  What JobyCorp publishes and how it tests.

  It shows what is measured, the method as a numbered sequence, and what a
  single record carries.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @quantities [
    %{quantity: "model", unit: "identifier"},
    %{quantity: "weights", unit: "bits"},
    %{quantity: "context", unit: "tokens"},
    %{quantity: "throughput", unit: "tok/s"},
    %{quantity: "latency", unit: "ms"},
    %{quantity: "memory", unit: "GB"}
  ]

  @method [
    %{
      number: "01",
      label: "fix the conditions",
      detail: "Choose a model, a machine, and a record of every setting before anything runs."
    },
    %{
      number: "02",
      label: "run the workload",
      detail:
        "The same set of prompts and tasks against each model, so runs differ only in the model."
    },
    %{
      number: "03",
      label: "measure the run",
      detail:
        "Throughput, latency, memory, and tokens, taken under the same conditions and in the same units."
    },
    %{
      number: "04",
      label: "publish the record",
      detail: "The method, the hardware, the data, and the numbers — in full."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Research",
       quantities: @quantities,
       method: @method
     )}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="research">
      <div class="mx-auto w-full max-w-6xl px-6 py-16 md:px-8 md:py-24">
        <header class="max-w-prose">
          <h1 class="hero-title">What we publish and how we test</h1>
          <p class="copy mt-6">
            JobyCorp benchmarks local language models on its own hardware. Every result is
            published with the conditions it was measured under, so it can be read, checked,
            and repeated.
          </p>
        </header>

        <%!-- What is measured. --%>
        <section class="section">
          <div class="space-y-8">
            <p class="mono-muted">research</p>
            <div class="two-col">
              <div class="max-w-prose space-y-5">
                <h2 class="section-title">What a run measures</h2>
                <p class="copy">
                  A small, fixed set of quantities. The same fields, the same units, on every
                  run — so a result is a number you can compare, not a paragraph.
                </p>
                <p class="copy">
                  Measured on the hardware that ran the model, never carried over from a
                  vendor's spec sheet.
                </p>
              </div>

              <div class="overflow-x-auto">
                <.table
                  id="research-measured"
                  table_id="research-measured-table"
                  rows={@quantities}
                  zebra={false}
                  class="figure-table"
                >
                  <:col :let={q} label="quantity">
                    <span class="font-mono">{q.quantity}</span>
                  </:col>
                  <:col :let={q} label="unit">
                    <span class="font-mono">{q.unit}</span>
                  </:col>
                </.table>
              </div>
            </div>
          </div>
        </section>

        <%!-- The method, as a sequence. --%>
        <section class="section">
          <div class="space-y-8">
            <p class="mono-muted">method</p>
            <h2 class="section-title max-w-prose">How a run is tested</h2>
            <ol class="max-w-3xl">
              <li
                :for={step <- @method}
                class="grid gap-2 border-t border-base-300 py-6 first:border-t-0 first:pt-0 sm:grid-cols-[3rem_11rem_1fr] sm:gap-x-8"
              >
                <span class="font-mono text-sm">{step.number}</span>
                <span class="mono-muted">{step.label}</span>
                <span class="copy-strong">{step.detail}</span>
              </li>
            </ol>
          </div>
        </section>

        <%!-- What a record carries. --%>
        <section class="section">
          <div class="space-y-8">
            <p class="mono-muted">record</p>
            <div class="grid gap-10 lg:grid-cols-[minmax(0,1fr)_minmax(0,20rem)] lg:items-start lg:gap-16">
              <div class="max-w-prose space-y-5">
                <h2 class="section-title">What a record carries</h2>
                <p class="copy">
                  Each run leaves a record with the fields it was measured against. Publishing
                  means publishing that record — the model, the hardware, the settings, and
                  the data — not just the headline number.
                </p>
                <p class="copy">
                  A record is the unit of work. Where a section asks for a result, the
                  record tells you how it was got.
                </p>
              </div>

              <div class="lg:pt-2">
                <CompositeComponents.record_card caption="Enough to repeat the run, not just admire it.">
                  <:row field="model" unit="identifier" />
                  <:row field="weights" unit="bits" />
                  <:row field="context" unit="tokens" />
                  <:row field="throughput" unit="tok/s" />
                  <:row field="latency" unit="ms" />
                  <:row field="memory" unit="GB" />
                </CompositeComponents.record_card>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

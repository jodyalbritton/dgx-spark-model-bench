defmodule BenchappWeb.HomeLive do
  @moduledoc """
  JobyCorp's landing page.

  It says what JobyCorp does in one sentence, then shows the research
  (what is measured and how), the hardware and method (local models,
  local hardware, results published in full), and closes on a call to
  read the research.
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

  @spec_sheet [
    %{
      label: "models",
      body: "Open-weights models only — the ones we can run and inspect ourselves."
    },
    %{
      label: "hardware",
      body: "Local machines we own, dedicated to benchmarking and described with every run."
    },
    %{
      label: "publication",
      body:
        "No abstract hiding the middle. Each run ships its method, its hardware, and its numbers."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, page_title: "JobyCorp", quantities: @quantities, spec_sheet: @spec_sheet)}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto w-full max-w-6xl px-6 md:px-8">
        <%!-- Hero: one sentence, one action, the run record beside it. --%>
        <section class="grid gap-10 py-16 md:py-24 lg:grid-cols-[minmax(0,1fr)_minmax(0,20rem)] lg:items-start lg:gap-16">
          <div>
            <h1 class="hero-title max-w-2xl">
              JobyCorp measures local language models on its own hardware and publishes every result in full.
            </h1>
            <p class="copy mt-6 max-w-prose">
              We run open models on the machines we own, hold the conditions steady, and share
              every run — the settings, the data, and the numbers — so anyone can repeat it.
            </p>
            <div class="mt-9">
              <.button navigate={~p"/research"} variant="primary" size="lg">
                Read the research
              </.button>
            </div>
          </div>

          <div class="lg:pt-2">
            <CompositeComponents.record_card caption="The same fields on every run, so runs compare.">
              <:row field="model" unit="identifier" />
              <:row field="weights" unit="bits" />
              <:row field="context" unit="tokens" />
              <:row field="throughput" unit="tok/s" />
              <:row field="latency" unit="ms" />
              <:row field="memory" unit="GB" />
            </CompositeComponents.record_card>
          </div>
        </section>

        <%!-- Research: what is measured, and how. --%>
        <section class="section">
          <div class="space-y-8">
            <p class="mono-muted">research</p>
            <div class="two-col">
              <div class="max-w-prose space-y-5">
                <h2 class="section-title">What a run measures</h2>
                <p class="copy">
                  Every run is measured against the same fixed set of quantities, on the same
                  hardware, with the settings recorded before anything starts. A number from
                  one model reads against a number from the next.
                </p>
                <p class="copy">
                  The fields are few and fixed. Each result reports them with their units —
                  and nothing else.
                </p>
              </div>

              <div class="overflow-x-auto">
                <.table
                  id="home-measured"
                  table_id="home-measured-table"
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

        <%!-- Hardware and method: local models, local hardware, full publication. --%>
        <section class="section">
          <div class="space-y-8">
            <p class="mono-muted">hardware</p>
            <h2 class="section-title">Local models, local hardware</h2>
            <dl class="max-w-3xl">
              <div
                :for={row <- @spec_sheet}
                class="grid gap-2 border-t border-base-300 py-5 sm:grid-cols-[11rem_1fr] sm:gap-8 first:border-t-0 first:pt-0"
              >
                <dt class="mono-muted">{row.label}</dt>
                <dd class="copy-strong max-w-prose">{row.body}</dd>
              </div>
            </dl>
          </div>
        </section>

        <%!-- Closing call to action. --%>
        <section class="section">
          <div class="max-w-prose">
            <h2 class="section-title">Read the research</h2>
            <p class="copy mt-5">
              The records are published with the work behind them. See what JobyCorp
              measures, how each run is tested, and what a result leaves behind.
            </p>
            <p class="mt-6">
              <.link
                navigate={~p"/research"}
                class="text-base font-medium text-primary underline decoration-1 underline-offset-4 transition-colors duration-150 hover:text-primary/80"
              >
                Read the research
              </.link>
            </p>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

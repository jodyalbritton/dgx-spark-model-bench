defmodule BenchappWeb.AboutLive do
  @moduledoc """
  Who JobyCorp is and why the work is shared.
  """

  use BenchappWeb, :live_view

  @published [
    %{part: "model", note: "which weights were measured"},
    %{part: "hardware", note: "the machine that ran it"},
    %{part: "settings", note: "how each run was configured"},
    %{part: "data", note: "what the model was measured on"},
    %{part: "results", note: "every number, with its unit"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About", published: @published)}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto w-full max-w-6xl px-6 py-16 md:px-8 md:py-24">
        <header class="max-w-prose">
          <h1 class="hero-title">Local models, measured and shared</h1>
          <p class="copy mt-6">
            JobyCorp is a local AI research company. It runs analysis and benchmarks of local
            language models on its own hardware, and shares the research openly with the
            community.
          </p>
        </header>

        <%!-- Who we are, and why the work is shared. --%>
        <section class="section">
          <div class="max-w-prose space-y-8">
            <h2 class="section-title">Why the work is shared</h2>
            <div class="space-y-5">
              <p class="copy">
                A benchmark only means something if it can be checked. JobyCorp runs the
                models on machines it owns, under conditions it records, and publishes the
                results in full — so anyone can see what was measured and repeat it.
              </p>
              <p class="copy">
                Open research is the point of the work. Numbers that sit behind a headline
                are not the work; the record behind them is.
              </p>
            </div>
          </div>
        </section>

        <%!-- What a published result includes. --%>
        <section class="section">
          <div class="space-y-8">
            <p class="mono-muted">publish</p>
            <div class="two-col">
              <div class="max-w-prose space-y-5">
                <h2 class="section-title">What a published result includes</h2>
                <p class="copy">
                  Publishing a result means publishing the record: the model, the hardware,
                  the settings, the data, and the numbers that came out of it.
                </p>
                <p class="copy">
                  Nothing about how it was got stays private.
                </p>
              </div>

              <div class="overflow-x-auto">
                <.table
                  id="published"
                  table_id="published-table"
                  rows={@published}
                  zebra={false}
                  class="figure-table"
                >
                  <:col :let={row} label="part">
                    <span class="font-mono">{row.part}</span>
                  </:col>
                  <:col :let={row} label="what it records">{row.note}</:col>
                </.table>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

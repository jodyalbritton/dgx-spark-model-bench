defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The JobyCorp about page.

  Who JobyCorp is and why the work is shared openly.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @specimen [
    %{label: "focus", value: "analysis and benchmarks of local LLMs"},
    %{label: "hardware", value: "owned and operated, at the job"},
    %{label: "method", value: "one sequence, recorded every run"},
    %{label: "publication", value: "full results, shared with the community"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About", specimen: @specimen)}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <CompositeComponents.container>
        <div class="space-y-8">
          <h1 class="max-w-3xl text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-6xl">
            Why the work is shared
          </h1>
          <CompositeComponents.prose>
            JobyCorp is a small AI research company. It runs analysis and benchmarks of
            local language models on its own hardware, and shares the research openly
            with the community that builds and runs them.
          </CompositeComponents.prose>
        </div>
      </CompositeComponents.container>

      <CompositeComponents.section running_head="who we are" heading="Open, because it can be checked">
        <CompositeComponents.two_column>
          <:content>
            <CompositeComponents.prose>
              Benchmarks matter only if they can be re-run. That is why we publish the
              whole record — the hardware, the configuration, the method — and why the
              tooling and results are shared with the community rather than kept
              behind a sign-up.
            </CompositeComponents.prose>
          </:content>
          <:figure>
            <div class="rounded-box border border-base-300 bg-base-200 p-6 md:w-96">
              <CompositeComponents.mono_label>premise</CompositeComponents.mono_label>
              <dl class="mt-5 space-y-4 font-mono text-sm">
                <div :for={item <- @specimen}>
                  <dt class="text-base-content/70">{item.label}</dt>
                  <dd class="mt-1">{item.value}</dd>
                </div>
              </dl>
            </div>
          </:figure>
        </CompositeComponents.two_column>
      </CompositeComponents.section>
    </Layouts.app>
    """
  end
end

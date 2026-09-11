defmodule BenchappWeb.ResearchLive do
  @moduledoc """
  What JobyCorp publishes and how each run is tested.
  """

  use BenchappWeb, :live_view

  import BenchappWeb.CompositeComponents

  @release_fields [
    %{field: "model", unit: "id"},
    %{field: "prompts", unit: "set id"},
    %{field: "seeds", unit: "count"},
    %{field: "ttft", unit: "ms"},
    %{field: "decode", unit: "tok/s"},
    %{field: "peak", unit: "MiB"},
    %{field: "method", unit: "version"}
  ]

  @method [
    "Pin the model to a fixed revision and the runtime to a fixed build.",
    "Fix the prompts, seeds, and metrics before the first run — never chosen after.",
    "Load and run locally, on hardware named in the record.",
    "Record every field from the run itself; nothing is filled in later.",
    "Publish the full record, so the result can be checked or reproduced."
  ]

  @fixed [
    %{field: "prompts", fixed_by: "a named set, shared with the results"},
    %{field: "seeds", fixed_by: "chosen before the run and listed per result"},
    %{field: "revision", fixed_by: "a pinned model and runtime build"},
    %{field: "device", fixed_by: "named in every record"},
    %{field: "metrics", fixed_by: "the same four, measured the same way"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Research",
       release_fields: @release_fields,
       method: @method,
       fixed: @fixed
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="research">
      <.page_body>
        <section class="grid items-start gap-12 py-16 md:py-24 lg:grid-cols-2">
          <div class="space-y-5">
            <h1 class="text-4xl font-semibold leading-[1.05] tracking-[-0.03em] md:text-6xl">
              How a run is published
            </h1>
            <.lede>
              We publish the record, not a summary of it. Each release bundles the fields a run was
              measured on, so a reader can check the method or run it again themselves.
            </.lede>
          </div>
          <div class="lg:pt-2">
            <.record_card
              title="release record"
              fields={@release_fields}
              caption="What a published release bundles."
            />
          </div>
        </section>

        <.section head="method" title="How a run is tested">
          <:lead>
            One protocol, applied the same way every time. The steps run in order; each one is fixed
            before the next begins.
          </:lead>
          <ol class="max-w-prose divide-y divide-base-300">
            <li :for={{step, index} <- Enum.with_index(@method, 1)} class="flex gap-4 py-4">
              <span class="w-6 shrink-0 font-mono text-sm text-primary">
                {String.pad_leading(Integer.to_string(index), 2, "0")}
              </span>
              <span class="text-base leading-relaxed md:text-lg">{step}</span>
            </li>
          </ol>
        </.section>

        <.section head="held fixed" title="What stays the same">
          <:lead>
            Comparisons only mean something when everything except the model is held fixed. Each
            input is named and shared alongside the results.
          </:lead>
          <.figure_table>
            <.table id="fixed" rows={@fixed} zebra={false}>
              <:col :let={r} label="input">
                <span class="font-mono text-sm">{r.field}</span>
              </:col>
              <:col :let={r} label="fixed by">
                <.prose_cell>{r.fixed_by}</.prose_cell>
              </:col>
            </.table>
          </.figure_table>
        </.section>
      </.page_body>
    </Layouts.app>
    """
  end
end

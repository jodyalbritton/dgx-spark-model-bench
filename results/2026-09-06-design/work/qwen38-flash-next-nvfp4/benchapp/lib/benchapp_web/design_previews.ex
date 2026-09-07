defmodule BenchappWeb.DesignPreviews do
  @moduledoc """
  Preview functions for **this app's** components, referenced by
  `BenchappWeb.DesignManifest`.

  The kit's own components are previewed by `JobyKit.Previews`, so
  `/design` shows the same examples in every JobyKit app. You only write
  previews for what you add.

  Each public function takes `assigns` (typically `%{}`) and returns a
  small HEEx rendering the component with sensible defaults. The
  manifest registers these via `preview: &BenchappWeb.DesignPreviews.X_preview/1`,
  and `JobyKit.SignatureComponent` invokes them inside the per-component
  card's collapsible Preview section.

  Naming convention: every preview function ends in `_preview` so they
  don't collide with the imported component functions of the same name
  (e.g. `button` vs `button_preview`).

  Previews are rendered inline on the catalogue page, so they read no
  assigns of their own — anything they show is written out in the
  template.
  """

  use BenchappWeb, :html

  alias BenchappWeb.CompositeComponents

  def record_card_preview(assigns) do
    ~H"""
    <div class="grid gap-6 sm:grid-cols-2">
      <CompositeComponents.record_card
        label="run record"
        fields={[
          %{name: "model", unit: "identifier"},
          %{name: "quantisation", unit: "format"},
          %{name: "prompt tokens", unit: "count"},
          %{name: "ttft", unit: "ms"},
          %{name: "generation", unit: "tokens/s"},
          %{name: "peak memory", unit: "GiB"},
          %{name: "power at wall", unit: "W"}
        ]}
        caption="Field names and units only — a record never carries an invented value."
      />
      <CompositeComponents.record_card
        label="hardware record"
        fields={[
          %{name: "accelerator", unit: "model"},
          %{name: "memory", unit: "GiB"},
          %{name: "runtime", unit: "version"},
          %{name: "driver", unit: "version"}
        ]}
        caption="The same card, filled with the fields of a machine record."
      />
    </div>
    """
  end

  def spec_sheet_preview(assigns) do
    ~H"""
    <div class="max-w-2xl">
      <CompositeComponents.spec_sheet>
        <:row label="models">Local weights, run from disk.</:row>
        <:row label="hardware">Machines JobyCorp owns and operates.</:row>
        <:row label="results">Published in full: fields, units, and method.</:row>
      </CompositeComponents.spec_sheet>
    </div>
    """
  end

  def running_head_preview(assigns) do
    ~H"""
    <div class="max-w-2xl">
      <CompositeComponents.running_head>ttft</CompositeComponents.running_head>
    </div>
    """
  end

  def section_head_preview(assigns) do
    ~H"""
    <div class="max-w-2xl">
      <CompositeComponents.section_head
        running_head="measures"
        lead="Six quantities come off every run."
      >
        What a run measures
      </CompositeComponents.section_head>
    </div>
    """
  end

  def content_column_preview(assigns) do
    ~H"""
    <CompositeComponents.content_column class="rounded-box bg-base-200 py-6">
      <p class="text-sm text-base-content/70">
        The column every page sits in: centred, <code class="font-mono">max-w-6xl</code>,
        with a wider gutter from the middle breakpoint up.
      </p>
    </CompositeComponents.content_column>
    """
  end

  def data_table_preview(assigns) do
    ~H"""
    <CompositeComponents.data_table
      id="preview-measures"
      rows={[
        %{quantity: "ttft", unit: "ms", reading: "Time from prompt to the first token."},
        %{quantity: "generation", unit: "tokens/s", reading: "Tokens per second once it starts."}
      ]}
    >
      <:col :let={m} kind="id" label="quantity">{m.quantity}</:col>
      <:col :let={m} kind="unit" label="unit">{m.unit}</:col>
      <:col :let={m} label="how to read it">{m.reading}</:col>
    </CompositeComponents.data_table>
    """
  end

  def closing_call_preview(assigns) do
    ~H"""
    <div class="max-w-2xl">
      <CompositeComponents.closing_call
        lead="A result you cannot inspect is a claim."
        href="#"
        label="How JobyCorp tests, and what it publishes"
      >
        Read the research
      </CompositeComponents.closing_call>
    </div>
    """
  end
end

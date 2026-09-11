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

  The previews call `JobyKit.CoreComponents` directly via the
  `CoreComponents` alias so the rendered HTML matches what the manifest
  declares — no dependency on the host's `<App>Web.CoreComponents`
  resolution.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents
  alias BenchappWeb.CompositeComponents

  def record_card_preview(assigns) do
    ~H"""
    <div class="max-w-sm">
      <CompositeComponents.record_card
        title="run record"
        fields={[
          %{field: "model", unit: "id"},
          %{field: "ttft", unit: "ms"},
          %{field: "throughput", unit: "tok/s"}
        ]}
        caption="What every published run carries."
      />
    </div>
    """
  end

  def spec_row_preview(assigns) do
    ~H"""
    <div class="space-y-4">
      <CompositeComponents.spec_row label="method">
        Each model is loaded and run locally, on hardware we own.
      </CompositeComponents.spec_row>
      <CompositeComponents.spec_row label="results">
        Published in full, fields and all.
      </CompositeComponents.spec_row>
    </div>
    """
  end

  def page_body_preview(assigns) do
    ~H"""
    <CompositeComponents.page_body>
      <CompositeComponents.lede>The page column every section sits inside.</CompositeComponents.lede>
    </CompositeComponents.page_body>
    """
  end

  def lede_preview(assigns) do
    ~H"""
    <CompositeComponents.lede>
      A lead paragraph, set at the reading measure in the secondary ink.
    </CompositeComponents.lede>
    """
  end

  def section_preview(assigns) do
    ~H"""
    <CompositeComponents.section head="method" title="How a run is tested">
      <:lead>One protocol, applied the same way every time.</:lead>
      The section body — a figure, table, or list.
    </CompositeComponents.section>
    """
  end

  def figure_table_preview(assigns) do
    rows = [
      %{field: "ttft", note: "Time to the first token, cold."},
      %{field: "decode", note: "Tokens generated per second."}
    ]

    assigns = assign(assigns, :rows, rows)

    ~H"""
    <CompositeComponents.figure_table>
      <CoreComponents.table id="preview-rows" rows={@rows} zebra={false}>
        <:col :let={r} label="field">
          <span class="font-mono text-sm">{r.field}</span>
        </:col>
        <:col :let={r} label="note">
          <CompositeComponents.prose_cell>{r.note}</CompositeComponents.prose_cell>
        </:col>
      </CoreComponents.table>
    </CompositeComponents.figure_table>
    """
  end

  def prose_cell_preview(assigns) do
    ~H"""
    <CompositeComponents.prose_cell>
      Reading-column text in secondary ink.
    </CompositeComponents.prose_cell>
    """
  end
end

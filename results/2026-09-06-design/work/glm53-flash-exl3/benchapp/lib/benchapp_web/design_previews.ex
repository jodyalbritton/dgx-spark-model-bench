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

  def empty_state_preview(assigns) do
    ~H"""
    <div class="grid gap-4 sm:grid-cols-2">
      <CompositeComponents.empty_state icon="hero-inbox" title="No messages yet">
        Start a conversation with a teammate to see it here.
        <:action>
          <CoreComponents.button variant="primary">New message</CoreComponents.button>
        </:action>
      </CompositeComponents.empty_state>
      <CompositeComponents.empty_state
        icon="hero-sparkles"
        title="Set up your workspace"
        tone="primary"
      >
        Connect your first integration to populate this dashboard.
      </CompositeComponents.empty_state>
    </div>
    """
  end

  def record_card_preview(assigns) do
    ~H"""
    <div class="grid gap-4 md:grid-cols-2">
      <CompositeComponents.record_card fields={[
        %{field: "model", unit: "identifier"},
        %{field: "hardware", unit: "name"},
        %{field: "ttft", unit: "ms"},
        %{field: "throughput", unit: "tokens/s"}
      ]} />
      <CompositeComponents.record_card
        fields={[
          %{field: "model", unit: "identifier"},
          %{field: "prompt", unit: "tokens"},
          %{field: "ttft", unit: "ms"}
        ]}
        caption="The fields a JobyCorp run record carries."
      />
    </div>
    """
  end

  def lead_preview(assigns) do
    ~H"""
    <div class="space-y-4">
      <CompositeComponents.lead>
        A run records how a model behaves, not how it describes itself.
      </CompositeComponents.lead>
      <CompositeComponents.lead class="max-w-none">
        The same measures, taken the same way on the same machines.
      </CompositeComponents.lead>
    </div>
    """
  end

  def section_heading_preview(assigns) do
    ~H"""
    <div class="space-y-8">
      <CompositeComponents.section_heading head="method">
        How a result is produced
      </CompositeComponents.section_heading>
      <CompositeComponents.section_heading>
        Why the work is shared
      </CompositeComponents.section_heading>
    </div>
    """
  end

  def page_section_preview(assigns) do
    ~H"""
    <div class="space-y-8">
      <CompositeComponents.page_section ruled>
        <CompositeComponents.section_heading head="record">
          What a record carries
        </CompositeComponents.section_heading>
      </CompositeComponents.page_section>
      <CompositeComponents.page_section narrow>
        <CompositeComponents.section_heading>
          Why the work is shared
        </CompositeComponents.section_heading>
      </CompositeComponents.page_section>
    </div>
    """
  end
end

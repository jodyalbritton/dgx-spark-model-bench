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

  @feature_preview [
    %{
      tag: "Ingest",
      icon: "hero-bolt",
      title: "Sub-millisecond routing",
      body: "Events land on dashboards before the request that produced them finishes."
    },
    %{
      tag: "Resilience",
      icon: "hero-shield-check",
      title: "Backpressure by default",
      body: "Spiky traffic sheds load gracefully instead of dropping data."
    },
    %{
      tag: "Query",
      icon: "hero-magnifying-glass",
      title: "Live SQL over fresh data",
      body: "Standards-compatible queries run against data seconds old, not minutes."
    }
  ]

  def feature_grid_preview(assigns) do
    assigns = assign(assigns, :features, @feature_preview)

    ~H"""
    <CompositeComponents.feature_grid features={@features} />
    """
  end

end

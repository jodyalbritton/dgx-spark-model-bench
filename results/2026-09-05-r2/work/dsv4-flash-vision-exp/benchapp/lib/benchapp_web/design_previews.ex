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

  def feature_card_preview(assigns) do
    ~H"""
    <div class="grid gap-4 sm:grid-cols-3">
      <CompositeComponents.feature_card icon="hero-bolt" title="Instant">
        Ship ideas the moment inspiration strikes.
      </CompositeComponents.feature_card>
      <CompositeComponents.feature_card icon="hero-chart-bar" title="Insightful">
        See what matters at a single glance.
      </CompositeComponents.feature_card>
      <CompositeComponents.feature_card icon="hero-shield-check" title="Secure">
        Your work stays private by default.
      </CompositeComponents.feature_card>
    </div>
    """
  end

  def section_band_preview(assigns) do
    ~H"""
    <CompositeComponents.section_band>
      <div class="px-4 py-6 text-sm text-base-content/70">
        Wrap sections in a band to inherit the shared landing chrome.
      </div>
    </CompositeComponents.section_band>
    """
  end
end

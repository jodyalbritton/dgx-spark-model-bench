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
  alias BenchappWeb.NavComponents

  def feature_grid_preview(assigns) do
    ~H"""
    <div class="space-y-4">
      <CompositeComponents.feature_grid features={[
        %{icon: "hero-map", title: "Offline tiles", text: "Download a region once and it stays put."},
        %{
          icon: "hero-pencil-square",
          title: "Field notes",
          text: "Pin observations to exact coordinates."
        },
        %{
          icon: "hero-battery-50",
          title: "Low draw",
          text: "A week of tracking on a single charge."
        }
      ]} />
      <CompositeComponents.feature_grid
        columns="2"
        features={[
          %{
            icon: "hero-lock-closed",
            title: "Private by default",
            text: "No accounts, no analytics."
          },
          %{
            icon: "hero-users",
            title: "Pack sharing",
            text: "Trade waypoints over radio."
          }
        ]}
      />
    </div>
    """
  end

  def main_nav_preview(assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-100 p-2">
      <NavComponents.main_nav active="home" />
      <p class="px-2 pb-1 pt-2 text-xs text-base-content/60">
        At phone widths the links collapse behind the <code class="font-mono">#nav-toggle</code>
        button.
      </p>
    </div>
    """
  end

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
end

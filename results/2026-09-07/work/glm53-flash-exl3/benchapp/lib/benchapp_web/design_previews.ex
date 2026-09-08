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

  def stat_card_preview(assigns) do
    ~H"""
    <div class="grid gap-4 sm:grid-cols-3">
      <CompositeComponents.stat_card value_id="preview-stat-1" value="42" label="Plants monitored" />
      <CompositeComponents.stat_card
        value_id="preview-stat-2"
        value="128"
        label="Signups"
        tone="secondary"
      />
      <CompositeComponents.stat_card
        value_id="preview-stat-3"
        value="7"
        label="Low-moisture alerts"
        tone="accent"
      />
    </div>
    """
  end

  def section_heading_preview(assigns) do
    ~H"""
    <CompositeComponents.section_heading
      title="Why teams pick it"
      subtitle="Supporting copy sits under the title, opt-in via the subtitle attr."
    />
    """
  end

  def feature_grid_preview(assigns) do
    ~H"""
    <CompositeComponents.feature_grid title="Why teams pick it" subtitle="Three of six sample cards.">
      <:feature icon="hero-bolt" title="Fast setup">
        Pair a sensor puck in under a minute — no account required.
      </:feature>
      <:feature icon="hero-shield-check" title="Private by default">
        Readings stay on the hub, exportable whenever you like.
      </:feature>
      <:feature icon="hero-bell-alert" title="Quiet nudges">
        One notification when a plant actually needs you.
      </:feature>
    </CompositeComponents.feature_grid>
    """
  end
end

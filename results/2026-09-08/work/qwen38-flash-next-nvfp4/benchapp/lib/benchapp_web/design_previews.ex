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
  alias BenchappWeb.{CompositeComponents, LandingComponents}

  @preview_features [
    %{
      icon: "hero-signal",
      eyebrow: "Telemetry",
      title: "Sampling at 1 Hz",
      body: "Turbidity, chlorophyll, and temperature from every moored node.",
      tag: "1 Hz"
    },
    %{
      icon: "hero-shield-check",
      eyebrow: "Integrity",
      title: "Citable calibration",
      body: "Drift correction and service history travel with the series.",
      tag: nil
    },
    %{
      icon: "hero-bell",
      eyebrow: "Alerting",
      title: "Thresholds that page",
      body: "Rolling-window rules escalate to the crew that services the node.",
      tag: "on-call"
    }
  ]

  @preview_activity [
    %{id: "signup-9", kind: :signup, text: "saltwater@harbour.gov joined the pilot list."},
    %{
      id: "tick-8",
      kind: :tick,
      text: "Sync cycle #8 closed — 92 windows until the fleet resyncs."
    },
    %{id: "signup-7", kind: :signup, text: "ada@lab.org joined the pilot list."}
  ]

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

  def feature_grid_preview(assigns) do
    assigns = assign(assigns, :preview_features, @preview_features)

    ~H"""
    <div class="space-y-5">
      <CompositeComponents.feature_grid items={@preview_features} columns="3" />
      <CompositeComponents.feature_grid items={@preview_features} columns="2" />
    </div>
    """
  end

  def stat_readout_preview(assigns) do
    ~H"""
    <div class="grid gap-3 sm:grid-cols-2">
      <CompositeComponents.stat_readout
        icon="hero-envelope"
        label="Pilot signups"
        hint="listed newest first"
        value={12}
        value_id="preview-stat-signups"
      />
      <CompositeComponents.stat_readout
        icon="hero-arrow-path"
        label="Countdown ticks"
        hint="one every five seconds"
        value={7}
        value_id="preview-stat-ticks"
        pulse
      />
    </div>
    """
  end

  def activity_feed_preview(assigns) do
    assigns = assign(assigns, :preview_activity, @preview_activity)

    ~H"""
    <CoreComponents.card variant="elevated" body_class="gap-3">
      <:eyebrow>Fleet log</:eyebrow>
      <:title>Activity</:title>
      <LandingComponents.activity_feed id="preview-activity" entries={@preview_activity} />
    </CoreComponents.card>
    """
  end
end

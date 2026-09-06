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
    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <CompositeComponents.feature_card icon="hero-sparkles" title="Delightful details">
        Micro-interactions, load states, and smooth transitions that make a product feel premium.
      </CompositeComponents.feature_card>
      <CompositeComponents.feature_card icon="hero-users" title="Shared everything" tone="primary">
        One list for every errand, plan, and packing run.
      </CompositeComponents.feature_card>
    </div>
    """
  end

  def section_header_preview(assigns) do
    ~H"""
    <div class="space-y-6">
      <CompositeComponents.section_header
        eyebrow="Why Hearth"
        title="Everything your household needs, nothing it doesn't"
        subtitle="Every feature is built on one idea: your home's shared life should feel calm, not cluttered."
      />
      <CompositeComponents.section_header
        eyebrow="Early access"
        title="Be first through the door"
        subtitle="Join the list and we'll send you an invite the moment it's ready."
        align="center"
      />
    </div>
    """
  end

  def stat_card_preview(assigns) do
    ~H"""
    <div class="grid gap-4 md:grid-cols-2">
      <CompositeComponents.stat_card label="Signups" value="128" value_id="preview-signups" />
      <CompositeComponents.stat_card label="Countdown ticks" value="42" value_id="preview-ticks" />
    </div>
    """
  end
end

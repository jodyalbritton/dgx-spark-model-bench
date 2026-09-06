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
  alias BenchappWeb.ChromeComponents
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
    <div class="grid gap-4 sm:grid-cols-2">
      <CompositeComponents.feature_card
        tag="01"
        icon="hero-clock"
        title="Launch windows, not crontabs"
      >
        Give every pipeline a window with a hard boundary. Late inputs fail the
        go/no-go instead of shipping quietly at 03:14.
      </CompositeComponents.feature_card>

      <CompositeComponents.feature_card
        tag="02"
        icon="hero-shield-check"
        title="Go / no-go by contract"
        tone="primary"
      >
        Freshness, row counts, and schema checks are gates, not dashboards.
        <:action>
          <CoreComponents.button size="sm" variant="ghost">
            Read the gate contract
            <CoreComponents.icon name="hero-arrow-right" class="size-4" />
          </CoreComponents.button>
        </:action>
      </CompositeComponents.feature_card>
    </div>
    """
  end

  def card_grid_preview(assigns) do
    ~H"""
    <CompositeComponents.card_grid id="preview-card-grid">
      <CompositeComponents.feature_card tag="grid" icon="hero-view-columns" title="Three across">
        The gutter and breakpoints live here so every card row in the app folds
        the same way on a phone.
      </CompositeComponents.feature_card>
      <CompositeComponents.feature_card tag="grid" icon="hero-squares-2x2" title="Two on a tablet">
        Same component, no extra classes at the call site.
      </CompositeComponents.feature_card>
      <CompositeComponents.feature_card tag="grid" icon="hero-circle-stack" title="One on a phone">
        Which is why the home feature grid, the about stack, and the crew row
        all use it.
      </CompositeComponents.feature_card>
    </CompositeComponents.card_grid>
    """
  end

  def stat_tile_preview(assigns) do
    ~H"""
    <div class="grid gap-px overflow-hidden rounded-box border border-base-300 bg-base-300 sm:grid-cols-2">
      <CompositeComponents.stat_tile
        id="stat-preview-signups"
        value={128}
        label="Crew manifest"
        unit="aboard"
        caption="Signups accepted this session"
        highlight
      />
      <CompositeComponents.stat_tile
        id="stat-preview-ticks"
        value={42}
        label="Beats logged"
        unit="ticks"
        caption="One every five seconds"
      />
    </div>
    """
  end

  def feed_row_preview(assigns) do
    ~H"""
    <ul class="divide-y divide-base-300 rounded-box border border-base-300">
      <CompositeComponents.feed_row
        icon="hero-at-symbol"
        tone="ok"
        title="ada@flightdeck.dev"
        detail="seat 1 · cleared manifest"
        stamp="06:11:04"
      />
      <CompositeComponents.feed_row
        icon="hero-clock"
        tone="primary"
        title="T-9 · beat logged"
        detail="weather window holding"
        stamp="06:11:00"
      />
      <CompositeComponents.feed_row
        icon="hero-clock"
        title="T-100 · beat logged"
        detail="all subsystems nominal"
        stamp="06:10:55"
      />
    </ul>
    """
  end

  def theme_switch_preview(assigns) do
    ~H"""
    <div class="flex items-center gap-3">
      <ChromeComponents.theme_switch id="theme-switch-preview" />
      <p class="text-sm text-base-content/65">
        Reads the current mode off <code class="font-mono text-xs">[data-theme]</code>
        and hands the flip to the theme script in the root layout.
      </p>
    </div>
    """
  end

  def site_footer_preview(assigns) do
    ~H"""
    <ChromeComponents.site_footer class="rounded-box" />
    """
  end
end

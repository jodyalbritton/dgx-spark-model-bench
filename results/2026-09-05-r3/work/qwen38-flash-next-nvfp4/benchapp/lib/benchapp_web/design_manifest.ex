defmodule BenchappWeb.DesignManifest do
  @moduledoc """
  This app's component manifest. Backed by `JobyKit.Manifest`.

  This registers **this app's** components — the ones that surface on
  `/custom-designs`.

  JobyKit registers its own, so `/design` shows the kit inventory
  without anything being listed here, and picks up new kit components
  when you upgrade the dependency rather than when someone remembers to
  edit this file. `/design.json` combines the kit's entries and yours,
  so agents still get one source of truth.
  """

  use JobyKit.Manifest

  alias BenchappWeb.ChromeComponents
  alias BenchappWeb.CompositeComponents
  alias BenchappWeb.DesignPreviews

  category :composite,
    label: "Generic composites",
    description: "Multi-primitive patterns reused across domains."

  category :domain,
    label: "Domain composites",
    description: "Composites tied to a product area."

  # ----------------------------------------------------------------- composite
  # `empty_state` is the worked example — a real composite that bundles
  # `<.icon>` + a heading + an optional action slot. Use it as the
  # template for your own: copy the attr / slot / data-component shape,
  # register the entry here, and add a preview in `design_previews.ex`.
  #
  # Generic composites belong in `BenchappWeb.CompositeComponents`;
  # domain-specific ones in their own module (e.g.
  # `BenchappWeb.ChatComponents`).

  component CompositeComponents, :empty_state,
    category: :composite,
    summary: "Centered icon + title + optional action; fills empty containers.",
    preview: &DesignPreviews.empty_state_preview/1

  component CompositeComponents, :feature_card,
    category: :composite,
    summary:
      "Tagged capability panel: mono tag, icon, title, copy, optional action. The home feature grid is N of these.",
    preview: &DesignPreviews.feature_card_preview/1

  component CompositeComponents, :stat_tile,
    category: :composite,
    summary:
      "One telemetry reading — mono value, label, optional unit and caption. Tiles tile into a stats strip.",
    preview: &DesignPreviews.stat_tile_preview/1

  component CompositeComponents, :card_grid,
    category: :composite,
    summary: "Responsive panel grid — one gutter and one set of breakpoints for every row of cards.",
    preview: &DesignPreviews.card_grid_preview/1

  component CompositeComponents, :feed_row,
    category: :composite,
    summary:
      "An <li> for telemetry lists: status icon, headline, detail, right-aligned stamp.",
    preview: &DesignPreviews.feed_row_preview/1

  # -------------------------------------------------------------------- chrome
  # The nav *is* the page it would be previewed on, so it ships without a
  # preview; the theme switch and footer preview with their own ids, since
  # the live page already owns `theme-toggle`.

  component ChromeComponents, :site_nav,
    category: :composite,
    summary:
      "Site navigation: inline link row at desktop, same links behind #nav-toggle at phone widths, aria-current on the active link."

  component ChromeComponents, :theme_switch,
    category: :composite,
    summary:
      "Single-button light/dark control; flips data-theme through the same phx:set-theme event the kit's segmented control dispatches.",
    preview: &DesignPreviews.theme_switch_preview/1

  component ChromeComponents, :site_footer,
    category: :composite,
    summary: "Page footer: product line plus the design surfaces, so the inventory stays reachable.",
    preview: &DesignPreviews.site_footer_preview/1

  # -------------------------------------------------------------------- domain
  # Add domain composites here:
  #
  #   component BenchappWeb.ChatComponents, :composer,
  #     category: :domain,
  #     summary: "Message composer with response-length controls."

  @doc """
  daisyUI primitives **this app** wraps that the kit does not.

  The kit declares its own, so there is nothing to list here until you
  wrap a primitive yourself — a `drawer`, say, or a `carousel`. Entries
  here flip that primitive to "Wrapped" in the catalogue on `/design`
  and link to your component. Ids must match `JobyKit.DaisyCatalogue`
  ids.

      def daisy_overrides do
        %{
          drawer: %{wrapper: "<.app_drawer>", anchor: "#jobykit-component-..."}
        }
      end
  """
  def daisy_overrides, do: %{}
end

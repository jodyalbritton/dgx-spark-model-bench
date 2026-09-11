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

  alias BenchappWeb.CompositeComponents
  alias BenchappWeb.JobyCorpComponents
  alias BenchappWeb.DesignPreviews

  category(:composite,
    label: "Generic composites",
    description: "Multi-primitive patterns reused across domains."
  )

  category(:domain,
    label: "Domain composites",
    description: "Composites tied to a product area."
  )

  # ----------------------------------------------------------------- composite
  # `empty_state` is the worked example — a real composite that bundles
  # `<.icon>` + a heading + an optional action slot. Use it as the
  # template for your own: copy the attr / slot / data-component shape,
  # register the entry here, and add a preview in `design_previews.ex`.
  #
  # Generic composites belong in `BenchappWeb.CompositeComponents`;
  # domain-specific ones in their own module (e.g.
  # `BenchappWeb.ChatComponents`).

  component(CompositeComponents, :empty_state,
    category: :composite,
    summary: "Centered icon + title + optional action; fills empty containers.",
    preview: &DesignPreviews.empty_state_preview/1
  )

  component(CompositeComponents, :record_card,
    category: :composite,
    summary: "Plotting-paper specimen card of a run record's fields and units.",
    preview: &DesignPreviews.record_card_preview/1
  )

  component(JobyCorpComponents, :hero_grid,
    category: :domain,
    summary: "Two-column hero grid: statement left, record card right.",
    preview: &DesignPreviews.hero_grid_preview/1
  )

  component(JobyCorpComponents, :section_head,
    category: :domain,
    summary: "Monospace running head plus section heading for a data section.",
    preview: &DesignPreviews.section_head_preview/1
  )

  component(JobyCorpComponents, :spec_row,
    category: :domain,
    summary: "Spec-sheet row: monospace term beside a reading column.",
    preview: &DesignPreviews.spec_row_preview/1
  )

  component(JobyCorpComponents, :body_text,
    category: :domain,
    summary: "Reading paragraph at measure — the site's body-text treatment.",
    preview: &DesignPreviews.body_text_preview/1
  )

  component(JobyCorpComponents, :cta_section,
    category: :domain,
    summary: "Closing call to action: heading plus one primary action.",
    preview: &DesignPreviews.cta_section_preview/1
  )

  component(JobyCorpComponents, :metric_row,
    category: :domain,
    summary: "One row of the measurement table: quantity, unit, meaning.",
    preview: &DesignPreviews.metric_row_preview/1
  )

  component(JobyCorpComponents, :page_column,
    category: :domain,
    summary: "The site's centred content column.",
    preview: &DesignPreviews.page_column_preview/1
  )

  component(JobyCorpComponents, :data_section,
    category: :domain,
    summary: "Hairline-topped data section with vertical rhythm.",
    preview: &DesignPreviews.data_section_preview/1
  )

  component(JobyCorpComponents, :hero_heading,
    category: :domain,
    summary: "The hero statement — the page's largest heading.",
    preview: &DesignPreviews.hero_heading_preview/1
  )

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

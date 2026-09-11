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
  # Generic composites reused across pages live in
  # `BenchappWeb.CompositeComponents` and are registered here so they
  # surface on `/custom-designs` and in `/design.json`. Each carries a
  # preview in `BenchappWeb.DesignPreviews`.

  component(CompositeComponents, :record_card,
    category: :composite,
    summary: "A run record specimen: fields and units on a plotting-paper surface.",
    preview: &DesignPreviews.record_card_preview/1
  )

  component(CompositeComponents, :spec_row,
    category: :composite,
    summary: "Monospace label column beside a reading column; stacks on phone.",
    preview: &DesignPreviews.spec_row_preview/1
  )

  component(CompositeComponents, :page_body,
    category: :composite,
    summary: "Centred page column, max-w-6xl, phone/desktop gutters.",
    preview: &DesignPreviews.page_body_preview/1
  )

  component(CompositeComponents, :lede,
    category: :composite,
    summary: "Lead paragraph at the reading measure in secondary ink.",
    preview: &DesignPreviews.lede_preview/1
  )

  component(CompositeComponents, :section,
    category: :composite,
    summary: "Hairline section with optional running head, heading, and lead.",
    preview: &DesignPreviews.section_preview/1
  )

  component(CompositeComponents, :figure_table,
    category: :composite,
    summary: "A table as a figure: base-200 header, hairlines, phone scroll.",
    preview: &DesignPreviews.figure_table_preview/1
  )

  component(CompositeComponents, :prose_cell,
    category: :composite,
    summary: "Reading-column text inside a table cell, secondary ink.",
    preview: &DesignPreviews.prose_cell_preview/1
  )

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

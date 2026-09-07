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
  # The site's figures: the record card a run is written on, the spec sheet
  # that lays a field name beside its explanation, and the running head that
  # opens a section of data. Each is used on more than one page.

  component(CompositeComponents, :record_card,
    category: :composite,
    summary: "A run record on plotting paper: field names and their units.",
    preview: &DesignPreviews.record_card_preview/1
  )

  component(CompositeComponents, :spec_sheet,
    category: :composite,
    summary: "Monospace label column beside a reading column, one row per field.",
    preview: &DesignPreviews.spec_sheet_preview/1
  )

  component(CompositeComponents, :running_head,
    category: :composite,
    summary: "Hairline and monospace section head for a section of data.",
    preview: &DesignPreviews.running_head_preview/1
  )

  component(CompositeComponents, :section_head,
    category: :composite,
    summary: "Running head, heading, and lead paragraph — the way every section opens.",
    preview: &DesignPreviews.section_head_preview/1
  )

  component(CompositeComponents, :content_column,
    category: :composite,
    summary: "The centred content column every page and piece of chrome sits in.",
    preview: &DesignPreviews.content_column_preview/1
  )

  component(CompositeComponents, :data_table,
    category: :composite,
    summary: "A figure, not a layout: header row, hairlines, monospace ids, right-aligned units.",
    preview: &DesignPreviews.data_table_preview/1
  )

  component(CompositeComponents, :closing_call,
    category: :composite,
    summary:
      "How a page ends: hairline, heading, one line of reason, and a link that says what to read.",
    preview: &DesignPreviews.closing_call_preview/1
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

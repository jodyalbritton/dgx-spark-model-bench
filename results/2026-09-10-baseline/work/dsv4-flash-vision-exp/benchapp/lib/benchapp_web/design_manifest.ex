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
  # JobyCorp-page scaffolding composites and the brand object.
  #
  # Generic composites belong in `BenchappWeb.CompositeComponents`;
  # domain-specific ones in their own module (e.g.
  # `BenchappWeb.ChatComponents`).

  for {name, summary} <- [
        container: "Centred content column (max-w-6xl, vertical rhythm).",
        section: "Hairline data/prose section with optional running head and heading.",
        mono_label: "Monospace running head or field label in the secondary colour.",
        prose: "Reading paragraph at prose width.",
        two_column: "Two-column layout with a content slot and a figure slot.",
        record_card: "Specimen of a JobyCorp run record on a plotting-paper surface."
      ] do
    component(CompositeComponents, name,
      category: :composite,
      summary: summary,
      preview: &DesignPreviews.composite_preview/1
    )
  end

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

defmodule <%= @web_module %>.DesignManifest do
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

  alias <%= @web_module %>.CompositeComponents
  alias <%= @web_module %>.DesignPreviews

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
  # Generic composites belong in `<%= @web_module %>.CompositeComponents`;
  # domain-specific ones in their own module (e.g.
  # `<%= @web_module %>.ChatComponents`).

  component CompositeComponents, :empty_state,
    category: :composite,
    summary: "Centered icon + title + optional action; fills empty containers.",
    preview: &DesignPreviews.empty_state_preview/1

  # -------------------------------------------------------------------- domain
  # Add domain composites here:
  #
  #   component <%= @web_module %>.ChatComponents, :composer,
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

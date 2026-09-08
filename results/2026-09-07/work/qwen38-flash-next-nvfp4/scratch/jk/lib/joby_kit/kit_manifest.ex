defmodule JobyKit.KitManifest do
  @moduledoc """
  The kit's own component inventory — what `/design` shows, everywhere.

  This is the canonical list. `JobyKit.PageComponent.page_component/1`
  renders it directly rather than filtering the host's manifest, so the
  kit surface is genuinely identical across every consumer rather than
  identical by convention.

  ## Why the host manifest doesn't decide this

  It used to. Each install generated registrations for the kit's
  components into the host's `DesignManifest`, with previews in the
  host's `DesignPreviews`. Three things drifted from there, all of them
  observed in the fleet:

    * **Which components appear.** Generated files are written once and
      never updated, so an app installed at 0.1 still advertised the 0.1
      inventory. One app showed 8 of the 14 components its kit version
      shipped, with no indication the other 6 existed.
    * **What each preview renders.** Host-owned previews were edited
      locally, so two apps on the same kit version demonstrated the same
      `<.button>` with different examples — one of them missing the
      icon-button case entirely.
    * **What the summary says.** Same component, different prose per app.

  A page that differs per app can't be the thing an agent learns once.

  Hosts register *their* components; the kit registers the kit's.
  """

  use JobyKit.Manifest

  alias JobyKit.CoreComponents
  alias JobyKit.NavComponent
  alias JobyKit.Previews

  category(:core,
    label: "Core wrappers",
    description: "One wrapper per daisyUI primitive. Shipped by JobyKit."
  )

  component(CoreComponents, :button,
    category: :core,
    daisy_basis: "btn",
    summary:
      "Text or icon button. `variant` carries tone; `shape` squares off icon-only actions.",
    preview: &Previews.button/1
  )

  component(CoreComponents, :badge,
    category: :core,
    daisy_basis: "badge",
    summary: "Status chip. `tone` names the state — neutral, ok, warn, danger, info.",
    preview: &Previews.badge/1
  )

  component(CoreComponents, :card,
    category: :core,
    daisy_basis: "card",
    summary: "Content surface with eyebrow, title, and actions slots. Body typography is opt-in.",
    preview: &Previews.card/1
  )

  component(CoreComponents, :eyebrow,
    category: :core,
    summary: "Small uppercase label. `card` and `header` use it for their :eyebrow slots.",
    preview: &Previews.eyebrow/1
  )

  component(CoreComponents, :icon,
    category: :core,
    daisy_basis: "hero-*",
    summary: "Heroicon span. Pass `name=\"hero-x-mark\"` and an optional `class`.",
    preview: &Previews.icon/1
  )

  component(CoreComponents, :input,
    category: :core,
    daisy_basis: "input / select / textarea / checkbox",
    summary:
      "Form control with label and error wiring. `class` is layout; `input_class` styles the control.",
    preview: &Previews.input/1
  )

  component(CoreComponents, :flash,
    category: :core,
    daisy_basis: "alert",
    summary: "A single notice. Render inside `flash_group/1`, which positions them.",
    preview: &Previews.flash/1
  )

  # No preview: it is the page's single fixed-position toast container,
  # so an inline preview would float over the design page itself.
  component(CoreComponents, :flash_group,
    category: :core,
    daisy_basis: "toast",
    summary: "Root-layout flash container. Stacks every notice in one toast."
  )

  component(CoreComponents, :header,
    category: :core,
    summary: "Page or section header. `level` picks the tag, `size` the type scale.",
    preview: &Previews.header/1
  )

  component(CoreComponents, :list,
    category: :core,
    daisy_basis: "list",
    summary: "Title/value pairs. `title_class` replaces the default treatment.",
    preview: &Previews.list/1
  )

  component(CoreComponents, :modal,
    category: :core,
    daisy_basis: "modal",
    summary: "Server-driven dialog. One `on_cancel` covers button, backdrop, and Escape.",
    preview: &Previews.modal/1
  )

  component(CoreComponents, :table,
    category: :core,
    daisy_basis: "table",
    summary: "Column-slot table. Takes a plain list or a LiveView stream.",
    preview: &Previews.table/1
  )

  component(CoreComponents, :theme_toggle,
    category: :core,
    daisy_basis: "theme-controller",
    summary: "System / light / dark control. Pairs with the root-layout theme script.",
    preview: &Previews.theme_toggle/1
  )

  component(NavComponent, :simple_nav,
    category: :core,
    daisy_basis: "navbar",
    summary: "App navbar with active state and an :actions slot. Draws no surface of its own.",
    preview: &Previews.simple_nav/1
  )

  @doc """
  The daisyUI primitives the kit wraps, for the catalogue's status pills.

  Merged under a host's own `daisy_overrides/0`, so an app that wraps a
  primitive the kit doesn't still gets credit for it.
  """
  def daisy_overrides do
    %{
      button: %{wrapper: "<.button>", anchor: anchor("button")},
      badge: %{wrapper: "<.badge>", anchor: anchor("badge")},
      card: %{wrapper: "<.card>", anchor: anchor("card")},
      alert: %{wrapper: "<.flash>", anchor: anchor("flash")},
      toast: %{wrapper: "<.flash_group>", anchor: anchor("flash_group")},
      list: %{wrapper: "<.list>", anchor: anchor("list")},
      modal: %{wrapper: "<.modal>", anchor: anchor("modal")},
      table: %{wrapper: "<.table>", anchor: anchor("table")},
      text_input: %{wrapper: "<.input>", anchor: anchor("input")},
      select: %{wrapper: ~s(<.input type="select">), anchor: anchor("input")},
      textarea: %{wrapper: ~s(<.input type="textarea">), anchor: anchor("input")},
      checkbox: %{wrapper: ~s(<.input type="checkbox">), anchor: anchor("input")},
      theme_controller: %{wrapper: "<.theme_toggle>", anchor: anchor("theme_toggle")},
      navbar: %{
        wrapper: "<.simple_nav>",
        anchor: "#jobykit-component-jobykit-navcomponent-simple_nav"
      }
    }
  end

  defp anchor(function), do: "#jobykit-component-jobykit-corecomponents-#{function}"
end

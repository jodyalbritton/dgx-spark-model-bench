defmodule JobyKit do
  @moduledoc """
  An opinionated, agentic-first design-system kit for Phoenix + daisyUI apps.

  JobyKit ships:

  * A small `JobyKit.Manifest` behaviour for hosts to declare their UI
    component inventory.
  * A `JobyKit.PageComponent` function component that renders a discoverable,
    machine-readable design page from any manifest module.
  * A `JobyKit.ManifestController` that serves the same data as JSON for
    coding agents.
  * A daisyUI catalogue indexing every primitive in the substrate so the next
    person reaching for a tab strip / modal / dropdown / skeleton can confirm
    it already exists before reinventing it.
  * The contract content (decision tree, wrapper rules, taxonomy) — universal
    to every consumer, not host-specific.

  Hosts own their wrapper components (in `core_components.ex`), their manifest
  declaration, their preview functions, and their skin CSS. JobyKit provides
  the rendering surface and the contract.

  ## Minimal install

      defmodule MyAppWeb.DesignManifest do
        use JobyKit.Manifest

        category :core,
          label: "Core wrappers",
          description: "One wrapper per daisyUI primitive. Live in core_components."

        component MyAppWeb.CoreComponents, :button,
          category: :core,
          daisy_basis: "btn",
          summary: "Standard text button.",
          preview: &MyAppWeb.DesignPreviews.button/1
      end

  Then in `router.ex`:

      live "/design", MyAppWeb.DesignSystemLive, :index

      get "/design.json", JobyKit.ManifestController, :show,
        private: %{joby_kit_manifest: MyAppWeb.DesignManifest}

  And in your LiveView:

      def render(assigns), do: ~H\"\"\"
        <Layouts.app flash={@flash}>
          <JobyKit.PageComponent.page_component manifest={MyAppWeb.DesignManifest} />
        </Layouts.app>
      \"\"\"
  """
end

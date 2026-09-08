defmodule BenchappWeb.DesignSystemLive do
  @moduledoc """
  The kit-curated design page. Renders `JobyKit.PageComponent.page_component`
  filtered to `:core` entries from `BenchappWeb.DesignManifest`.

  The `:custom_path` attr drives the agent-redirect callout that points new
  composites and domain components at the custom-designs page.
  """

  use BenchappWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> BenchappWeb.Chrome.assign_chrome() |> assign(page_title: "Design System")}
  end

  @impl true
  def handle_event("toggle_nav", _params, socket) do
    {:noreply, BenchappWeb.Chrome.toggle_nav(socket)}
  end

  # The theme flip is applied client-side by `assets/js/app.js`; answering
  # the event keeps the control a LiveView event target on every page.
  def handle_event("toggle_theme", _params, socket), do: {:noreply, socket}

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="design" nav_open={@nav_open}>
      <div id="design-system-page" class="space-y-8 p-4 sm:p-8">
        <header>
          <h1 class="text-3xl font-semibold leading-tight">Design System</h1>
          <p class="mt-2 max-w-3xl text-sm text-base-content/70">
            JobyKit's curated wrapper inventory and contract. Composites and domain
            components live on <.link navigate={~p"/custom-designs"} class="link link-primary">/custom-designs</.link>.
          </p>
        </header>

        <JobyKit.PageComponent.page_component
          manifest={BenchappWeb.DesignManifest}
          custom_path={~p"/custom-designs"}
        />
      </div>
    </Layouts.app>
    """
  end
end

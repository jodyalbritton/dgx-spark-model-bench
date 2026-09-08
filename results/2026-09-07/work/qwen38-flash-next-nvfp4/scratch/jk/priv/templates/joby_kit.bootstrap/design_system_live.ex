defmodule <%= @web_module %>.DesignSystemLive do
  @moduledoc """
  The kit-curated design page (`/design`). Renders
  `JobyKit.PageComponent.page_component` filtered to `:core` entries
  from `<%= @web_module %>.DesignManifest`.

  The agent-redirect callout (driven by `:custom_path`) tells
  contributors where new composites and domain components belong.
  """

  use <%= @web_module %>, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Design System")}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <main id="design-system-page" class="mx-auto max-w-6xl space-y-8 px-6 py-10">
        <header>
          <h1 class="text-3xl font-semibold leading-tight">Design System</h1>
          <p class="mt-2 max-w-3xl text-sm text-base-content/70">
            JobyKit's curated wrapper inventory and contract. Composites and domain
            components live on
            <.link navigate={~p"/custom-designs"} class="link link-primary">/custom-designs</.link>.
          </p>
        </header>

        <JobyKit.PageComponent.page_component
          manifest={<%= @web_module %>.DesignManifest}
          custom_path={~p"/custom-designs"}
        />
      </main>
    </Layouts.app>
    """
  end
end

defmodule <%= @web_module %>.CustomDesignsLive do
  @moduledoc """
  This app's catalogue of generic composites and domain components.

  Pairs with `/design`, which is JobyKit's curated kit surface. The kit
  page intentionally hides composites and domain entries so every
  JobyKit consumer sees the same wrapper inventory; this page is where
  this app's `:composite` and `:domain` manifest entries surface.

  Both pages share `<%= @web_module %>.DesignManifest`. The
  `/design.json` endpoint serves *all* entries (kit core + composites +
  domain) so agents have one source of truth.
  """

  use <%= @web_module %>, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Custom Designs")}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="custom-designs-page" class="space-y-8 p-4 sm:p-8">
        <header>
          <h1 class="text-3xl font-semibold leading-tight">Custom Designs</h1>
          <p class="mt-2 max-w-3xl text-sm text-base-content/70">
            This app's generic composites and domain components. Kit-curated
            wrappers and the contract live on
            <.link navigate={~p"/design"} class="link link-primary">/design</.link>.
          </p>
        </header>

        <JobyKit.PageComponent.custom_page_component
          manifest={<%= @web_module %>.DesignManifest}
          back_to={~p"/design"}
        />
      </div>
    </Layouts.app>
    """
  end
end

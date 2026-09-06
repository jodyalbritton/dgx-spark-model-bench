defmodule BenchappWeb.AboutLive do
  @moduledoc """
  About page for Lumen. Same app layout as the landing page, reached
  from the top navigation.
  """

  use BenchappWeb, :live_view

  @principles [
    %{
      title: "Composition over creation",
      body:
        "We arrange registered primitives rather than hand-rolling markup, so the inventory, the page, and the manifest never drift apart."
    },
    %{
      title: "One source of truth",
      body:
        "A single component manifest feeds the rendered UI, the design catalog, and a JSON endpoint read by agents."
    },
    %{
      title: "Calm defaults, sharp edges",
      body:
        "Neutral surfaces and a disciplined type scale, with a primary accent reserved for the moment that matters."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About", principles: @principles)}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto w-full max-w-3xl space-y-10 px-4 py-16 sm:px-6">
        <.header size="page">
          About Lumen
          <:eyebrow>The idea</:eyebrow>
          <:subtitle>
            Lumen is a design exercise in realtime product surfaces: a themed,
            mobile-ready interface assembled entirely from a small set of
            registered, contract-checked components.
          </:subtitle>
        </.header>

        <p class="text-base-content/80">
          The landing page you came from is not a mockup. Its countdown, signup
          form, stats, and activity feed are live Phoenix LiveView state, updated
          in place over a websocket with no database behind them. The whole thing
          is one page of Elixir composed from the same component catalog you can
          browse on <.link navigate={~p"/design"} class="link link-primary">/design</.link>.
        </p>

        <section class="space-y-4">
          <.header level="h2">Principles</.header>
          <.list>
            <:item :for={p <- @principles} title={p.title}>{p.body}</:item>
          </.list>
        </section>

        <div class="rounded-box border border-base-300 bg-base-100 p-6">
          <.header level="h3">Get in touch</.header>
          <p class="mt-2 text-sm text-base-content/70">
            Lumen is a fictional product built to demonstrate a JobyKit +
            Phoenix LiveView app. Head back to the
            <.link navigate={~p"/"} class="link link-primary">landing page</.link>
            to try the live widgets.
          </p>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

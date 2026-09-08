defmodule BenchappWeb.AboutLive do
  @moduledoc "The About page for Fernline."

  use BenchappWeb, :live_view

  import BenchappWeb.CompositeComponents, only: [section_heading: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl space-y-10 px-4 py-12 sm:px-6">
        <header class="space-y-4">
          <p class="font-mono text-xs uppercase tracking-[0.2em] text-primary">About</p>
          <h1 class="text-4xl font-black tracking-tight sm:text-5xl">
            A houseplant company that keeps its data at home.
          </h1>
          <p class="text-lg text-base-content/70">
            Fernline started as a dead fern and a spreadsheet. It grew into
            a small sensor puck, a hallway hub, and a stubborn opinion:
            the record of what happens in your home belongs to you.
          </p>
        </header>

        <section class="space-y-4">
          <.section_heading title="What we believe" />
          <.list>
            <:item title="Local first">
              Every soil reading is stored on the hub in your hallway. The
              cloud is optional, and never required for the basics.
            </:item>
            <:item title="Calm by design">
              Notifications fire when a plant crosses its threshold — not
              when a metric drifts. Most days you should hear nothing.
            </:item>
            <:item title="Open by default">
              The hub speaks a documented local API. Your data leaves in
              CSV or JSON whenever you ask it to.
            </:item>
          </.list>
        </section>

        <section class="rounded-3xl border border-base-300 bg-gradient-to-br from-secondary/10 via-base-100 to-primary/10 p-8">
          <.section_heading title="Early access opens soon" />
          <p class="mt-2 text-base-content/70">
            We're letting the first thousand households in, one batch at a
            time. The list lives on the home page.
          </p>
          <div class="mt-4">
            <.button variant="primary" navigate={~p"/"}>Back to the countdown</.button>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The Nimbus about page — story, mission, and values.
  """

  use BenchappWeb, :live_view

  @values [
    %{
      icon: "hero-trophy",
      title: "Precision",
      detail: "We obsess over the last hundred metres, not the last mile."
    },
    %{
      icon: "hero-heart",
      title: "Craft",
      detail: "Weather you can read at a glance, on any device."
    },
    %{
      icon: "hero-users",
      title: "Trust",
      detail: "Your data stays yours — we never sell it, ever."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About", values: @values)}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-4xl px-4 py-16 sm:px-6 sm:py-24">
        <header class="text-center">
          <p class="mb-4 inline-flex items-center gap-2 rounded-full border border-base-300 bg-base-100/70 px-3 py-1 text-xs font-medium text-base-content/70">
            <span class="size-1.5 rounded-full bg-accent"></span> Our story
          </p>
          <h1 class="text-4xl font-bold leading-tight tracking-tight text-base-content sm:text-5xl">
            Weather that knows your street.
          </h1>
          <p class="mx-auto mt-6 max-w-2xl text-lg text-base-content/70">
            Nimbus started with a simple frustration: a forecast for the wrong
            side of the hill is no forecast at all. We build tools that turn
            millions of sensor readings into guidance you can actually act on.
          </p>
        </header>

        <div class="mt-16 grid gap-4 sm:grid-cols-3">
          <BenchappWeb.CompositeComponents.stat_card
            value="2019"
            label="Founded"
            detail="In a garage with one radar dish and a lot of ambition."
          />
          <BenchappWeb.CompositeComponents.stat_card
            value="40k"
            label="Sensors"
            detail="Street-level sensors feeding our models every minute."
          />
          <BenchappWeb.CompositeComponents.stat_card
            value="98%"
            label="Accuracy"
            detail="Forecast accuracy within a half-hour window. Still climbing."
          />
        </div>

        <section class="mt-16">
          <h2 class="text-center text-2xl font-semibold text-base-content">What we believe</h2>
          <div class="mt-8 grid gap-4 sm:grid-cols-3">
            <.card :for={value <- @values}>
              <:title>{value.title}</:title>
              <span class="flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
                <JobyKit.CoreComponents.icon name={value.icon} class="size-5" />
              </span>
              <p class="mt-3 text-sm text-base-content/65">{value.detail}</p>
            </.card>
          </div>
        </section>

        <div class="mt-16 text-center">
          <p class="text-base-content/70">Curious where this is headed?</p>
          <div class="mt-4">
            <.button variant="primary" navigate={~p"/"}>Back to the landing page</.button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

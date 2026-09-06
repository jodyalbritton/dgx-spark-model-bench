defmodule BenchappWeb.AboutLive do
  @moduledoc "About Zephyr."

  use BenchappWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto w-full max-w-3xl space-y-8 px-4 py-12 sm:px-6">
        <.header size="page">
          About Zephyr
          <:eyebrow>Our story</:eyebrow>
          <:subtitle>
            Zephyr started as a weekend experiment in calm software. It became a
            workspace that treats your attention as the scarcest resource it has.
          </:subtitle>
        </.header>

        <div class="space-y-4 text-sm leading-relaxed text-base-content/70">
          <p>
            We believe software should feel like a light tailwind at your back —
            present, helpful, and never in the way. Zephyr gathers tasks, notes,
            and your calendar into one quiet surface, then stays out of sight
            until you need it.
          </p>
          <p>
            The team is small, remote, and obsessed with latency budgets. Every
            interaction in Zephyr is measured, and anything slower than a blink
            gets rebuilt.
          </p>
        </div>

        <div class="grid gap-4 sm:grid-cols-3">
          <.card prose>
            <:eyebrow>Principle</:eyebrow>
            <:title>Calm by default</:title>
            No badges, no pings, no red dots. Zephyr never interrupts you
            without permission.
          </.card>
          <.card prose>
            <:eyebrow>Principle</:eyebrow>
            <:title>Fast is a feature</:title>
            Every screen renders in under 100 milliseconds, everywhere.
          </.card>
          <.card prose>
            <:eyebrow>Principle</:eyebrow>
            <:title>Yours to keep</:title>
            Your data exports in open formats at any time. No lock-in, ever.
          </.card>
        </div>

        <div class="flex gap-3">
          <.button navigate={~p"/"} variant="primary">Back to home</.button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

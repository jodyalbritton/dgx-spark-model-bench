defmodule BenchappWeb.AboutLive do
  @moduledoc "About page for Vela."

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About")}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl space-y-10 px-4 py-12 sm:px-6">
        <.header size="page">
          About Vela
          <:subtitle>
            We think calendars should defend your attention, not auction it off.
          </:subtitle>
        </.header>

        <div class="space-y-4 text-base leading-relaxed text-base-content/75">
          <p>
            Vela started as an internal tool at a company where every engineer's
            Tuesday had dissolved into a grid of syncs. We built a small scheduler
            that politely held focus hours — and it stuck.
          </p>
          <p>
            Today Vela is a scheduling assistant for teams that care about attention
            as a resource. It reads availability without ever reading contents,
            proposes slots that respect energy and timezones, and summarizes the
            noise into one quiet daily digest.
          </p>
        </div>

        <div class="grid gap-4 sm:grid-cols-3">
          <CompositeComponents.stat_card label="Founded" value="2025" />
          <CompositeComponents.stat_card label="Team" value="Fully remote" />
          <CompositeComponents.stat_card label="Principle" value="Privacy first" />
        </div>

        <div class="rounded-3xl border border-primary/30 bg-primary/5 p-8 text-center">
          <h2 class="text-xl font-semibold">Want the launch news first?</h2>
          <p class="mx-auto mt-2 max-w-md text-sm text-base-content/70">
            The launch list on the home page gets exactly one email when Vela ships.
          </p>
          <div class="mt-5">
            <.button navigate={~p"/"} variant="primary">Back to home</.button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

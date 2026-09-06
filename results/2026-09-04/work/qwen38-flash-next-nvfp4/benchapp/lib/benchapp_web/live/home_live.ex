defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Benchapp.

  Composes JobyKit wrappers for every primitive and page-level Tailwind
  for layout, motion, and hierarchy. Hosts the live launch countdown,
  which ticks down from 100 one step every five seconds.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @countdown_start 100
  @tick_interval_ms 5_000

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Home", count: @countdown_start)
      |> schedule_tick()

    {:ok, socket}
  end

  defp schedule_tick(socket) do
    if connected?(socket), do: Process.send_after(self(), :tick, @tick_interval_ms)
    socket
  end

  @impl true
  def handle_info(:tick, socket) do
    count = socket.assigns.count

    socket =
      cond do
        count <= 0 ->
          socket

        count == 1 ->
          assign(socket, count: 0)

        true ->
          socket
          |> assign(count: count - 1)
          |> schedule_tick()
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="relative overflow-hidden">
        <%!-- ambient background --%>
        <div aria-hidden="true" class="pointer-events-none absolute inset-x-0 top-0 -z-10">
          <div class="absolute -top-40 left-1/2 h-[34rem] w-[64rem] -translate-x-1/2 rounded-full bg-gradient-to-br from-primary/20 via-secondary/15 to-transparent blur-3xl">
          </div>
        </div>

        <%!-- hero --%>
        <section class="mx-auto flex max-w-6xl flex-col items-center px-4 pb-20 pt-20 text-center sm:px-6 sm:pt-28">
          <.badge
            tone="info"
            class="mb-6 gap-1.5 border-primary/30 bg-primary/10 px-3 py-1.5 font-medium"
          >
            <.icon name="hero-sparkles" class="size-3.5" /> Now live on Phoenix + JobyKit
          </.badge>

          <h1 class="max-w-3xl text-balance text-5xl font-extrabold leading-[1.05] tracking-tight text-base-content sm:text-6xl">
            Ship interfaces that
            <span class="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
              invent themselves
            </span>
          </h1>

          <p class="mt-6 max-w-xl text-pretty text-lg leading-relaxed text-base-content/70">
            Benchapp wires Phoenix LiveView to a machine-readable component
            manifest, so every button, card, and input you render is discoverable,
            reusable, and never out of date.
          </p>

          <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
            <.button
              navigate={~p"/design"}
              variant="primary"
              size="lg"
              class="shadow-lg shadow-primary/25 transition-transform hover:-translate-y-0.5"
            >
              Explore the inventory
            </.button>
            <.button navigate={~p"/custom-designs"} variant="ghost" size="lg">
              View components <.icon name="hero-arrow-right" class="size-4" />
            </.button>
          </div>

          <%!-- countdown --%>
          <div class="mt-16 w-full max-w-md" id="countdown-card">
            <.card class="border border-base-300/70 bg-base-100/70 shadow-xl shadow-base-200/50 backdrop-blur">
              <div class="flex flex-col items-center gap-4 px-8 py-8">
                <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/50">
                  Launch countdown
                </p>
                <p
                  id="countdown-value"
                  class={[
                    "font-mono text-7xl font-black tabular-nums transition-all duration-500",
                    (@count == 0 && "text-success") || "text-base-content"
                  ]}
                >
                  {@count}
                </p>
                <progress
                  class="progress progress-primary w-full"
                  value={@count}
                  max="100"
                ></progress>
                <p class="text-sm text-base-content/60">
                  <%= if @count > 0 do %>
                    Ticking down — one step every 5 seconds
                  <% else %>
                    Liftoff. 🚀
                  <% end %>
                </p>
              </div>
            </.card>
          </div>
        </section>

        <%!-- feature grid --%>
        <section class="mx-auto max-w-6xl px-4 pb-24 sm:px-6">
          <div class="grid gap-5 md:grid-cols-3">
            <CompositeComponents.feature_card
              icon="hero-swatch"
              title="Curated wrappers"
              tone="primary"
            >
              Buttons, inputs, cards, and icons flow through one registered
              contract — rendered live at <span class="font-mono text-xs">/design</span>.
            </CompositeComponents.feature_card>

            <CompositeComponents.feature_card
              icon="hero-code-bracket"
              title="Agent-readable"
              tone="secondary"
            >
              The same inventory as JSON at <span class="font-mono text-xs">/design.json</span>
              — attrs, slots,
              and source lines, no HTML parsing required.
            </CompositeComponents.feature_card>

            <CompositeComponents.feature_card
              icon="hero-bolt"
              title="Real-time by default"
              tone="accent"
            >
              Every surface is a LiveView. Like the countdown above — pushed from
              the server, zero JavaScript written.
            </CompositeComponents.feature_card>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

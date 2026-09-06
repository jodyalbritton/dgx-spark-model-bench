defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Benchapp. Features a server-driven countdown that
  starts at 100 and ticks down by one every 5 seconds, updating live
  in the page via LiveView.
  """

  use BenchappWeb, :live_view

  @doc false
  def countdown_interval_ms, do: :timer.seconds(5)

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Home",
        countdown: 100,
        total: 100
      )

    if connected?(socket) do
      Process.send_after(self(), :tick, countdown_interval_ms())
    end

    {:ok, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    socket = update(socket, :countdown, &max(&1 - 1, 0))

    socket =
      if socket.assigns.countdown > 0 do
        Process.send_after(self(), :tick, countdown_interval_ms())
        socket
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <section class="relative overflow-hidden bg-linear-to-b from-primary/5 via-base-100 to-base-100">
        <div
          class="pointer-events-none absolute inset-0 opacity-40"
          style="background-image: radial-gradient(circle at 1px 1px, color-mix(in oklab, currentColor 12%, transparent) 1px, transparent 0); background-size: 24px 24px;"
          aria-hidden="true"
        >
        </div>

        <div class="relative mx-auto max-w-6xl px-4 py-24 text-center sm:px-6">
          <span class="badge badge-primary badge-soft badge-sm mx-auto badge">
            Now in open beta
          </span>
          <h1 class="mx-auto mt-6 max-w-3xl text-4xl font-extrabold tracking-tight text-balance sm:text-5xl lg:text-6xl">
            Ship benchmarks that
            <span class="bg-linear-to-r from-primary to-secondary bg-clip-text text-transparent">actually matter</span>
          </h1>
          <p class="mx-auto mt-6 max-w-2xl text-lg leading-relaxed text-base-content/70 text-pretty">
            Benchapp turns raw Elixir measurements into insight — reproducible
            scenarios, live dashboards, and history you can trust. Point it at
            your code and let the numbers speak.
          </p>
          <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
            <.button navigate={~p"/design"} variant="primary" size="lg">
              <.icon name="hero-rocket-launch" class="size-4" /> Get started
            </.button>
            <.button navigate={~p"/custom-designs"} variant="ghost" size="lg">
              View components <.icon name="hero-arrow-right" class="size-4" />
            </.button>
          </div>

          <div class="mx-auto mt-16 max-w-md">
            <div
              id="countdown-card"
              class="card card-border border-base-300 bg-base-100/80 shadow-sm backdrop-blur transition-shadow duration-300 hover:shadow-md"
            >
              <div class="card-body items-center gap-2 p-6 text-center">
                <p class="text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-base-content/55">
                  Launch countdown
                </p>
                <div class="flex items-end gap-2">
                  <span
                    id="countdown-value"
                    class="font-mono text-5xl font-bold tabular-nums text-primary"
                  >
                    {@countdown}
                  </span>
                  <span class="pb-1 text-sm text-base-content/50">/ 100</span>
                </div>
                <progress
                  id="countdown-progress"
                  class="progress progress-primary w-full"
                  value={@countdown}
                  max={@total}
                ></progress>
                <p class="text-xs text-base-content/50">
                  Ticks down by one every 5 seconds
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="border-t border-base-300/50 bg-base-200/30">
        <div class="mx-auto max-w-6xl px-4 py-20 sm:px-6">
          <div class="mx-auto max-w-2xl text-center">
            <p class="text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-base-content/55">
              Why Benchapp
            </p>
            <h2 class="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">
              Everything a benchmark needs
            </h2>
          </div>

          <div class="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            <.card variant="elevated" class="transition-transform duration-200 hover:-translate-y-1">
              <span class="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <.icon name="hero-bolt" class="size-6" />
              </span>
              <h3 class="mt-4 card-title text-lg font-semibold">Fast setup</h3>
              <p class="text-sm leading-relaxed text-base-content/70">
                One command scaffolds scenarios, telemetry, and dashboards. No YAML archaeology required.
              </p>
            </.card>

            <.card variant="elevated" class="transition-transform duration-200 hover:-translate-y-1">
              <span class="flex size-11 items-center justify-center rounded-xl bg-secondary/10 text-secondary">
                <.icon name="hero-chart-bar" class="size-6" />
              </span>
              <h3 class="mt-4 card-title text-lg font-semibold">Live results</h3>
              <p class="text-sm leading-relaxed text-base-content/70">
                Watch latency and throughput stream in real time while your suite runs.
              </p>
            </.card>

            <.card variant="elevated" class="transition-transform duration-200 hover:-translate-y-1">
              <span class="flex size-11 items-center justify-center rounded-xl bg-accent/10 text-accent">
                <.icon name="hero-clock" class="size-6" />
              </span>
              <h3 class="mt-4 card-title text-lg font-semibold">Track regressions</h3>
              <p class="text-sm leading-relaxed text-base-content/70">
                Every run is stored and diffed against history, so slowdowns surface before your users notice.
              </p>
            </.card>
          </div>
        </div>
      </section>

      <section class="mx-auto max-w-6xl px-4 py-20 sm:px-6">
        <.card variant="ghost" class="mx-auto max-w-4xl overflow-hidden">
          <div class="card-body items-center gap-4 p-10 text-center sm:p-12">
            <h2 class="text-2xl font-semibold tracking-tight sm:text-3xl">
              Ready to measure what matters?
            </h2>
            <p class="max-w-xl text-sm leading-relaxed text-base-content/70">
              Spin up your first benchmark in minutes — free while in beta.
            </p>
            <.button navigate={~p"/design"} variant="primary" size="lg">
              Start benchmarking
            </.button>
          </div>
        </.card>
      </section>
    </Layouts.app>
    """
  end
end

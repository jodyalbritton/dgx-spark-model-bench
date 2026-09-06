defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Benchapp — a modern, product-style home screen.

  The hero includes a live countdown that starts at 100 and ticks down
  by 1 every 5 seconds while the LiveView is connected.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @countdown_start 100
  @interval_ms 5_000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :tick, @interval_ms)
    end

    {:ok,
     assign(socket,
       page_title: "Benchapp",
       countdown: @countdown_start
     )}
  end

  @impl true
  def handle_info(:tick, socket) do
    count = max(socket.assigns.countdown - 1, 0)

    if count > 0 do
      Process.send_after(self(), :tick, @interval_ms)
    end

    {:noreply, assign(socket, countdown: count)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <%!-- Hero --%>
      <section class="relative overflow-hidden">
        <div class="pointer-events-none absolute inset-0 -z-10 bg-gradient-to-b from-primary/10 via-transparent to-transparent" />
        <div class="mx-auto grid w-full max-w-6xl items-center gap-10 px-4 py-16 sm:px-6 lg:grid-cols-2 lg:py-24">
          <div class="space-y-6">
            <span class="inline-flex items-center gap-2 rounded-full border border-primary/30 bg-primary/5 px-3 py-1 text-xs font-medium text-primary">
              <.icon name="hero-sparkles" class="size-3.5" /> Built on Phoenix + JobyKit
            </span>

            <h1 class="text-4xl font-bold leading-tight tracking-tight sm:text-5xl">
              Ship delightful
              <span class="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                web apps
              </span>
              fast.
            </h1>

            <p class="max-w-md text-lg text-base-content/70">
              Benchapp is a modern Phoenix starter wired to JobyKit — a
              component-driven design system with a machine-readable
              manifest, so your UI stays discoverable and reusable.
            </p>

            <div class="flex flex-wrap gap-3">
              <.button navigate={~p"/design"} variant="primary" size="lg">
                Open the inventory <.icon name="hero-arrow-right" class="size-4" />
              </.button>
              <.button navigate={~p"/custom-designs"} variant="soft" size="lg">
                Custom designs
              </.button>
            </div>

            <div class="flex items-center gap-6 pt-2 text-sm text-base-content/60">
              <span class="flex items-center gap-1.5">
                <.icon name="hero-check-circle" class="size-4 text-success" /> Registered wrappers
              </span>
              <span class="flex items-center gap-1.5">
                <.icon name="hero-check-circle" class="size-4 text-success" /> Themeable
              </span>
            </div>
          </div>

          <%!-- Countdown card --%>
          <div class="flex justify-center lg:justify-end">
            <div class="relative w-full max-w-sm">
              <div class="absolute -inset-4 -z-10 rounded-3xl bg-gradient-to-br from-primary/20 to-accent/20 blur-2xl" />
              <div class="rounded-3xl border border-base-300 bg-base-100/70 p-8 shadow-xl backdrop-blur">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-base-content/60">Live countdown</p>
                  <span class="flex items-center gap-1.5 rounded-full bg-success/10 px-2 py-0.5 text-xs font-medium text-success">
                    <span class="relative flex size-2">
                      <span class="absolute inline-flex size-full animate-ping rounded-full bg-success opacity-75" />
                      <span class="relative inline-flex size-2 rounded-full bg-success" />
                    </span>
                    live
                  </span>
                </div>

                <div class="mt-6 flex items-baseline justify-center">
                  <span
                    id="countdown"
                    class="bg-gradient-to-br from-primary to-accent bg-clip-text font-mono text-7xl font-bold tabular-nums text-transparent"
                  >
                    {@countdown}
                  </span>
                </div>
                <p class="mt-3 text-center text-sm text-base-content/60">
                  Decreasing by 1 every 5 seconds
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- Feature grid --%>
      <section class="border-t border-base-200 bg-base-100/50">
        <div class="mx-auto w-full max-w-6xl px-4 py-16 sm:px-6">
          <div class="mb-10 max-w-xl">
            <p class="eyebrow text-sm font-semibold text-primary">Why Benchapp</p>
            <h2 class="mt-2 text-2xl font-bold tracking-tight">
              Everything you need to start building
            </h2>
          </div>

          <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <CompositeComponents.feature_card
              icon="hero-squares-2x2"
              title="Component inventory"
              tint="primary"
            >
              Every UI primitive is a registered wrapper, surfaced on <code class="font-mono text-xs">/design</code>.
            </CompositeComponents.feature_card>

            <CompositeComponents.feature_card
              icon="hero-code-bracket"
              title="Machine-readable"
              tint="secondary"
            >
              Fetch <code class="font-mono text-xs">/design.json</code> for a
              manifest your agents can parse.
            </CompositeComponents.feature_card>

            <CompositeComponents.feature_card
              icon="hero-moon"
              title="Themeable by design"
              tint="accent"
            >
              One toggle flips light, dark, and system themes across the app.
            </CompositeComponents.feature_card>

            <CompositeComponents.feature_card icon="hero-bolt" title="LiveView-native" tint="info">
              Real-time updates with zero custom JavaScript.
            </CompositeComponents.feature_card>

            <CompositeComponents.feature_card
              icon="hero-cube"
              title="Reusable wrappers"
              tint="warning"
            >
              Compose kit-wrapped primitives instead of hand-rolling markup.
            </CompositeComponents.feature_card>

            <CompositeComponents.feature_card
              icon="hero-check-badge"
              title="Contract-checked"
              tint="success"
            >
              <code class="font-mono text-xs">mix joby_kit.lint</code> keeps
              every component contract honest.
            </CompositeComponents.feature_card>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end

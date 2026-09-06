defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The LumenLab story — what the product is, who it's for, and why.
  Shares the app layout (`Layouts.app`), so it picks up `main-nav`,
  the theme toggle, and the footer like every other page.
  """

  use BenchappWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About — LumenLab")}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl px-4 py-16 sm:px-6 sm:py-24">
        <p class="text-xs font-semibold uppercase tracking-[0.25em] text-primary">
          About
        </p>
        <h1 class="mt-4 text-4xl font-bold tracking-tight text-base-content sm:text-5xl">
          We believe dashboards should feel like good coffee — strong, clear, and warm
        </h1>
        <p class="mt-6 text-lg leading-relaxed text-base-content/70">
          LumenLab started in a shared notebook: three teammates, one whiteboard,
          and a frustration with dashboards that needed a manual to read. We
          build instruments for curious teams — tools that surface what moved,
          why it moved, and what to try next.
        </p>

        <div class="mt-12 grid gap-4 sm:grid-cols-2">
          <div class="rounded-2xl border border-base-300 bg-base-100 p-6">
            <h2 class="text-lg font-semibold text-base-content">Our principles</h2>
            <ul class="mt-3 list-disc space-y-2 pl-5 text-sm text-base-content/70">
              <li>Live over stale — if a number can update, it should.</li>
              <li>Calm over noisy — one clear signal beats ten blinking charts.</li>
              <li>Fast over fancy — the best interface is the one you forget.</li>
            </ul>
          </div>
          <div class="rounded-2xl border border-base-300 bg-base-100 p-6">
            <h2 class="text-lg font-semibold text-base-content">The team</h2>
            <p class="mt-3 text-sm leading-relaxed text-base-content/70">
              A small crew of engineers, designers, and one very opinionated
              data dog. We ship weekly, write postmortems monthly, and read
              every reply to the launch note.
            </p>
          </div>
        </div>

        <div class="mt-12 rounded-2xl border border-primary/30 bg-primary/5 p-6 text-center">
          <h2 class="text-xl font-semibold text-base-content">
            Want in before launch?
          </h2>
          <p class="mx-auto mt-2 max-w-md text-sm text-base-content/70">
            The beta opens with the countdown on the home page — grab a spot
            and we'll hold a seat.
          </p>
          <div class="mt-4">
            <JobyKit.CoreComponents.button variant="primary" navigate={~p"/"}>
              Back to the countdown
            </JobyKit.CoreComponents.button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

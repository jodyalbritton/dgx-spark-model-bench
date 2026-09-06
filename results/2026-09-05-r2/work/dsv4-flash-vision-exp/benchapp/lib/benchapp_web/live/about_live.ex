defmodule BenchappWeb.AboutLive do
  @moduledoc """
  About page for the Lumen launch platform.
  """

  use BenchappWeb, :live_view

  @stats [
    %{value: "12k+", label: "Makers onboard"},
    %{value: "40M+", label: "Launch impressions"},
    %{value: "4.9★", label: "Average rating"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About — Lumen", stats: @stats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl px-4 py-16 sm:px-6 sm:py-24">
        <span class="text-xs font-medium uppercase tracking-widest text-primary">Our story</span>
        <h1 class="mt-3 text-4xl font-extrabold tracking-tight text-base-content sm:text-5xl">
          We believe launches should feel like <span class="text-primary">events</span>.
        </h1>
        <div class="mt-8 space-y-5 text-base-content/70">
          <p class="leading-relaxed">
            Lumen started with a simple frustration: great products kept
            launching into silence. Countdown timers were static, waitlists
            lived in spreadsheets, and no one could feel momentum build.
          </p>
          <p class="leading-relaxed">
            So we built a platform where the countdown is alive, every
            subscriber is captured in the moment, and a live activity feed
            turns launch day into something your audience can feel.
          </p>
          <p class="leading-relaxed">
            Today, thousands of makers use Lumen to turn release dates into
            community rituals.
          </p>
        </div>

        <div class="mt-12 grid gap-4 sm:grid-cols-3">
          <div :for={stat <- @stats} class="rounded-2xl border border-base-300 bg-base-100/60 p-6">
            <div class="text-3xl font-extrabold text-primary">{stat.value}</div>
            <div class="mt-1 text-sm text-base-content/60">{stat.label}</div>
          </div>
        </div>

        <div class="mt-12 flex flex-wrap gap-3">
          <.button navigate={~p"/"} variant="primary">
            Back to the countdown <.icon name="hero-arrow-left" class="size-4" />
          </.button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

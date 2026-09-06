defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Zephyr landing page: hero, live countdown, newsletter signup with a
  recent-signups list, stats strip, and activity feed.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.Presence

  @tick_interval_ms 5_000

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Zephyr — focus that drifts with you")
      |> assign(form: to_form(%{}, as: :signup))
      |> assign(signup_error: nil)
      |> assign(ticks: 0)
      |> assign(countdown: 100)
      |> assign(signups: Presence.recent_signups())
      |> assign(activities: [])

    if connected?(socket) do
      :timer.send_interval(@tick_interval_ms, self(), :tick)
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"signup" => %{"email" => email}}, socket) do
    case Presence.add_signup(email) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(signup_error: nil)
         |> assign(signups: Presence.recent_signups())
         |> assign(form: to_form(%{"email" => ""}, as: :signup))}

      {:error, :taken} ->
        {:noreply,
         socket
         |> assign(signup_error: "That address is already on the list.")
         |> assign(form: to_form(%{"email" => email}, as: :signup))}

      {:error, :invalid} ->
        {:noreply,
         socket
         |> assign(signup_error: "Please enter a valid email address.")
         |> assign(form: to_form(%{"email" => email}, as: :signup))}
    end
  end

  @impl true
  def handle_info(:tick, socket) do
    {countdown, ticks, activities} = Presence.tick()

    {:noreply,
     socket
     |> assign(countdown: countdown)
     |> assign(ticks: ticks)
     |> assign(activities: activities)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto w-full max-w-5xl space-y-16 px-4 py-12 sm:px-6 sm:py-16">
        <section class="relative overflow-hidden rounded-3xl border border-base-300/60 bg-gradient-to-br from-primary/10 via-base-100 to-secondary/10 px-6 py-16 text-center sm:px-12 sm:py-20">
          <div class="flex flex-col items-center gap-6">
            <span class="badge badge-primary badge-outline">Early access opens soon</span>
            <h1 class="max-w-2xl text-4xl font-semibold leading-tight tracking-tight sm:text-5xl">
              Zephyr — focus that drifts with you
            </h1>
            <p class="max-w-xl text-base-content/70">
              A calm workspace that gathers your tasks, notes, and calendar into a
              single breeze. Launch day is counted down to the second — join the
              list below and be first through the door.
            </p>
            <div class="flex flex-wrap items-center justify-center gap-3">
              <.button navigate={~p"/about"} variant="primary">Learn more</.button>
              <.button navigate={~p"/design"} variant="ghost">Component inventory</.button>
            </div>
          </div>
        </section>

        <section class="grid gap-4 sm:grid-cols-3" id="stats" data-testid="stats">
          <.stat_card icon="hero-users" tone="primary" label="Signups so far">
            <span class="stat-value text-primary" id="stat-signups">{length(@signups)}</span>
          </.stat_card>
          <.stat_card icon="hero-clock" tone="secondary" label="Countdown ticks">
            <span class="stat-value text-secondary" id="stat-ticks">{@ticks}</span>
          </.stat_card>
          <.stat_card icon="hero-sparkles" label="Launch countdown">
            <span class="stat-value tabular-nums" id="countdown">{@countdown}</span>
            <span class="stat-desc">Decrements every 5 seconds</span>
          </.stat_card>
        </section>

        <section class="grid gap-4 md:grid-cols-2">
          <div class="space-y-4">
            <.header level="h2">
              Join the launch list
              <:eyebrow>Newsletter</:eyebrow>
              <:subtitle>One email when Zephyr ships. Nothing else.</:subtitle>
            </.header>

            <.form
              id="signup-form"
              for={@form}
              phx-submit="save"
              class="join w-full max-w-md"
              aria-label="Newsletter signup"
            >
              <.input
                field={@form[:email]}
                type="email"
                name="signup[email]"
                placeholder="you@example.com"
                aria-label="Email address"
                input_class="join-item"
                class="join-item w-auto flex-1"
                required={false}
              />
              <.button type="submit" variant="primary" class="join-item">Sign up</.button>
            </.form>
            <p
              :if={@signup_error}
              id="signup-error"
              role="alert"
              class="text-sm font-medium text-error"
            >
              {@signup_error}
            </p>

            <div class="space-y-2">
              <h3 class="text-sm font-semibold uppercase tracking-wide text-base-content/50">
                Recent signups
              </h3>
              <ul id="signups" class="list bg-base-200/50 rounded-box">
                <li :for={email <- @signups} class="list-row font-mono text-sm">
                  {email}
                </li>
              </ul>
            </div>
          </div>

          <div class="space-y-4">
            <.header level="h2">
              Live activity
              <:eyebrow>Feed</:eyebrow>
              <:subtitle>Signups and countdown ticks as they happen.</:subtitle>
            </.header>
            <ul id="activity" class="list bg-base-200/50 rounded-box">
              <li :for={entry <- @activities} class="list-row text-sm">
                {entry}
              </li>
            </ul>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp stat_card(assigns) do
    assigns = assign(assigns, :tone, assigns[:tone])

    ~H"""
    <.card class="!flex-col stat border border-base-300/60">
      <div class={["stat-figure", @tone && "text-#{@tone}"]}>
        <.icon name={@icon} class="size-8" />
      </div>
      <div class="stat-title">{@label}</div>
      {render_slot(@inner_block)}
    </.card>
    """
  end
end

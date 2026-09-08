defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Lumen — a desk lamp that follows your focus.
  """

  use BenchappWeb, :live_view

  @tick_interval_ms 5_000
  @countdown_start 100
  @max_activity 10

  @features [
    %{
      icon: "hero-bolt",
      title: "Instant on",
      text: "Wakes in 80 ms with your last scene, no fumbling for switches."
    },
    %{
      icon: "hero-adjustments-horizontal",
      title: "Adaptive glow",
      text: "Color temperature that tracks your circadian rhythm through the day."
    },
    %{
      icon: "hero-eye",
      title: "Presence sensing",
      text: "Dims when you step away, brightens the moment you sit back down."
    },
    %{
      icon: "hero-moon",
      title: "Night warm",
      text: "Melatonin-safe amber tones after sunset so evenings wind down."
    },
    %{
      icon: "hero-device-phone-mobile",
      title: "Scene control",
      text: "Focus, read, and unwind scenes from your phone or the lamp itself."
    },
    %{
      icon: "hero-bolt",
      title: "Weeks of charge",
      text: "Cordless for up to 30 days on a single USB-C top-up."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Lumen — Light for deep work",
        countdown: @countdown_start,
        ticks: 0,
        signups: [],
        activity: [],
        form: to_form(%{"email" => ""}, as: :signup),
        error: nil,
        features: @features
      )

    socket =
      if connected?(socket) do
        schedule_tick(socket)
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    {:noreply, handle_signup(socket, email)}
  end

  @impl true
  def handle_info(:tick, socket) do
    socket =
      socket
      |> assign(countdown: socket.assigns.countdown - 1, ticks: socket.assigns.ticks + 1)
      |> add_activity("A focus session ticked over")
      |> schedule_tick()

    {:noreply, socket}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)
    socket
  end

  defp handle_signup(socket, email) do
    email = String.trim(email)

    cond do
      not valid_email?(email) ->
        assign(socket, error: "Please enter a valid email address.")

      email in socket.assigns.signups ->
        assign(socket, error: "You're already on the list.")

      true ->
        socket
        |> assign(signups: socket.assigns.signups ++ [email], error: nil)
        |> add_activity("#{email} joined the early access list")
        |> assign(form: to_form(%{"email" => ""}, as: :signup))
    end
  end

  defp add_activity(socket, message) do
    entry = %{id: System.unique_integer([:positive]), message: message}
    assign(socket, activity: [entry | socket.assigns.activity] |> Enum.take(@max_activity))
  end

  defp valid_email?(email) do
    Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl space-y-16 px-4 py-12 sm:px-6">
        <%!-- Hero --%>
        <section class="relative overflow-hidden rounded-3xl border border-base-300 bg-gradient-to-br from-primary/10 via-base-100 to-secondary/10 px-6 py-16 text-center sm:px-12">
          <div class="mx-auto max-w-2xl space-y-6">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">
              Early access opens soon
            </p>
            <h1 class="text-4xl font-black tracking-tight sm:text-6xl">
              Light that works the way you think.
            </h1>
            <p class="text-lg text-base-content/70">
              Lumen is a desk lamp that senses focus, shifts color with your day,
              and runs for weeks without a cable. Reserve yours before the first
              batch ships.
            </p>
            <div class="flex flex-wrap items-center justify-center gap-3">
              <JobyKit.CoreComponents.button href="#signup" variant="primary" size="lg">
                Reserve your Lumen
              </JobyKit.CoreComponents.button>
              <JobyKit.CoreComponents.button navigate={~p"/about"} variant="soft" size="lg">
                Why Lumen?
              </JobyKit.CoreComponents.button>
            </div>
          </div>
        </section>

        <%!-- Stats strip --%>
        <section id="stats" class="stats stats-vertical w-full shadow sm:stats-horizontal">
          <div class="stat">
            <div class="stat-title">Focus units left</div>
            <div class="stat-value text-primary" id="countdown">{@countdown}</div>
            <div class="stat-desc">of the first batch</div>
          </div>
          <div class="stat">
            <div class="stat-title">Early access signups</div>
            <div class="stat-value" id="stat-signups">{length(@signups)}</div>
            <div class="stat-desc">people waiting</div>
          </div>
          <div class="stat">
            <div class="stat-title">Ticks so far</div>
            <div class="stat-value" id="stat-ticks">{@ticks}</div>
            <div class="stat-desc">since you arrived</div>
          </div>
        </section>

        <%!-- Signup + activity --%>
        <section id="signup" class="grid gap-8 lg:grid-cols-2">
          <div class="space-y-4">
            <h2 class="text-2xl font-bold tracking-tight">Join the early access list</h2>
            <p class="text-base-content/70">
              We open the first batch in small waves. One email, no spam.
            </p>
            <.form id="signup-form" for={@form} phx-submit="signup" class="space-y-3">
              <JobyKit.CoreComponents.input
                field={@form[:email]}
                type="email"
                label="Email address"
                placeholder="you@example.com"
                phx-debounce="200"
              />
              <JobyKit.CoreComponents.button variant="primary" type="submit">
                Reserve my spot
              </JobyKit.CoreComponents.button>
              <p
                id="signup-error"
                role="alert"
                class={["text-sm text-error", @error == nil && "hidden"]}
              >
                {@error}
              </p>
            </.form>
          </div>

          <div class="space-y-4">
            <h2 class="text-2xl font-bold tracking-tight">Recent signups</h2>
            <ul id="signups" class="space-y-2">
              <li
                :for={email <- @signups}
                class="flex items-center gap-3 rounded-box bg-base-200/60 px-4 py-2 text-sm"
              >
                <JobyKit.CoreComponents.icon name="hero-envelope" class="size-4 text-primary" />
                {email}
              </li>
              <li
                :if={@signups == []}
                class="rounded-box border border-dashed border-base-300 px-4 py-6 text-center text-sm text-base-content/50"
              >
                No signups yet — be the first.
              </li>
            </ul>

            <h3 class="pt-4 text-lg font-semibold tracking-tight">Activity</h3>
            <ul id="activity" class="space-y-1 text-sm text-base-content/70">
              <li
                :for={entry <- @activity}
                id={"activity-#{entry.id}"}
                class="rounded-box bg-base-200/40 px-3 py-2"
              >
                {entry.message}
              </li>
              <li
                :if={@activity == []}
                class="rounded-box border border-dashed border-base-300 px-3 py-4 text-center text-base-content/50"
              >
                All quiet for now.
              </li>
            </ul>
          </div>
        </section>

        <%!-- Feature grid --%>
        <section class="space-y-4">
          <JobyKit.CoreComponents.header level="h2">
            Why Lumen
            <:eyebrow>Features</:eyebrow>
            <:subtitle>
              Six reasons the first batch sold out in nine minutes.
            </:subtitle>
          </JobyKit.CoreComponents.header>
          <BenchappWeb.CompositeComponents.feature_grid features={@features} columns="3" />
        </section>
      </div>
    </Layouts.app>
    """
  end
end

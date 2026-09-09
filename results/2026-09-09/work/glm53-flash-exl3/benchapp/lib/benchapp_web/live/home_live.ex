defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Vela — scheduling that protects your focus.

  Live state drives a 5-second countdown tick, an in-memory newsletter
  signup list, a stats strip, and an activity feed.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval_ms 5_000
  @countdown_start 100
  @max_activity 10

  @email_regex ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Vela",
        countdown: @countdown_start,
        ticks: 0,
        signups: [],
        activity: [],
        form: to_form(%{"email" => ""}, as: :signup),
        error: nil
      )

    socket = if connected?(socket), do: schedule_tick(socket), else: socket

    {:ok, socket}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)
    socket
  end

  @impl true
  def handle_info(:tick, socket) do
    countdown =
      if socket.assigns.countdown <= 1, do: @countdown_start, else: socket.assigns.countdown - 1

    {:noreply,
     socket
     |> assign(countdown: countdown, ticks: socket.assigns.ticks + 1)
     |> log_activity("Countdown ticked — launch window at #{countdown}")
     |> schedule_tick()}
  end

  @impl true
  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    email = String.trim(email)

    cond do
      not valid_email?(email) ->
        {:noreply, assign(socket, error: "Please enter a valid email address.")}

      already_signed_up?(socket.assigns.signups, email) ->
        {:noreply, assign(socket, error: "That address is already on the launch list.")}

      true ->
        {:noreply,
         socket
         |> assign(
           signups: [%{email: email} | socket.assigns.signups],
           error: nil,
           form: to_form(%{"email" => ""}, as: :signup)
         )
         |> log_activity("#{email} joined the launch list")}
    end
  end

  def handle_event("signup", _params, socket) do
    {:noreply, assign(socket, error: "Please enter a valid email address.")}
  end

  defp valid_email?(email),
    do: Regex.match?(@email_regex, email) and String.length(email) <= 254

  defp already_signed_up?(signups, email),
    do: Enum.any?(signups, &(&1.email == email))

  defp log_activity(socket, message) do
    entry = %{id: System.unique_integer([:positive, :monotonic]), message: message}
    assign(socket, activity: Enum.take([entry | socket.assigns.activity], @max_activity))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl space-y-16 px-4 py-12 sm:px-6">
        <section class="relative overflow-hidden rounded-3xl border border-base-300/70 bg-gradient-to-br from-primary/10 via-base-100 to-secondary/10 px-6 py-16 text-center sm:px-12">
          <div
            class="pointer-events-none absolute -top-24 left-1/2 size-72 -translate-x-1/2 rounded-full bg-primary/15 blur-3xl"
            aria-hidden="true"
          >
          </div>
          <div class="relative">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-primary">
              Coming soon
            </p>
            <h1 class="mx-auto mt-4 max-w-2xl text-4xl font-bold leading-tight tracking-tight sm:text-5xl">
              Scheduling that protects your focus
            </h1>
            <p class="mx-auto mt-5 max-w-xl text-base leading-relaxed text-base-content/70 sm:text-lg">
              Vela is a scheduling assistant that reads your calendar, defends your
              deep-work hours, and finds meeting slots everyone can actually make —
              without the back-and-forth.
            </p>
            <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
              <.button navigate={~p"/about"} variant="primary" size="md">
                Why Vela
              </.button>
              <.button href="#signup" variant="soft" size="md">
                Join the launch list
              </.button>
            </div>
          </div>
        </section>

        <section class="space-y-4">
          <div class="flex flex-col items-center gap-2 text-center">
            <.header level="h2">Launch countdown</.header>
            <p class="text-sm text-base-content/65">
              One tick every five seconds, straight from LiveView state.
            </p>
          </div>
          <div class="flex justify-center">
            <div class="flex size-40 flex-col items-center justify-center rounded-full border-4 border-primary/30 bg-base-100 shadow-inner transition-transform duration-500">
              <span id="countdown" class="font-mono text-5xl font-bold tabular-nums text-primary">
                {@countdown}
              </span>
              <span class="mt-1 text-xs uppercase tracking-widest text-base-content/50">
                ticks
              </span>
            </div>
          </div>
        </section>

        <section>
          <div id="stats" class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <CompositeComponents.stat_card
              label="Signups"
              value={to_string(length(@signups))}
              value_id="stat-signups"
              value_class="mt-2 font-mono text-4xl font-bold tabular-nums"
            />
            <CompositeComponents.stat_card
              label="Countdown ticks"
              value={to_string(@ticks)}
              value_id="stat-ticks"
              value_class="mt-2 font-mono text-4xl font-bold tabular-nums"
            />
          </div>
        </section>

        <section class="grid gap-8 lg:grid-cols-2">
          <div class="space-y-4">
            <.header level="h2">
              Join the launch list
              <:subtitle>No spam. One email when we ship.</:subtitle>
            </.header>
            <.form for={@form} id="signup-form" phx-submit="signup" class="space-y-2">
              <div class="flex flex-col gap-2 sm:flex-row">
                <.input
                  field={@form[:email]}
                  type="email"
                  placeholder="you@example.com"
                  aria-label="Email address"
                  class="flex-1"
                />
                <.button type="submit" variant="primary" class="shrink-0">
                  Notify me
                </.button>
              </div>
              <p
                :if={@error}
                id="signup-error"
                role="alert"
                class="text-sm font-medium text-error"
              >
                {@error}
              </p>
            </.form>

            <div :if={@signups != []} class="space-y-2 pt-2">
              <h3 class="text-sm font-semibold uppercase tracking-[0.18em] text-base-content/55">
                Recent signups
              </h3>
              <ul
                id="signups"
                class="menu flex-col gap-1 rounded-2xl border border-base-300/80 bg-base-100 p-2"
              >
                <li :for={signup <- @signups}>
                  <span class="flex items-center gap-2 font-mono text-sm">
                    <.icon name="hero-envelope" class="size-4 text-primary" />
                    {signup.email}
                  </span>
                </li>
              </ul>
            </div>
          </div>

          <div class="space-y-4">
            <.header level="h2">
              Activity
              <:subtitle>Signups and ticks, newest first.</:subtitle>
            </.header>
            <ul id="activity" class="space-y-2">
              <li
                :for={entry <- @activity}
                class="flex items-start gap-2 rounded-xl border border-base-300/60 bg-base-100/60 px-3 py-2 text-sm text-base-content/75"
              >
                <.icon name="hero-pulse" class="mt-0.5 size-4 shrink-0 text-primary/70" />
                <span>{entry.message}</span>
              </li>
              <li
                :if={@activity == []}
                class="rounded-xl border border-dashed border-base-300 px-3 py-4 text-center text-sm text-base-content/50"
              >
                Nothing yet — the first tick lands in five seconds.
              </li>
            </ul>
          </div>
        </section>

        <section class="space-y-6">
          <.header level="h2">
            Built for calm calendars
            <:eyebrow>Features</:eyebrow>
          </.header>

          <CompositeComponents.feature_grid>
            <:feature icon="hero-shield-check" title="Private by default">
              Your calendar never leaves your control. Vela reads availability, never contents.
            </:feature>
            <:feature icon="hero-bolt" title="Zero-config focus holds">
              Defend deep-work hours with one click and Vela politely declines the rest.
            </:feature>
            <:feature icon="hero-clock" title="Timezone aware">
              Every invite lands at the right hour, from Tokyo to Toronto.
            </:feature>
            <:feature icon="hero-users" title="Team load balancing">
              Spread meetings evenly so nobody burns their week on syncs.
            </:feature>
            <:feature icon="hero-sparkles" title="Smart slot finding">
              Propose times that fit everyone's energy, not just everyone's calendar.
            </:feature>
            <:feature icon="hero-inbox-arrow-down" title="Quiet digests">
              One daily summary instead of a hundred notifications.
            </:feature>
          </CompositeComponents.feature_grid>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

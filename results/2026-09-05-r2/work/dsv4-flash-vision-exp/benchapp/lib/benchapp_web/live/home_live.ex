defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Lumen — the landing page for a fictional product-launch platform.

  This single LiveView demonstrates a live countdown, a client-side
  newsletter waitlist, a stats strip, and an activity feed, all tracked
  as live state (no database required).
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @countdown_start 100
  @tick_interval_ms 5_000
  @max_activity 10
  @email_regex ~r/^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/

  @features [
    %{
      icon: "hero-bolt",
      title: "Launch at 60fps",
      copy: "Preview your release experience in real time, with zero lag."
    },
    %{
      icon: "hero-hand-raised",
      title: "Built for waitlists",
      copy: "Collect early access emails the moment interest peaks."
    },
    %{
      icon: "hero-chart-bar",
      title: "Live momentum",
      copy: "Watch signups and ticks roll in as your community wakes up."
    },
    %{
      icon: "hero-bell",
      title: "One-tap reminders",
      copy: "Notify every subscriber the second you go live."
    },
    %{
      icon: "hero-shield-check",
      title: "Privacy first",
      copy: "Subscriber data stays yours — never sold, never shared."
    },
    %{
      icon: "hero-rocket-launch",
      title: "Any platform",
      copy: "Ship to web, mobile, and desktop from a single flow."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    {:ok,
     assign(socket,
       page_title: "Lumen — launch on time",
       countdown: @countdown_start,
       ticks: 0,
       signups: [],
       activity: [],
       next_activity_id: 1,
       signup_form: to_form(%{}, as: :signup),
       signup_error: nil,
       features: @features
     )}
  end

  @impl true
  def handle_info(:tick, socket) do
    countdown = max(socket.assigns.countdown - 1, 0)
    ticks = socket.assigns.ticks + 1

    if countdown > 0 do
      Process.send_after(self(), :tick, @tick_interval_ms)
    end

    {:noreply,
     socket
     |> assign(countdown: countdown, ticks: ticks)
     |> add_activity(:tick, "T-minus #{countdown}s — countdown ticked")}
  end

  @impl true
  def handle_event("signup_change", %{"signup" => signup_params}, socket) do
    {:noreply, assign(socket, signup_form: to_form(signup_params, as: :signup))}
  end

  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    email = email |> to_string() |> String.trim()

    cond do
      not valid_email?(email) ->
        {:noreply, assign(socket, signup_error: "Please enter a valid email address.")}

      email in socket.assigns.signups ->
        {:noreply, assign(socket, signup_error: "That address is already on the list.")}

      true ->
        {:noreply,
         socket
         |> assign(signups: [email | socket.assigns.signups], signup_error: nil)
         |> assign(signup_form: to_form(%{}, as: :signup))
         |> add_activity(:signup, "#{email} joined the waitlist")}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp valid_email?(""), do: false
  defp valid_email?(email), do: Regex.match?(@email_regex, email)

  defp add_activity(socket, kind, text) do
    id = socket.assigns.next_activity_id

    activity =
      [%{id: id, kind: kind, text: text} | socket.assigns.activity] |> Enum.take(@max_activity)

    assign(socket, activity: activity, next_activity_id: id + 1)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <%!-- Hero --%>
      <section class="relative overflow-hidden">
        <div class="pointer-events-none absolute inset-0 bg-gradient-to-br from-primary/15 via-base-200/40 to-base-100">
        </div>
        <div class="relative mx-auto max-w-6xl px-4 py-20 sm:px-6 sm:py-28">
          <div class="max-w-2xl">
            <span class="inline-flex items-center gap-2 rounded-full border border-primary/30 bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
              <span class="size-1.5 rounded-full bg-primary motion-safe:animate-pulse"></span>
              General availability
            </span>
            <h1 class="mt-5 text-4xl font-bold tracking-tight text-base-content sm:text-5xl lg:text-6xl">
              Launch like the future <span class="text-primary">depends on it.</span>
            </h1>
            <p class="mt-5 max-w-xl text-lg leading-relaxed text-base-content/70">
              Lumen is a launch platform that fuses a live countdown, a waitlist, and
              momentum analytics. Reserve your spot below and watch the clock tick.
            </p>
            <div class="mt-8 flex flex-wrap items-center gap-3">
              <.button
                type="button"
                variant="primary"
                size="lg"
                phx-click={JS.focus(to: "#signup-form input[type=email]")}
              >
                Get early access
              </.button>
              <.button navigate={~p"/about"} variant="ghost" size="lg">
                Learn more <.icon name="hero-arrow-right" class="size-4" />
              </.button>
            </div>
          </div>
        </div>
      </section>

      <%!-- Countdown --%>
      <CompositeComponents.section_band>
        <div class="mx-auto max-w-6xl px-4 py-16 text-center sm:px-6">
          <div class="mb-2 text-xs font-medium uppercase tracking-widest text-primary">
            Public launch in
          </div>
          <div class="flex items-center justify-center gap-3">
            <span
              id="countdown"
              class="text-7xl font-extrabold tabular-nums tracking-tight text-base-content sm:text-8xl"
            >
              {@countdown}
            </span>
            <span class="self-end pb-3 text-sm font-medium text-base-content/50">seconds</span>
          </div>
          <p class="mx-auto mt-4 max-w-md text-sm text-base-content/60">
            Live every five seconds — no refresh, no drama.
          </p>
        </div>
      </CompositeComponents.section_band>

      <%!-- Signup --%>
      <section class="border-t border-base-300">
        <div class="mx-auto max-w-3xl px-4 py-16 text-center sm:px-6">
          <h2 class="text-2xl font-bold tracking-tight text-base-content sm:text-3xl">
            Join the waitlist
          </h2>
          <p class="mx-auto mt-3 max-w-md text-base-content/60">
            Drop your email and we'll ping you the moment the lights go on.
          </p>

          <.form
            for={@signup_form}
            id="signup-form"
            class="mx-auto mt-8 flex max-w-xl flex-col gap-3 text-left sm:flex-row sm:items-start"
            phx-change="signup_change"
            phx-submit="signup"
          >
            <.input
              type="email"
              field={@signup_form[:email]}
              label="Email address"
              placeholder="you@example.com"
              class="flex-1"
              autocomplete="email"
              required
            />
            <.button type="submit" variant="primary" class="shrink-0">
              Get early access
            </.button>
          </.form>

          <p :if={@signup_error} id="signup-error" class="mt-3 text-sm font-medium text-error">
            {@signup_error}
          </p>

          <div class="mt-10">
            <h3 class="text-left text-sm font-semibold text-base-content">
              Recent signups
            </h3>
            <ul id="signups" class="mt-4 grid gap-2 text-left">
              <li
                :for={email <- @signups}
                class="flex items-center gap-2 rounded-lg bg-base-200/60 px-3 py-2 text-sm text-base-content/80"
              >
                <span class="flex size-5 items-center justify-center rounded-full bg-success/15 text-success">
                  <.icon name="hero-check" class="size-3" />
                </span>
                {email}
              </li>
            </ul>
          </div>
        </div>
      </section>

      <%!-- Stats strip --%>
      <CompositeComponents.section_band id="stats">
        <div class="mx-auto grid max-w-6xl grid-cols-2 gap-px overflow-hidden border border-base-300 rounded-2xl my-16 px-4 sm:px-6">
          <div class="flex flex-col items-center gap-1 bg-base-100 py-8">
            <span id="stat-signups" class="text-4xl font-extrabold tabular-nums text-primary">
              {length(@signups)}
            </span>
            <span class="text-xs font-medium uppercase tracking-wide text-base-content/50">Signups</span>
          </div>
          <div class="flex flex-col items-center gap-1 bg-base-100 py-8">
            <span id="stat-ticks" class="text-4xl font-extrabold tabular-nums text-primary">
              {@ticks}
            </span>
            <span class="text-xs font-medium uppercase tracking-wide text-base-content/50">Countdown ticks</span>
          </div>
        </div>
      </CompositeComponents.section_band>

      <%!-- Activity feed --%>
      <section class="border-t border-base-300">
        <div class="mx-auto max-w-3xl px-4 py-16 sm:px-6">
          <h2 class="text-2xl font-bold tracking-tight text-base-content sm:text-3xl">
            Live activity
          </h2>
          <ul id="activity" class="mt-8 flex flex-col gap-3">
            <li
              :for={entry <- @activity}
              id={"activity-#{entry.id}"}
              class="flex items-center gap-3 rounded-xl border border-base-300 bg-base-100/70 px-4 py-3 text-sm"
            >
              <span class={[
                "flex size-8 shrink-0 items-center justify-center rounded-full",
                entry.kind == "signup" && "bg-success/15 text-success",
                entry.kind == "tick" && "bg-primary/10 text-primary"
              ]}>
                <.icon
                  name={(entry.kind == "signup" && "hero-user-plus") || "hero-clock"}
                  class="size-4"
                />
              </span>
              <span class="text-base-content/80">{entry.text}</span>
            </li>
          </ul>
          <p :if={@activity == []} class="mt-8 text-sm text-base-content/50">
            Nothing yet — activity will appear here as it happens.
          </p>
        </div>
      </section>

      <%!-- Feature grid --%>
      <CompositeComponents.section_band>
        <div class="mx-auto max-w-6xl px-4 py-16 sm:px-6">
          <div class="mb-10 max-w-2xl">
            <span class="text-xs font-medium uppercase tracking-widest text-primary">Why Lumen</span>
            <h2 class="mt-2 text-2xl font-bold tracking-tight text-base-content sm:text-3xl">
              Everything you need to land big
            </h2>
            <p class="mt-3 text-base-content/60">
              Six reasons teams pick Lumen for their next big launch.
            </p>
          </div>
          <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <CompositeComponents.feature_card
              :for={feature <- @features}
              icon={feature.icon}
              title={feature.title}
            >
              {feature.copy}
            </CompositeComponents.feature_card>
          </div>
        </div>
      </CompositeComponents.section_band>
    </Layouts.app>
    """
  end
end

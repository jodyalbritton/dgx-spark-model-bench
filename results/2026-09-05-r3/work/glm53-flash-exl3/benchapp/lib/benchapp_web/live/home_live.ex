defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Windrose — offline-first trail maps & field notes.

  The beta panel is live: a beacon countdown that starts at 100 and
  steps down every 5 seconds, a waitlist signup form validated in
  memory, a stats strip computed from that state, and an activity feed
  streamed newest-first.
  """

  use BenchappWeb, :live_view

  @tick_interval_ms 5_000
  @starting_countdown 100
  @max_activity 10
  @max_recent_signups 10

  @email_format ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  @features [
    %{
      icon: "hero-map",
      title: "Whole regions, offline",
      text:
        "Download the quad before you lose bars. Tiles, contours, and water sources stay on the device."
    },
    %{
      icon: "hero-pencil-square",
      title: "Field notes that stick",
      text:
        "Pin observations to exact coordinates — a bloom, a washout, a bear print — and find them later."
    },
    %{
      icon: "hero-signal-slash",
      title: "Zero-bars routing",
      text: "Reroute around closures and washouts with a solver that never phones home."
    },
    %{
      icon: "hero-battery-50",
      title: "Gentle on batteries",
      text: "A week of tracking on one charge, even with the screen dimmed to trail-light."
    },
    %{
      icon: "hero-lock-closed",
      title: "Yours, and only yours",
      text: "Tracks and notes never leave the phone unless you export them yourself."
    },
    %{
      icon: "hero-users",
      title: "Pack sharing",
      text: "Trade a trailhead pin with a friend over radio — no signal, no accounts, no fuss."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        page_title: "Windrose — offline-first trail maps",
        countdown: @starting_countdown,
        ticks: 0,
        signups: [],
        signup_emails: MapSet.new(),
        signup_count: 0,
        activity_log: [],
        activity_seq: 0,
        error_message: nil,
        features: @features,
        form: to_form(%{"email" => ""}, as: :signup)
      )
      |> stream(:signups, [])
      |> stream(:activity, [])

    if connected?(socket) do
      Process.send_after(self(), :tick, @tick_interval_ms)
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("request-access", %{"signup" => %{"email" => email}}, socket) do
    email = email |> String.trim() |> String.downcase()

    socket =
      cond do
        not valid_email?(email) ->
          reject_signup(
            socket,
            email,
            "That doesn't look like an email address — try name@domain.com."
          )

        MapSet.member?(socket.assigns.signup_emails, email) ->
          reject_signup(
            socket,
            email,
            "#{email} is already on the list — no need to sign up twice."
          )

        true ->
          accept_signup(socket, email)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    ticks = socket.assigns.ticks + 1
    countdown = max(@starting_countdown - ticks, 0)

    {:noreply,
     socket
     |> assign(ticks: ticks, countdown: countdown)
     |> log_activity(:tick, "Beacon check-in ##{ticks} — grid sync ok")}
  end

  defp valid_email?(email), do: Regex.match?(@email_format, email)

  defp reject_signup(socket, email, message) do
    socket
    |> assign(error_message: message, form: to_form(%{"email" => email}, as: :signup))
  end

  defp accept_signup(socket, email) do
    signup_id = socket.assigns.signup_count + 1
    signups = [%{id: signup_id, email: email} | socket.assigns.signups]
    signup_count = signup_id

    socket
    |> assign(
      signups: signups,
      signup_emails: MapSet.put(socket.assigns.signup_emails, email),
      signup_count: signup_count,
      error_message: nil,
      form: to_form(%{"email" => ""}, as: :signup)
    )
    |> stream(:signups, Enum.take(signups, @max_recent_signups), reset: true)
    |> log_activity(:signup, "#{email} requested beta access")
  end

  defp log_activity(socket, kind, message) do
    seq = socket.assigns.activity_seq + 1
    entries = [%{id: seq, kind: kind, message: message} | socket.assigns.activity_log]

    socket
    |> assign(activity_seq: seq, activity_log: Enum.take(entries, @max_activity))
    |> stream(:activity, Enum.take(entries, @max_activity), reset: true)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl space-y-16 px-4 pb-16 sm:px-6">
        <%!-- Hero --%>
        <section id="hero" class="space-y-8 pt-12 text-center sm:pt-16">
          <div class="space-y-4">
            <span class="badge badge-outline gap-1.5 rounded-full border-primary/40 bg-primary/5 py-3 text-primary">
              <.icon name="hero-beaker" class="size-3.5" /> Private beta · Fall 2026
            </span>
            <h1 class="mx-auto max-w-3xl text-4xl font-bold tracking-tight text-balance sm:text-5xl">
              The map in your pack.
              <span class="block bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                No bars required.
              </span>
            </h1>
            <p class="mx-auto max-w-2xl text-lg leading-relaxed text-base-content/70">
              Windrose keeps whole regions of trail, terrain, and your own field notes on the
              phone in your pocket — so the moment the signal drops is when it starts earning
              its keep.
            </p>
            <div class="flex flex-wrap items-center justify-center gap-3 pt-2">
              <.button variant="primary" href="#signup">
                Request early access <.icon name="hero-arrow-down" class="size-4" />
              </.button>
              <.button variant="ghost" navigate={~p"/about"}>
                How it works <.icon name="hero-arrow-right" class="size-4" />
              </.button>
            </div>
          </div>

          <div class="relative mx-auto max-w-3xl overflow-hidden rounded-box border border-base-300 bg-base-200/60 p-1.5 shadow-xl">
            <div class="rounded-[calc(var(--radius-box)-0.3rem)] bg-base-100 p-4 sm:p-6">
              <svg viewBox="0 0 640 200" class="h-40 w-full text-primary sm:h-48" aria-hidden="true">
                <defs>
                  <pattern id="trail-grid" width="32" height="32" patternUnits="userSpaceOnUse">
                    <path
                      d="M 32 0 L 0 0 0 32"
                      fill="none"
                      stroke="currentColor"
                      stroke-opacity="0.12"
                    />
                  </pattern>
                </defs>
                <rect width="640" height="200" fill="url(#trail-grid)" class="text-base-content" />
                <path
                  d="M 20 170 C 120 150, 140 90, 230 100 S 380 160, 440 90 S 560 30, 620 40"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="3"
                  stroke-linecap="round"
                  stroke-dasharray="2 8"
                />
                <circle cx="20" cy="170" r="7" fill="currentColor" />
                <circle cx="230" cy="100" r="7" fill="currentColor" opacity="0.6" />
                <circle cx="440" cy="90" r="7" fill="currentColor" opacity="0.6" />
                <circle cx="620" cy="40" r="9" fill="currentColor" />
                <circle
                  cx="620"
                  cy="40"
                  r="16"
                  fill="none"
                  stroke="currentColor"
                  stroke-opacity="0.4"
                />
              </svg>
              <p class="mt-3 flex items-center justify-center gap-2 font-mono text-xs text-base-content/50">
                <.icon name="hero-map-pin" class="size-3.5" /> quad 44.01°N · 71.68°W — cached 100%
              </p>
            </div>
          </div>
        </section>

        <%!-- Beta: countdown + signup --%>
        <section id="signup" class="grid gap-6 lg:grid-cols-2">
          <.card class="bg-gradient-to-br from-primary/10 to-base-100">
            <:eyebrow>Private beta</:eyebrow>
            <:title>Early-access keys remaining</:title>
            <div class="space-y-4">
              <p class="text-6xl font-bold tabular-nums tracking-tight text-primary" id="countdown">
                {@countdown}
              </p>
              <progress
                class="progress progress-primary w-full"
                value={@countdown}
                max="100"
              ></progress>
              <p class="text-sm text-base-content/70">
                The beacon pings every five seconds and a key is claimed with each pulse.
              </p>
            </div>
          </.card>

          <.card>
            <:eyebrow>Waitlist</:eyebrow>
            <:title>Request beta access</:title>
            <div class="space-y-4">
              <.form for={@form} id="signup-form" phx-submit="request-access" novalidate>
                <div class="space-y-3">
                  <.input
                    field={@form[:email]}
                    type="email"
                    label="Email"
                    placeholder="you@trailmail.com"
                    input_class="bg-base-100"
                  />
                  <.button variant="primary" class="w-full">
                    Put me on the list <.icon name="hero-paper-airplane" class="size-4" />
                  </.button>
                </div>
              </.form>

              <div
                :if={@error_message}
                id="signup-error"
                role="alert"
                class="flex items-start gap-2 rounded-field border border-error/30 bg-error/10 px-3 py-2 text-sm text-error"
              >
                <.icon name="hero-exclamation-triangle" class="mt-0.5 size-4 shrink-0" />
                <span>{@error_message}</span>
              </div>

              <div class="space-y-2">
                <h3 class="text-xs font-semibold uppercase tracking-widest text-base-content/50">
                  Recent signups
                </h3>
                <ul
                  id="signups"
                  phx-update="stream"
                  class="menu flex-col gap-1 rounded-box bg-base-200/50 p-2"
                >
                  <li
                    id="signups-empty"
                    class="hidden only:block px-2 py-1 text-sm text-base-content/60"
                  >
                    Nobody yet — be the first on the trailhead board.
                  </li>
                  <li :for={{id, signup} <- @streams.signups} id={id} class="rounded-field">
                    <span class="flex items-center gap-2 font-mono text-sm">
                      <.icon name="hero-user-plus" class="size-4 text-primary" />
                      {signup.email}
                    </span>
                  </li>
                </ul>
              </div>
            </div>
          </.card>
        </section>

        <%!-- Stats strip --%>
        <section aria-label="Beta numbers">
          <div
            id="stats"
            class="stats stats-vertical w-full bg-base-200/40 shadow-sm sm:stats-horizontal"
          >
            <div class="stat">
              <div class="stat-figure text-primary">
                <.icon name="hero-inbox-arrow-down" class="size-8" />
              </div>
              <div class="stat-title">Beta requests</div>
              <div class="stat-value" id="stat-signups">{@signup_count}</div>
              <div class="stat-desc">waitlist, this visit</div>
            </div>
            <div class="stat">
              <div class="stat-figure text-secondary">
                <.icon name="hero-signal" class="size-8" />
              </div>
              <div class="stat-title">Beacon ticks</div>
              <div class="stat-value" id="stat-ticks">{@ticks}</div>
              <div class="stat-desc">since you opened the page</div>
            </div>
          </div>
        </section>

        <%!-- Activity feed --%>
        <section class="space-y-4">
          <.header level="h2">
            Live from the trailhead
            <:eyebrow>Activity</:eyebrow>
            <:subtitle>Every beacon pulse and every new request, newest first.</:subtitle>
          </.header>

          <div class="rounded-box border border-base-300 bg-base-100">
            <ul id="activity" phx-update="stream" class="divide-y divide-base-300">
              <li
                id="activity-empty"
                class="hidden only:block px-4 py-6 text-center text-sm text-base-content/60"
              >
                All quiet. The beacon hasn't pulsed yet.
              </li>
              <li
                :for={{id, entry} <- @streams.activity}
                id={id}
                class="flex items-center gap-3 px-4 py-3"
              >
                <span class={[
                  "flex size-8 shrink-0 items-center justify-center rounded-full",
                  entry.kind == :signup && "bg-primary/10 text-primary",
                  entry.kind == :tick && "bg-base-200 text-base-content/60"
                ]}>
                  <.icon
                    name={if entry.kind == :signup, do: "hero-user-plus", else: "hero-signal"}
                    class="size-4"
                  />
                </span>
                <span class="text-sm text-base-content/80">{entry.message}</span>
              </li>
            </ul>
          </div>
        </section>

        <%!-- Feature grid --%>
        <section id="features" class="space-y-4">
          <.header level="h2">
            Built for the places bars don't reach
            <:eyebrow>Features</:eyebrow>
            <:subtitle>
              Six reasons Windrose rides in the top tube bag instead of the junk drawer.
            </:subtitle>
          </.header>

          <.feature_grid features={@features} />
        </section>

        <%!-- Closing CTA --%>
        <section class="rounded-box border border-base-300 bg-base-200/40 px-6 py-10 text-center">
          <h2 class="text-2xl font-semibold tracking-tight">Ready when you are</h2>
          <p class="mx-auto mt-2 max-w-xl text-sm leading-relaxed text-base-content/70">
            Keys are going fast — grab one from the beacon panel and we'll see you at the
            trailhead.
          </p>
          <div class="mt-5">
            <.button variant="primary" href="#signup">Back to the beacon</.button>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

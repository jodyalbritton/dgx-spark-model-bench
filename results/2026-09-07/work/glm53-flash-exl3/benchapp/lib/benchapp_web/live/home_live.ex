defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Fernline — smart moisture sensors for houseplants.

  Live surface: a countdown that ticks down from 100 once every five
  seconds, a newsletter signup with in-memory validation and
  deduplication, a stats strip computed from that live state, and an
  activity feed recording every signup and tick.
  """

  use BenchappWeb, :live_view

  import BenchappWeb.CompositeComponents,
    only: [feature_grid: 1, stat_card: 1, section_heading: 1]

  @countdown_start 100
  @tick_interval_ms 5_000
  @max_activity 10
  @email_regex ~r/^[\w.+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$/

  @features [
    %{
      icon: "hero-beaker",
      title: "Probe-grade sensors",
      body:
        "Capacitive soil probes sampled every sixty seconds, accurate to ±2% volumetric moisture."
    },
    %{
      icon: "hero-wifi",
      title: "Hub, not cloud",
      body:
        "Your plants' history lives on the Fernline hub in your hallway. No account, no telemetry resale."
    },
    %{
      icon: "hero-bell-alert",
      title: "Nudges that matter",
      body:
        "One quiet ping when a plant crosses its thirst threshold — not a dashboard of red badges."
    },
    %{
      icon: "hero-sun",
      title: "Light mapping",
      body:
        "Learn which windowsill is actually 'bright indirect' by tracking a week of real daylight."
    },
    %{
      icon: "hero-battery-charging",
      title: "A year per charge",
      body: "Sensor pucks sip power and top up over USB-C. Swap one in winter without re-pairing."
    },
    %{
      icon: "hero-command-line",
      title: "Open API",
      body:
        "Every reading is exportable. Feed it to Home Assistant, a spreadsheet, or your own weird terminal dashboard."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Home",
        features: @features,
        countdown: @countdown_start,
        ticks: 0,
        signups: [],
        activity: [],
        signup_error: nil,
        form: to_form(%{"email" => ""}, as: :signup)
      )

    if connected?(socket) do
      Process.send_after(self(), :tick, @tick_interval_ms)
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    email = String.trim(email)

    cond do
      not Regex.match?(@email_regex, email) ->
        {:noreply, assign(socket, signup_error: "That doesn't look like an email address.")}

      Enum.member?(socket.assigns.signups, email) ->
        {:noreply, assign(socket, signup_error: "You're already on the list.")}

      true ->
        socket =
          socket
          |> assign(signups: [email | socket.assigns.signups], signup_error: nil)
          |> add_activity(%{kind: :signup, text: "#{email} joined the early-access list"})
          |> assign(form: to_form(%{"email" => ""}, as: :signup))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    countdown =
      if socket.assigns.countdown <= 1, do: @countdown_start, else: socket.assigns.countdown - 1

    socket =
      socket
      |> assign(countdown: countdown, ticks: socket.assigns.ticks + 1)
      |> add_activity(%{kind: :tick, text: "Countdown ticked to #{countdown}"})

    {:noreply, socket}
  end

  defp add_activity(socket, entry) do
    id = "activity-#{System.unique_integer([:positive])}"
    entry = Map.put(entry, :id, id)
    assign(socket, activity: Enum.take([entry | socket.assigns.activity], @max_activity))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl space-y-16 px-4 py-12 sm:px-6">
        <%!-- Hero --%>
        <section class="relative overflow-hidden rounded-3xl border border-base-300 bg-gradient-to-br from-primary/10 via-base-100 to-secondary/10 px-6 py-14 sm:px-10 sm:py-20">
          <div class="max-w-2xl space-y-6">
            <p class="font-mono text-xs uppercase tracking-[0.2em] text-primary">
              Early access · Spring 2027
            </p>
            <h1 class="text-4xl font-black leading-tight tracking-tight sm:text-6xl">
              Your plants are trying to tell you something.
            </h1>
            <p class="text-lg text-base-content/70">
              Fernline is a soil-moisture sensor and hallway hub that turns
              frantic watering guesswork into a single, calm notification —
              and keeps every reading on your own hardware.
            </p>
            <div class="flex flex-wrap items-center gap-3">
              <.button variant="primary" size="lg" href={~p"/about"}>Why Fernline?</.button>
              <.button variant="ghost" size="lg" href={~p"/design"}>Browse the component kit</.button>
            </div>
          </div>
        </section>

        <%!-- Countdown + stats strip --%>
        <section id="stats" class="grid grid-cols-2 gap-4 sm:grid-cols-3" aria-label="Live stats">
          <.stat_card
            value_id="countdown"
            value={to_string(@countdown)}
            label="Seconds left in beta slot"
          />
          <.stat_card
            value_id="stat-signups"
            value={to_string(length(@signups))}
            label="Early-access signups"
            tone="secondary"
          />
          <.stat_card
            value_id="stat-ticks"
            value={to_string(@ticks)}
            label="Ticks since you arrived"
            tone="accent"
            class="col-span-2 sm:col-span-1"
          />
        </section>

        <%!-- Signup --%>
        <section class="grid gap-8 md:grid-cols-2" aria-label="Newsletter signup">
          <div class="space-y-4">
            <.section_heading title="Get notified at launch" />
            <p class="text-base-content/70">
              One email when early access opens. No drip campaign, no
              "last chance" countdowns — the countdown above is purely
              decorative honesty.
            </p>
            <.form for={@form} id="signup-form" phx-submit="signup" class="space-y-2">
              <.input
                field={@form[:email]}
                type="email"
                placeholder="you@example.com"
                label="Email address"
              />
              <.button type="submit" variant="primary">Sign up</.button>
              <p
                :if={@signup_error}
                id="signup-error"
                role="alert"
                class="text-sm font-medium text-error"
              >
                {@signup_error}
              </p>
            </.form>
          </div>

          <div class="space-y-3">
            <h3 class="text-sm font-semibold uppercase tracking-wide text-base-content/60">
              Recent signups
            </h3>
            <ul id="signups" class="space-y-2">
              <li
                :for={email <- @signups}
                class="flex items-center gap-2 rounded-xl border border-base-300 bg-base-100 px-4 py-2 text-sm"
              >
                <.icon name="hero-envelope" class="size-4 text-primary" />
                {email}
              </li>
            </ul>
          </div>
        </section>

        <%!-- Feature grid (composite) --%>
        <.feature_grid
          title="What's in the box"
          subtitle="Six reasons the hallway hub earns its shelf space."
        >
          <:feature :for={f <- @features} icon={f.icon} title={f.title}>
            {f.body}
          </:feature>
        </.feature_grid>

        <%!-- Activity feed --%>
        <section aria-label="Activity feed" class="space-y-3">
          <.section_heading title="Live activity" />
          <ol id="activity" class="space-y-2">
            <li
              :for={entry <- @activity}
              id={entry.id}
              class="flex items-center gap-3 rounded-xl border border-base-300 bg-base-100 px-4 py-2 text-sm text-base-content/80"
            >
              <.icon
                name={if entry.kind == :signup, do: "hero-user-plus", else: "hero-clock"}
                class={[
                  "size-4 shrink-0",
                  entry.kind == :signup && "text-primary",
                  entry.kind == :tick && "text-base-content/40"
                ]}
              />
              <span>{entry.text}</span>
            </li>
          </ol>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

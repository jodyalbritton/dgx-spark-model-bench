defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Tidepool's landing page.

  Three live things share one socket: the launch-window countdown, the
  pilot-list signup form, and the fleet activity log. They share it because
  they are one story — the countdown ticks, the tick is counted and logged,
  and a signup is counted and logged beside it. So `#stats` reads the state
  the page is rendering rather than a cached copy: `#stat-signups` is
  `length(@signups)` and `#stat-ticks` is `@ticks`.

  ## The countdown

  `@tick_interval_ms` is a module attribute, not configuration, and it is
  `5_000` in every environment including `:test`. Tests wait on the real
  interval; nothing here is shortened, parked, or stubbed for them. The
  timer is armed only once `connected?/1`, so a static first render doesn't
  send `:countdown_tick` to a socket nobody is listening to. The countdown
  holds at zero and stops re-arming — the fleet has resynced.

  ## The pilot list

  State lives in these assigns; `Benchapp.LaunchList` holds the rules. A
  rejected address leaves the list untouched and explains itself in
  `#signup-error`, and it is the same message live validation shows, so the
  error does not change shape between a keystroke and a submit.

  ## The activity log

  `@activity_limit` caps the feed at ten entries, newest first, one per
  signup and one per tick. The cap lives in the assign rather than in the
  markup, so `#activity li` is a truthful count.
  """

  use BenchappWeb, :live_view

  alias Benchapp.LaunchList
  alias BenchappWeb.{Chrome, CompositeComponents, LandingComponents}

  @countdown_start 100
  @tick_interval_ms 5_000
  @activity_limit 10

  @features [
    %{
      icon: "hero-signal",
      eyebrow: "Telemetry",
      title: "Buoy-grade sampling",
      body:
        "Turbidity, chlorophyll, and temperature at 1 Hz from every moored node, buffered through dropped links.",
      tag: "1 Hz"
    },
    %{
      icon: "hero-shield-check",
      eyebrow: "Integrity",
      title: "Calibration you can cite",
      body:
        "Every series carries its drift correction and its sensor's service history, so a result survives review.",
      tag: nil
    },
    %{
      icon: "hero-map-pin",
      eyebrow: "Coverage",
      title: "Catchment maps, not dashboards",
      body:
        "Sites group by waterbody on their own. Compare an inlet to its outlet without writing a query.",
      tag: nil
    },
    %{
      icon: "hero-bell",
      eyebrow: "Alerting",
      title: "Thresholds that page a person",
      body:
        "Rolling-window rules escalate to whoever last serviced that node. No alert inbox to tend.",
      tag: "on-call"
    },
    %{
      icon: "hero-cloud-arrow-down",
      eyebrow: "Archive",
      title: "Export the whole record",
      body:
        "Parquet, CSV, or a DOI for the survey itself. The dataset your crew collected leaves with you.",
      tag: nil
    },
    %{
      icon: "hero-users",
      eyebrow: "Sharing",
      title: "Read access for the town",
      body:
        "Publish a waterbody to the public read tier while the raw series stays with the lab that took it.",
      tag: nil
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> Chrome.assign_chrome()
      |> assign(
        page_title: "Tidepool",
        countdown: @countdown_start,
        ticks: 0,
        signups: [],
        activity: [],
        activity_seq: 0,
        signup_form: to_form(%{"email" => ""}, as: "signup"),
        signup_error: nil,
        features: @features
      )

    socket = if connected?(socket), do: schedule_tick(socket), else: socket

    {:ok, socket}
  end

  @impl true
  def handle_info(:countdown_tick, socket) do
    remaining = max(socket.assigns.countdown - 1, 0)
    ticks = socket.assigns.ticks + 1
    seq = socket.assigns.activity_seq + 1

    socket =
      socket
      |> assign(countdown: remaining, ticks: ticks, activity_seq: seq)
      |> push_activity(%{
        id: "tick-#{seq}",
        kind: :tick,
        text: "Sync cycle ##{ticks} closed — #{remaining} windows until the fleet resyncs."
      })

    {:noreply, if(remaining > 0, do: schedule_tick(socket), else: socket)}
  end

  @impl true
  def handle_event("toggle_nav", _params, socket) do
    {:noreply, Chrome.toggle_nav(socket)}
  end

  # Live validation: the same rules as submit, but silent while the field is
  # empty so a half-typed address doesn't read as a mistake.
  def handle_event("validate", %{"signup" => params}, socket) do
    email = Map.get(params, "email", "")

    error =
      case email do
        "" ->
          nil

        email ->
          case LaunchList.check_signup(email, socket.assigns.signups) do
            {:ok, _} -> nil
            {:error, message} -> message
          end
      end

    {:noreply,
     assign(socket, signup_form: to_form(%{"email" => email}, as: "signup"), signup_error: error)}
  end

  def handle_event("signup", %{"signup" => params}, socket) do
    case LaunchList.check_signup(Map.get(params, "email"), socket.assigns.signups) do
      {:ok, email} ->
        seq = socket.assigns.activity_seq + 1

        {:noreply,
         socket
         |> assign(activity_seq: seq, signups: [email | socket.assigns.signups])
         |> push_activity(%{
           id: "signup-#{seq}",
           kind: :signup,
           text: "#{email} joined the pilot list."
         })
         |> assign(signup_form: to_form(%{"email" => ""}, as: "signup"), signup_error: nil)}

      {:error, message} ->
        {:noreply,
         assign(socket, signup_error: message, signup_form: to_form(params, as: "signup"))}
    end
  end

  # `#theme-toggle` owns the theme. `<html data-theme>` lives outside the
  # LiveView tree, so `assets/js/app.js` applies the flip on click — before
  # paint, persisted to localStorage, exactly as the kit's own theme control
  # does. Answering the event here is still deliberate: the control is a
  # LiveView event target, so `Phoenix.LiveViewTest` can drive it like any
  # other one.
  def handle_event("toggle_theme", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp schedule_tick(socket) do
    Process.send_after(self(), :countdown_tick, @tick_interval_ms)
    socket
  end

  defp push_activity(socket, entry) do
    assign(socket, :activity, Enum.take([entry | socket.assigns.activity], @activity_limit))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home" nav_open={@nav_open}>
      <div id="hero" class="relative overflow-hidden border-b border-base-300/60">
        <div class="pointer-events-none absolute inset-0 bg-gradient-to-br from-primary/15 via-transparent to-secondary/10" />
        <div class="pointer-events-none absolute -right-24 -top-24 size-72 rounded-full bg-primary/10 blur-3xl" />

        <div class="relative mx-auto grid max-w-6xl items-center gap-12 px-4 py-16 sm:px-6 lg:grid-cols-[1.05fr_0.95fr] lg:py-24">
          <div class="space-y-7">
            <div class="flex flex-wrap items-center gap-2">
              <.badge tone="ok" variant="solid" size="sm">Cohort 12 open</.badge>
              <.badge tone="neutral" variant="outline" size="sm">
                <span class="flex items-center gap-1.5">
                  <span class="size-1.5 animate-pulse rounded-full bg-current" /> fleet online
                </span>
              </.badge>
            </div>

            <h1 class="text-4xl font-semibold leading-[1.05] tracking-tight text-base-content sm:text-5xl lg:text-6xl">
              Know what is in the water
              <span class="block text-primary">before anyone wades in.</span>
            </h1>

            <p class="max-w-xl text-lg leading-relaxed text-base-content/70">
              Tidepool puts buoy-grade telemetry within reach of the labs,
              councils, and volunteer crews who actually walk the shoreline —
              with the calibration record to prove it.
            </p>

            <div class="flex flex-wrap items-center gap-3">
              <.button variant="primary" size="lg" href="#signup-form">
                Join the pilot list <.icon name="hero-arrow-down" class="size-4" />
              </.button>
              <.button variant="neutral" size="lg" navigate={~p"/about"}>How it works</.button>
            </div>

            <p class="flex items-center gap-2 text-sm text-base-content/55">
              <.icon name="hero-check-circle" class="size-4 shrink-0 text-success" />
              Six watersheds reporting now · no hardware deposit
            </p>
          </div>

          <div class="relative rounded-3xl border border-base-300 bg-base-100/95 p-6 shadow-xl shadow-base-300/40 backdrop-blur">
            <div class="flex items-start justify-between gap-4">
              <div>
                <.eyebrow>Next fleet resync</.eyebrow>
                <p class="mt-1 text-sm text-base-content/60">
                  Windows left before every node re-reads its calibration curve.
                </p>
              </div>
              <span class="flex size-10 shrink-0 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                <.icon name="hero-clock" class="size-5" />
              </span>
            </div>

            <div class="mt-6 flex items-end gap-3">
              <p
                id="countdown"
                class="font-mono text-6xl font-semibold leading-none tabular-nums tracking-tight text-base-content"
              >
                {@countdown}
              </p>
              <span class="pb-1 text-sm text-base-content/55">windows</span>
            </div>

            <div class="mt-4 h-1.5 overflow-hidden rounded-full bg-base-200">
              <div
                class="h-full rounded-full bg-primary transition-all duration-700 ease-out"
                style={"width: #{@countdown}%"}
              />
            </div>

            <div class="mt-6 space-y-2 border-t border-base-300/70 pt-4 text-sm text-base-content/65">
              <p class="flex items-center justify-between gap-4">
                <span>Sync cycles this session</span>
                <span class="font-mono tabular-nums text-base-content">{@ticks}</span>
              </p>
              <p class="flex items-center justify-between gap-4">
                <span>On the pilot list</span>
                <span class="font-mono tabular-nums text-base-content">{length(@signups)}</span>
              </p>
            </div>
          </div>
        </div>
      </div>

      <div class="mx-auto max-w-6xl space-y-16 px-4 py-14 sm:px-6">
        <section id="stats" aria-label="Live figures" class="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <CompositeComponents.stat_readout
            icon="hero-envelope"
            label="Pilot signups"
            hint="listed newest first"
            value={length(@signups)}
            value_id="stat-signups"
          />
          <CompositeComponents.stat_readout
            icon="hero-arrow-path"
            label="Countdown ticks"
            hint="one every five seconds"
            value={@ticks}
            value_id="stat-ticks"
            pulse
          />
          <CompositeComponents.stat_readout
            icon="hero-water"
            label="Watersheds reporting"
            hint="public read tier"
            value={6}
          />
          <CompositeComponents.stat_readout
            icon="hero-bolt"
            label="Samples per second"
            hint="across all moored nodes"
            value={284}
          />
        </section>

        <section class="space-y-5">
          <.header level="h2" size="page">
            Built for the shoreline, not the server room
            <:eyebrow>What Tidepool does</:eyebrow>
            <:subtitle>
              Six capabilities carry the whole product. These tiles are one
              composite — <code class="font-mono text-xs">feature_grid</code>
              —
              registered on
              <.link navigate={~p"/custom-designs"} class="link link-primary">the components page</.link>
              and previewed there with sample data.
            </:subtitle>
          </.header>

          <CompositeComponents.feature_grid items={@features} columns="3" id="feature-grid" />
        </section>

        <section class="grid gap-6 lg:grid-cols-[0.95fr_1.05fr]">
          <.card variant="elevated" body_class="gap-4">
            <:eyebrow>Pilot programme</:eyebrow>
            <:title>Join cohort 12</:title>
            <p class="text-sm leading-relaxed text-base-content/70">
              Twelve labs get the first fleet windows. Leave an address and we
              hold a place for your waterbody — one address per lab, and a
              repeat is politely refused.
            </p>

            <.form
              for={@signup_form}
              id="signup-form"
              phx-submit="signup"
              phx-change="validate"
              class="flex items-start gap-2"
            >
              <.input
                field={@signup_form[:email]}
                type="email"
                class="min-w-0 flex-1"
                placeholder="lab@example.org"
                autocomplete="email"
                aria-label="Email address"
                aria-describedby="signup-error"
              />
              <.button type="submit" variant="primary" class="mt-0.5 shrink-0">
                Join
              </.button>
            </.form>

            <p
              :if={@signup_error}
              id="signup-error"
              role="alert"
              aria-live="polite"
              class="flex items-center gap-2 text-sm font-medium text-error"
            >
              <.icon name="hero-exclamation-circle" class="size-4 shrink-0" />
              {@signup_error}
            </p>

            <div class="space-y-2 border-t border-base-300/70 pt-4">
              <.eyebrow>Recent signups</.eyebrow>
              <ul id="signups" class="space-y-1.5 text-sm">
                <li
                  :for={email <- @signups}
                  key={email}
                  class="flex items-center gap-2 text-base-content/80"
                >
                  <.icon name="hero-check" class="size-4 shrink-0 text-success" />
                  <span class="break-all">{email}</span>
                </li>
              </ul>
              <p :if={@signups == []} class="text-sm text-base-content/45">
                Nobody yet — be the first shoreline on the list.
              </p>
            </div>
          </.card>

          <.card variant="ghost" body_class="gap-4">
            <:eyebrow>Fleet log</:eyebrow>
            <:title>Activity</:title>
            <p class="text-sm text-base-content/60">
              Every signup and every countdown tick, newest first, last ten kept.
            </p>

            <div id="activity-panel" class="max-h-80 overflow-y-auto pr-1">
              <LandingComponents.activity_feed id="activity" entries={@activity} />
              <CompositeComponents.empty_state
                :if={@activity == []}
                icon="hero-radio"
                title="Waiting on the first cycle"
              >
                The log fills as the countdown runs and addresses arrive.
              </CompositeComponents.empty_state>
            </div>
          </.card>
        </section>

        <section class="flex flex-col items-center gap-5 rounded-3xl border border-base-300/70 bg-gradient-to-br from-base-200/70 to-base-100 px-6 py-12 text-center sm:px-10">
          <div class="max-w-2xl space-y-3">
            <.eyebrow>Standing by</.eyebrow>
            <h2 class="text-3xl font-semibold leading-tight tracking-tight">
              Six watersheds, one calibration standard
            </h2>
            <p class="text-base-content/70">
              Tidepool runs on the same record your regulator asks for. Read how
              the fleet, the numbers, and the people behind both are kept honest.
            </p>
          </div>
          <.button variant="primary" navigate={~p"/about"}>Read the about page</.button>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

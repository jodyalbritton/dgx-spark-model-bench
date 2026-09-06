defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The Lodestar landing page: hero, live launch countdown, crew-manifest
  signup, telemetry stats, activity feed, and the feature grid.

  All state is per-connection and in-memory — `Benchapp.Crew` holds the
  policy, this module keeps the timers and the assigns. Two things are
  worth knowing before editing:

    * the countdown is driven by a `Process.send_after/3` beat
      (`@tick_interval_ms`), and every number on the page derives from
      `@count` and `@ticks` rather than being stored twice;
    * `?tick_ms=` shortens the beat for tests. Nothing in the UI links to
      it; ordinary traffic always gets the five-second default.
  """

  use BenchappWeb, :live_view

  alias Benchapp.Crew
  alias BenchappWeb.CompositeComponents

  @start_count 100
  @tick_interval_ms 5_000
  @activity_limit 10

  @beat_notes [
    "all subsystems nominal",
    "range is clear, telemetry hot",
    "fuel transfer complete",
    "weather window holding",
    "ground crew confirms go"
  ]

  @hero_facts [
    %{value: "412", label: "teams aboard"},
    %{value: "1.4M", label: "beats / day"},
    %{value: "99.4%", label: "on-window rate"}
  ]

  @features [
    %{
      tag: "01",
      icon: "hero-clock",
      title: "Launch windows, not crontabs",
      body:
        "Give every pipeline a window with a hard boundary. Late inputs fail the go/no-go instead of shipping quietly at 03:14."
    },
    %{
      tag: "02",
      icon: "hero-shield-check",
      title: "Go / no-go by contract",
      tone: "primary",
      body:
        "Freshness, row counts, and schema checks are gates, not dashboards. A pipeline that cannot prove it is ready does not launch."
    },
    %{
      tag: "03",
      icon: "hero-signal",
      title: "One beat of telemetry",
      body:
        "Every beat lands in a single append-only stream. Rebuild last Tuesday's state from the log instead of from three schedulers."
    },
    %{
      tag: "04",
      icon: "hero-hand-raised",
      title: "Holds everyone can see",
      body:
        "Anyone on the team can hold a launch, and the reason sits beside the run for as long as the run exists."
    },
    %{
      tag: "05",
      icon: "hero-circle-stack",
      title: "Rideshare for shared steps",
      body:
        "Models several teams depend on launch once and fan out. Nobody pays for the same aggregation twice."
    },
    %{
      tag: "06",
      icon: "hero-bell-alert",
      title: "Alarms with a flight plan",
      body:
        "Alerts arrive with the checklist attached: what failed, which downstream windows slip, and the one button that retries."
    }
  ]

  @flight_plan [
    %{
      title: "Declare the window",
      detail:
        "Point Lodestar at a warehouse and a schedule. It infers the DAG and proposes windows from your upstream arrival history."
    },
    %{
      title: "Sign the go/no-go",
      detail:
        "Gates are code-reviewed like any other change. A green board means every consumer of the model agreed to the contract."
    },
    %{
      title: "Read the log, not the vibes",
      detail:
        "Beats, holds, and launches land in one stream you can query from the CLI or subscribe to over webhook."
    }
  ]

  @doc """
  The beat interval in milliseconds. Five seconds for anything a person
  loads; `mount/3` accepts `?tick_ms=` so tests can drive a faster board.
  """
  def tick_interval_ms, do: @tick_interval_ms

  @impl true
  def mount(params, _session, socket) do    tick_ms = tick_interval(params)

    if connected?(socket), do: schedule_beat(tick_ms)

    {:ok,
     assign(socket,
       page_title: "Launch control for data teams",
       count: @start_count,
       ticks: 0,
       tick_ms: tick_ms,
       beat_label: beat_label(tick_ms),
       signups: [],
       signup_count: 0,
       activity: [],
       signup_error: nil,
       form: to_form(Crew.change_signup()),
       features: @features,
       flight_plan: @flight_plan
     )}
  end

  @impl true
  def handle_event("validate", %{"signup" => params}, socket) do
    changeset = Crew.change_signup(params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset))
     |> assign(signup_error: nil)}
  end

  def handle_event("join_manifest", %{"signup" => params}, socket) do
    case Crew.subscribe(socket.assigns.signups, params["email"]) do
      {:ok, entry, entries} ->
        {:noreply,
         socket
         |> assign(
           signups: entries,
           signup_count: length(entries),
           signup_error: nil,
           form: to_form(Crew.change_signup())
         )
         |> log(%{
           kind: "signup",
           icon: "hero-at-symbol",
           title: entry.email,
           detail: "cleared the manifest · seat #{entry.seq}",
           tone: "ok"
         })}

      {:error, :duplicate} ->
        {:noreply,
         socket
         |> assign(form: to_form(Crew.change_signup(params)))
         |> assign(
           signup_error: "That address is already on the manifest. Check your inbox."
         )}

      {:error, :invalid} ->
        changeset = Crew.change_signup(params)

        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> assign(
           signup_error:
             Crew.error_message(changeset) || "Enter a valid email address to join the manifest."
         )}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def handle_info(:beat, %{assigns: %{count: count}} = socket) when count <= 0 do
    {:noreply, socket}
  end

  def handle_info(:beat, socket) do
    count = socket.assigns.count - 1
    ticks = socket.assigns.ticks + 1

    if count > 0, do: schedule_beat(socket.assigns.tick_ms)

    {:noreply,
     socket
     |> assign(count: count, ticks: ticks)
     |> log(%{
       kind: "beat",
       icon: "hero-clock",
       title: "T-#{count} · beat logged",
       detail: Enum.at(@beat_notes, rem(ticks - 1, length(@beat_notes))),
       tone: if(count <= 10, do: "primary", else: "neutral")
     })}
  end

  defp schedule_beat(interval_ms), do: Process.send_after(self(), :beat, interval_ms)

  # One place builds activity entries, so every producer — a signup, a beat —
  # yields the same shape and the cap lives here rather than in the template.
  defp log(socket, attrs) do
    entry =
      attrs
      |> Map.put(:id, "activity-#{System.unique_integer([:positive, :monotonic])}")
      |> Map.put(:at, Time.utc_now())

    activity = Enum.take([entry | socket.assigns.activity], @activity_limit)

    assign(socket, activity: activity)
  end

  defp tick_interval(%{"tick_ms" => value}) do
    case Integer.parse(to_string(value)) do
      {ms, _} when ms >= 50 and ms <= 60_000 -> ms
      _ -> @tick_interval_ms
    end
  end

  defp tick_interval(_params), do: @tick_interval_ms

  defp beat_label(ms) when rem(ms, 1000) == 0, do: "#{div(ms, 1000)}s"
  defp beat_label(ms), do: "#{ms}ms"

  defp stamp(%Time{} = time), do: Calendar.strftime(time, "%H:%M:%S")

  defp progress_width(count), do: "#{Float.round(count / @start_count * 100, 1)}%"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div id="home-page" class="mx-auto w-full max-w-6xl px-4 pb-20 sm:px-6">
        <.hero
          count={@count}
          ticks={@ticks}
          beat_label={@beat_label}
          signup_count={@signup_count}
          progress={progress_width(@count)}
        />

        <.launch_board
          signup_count={@signup_count}
          ticks={@ticks}
          count={@count}
          signups={@signups}
          activity={@activity}
          form={@form}
          signup_error={@signup_error}
        />

        <section class="mt-20 space-y-6">
          <.header level="h2" id="features-heading">
            What a launch-ready pipeline looks like
            <:eyebrow>Capabilities · &lt;.feature_card&gt;</:eyebrow>
            <:subtitle>
              Six panels, one composite: the grid below is
              <code class="font-mono text-xs">CompositeComponents.feature_card</code>
              repeated, so the card on this page and the card on the component
              page are the same contract.
            </:subtitle>
          </.header>

          <CompositeComponents.card_grid id="feature-grid">
            <CompositeComponents.feature_card
              :for={feature <- @features}
              tag={feature.tag}
              icon={feature.icon}
              title={feature.title}
              tone={Map.get(feature, :tone, "neutral")}
            >
              {feature.body}
            </CompositeComponents.feature_card>
          </CompositeComponents.card_grid>
        </section>

        <section class="mt-20 space-y-6">
          <.header level="h2" id="plan-heading">
            Three moves to a schedule you can defend
            <:eyebrow>Flight plan · &lt;.list&gt;</:eyebrow>
          </.header>

          <div class="grid gap-4 lg:grid-cols-[1.1fr_0.9fr]">
            <.card class="justify-center">
              <:eyebrow>Sequence</:eyebrow>
              <:title>Boarding procedure</:title>
              <.list>
                <:item :for={step <- @flight_plan} title={step.title}>
                  {step.detail}
                </:item>
              </.list>
            </.card>

            <.card variant="elevated" prose class="justify-center">
              <:eyebrow>Cohort 7</:eyebrow>
              <:title>Who is already aboard</:title>
              <p>
                412 data teams run their critical path on a launch window.
                Twelve joined this week, and every one of them is on a
                manifest like this one.
              </p>
              <:actions>
                <.button navigate={~p"/about"} size="sm">
                  Read the mission brief
                  <.icon name="hero-arrow-right" class="size-4" />
                </.button>
              </:actions>
            </.card>
          </div>
        </section>

        <section class="mt-20">
          <div class="launch-grid relative overflow-hidden rounded-box border border-primary/30 bg-primary/5 px-6 py-12 text-center sm:px-12">
            <div class="relative space-y-4">
              <.eyebrow class="font-mono">Final call</.eyebrow>
              <h2 id="join-heading" class="mx-auto max-w-2xl text-2xl font-semibold leading-tight tracking-tight sm:text-3xl">
                Put the next launch on the board
              </h2>
              <p class="mx-auto max-w-xl text-sm leading-relaxed text-base-content/70">
                The manifest closes when the countdown reaches zero. Leave an
                address and the board itself will tell you when the seats are
                gone.
              </p>
              <div class="flex flex-wrap items-center justify-center gap-3 pt-2">
                <.button variant="primary" href="#signup-form">
                  Join the manifest
                </.button>
                <.button variant="ghost" navigate={~p"/about"}>
                  About Lodestar
                </.button>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  # ------------------------------------------------------------------ hero

  attr :count, :integer, required: true
  attr :ticks, :integer, required: true
  attr :beat_label, :string, required: true
  attr :signup_count, :integer, required: true
  attr :progress, :string, required: true

  attr :facts, :list,
    default: @hero_facts,
    doc: "Proof-points under the hero: `%{value:, label:}`."

  defp hero(assigns) do
    ~H"""
    <section class="grid gap-10 pt-14 pb-4 lg:grid-cols-[1.15fr_0.85fr] lg:items-center lg:pt-20">
      <div class="hero-rise space-y-6">
        <div class="inline-flex items-center gap-2 rounded-full border border-primary/30 bg-primary/5 px-3 py-1">
          <span class="relative flex size-2">
            <span class="absolute inline-flex size-full animate-ping rounded-full bg-primary opacity-60" />
            <span class="relative inline-flex size-2 rounded-full bg-primary" />
          </span>
          <span class="font-mono text-[0.7rem] uppercase tracking-[0.2em] text-primary">
            Cohort 7 · boarding
          </span>
        </div>

        <h1 class="text-4xl font-semibold leading-[1.05] tracking-tight sm:text-5xl lg:text-6xl">
          Put your data pipelines
          <span class="text-primary">on a launch schedule.</span>
        </h1>

        <p class="max-w-xl text-base leading-relaxed text-base-content/70">
          Lodestar replaces cron sprawl with flight plans: a window with a hard
          edge, a go/no-go the whole team signs, a hold anyone can see, and
          telemetry you can read at 3am without opening six tabs.
        </p>

        <div class="flex flex-wrap items-center gap-3 pt-1">
          <.button variant="primary" size="lg" href="#signup-form">
            Join the crew manifest
            <.icon name="hero-arrow-right" class="size-4" />
          </.button>
          <.button variant="ghost" size="lg" navigate={~p"/about"}>
            How it works
          </.button>
        </div>

        <dl class="flex flex-wrap items-center gap-x-8 gap-y-3 pt-3 text-sm">
          <div :for={fact <- @facts} class="flex items-baseline gap-2">
            <dt class="font-mono text-lg font-semibold tabular-nums">{fact.value}</dt>
            <dd class="text-base-content/60">{fact.label}</dd>
          </div>
        </dl>
      </div>

      <div class="launch-grid relative rounded-box border border-base-300 bg-base-200/50 p-6">
        <div class="relative space-y-5">
          <div class="flex items-center justify-between">
            <.eyebrow class="font-mono">Window · LST-07</.eyebrow>
            <.badge tone={if(@count <= 10, do: "warn", else: "ok")} variant="outline">
              {if(@count <= 10, do: "Terminal count", else: "Go for launch")}
            </.badge>
          </div>

          <div role="status" aria-live="polite">
            <p class="text-xs uppercase tracking-[0.2em] text-base-content/50">
              Manifest closes in
            </p>
            <p class="mt-2 flex items-baseline gap-2">
              <span id="countdown" class="font-mono text-7xl font-semibold leading-none tabular-nums text-base-content sm:text-8xl">{@count}</span>
              <span class="font-mono text-xs uppercase tracking-[0.2em] text-base-content/45">
                beats
              </span>
            </p>
          </div>

          <div class="space-y-2">
            <div class="h-1.5 w-full overflow-hidden rounded-full bg-base-300">
              <div
                class="h-full rounded-full bg-primary transition-all duration-700 ease-out"
                style={"width: #{@progress}"}
              />
            </div>
            <p class="font-mono text-[0.7rem] text-base-content/50">
              one beat = {@beat_label} · {@ticks} logged so far
            </p>
          </div>

          <div class="flex items-end justify-between gap-3 border-t border-base-300 pt-4">
            <CompositeComponents.stat_tile
              size="sm"
              value={@signup_count}
              label="Aboard"
              caption="this window"
            />
            <CompositeComponents.stat_tile
              size="sm"
              value={max(0, 25 - @signup_count)}
              label="Seats left"
              caption="of 25"
              class="items-end text-right"
            />
          </div>
        </div>
      </div>
    </section>
    """
  end

  # ------------------------------------------------- stats · signup · feed

  attr :signup_count, :integer, required: true
  attr :ticks, :integer, required: true
  attr :count, :integer, required: true
  attr :signups, :list, required: true
  attr :activity, :list, required: true
  attr :form, :any, required: true
  attr :signup_error, :string, default: nil

  defp launch_board(assigns) do
    ~H"""
    <section class="space-y-6">
      <div
        id="stats"
        role="group"
        aria-label="Live launch telemetry"
        class="grid divide-y divide-base-300 rounded-box border border-base-300 bg-base-100 sm:grid-cols-2 sm:divide-x lg:grid-cols-4 lg:divide-y-0"
      >
        <CompositeComponents.stat_tile
          id="stat-signups"
          value={@signup_count}
          label="Crew manifest"
          unit="aboard"
          caption="Signups accepted this session"
          highlight
        />
        <CompositeComponents.stat_tile
          id="stat-ticks"
          value={@ticks}
          label="Beats logged"
          unit="ticks"
          caption="One every five seconds"
        />
        <CompositeComponents.stat_tile
          id="stat-beats"
          value={@count}
          label="Beats remaining"
          unit="t-minus"
          caption="Manifest closes at zero"
        />
        <CompositeComponents.stat_tile
          id="stat-windows"
          value="34"
          label="Windows / week"
          unit="sched"
          caption="Median per workspace"
        />
      </div>

      <div class="grid gap-6 lg:grid-cols-[1.05fr_0.95fr]">
        <.card variant="elevated" prose body_class="gap-4">
          <:eyebrow>Crew manifest · &lt;.input&gt;</:eyebrow>
          <:title>Board the next launch</:title>
          <p>
            One address per seat. We send the boarding pass and nothing else —
            this demo holds the manifest in process memory.
          </p>

          <%!-- `novalidate` keeps the browser's constraint bubble out of the
               way: `#signup-error` is the one place an address gets refused,
               so a malformed address has to reach the server to be refused. --%>
          <.form
            id="signup-form"
            for={@form}
            novalidate
            phx-change="validate"
            phx-submit="join_manifest"
            class="flex flex-col gap-3 sm:flex-row sm:items-start"
          >
            <.input
              field={@form[:email]}
              type="email"
              class="flex-1"
              input_class="font-mono text-sm"
              placeholder="you@flightdeck.dev"
              autocomplete="email"
              aria-label="Email address"
              aria-describedby={@signup_error && "signup-error"}
            />
            <.button id="signup-submit" type="submit" variant="primary" class="w-full sm:w-auto">
              Board
              <.icon name="hero-paper-airplane" class="size-4" />
            </.button>
          </.form>

          <p
            :if={@signup_error}
            id="signup-error"
            role="alert"
            class="rounded-field border border-error/40 bg-error/10 px-3 py-2 text-sm text-error"
          >
            {@signup_error}
          </p>

          <div class="space-y-2 pt-1">
            <div class="flex items-center justify-between">
              <.eyebrow class="font-mono">Recent signups</.eyebrow>
              <span class="font-mono text-[0.7rem] text-base-content/40">
                {@signup_count} total
              </span>
            </div>

            <ul
              id="signups"
              class={[
                "divide-y divide-base-300 rounded-box border border-base-300 bg-base-200/40",
                @signups == [] && "hidden"
              ]}
            >
              <CompositeComponents.feed_row
                :for={signup <- @signups}
                icon="hero-at-symbol"
                tone="ok"
                title={signup.email}
                detail={"seat #{signup.seq} · cleared manifest"}
                stamp={stamp(signup.at)}
              />
            </ul>

            <CompositeComponents.empty_state
              :if={@signups == []}
              icon="hero-at-symbol"
              title="No seats filled yet"
            >
              Be the first name on this launch's manifest.
            </CompositeComponents.empty_state>
          </div>
        </.card>

        <.card variant="elevated" prose body_class="gap-4">
          <:eyebrow>Activity · live feed</:eyebrow>
          <:title>Flight log</:title>
          <p>
            Every beat and every boarding lands here, newest first, ten rows
            deep. It is the same stream the CLI tails.
          </p>

          <ul
            id="activity"
            class={[
              "divide-y divide-base-300 rounded-box border border-base-300 bg-base-200/40",
              @activity == [] && "hidden"
            ]}
          >
            <CompositeComponents.feed_row
              :for={entry <- @activity}
              icon={entry.icon}
              tone={entry.tone}
              title={entry.title}
              detail={entry.detail}
              stamp={stamp(entry.at)}
            />
          </ul>

          <CompositeComponents.empty_state
            :if={@activity == []}
            icon="hero-clock"
            title="Awaiting the first beat"
          >
            The log opens on the next five-second tick.
          </CompositeComponents.empty_state>
        </.card>
      </div>
    </section>
    """
  end
end

defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Cadence landing page.

  Sections: hero, live beta countdown, newsletter signup, stats strip,
  activity feed, and the feature grid built from this app's
  `feature_card` composite (previewed at `/custom-designs`).

  Everything is per-session and in-memory:

    * `countdown` — steps down from `Benchapp.Launch.countdown_start/0`
      once every 5 seconds
    * `ticks` — how many countdown steps have fired so far
    * `signups` — accepted newsletter addresses, newest first
    * `:activity` stream — one entry per signup and per tick, newest
      first, capped at `@activity_limit`
  """
  use BenchappWeb, :live_view

  alias Benchapp.Launch
  alias BenchappWeb.CompositeComponents

  @activity_limit 10

  # Five seconds in dev, prod, and the browser. The test suite raises it
  # so tests drive ticks by hand instead of racing a timer.
  defp tick_interval, do: Application.get_env(:benchapp, :tick_interval_ms, 5_000)

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        page_title: "Cadence — ship on Friday, sleep on Saturday",
        features: features(),
        activity_limit: @activity_limit,
        countdown: Launch.countdown_start(),
        ticks: 0,
        signups: [],
        activity_entries: [],
        form: to_form(Launch.signup_changeset()),
        error: nil
      )
      |> stream(:activity, [])

    if connected?(socket), do: Process.send_after(self(), :tick, tick_interval())

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"signup" => params}, socket) do
    {:noreply, assign(socket, :form, to_form(Launch.signup_changeset(params)))}
  end

  def handle_event("signup", %{"signup" => params}, socket) do
    taken = Enum.map(socket.assigns.signups, & &1.email)

    case Launch.register(params, taken) do
      {:ok, signup} ->
        socket =
          socket
          |> update(:signups, &[signup | &1])
          |> push_activity(:signup, "New signup · #{signup.email}")
          |> assign(form: to_form(Launch.signup_changeset()), error: nil)

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:error, Launch.error_message(changeset))}
    end
  end

  @impl true
  def handle_info(:tick, %{assigns: %{countdown: 0}} = socket) do
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, tick_interval())
    next_tick = socket.assigns.ticks + 1

    {:noreply,
     socket
     |> update(:countdown, &(&1 - 1))
     |> assign(:ticks, next_tick)
     |> push_activity(:tick, "Countdown step ##{next_tick} · one wave closed")}
  end

  defp push_activity(socket, kind, text) do
    entry = %{id: "#{kind}-#{System.unique_integer([:positive])}", kind: kind, text: text}
    socket = stream(socket, :activity, [entry], at: 0)

    {keep, drop} = [entry | socket.assigns.activity_entries] |> Enum.split(@activity_limit)

    socket =
      Enum.reduce(drop, socket, fn dropped, acc -> stream_delete(acc, :activity, dropped) end)

    assign(socket, :activity_entries, keep)
  end

  @features [
    %{
      icon: "hero-eye",
      title: "One rollup for every repo",
      body:
        "Cadence reads commits, PRs, and releases across your org, then writes the changelog nobody has time to write."
    },
    %{
      icon: "hero-shield-check",
      title: "Risk you can see",
      body:
        "Every release gets a blast-radius score from the files it touches and how often those files break."
    },
    %{
      icon: "hero-bell",
      title: "Pings that respect you",
      body:
        "One digest per channel, and only when something shipped that your team actually owns."
    },
    %{
      icon: "hero-chart-bar",
      title: "Cadence metrics",
      body:
        "Deploy frequency, lead time, and rollback rate per team — built from events you already emit."
    },
    %{
      icon: "hero-code-bracket",
      title: "An API for the boring parts",
      body:
        "REST and webhooks for releases, notes, and risk. Script the release ritual once, then forget it."
    },
    %{
      icon: "hero-server-stack",
      title: "Runs where you run",
      body:
        "Managed cloud or a single self-hosted container. Your git tokens never leave your network."
    }
  ]

  defp features, do: @features

  # The strip's markup appears once; only the two live tiles carry ids.
  defp stat_tiles(signups, ticks, countdown) do
    [
      %{
        label: "Signups",
        id: "stat-signups",
        value: length(signups),
        desc: "accepted by this form",
        accent: true
      },
      %{
        label: "Ticks",
        id: "stat-ticks",
        value: ticks,
        desc: "countdown steps so far",
        accent: false
      },
      %{
        label: "Waves left",
        id: nil,
        value: countdown,
        desc: "before the gate shuts",
        accent: false
      },
      %{
        label: "Cadence",
        id: nil,
        value: "4.2h",
        desc: "median time to ship",
        accent: false
      }
    ]
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-6xl px-4 sm:px-6">
        <%!-- hero --%>
        <section class="relative py-16 sm:py-20">
          <div
            aria-hidden="true"
            class="pointer-events-none absolute -top-24 left-1/2 -z-10 h-72 w-[42rem] max-w-full -translate-x-1/2 rounded-full bg-primary/15 blur-3xl"
          >
          </div>
          <div class="mx-auto max-w-3xl text-center">
            <.badge tone="info" variant="outline" class="uppercase tracking-wide">
              Private beta · closing soon
            </.badge>
            <h1 class="mt-5 text-balance text-4xl font-extrabold leading-tight tracking-tight sm:text-6xl">
              Ship on Friday. <span class="text-primary">Sleep on Saturday.</span>
            </h1>
            <p class="mx-auto mt-5 max-w-2xl text-pretty text-base text-base-content/70 sm:text-lg">
              Cadence turns your commits, PRs, and releases into release notes the
              whole company can read — scored by risk, delivered to the channel that
              owns the code.
            </p>
            <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
              <.button variant="primary" size="lg" href="#signup-form">
                Join the beta <.icon name="hero-arrow-down" class="size-4" />
              </.button>
              <.button variant="ghost" size="lg" navigate={~p"/about"}>How it works</.button>
            </div>
            <p class="mt-6 font-mono text-xs text-base-content/50">
              no credit card · self-host option · single binary
            </p>
          </div>
        </section>

        <%!-- countdown + signup --%>
        <section class="grid gap-4 pb-4 lg:grid-cols-[1.1fr_1fr]">
          <.card variant="elevated">
            <div class="flex h-full flex-col justify-between gap-6 p-2 sm:p-3">
              <div>
                <.eyebrow>Beta gate closes in</.eyebrow>
                <p class="mt-2 max-w-md text-sm text-base-content/70">
                  We onboard in waves. Every step down the counter is one wave that
                  has left the current cohort — when it hits zero the gate shuts
                  until the next round.
                </p>
              </div>

              <div class="flex items-end justify-between gap-4">
                <div
                  id="countdown"
                  class="font-mono text-7xl leading-none font-bold tabular-nums text-primary sm:text-8xl"
                >
                  {@countdown}
                </div>
                <div class="pb-1 text-right text-xs text-base-content/60">
                  <div class="font-semibold uppercase tracking-wide">waves left</div>
                  <div class="font-mono">-1 every 5s</div>
                </div>
              </div>

              <progress
                class="progress progress-primary w-full"
                value={@countdown}
                max={Launch.countdown_start()}
              ></progress>
            </div>
          </.card>

          <.card variant="elevated">
            <div class="flex h-full flex-col gap-4 p-2 sm:p-3">
              <div>
                <.eyebrow>Newsletter</.eyebrow>
                <h2 class="mt-2 text-xl font-semibold">Get the launch note</h2>
                <p class="mt-1 text-sm text-base-content/65">
                  One email when the beta opens, then a monthly release-craft digest.
                </p>
              </div>

              <.form for={@form} id="signup-form" phx-change="validate" phx-submit="signup">
                <.input
                  field={@form[:email]}
                  type="email"
                  label="Work email"
                  placeholder="you@company.com"
                  autocomplete="email"
                  class="w-full"
                />
                <.button id="signup-submit" type="submit" variant="primary" class="mt-3 w-full">
                  Join the list <.icon name="hero-paper-airplane" class="size-4" />
                </.button>
              </.form>

              <p
                :if={@error}
                id="signup-error"
                role="alert"
                class="flex items-start gap-2 text-sm text-error"
              >
                <.icon name="hero-exclamation-circle" class="mt-0.5 size-4 shrink-0" />
                <span>Email {@error}</span>
              </p>

              <div class="mt-auto">
                <h3 class="text-xs font-semibold tracking-wide text-base-content/60 uppercase">
                  Recent signups
                </h3>
                <ul id="signups" class="mt-2 flex flex-wrap items-center gap-2">
                  <li :if={@signups == []} id="signups-empty" class="text-xs text-base-content/50">
                    No signups yet — be the first.
                  </li>
                  <li
                    :for={signup <- @signups}
                    class="badge badge-ghost gap-1 font-mono text-xs"
                  >
                    <.icon name="hero-check-circle" class="size-3 text-success" />
                    {signup.email}
                  </li>
                </ul>
              </div>
            </div>
          </.card>
        </section>

        <%!-- stats --%>
        <section id="stats" class="py-8">
          <.header level="h2" class="sr-only">Launch stats</.header>
          <div class="grid grid-cols-2 gap-px overflow-hidden rounded-box border border-base-300 bg-base-300 sm:grid-cols-4">
            <div
              :for={tile <- stat_tiles(@signups, @ticks, @countdown)}
              class="flex flex-col items-center gap-1 bg-base-100 px-6 py-5 text-center"
            >
              <span class="text-xs font-semibold tracking-wide text-base-content/60 uppercase">{tile.label}</span>
              <span
                id={tile.id}
                class={["text-3xl font-bold tabular-nums", tile.accent && "text-primary"]}
              >
                {tile.value}
              </span>
              <span class="text-xs text-base-content/50">{tile.desc}</span>
            </div>
          </div>
        </section>

        <%!-- activity feed --%>
        <section class="space-y-4 pb-8">
          <.header level="h2">
            Everything the launch did
            <:eyebrow>Activity</:eyebrow>
            <:subtitle>
              One entry per signup and per countdown step, newest first — the last {@activity_limit} events only.
            </:subtitle>
          </.header>

          <.card>
            <ul id="activity" phx-update="stream" class="divide-y divide-base-200">
              <li
                :for={{dom_id, entry} <- @streams.activity}
                id={dom_id}
                class="flex items-center gap-3 px-1 py-3 text-sm"
              >
                <span class={[
                  "flex size-7 shrink-0 items-center justify-center rounded-full",
                  entry.kind == "signup" && "bg-primary/10 text-primary",
                  entry.kind == "tick" && "bg-base-200 text-base-content/60"
                ]}>
                  <.icon
                    name={if entry.kind == "signup", do: "hero-envelope", else: "hero-clock"}
                    class="size-4"
                  />
                </span>
                <span class="truncate">{entry.text}</span>
              </li>
            </ul>

            <CompositeComponents.empty_state
              :if={@activity_entries == []}
              icon="hero-clock"
              title="Nothing on the wire yet"
            >
              Sign up, or wait for the first countdown step, and it shows up here.
            </CompositeComponents.empty_state>
          </.card>
        </section>

        <%!-- features --%>
        <section class="space-y-5 pb-16">
          <.header level="h2">
            Built for the boring parts of shipping
            <:eyebrow>Features</:eyebrow>
            <:subtitle>
              Each card is a <code class="font-mono text-xs">.feature_card</code>
              composite — registered in the manifest and previewed at <.link
                navigate={~p"/custom-designs"}
                class="link link-hover"
              >/custom-designs</.link>.
            </:subtitle>
          </.header>

          <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <CompositeComponents.feature_card
              :for={feature <- @features}
              icon={feature.icon}
              title={feature.title}
            >
              {feature.body}
            </CompositeComponents.feature_card>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

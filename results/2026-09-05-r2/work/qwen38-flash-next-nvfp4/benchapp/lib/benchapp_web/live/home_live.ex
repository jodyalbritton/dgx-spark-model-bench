defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Lumen — a fictional realtime product surface.

  Holds the page's live state in memory (no database): a countdown that
  ticks every 5 seconds, a newsletter signup form, derived stats, and a
  capped activity feed that logs one entry per signup and per tick.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @countdown_start 100
  @tick_ms 5_000
  @activity_max 10
  @email_regex ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  @features [
    %{
      icon: "hero-bolt",
      title: "Realtime by default",
      body: "State streams to every client over one socket — no polling, no manual refresh.",
      tag: "Engine"
    },
    %{
      icon: "hero-shield-check",
      title: "Typed contracts",
      body: "Every primitive is declared, registered, and linted against its own contract.",
      tag: "Safety"
    },
    %{
      icon: "hero-swatch",
      title: "Themeable",
      body: "Light and dark from a single token set, so a palette swap never touches markup.",
      tag: "Craft"
    },
    %{
      icon: "hero-device-phone-mobile",
      title: "Responsive everywhere",
      body: "A phone-width menu, fluid grids, and touch targets that stay honest at any size.",
      tag: "Layout"
    },
    %{
      icon: "hero-code-bracket",
      title: "Agent-readable",
      body: "A live component manifest means a machine can discover the UI as easily as you.",
      tag: "Tooling"
    },
    %{
      icon: "hero-clock",
      title: "Always current",
      body: "Countdowns, counters, and feeds that update in place without a page reload.",
      tag: "Motion"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        page_title: "Home",
        countdown: @countdown_start,
        ticks: 0,
        signup_emails: [],
        signup_count: 0,
        signup_error: nil,
        features: @features,
        form: to_form(%{}, as: "signup"),
        activity_seq: 0,
        activity_keys: []
      )
      |> stream(:activity, [])

    if connected?(socket), do: schedule_tick()

    {:ok, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    next = max(socket.assigns.countdown - 1, 0)
    schedule_tick()

    {:noreply,
     socket
     |> assign(countdown: next, ticks: socket.assigns.ticks + 1)
     |> add_activity("tick", "Countdown ticked down to #{next}.")}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply,
     socket
     |> assign(:signup_error, nil)
     |> assign(:form, to_form(params, as: "signup"))}
  end

  def handle_event("subscribe", %{"signup" => %{"email" => raw}} = params, socket) do
    email = raw |> to_string() |> String.trim() |> String.downcase()

    cond do
      email == "" or !Regex.match?(@email_regex, email) ->
        {:noreply,
         socket
         |> assign(:signup_error, "Please enter a valid email address.")
         |> assign(:form, to_form(params, as: "signup"))}

      Enum.member?(socket.assigns.signup_emails, email) ->
        {:noreply,
         socket
         |> assign(:signup_error, "#{email} is already subscribed.")
         |> assign(:form, to_form(params, as: "signup"))}

      true ->
        emails = [email | socket.assigns.signup_emails]

        {:noreply,
         socket
         |> assign(
           signup_emails: emails,
           signup_count: length(emails),
           signup_error: nil,
           form: to_form(%{}, as: "signup")
         )
         |> add_activity("signup", "#{email} subscribed to the newsletter.")}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp schedule_tick, do: Process.send_after(self(), :tick, @tick_ms)

  defp add_activity(socket, kind, text) do
    seq = socket.assigns.activity_seq + 1
    id = "activity-#{seq}"
    keys = [id | socket.assigns.activity_keys]
    {keep, dropped} = Enum.split(keys, @activity_max)

    socket =
      Enum.reduce(dropped, socket, fn d, acc -> stream_delete(acc, :activity, %{id: d}) end)

    socket
    |> stream(:activity, [%{id: id, kind: kind, text: text}], at: 0)
    |> assign(activity_seq: seq, activity_keys: keep)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto w-full max-w-6xl px-4 sm:px-6">
        <!-- Hero -->
        <section class="grid items-center gap-10 py-16 sm:py-24 lg:grid-cols-2">
          <div class="space-y-6">
            <.badge tone="ok" class="gap-1.5">
              <span class="relative flex size-2">
                <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-primary opacity-70" />
                <span class="relative inline-flex size-2 rounded-full bg-primary" />
              </span>
              Live demo
            </.badge>

            <h1 class="text-balance text-4xl font-semibold leading-[1.05] tracking-tight sm:text-5xl lg:text-6xl">
              Ship realtime product surfaces <span class="text-primary">without the wiring.</span>
            </h1>

            <p class="max-w-xl text-lg text-base-content/70">
              Lumen turns a design manifest into a themed, mobile-ready interface —
              countdowns, forms, and feeds that update in place over one socket.
            </p>

            <div class="flex flex-wrap items-center gap-3">
              <.button variant="primary" size="lg">
                Get early access
              </.button>
              <.button variant="ghost" size="lg" navigate={~p"/about"}>
                Learn more
              </.button>
            </div>

            <!-- Stats strip -->
            <div
              id="stats"
              class="mt-2 grid grid-cols-2 gap-4 rounded-box border border-base-300 bg-base-100 p-4 sm:max-w-md"
            >
              <div class="flex flex-col gap-1">
                <span class="text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-base-content/55">
                  Signups
                </span>
                <span id="stat-signups" class="text-3xl font-semibold tabular-nums">
                  {@signup_count}
                </span>
              </div>
              <div class="flex flex-col gap-1">
                <span class="text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-base-content/55">
                  Ticks
                </span>
                <span id="stat-ticks" class="text-3xl font-semibold tabular-nums">
                  {@ticks}
                </span>
              </div>
            </div>
          </div>

          <!-- Live panel: countdown + signup + activity -->
          <div class="space-y-4 rounded-3xl border border-base-300 bg-base-100 p-5 shadow-sm sm:p-6">
            <div class="flex items-center justify-between">
              <.eyebrow>Launching in</.eyebrow>
              <.badge tone="info">updating live</.badge>
            </div>

            <div class="flex items-baseline gap-2">
              <span id="countdown" class="text-6xl font-bold tabular-nums tracking-tight">
                {@countdown}
              </span>
              <span class="text-sm text-base-content/60">seconds · −1 / 5s</span>
            </div>

            <!-- Signup form -->
            <.form
              for={@form}
              id="signup-form"
              phx-change="validate"
              phx-submit="subscribe"
              class="space-y-2"
            >
              <.input
                field={@form[:email]}
                type="email"
                id="signup-email"
                name="signup[email]"
                label="Get notified at launch"
                placeholder="you@example.com"
                autocomplete="email"
              />
              <p :if={@signup_error} id="signup-error" role="alert" class="text-sm text-error">
                {@signup_error}
              </p>
              <.button type="submit" variant="primary" class="w-full sm:w-auto">
                Subscribe
              </.button>
            </.form>

            <div class="space-y-2">
              <div class="flex items-center justify-between">
                <.eyebrow>Recent signups</.eyebrow>
                <.badge tone="neutral" id="signup-count-badge">{@signup_count}</.badge>
              </div>
              <ul id="signups" class="flex flex-wrap gap-2">
                <li
                  :if={@signup_emails == []}
                  class="text-sm text-base-content/50"
                  data-empty="true"
                >
                  No signups yet — be the first.
                </li>
                <li
                  :for={email <- @signup_emails}
                  data-signup={email}
                  class="badge badge-neutral badge-outline font-mono text-xs"
                >
                  {email}
                </li>
              </ul>
            </div>

            <!-- Activity feed -->
            <div class="space-y-2">
              <.eyebrow>Activity</.eyebrow>
              <p :if={@activity_keys == []} class="text-sm text-base-content/50">
                Waiting for the first tick or signup…
              </p>
              <ul
                id="activity"
                phx-update="stream"
                class="divide-y divide-base-200 overflow-hidden rounded-box border border-base-200"
              >
                <li
                  :for={{id, entry} <- @streams.activity}
                  id={id}
                  class="flex items-start gap-2 px-3 py-2 text-sm"
                >
                  <.icon
                    name={if entry.kind == "signup", do: "hero-envelope", else: "hero-clock"}
                    class="mt-0.5 size-4 shrink-0 text-base-content/40"
                  />
                  <span class="text-base-content/80">{entry.text}</span>
                </li>
              </ul>
            </div>
          </div>
        </section>

        <!-- Feature grid -->
        <section class="space-y-6 border-t border-base-300 py-16">
          <.header size="page" level="h2">
            Everything in the box
            <:eyebrow>Features</:eyebrow>
            <:subtitle>
              Built from <code class="font-mono text-xs">&lt;.feature_grid&gt;</code>, a
              registered composite that lays out one
              <code class="font-mono text-xs">&lt;.card&gt;</code>
              per feature.
            </:subtitle>
          </.header>

          <CompositeComponents.feature_grid features={@features} />
        </section>
      </div>
    </Layouts.app>
    """
  end
end

defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Lumen landing page: hero, live launch countdown, newsletter signup,
  live stats, activity feed, and the feature grid built from the app's
  registered composites.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @countdown_start 100
  @tick_interval_ms 5_000
  @activity_limit 10
  @recent_signups_limit 8

  @features [
    %{
      key: "ambient",
      icon: "hero-bolt",
      title: "Ambient sync",
      tone: "primary",
      body: "Your workspace follows you between surfaces — phone, desktop, watch — with no manual handoff and no visible machinery."
    },
    %{
      key: "focus",
      icon: "hero-moon",
      title: "Focus tides",
      tone: "accent",
      body: "Lumen reads your calendar's shape and quietly raises a shield before deep work, then lowers it when the coast is clear."
    },
    %{
      key: "recall",
      icon: "hero-sparkles",
      title: "Total recall",
      tone: "secondary",
      body: "Every note, thread, and sketch you've touched is searchable in plain language — indexed locally, never uploaded."
    },
    %{
      key: "privacy",
      icon: "hero-shield-check",
      title: "Private by construction",
      tone: "primary",
      body: "On-device models do the reasoning. There is no cloud corpus because there never was a pipe to one."
    },
    %{
      key: "sketch",
      icon: "hero-pencil-square",
      title: "Sketch-to-ship",
      tone: "accent",
      body: "Draw a rough interface on the tablet and Lumen drafts real components you can drop straight into a branch."
    },
    %{
      key: "rituals",
      icon: "hero-sun",
      title: "Daily rituals",
      tone: "secondary",
      body: "A two-minute morning brief and an evening unwind, tuned to what actually changed while you were away."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        page_title: "Launch",
        countdown: @countdown_start,
        ticks: 0,
        signup_count: 0,
        recent_signups: [],
        activity: [],
        form: to_form(%{}, as: :signup)
      )

    socket =
      if connected?(socket) do
        schedule_tick()
        socket
      else
        socket
      end

    {:ok, socket}
  end

  defp schedule_tick, do: Process.send_after(self(), :countdown_tick, @tick_interval_ms)

  @impl true
  def handle_info(:countdown_tick, socket) do
    schedule_tick()

    value = max(socket.assigns.countdown - 1, 0)
    entry = %{kind: "tick", text: "launch window ticked down to #{value}", at: minutes_ago(0)}

    {:noreply,
     socket
     |> assign(:countdown, value)
     |> assign(:ticks, socket.assigns.ticks + 1)
     |> push_activity(entry)}
  end

  @impl true
  def handle_event("validate", %{"signup" => %{"email" => email}}, socket) do
    {:noreply, assign(socket, :form, to_form(%{"email" => email}, as: :signup))}
  end

  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    if valid_email?(email) do
      address = String.trim(email)
      entry = %{kind: "signup", text: "new signup: #{address}", at: minutes_ago(0)}

      {:noreply,
        socket
        |> assign(:form, to_form(%{}, as: :signup))
        |> assign(:signup_count, socket.assigns.signup_count + 1)
        |> assign(:recent_signups,
          Enum.take([address | socket.assigns.recent_signups], @recent_signups_limit)
        )
        |> push_activity(entry)}
    else
      form =
        socket.assigns.form
        |> to_form(%{"email" => email}, as: :signup)
        |> Map.put(:errors, [{"is not a valid email address", []}])

      {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("signup", _params, socket), do: {:noreply, socket}
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp push_activity(socket, entry) do
    assign(socket, :activity, Enum.take([entry | socket.assigns.activity], @activity_limit))
  end

  @email_re ~r/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/
  defp valid_email?(email) when is_binary(email), do: Regex.match?(@email_re, String.trim(email))
  defp valid_email?(_), do: false

  defp minutes_ago(_), do: "just now"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto w-full max-w-6xl px-4 sm:px-6">
        <!-- hero -->
        <section class="relative overflow-hidden py-16 sm:py-24">
          <div
            class="pointer-events-none absolute inset-x-0 -top-40 -z-0 mx-auto h-80 max-w-3xl rounded-full bg-primary/20 blur-3xl"
            aria-hidden="true"
          />
          <div class="relative z-10 mx-auto flex max-w-3xl flex-col items-center gap-6 text-center">
            <.badge tone="info" class="uppercase tracking-widest">Public beta · Spring drop</.badge>
            <h1 class="text-4xl font-bold leading-tight tracking-tight sm:text-6xl">
              Your day, arranged by
              <span class="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                Lumen
              </span>
            </h1>
            <p class="max-w-xl text-base leading-7 text-base-content/65 sm:text-lg">
              Lumen is the ambient workspace that syncs your context, shields your focus, and
              remembers everything — privately, on device. Join the launch list and be first
              through the door.
            </p>

            <div class="flex flex-col items-center gap-2">
              <CompositeComponents.countdown_display
                id="countdown"
                value={@countdown}
                label="ticks left in the launch window"
              />
              <p class="text-xs text-base-content/50">The window closes one tick at a time.</p>
            </div>

            <div class="flex flex-wrap items-center justify-center gap-3 pt-2">
              <.button
                phx-click="scroll-to-signup"
                variant="primary"
                size="lg"
                class="shadow-lg shadow-primary/25"
              >
                Claim your spot
              </.button>
              <.button navigate={~p"/about"} variant="ghost" size="lg">How it works</.button>
            </div>
          </div>
        </section>

        <!-- stats strip -->
        <section
          id="stats"
          class="grid grid-cols-1 gap-4 rounded-3xl border border-base-300 bg-base-100/60 p-6 sm:grid-cols-3 sm:p-8"
          aria-label="Live launch stats"
        >
          <div class="flex flex-col gap-1">
            <span class="text-xs font-medium uppercase tracking-widest text-base-content/50">
              Signups
            </span>
            <span id="stat-signups" class="text-3xl font-bold tabular-nums">
              {@signup_count}
            </span>
          </div>
          <div class="flex flex-col gap-1">
            <span class="text-xs font-medium uppercase tracking-widest text-base-content/50">
              Countdown ticks
            </span>
            <span id="stat-ticks" class="text-3xl font-bold tabular-nums">{@ticks}</span>
          </div>
          <div class="flex flex-col gap-1">
            <span class="text-xs font-medium uppercase tracking-widest text-base-content/50">
              Window
            </span>
            <span class="text-3xl font-bold tabular-nums text-primary">{@countdown}</span>
          </div>
        </section>

        <!-- signup + activity -->
        <section class="grid gap-6 py-16 lg:grid-cols-2">
          <div class="flex flex-col gap-4 rounded-3xl border border-base-300 bg-base-100 p-6 sm:p-8">
            <.header level="h2" class="mb-0">
              Join the launch list
              <:eyebrow>No spam, one email</:eyebrow>
              <:subtitle>
                We'll write once, the morning the doors open.
              </:subtitle>
            </.header>

            <.form
              for={@form}
              id="signup-form"
              phx-change="validate"
              phx-submit="signup"
              class="flex flex-col gap-3"
            >
              <.input
                field={@form[:email]}
                type="email"
                name="email"
                placeholder="you@example.com"
                aria-label="Email address"
                autocomplete="email"
              />
              <p :if={@form.errors != []} id="signup-error" class="text-sm font-medium text-error">
                That doesn't look like an email address — try again?
              </p>
              <.button type="submit" variant="primary" class="w-full sm:w-auto">
                Keep me posted
              </.button>
            </.form>

            <div class="flex flex-col gap-2 pt-2">
              <h3 class="text-xs font-medium uppercase tracking-widest text-base-content/50">
                Recent signups
              </h3>
              <ul id="signups" class="flex flex-col gap-1.5">
                <li
                  :for={{email, i} <- Enum.with_index(@recent_signups)}
                  key={"signup-#{email}-#{i}"}
                  class="flex items-center gap-2 text-sm text-base-content/75"
                >
                  <.icon name="hero-check-circle" class="size-4 shrink-0 text-success" />
                  <span class="truncate font-mono text-xs">{email}</span>
                </li>
                <li :if={@recent_signups == []} class="text-sm text-base-content/40">
                  Nobody yet — be the first.
                </li>
              </ul>
            </div>
          </div>

          <div class="flex flex-col gap-4 rounded-3xl border border-base-300 bg-base-100 p-2 sm:p-4">
            <div class="px-4 pt-3">
              <.header level="h2" class="mb-0">
                Launch activity
                <:eyebrow>Newest first</:eyebrow>
              </.header>
            </div>
            <ul id="activity" class="divide-y divide-base-200">
              <CompositeComponents.activity_entry
                :for={{entry, i} <- Enum.with_index(@activity)}
                key={"activity-#{entry.kind}-#{entry.text}-#{i}"}
                kind={entry.kind}
                text={entry.text}
                time={entry.at}
              />
              <li :if={@activity == []} class="px-4 py-3 text-sm text-base-content/40">
                The feed warms up as the countdown runs.
              </li>
            </ul>
          </div>
        </section>

        <!-- feature grid -->
        <section class="pb-20">
          <.header level="h2" class="mb-8">
            Six reasons it feels like magic
            <:eyebrow>Built with &lt;.feature_card&gt;</:eyebrow>
            <:subtitle>
              Every card below is the <code class="font-mono text-xs">feature_card</code> composite —
              preview it on <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>.
            </:subtitle>
          </.header>
          <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <CompositeComponents.feature_card
              :for={feature <- @features}
              icon={feature.icon}
              title={feature.title}
              tone={feature.tone}
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

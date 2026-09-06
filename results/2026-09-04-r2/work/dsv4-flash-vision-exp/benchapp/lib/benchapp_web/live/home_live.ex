defmodule BenchappWeb.HomeLive do
  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval 5_000
  @start_countdown 100
  @max_activity 10
  @email_regex ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  @features [
    %{
      icon: "hero-bolt",
      title: "Instant capture",
      desc: "Jot a thought in seconds. Lumen files it where you'll find it later."
    },
    %{
      icon: "hero-sun",
      title: "Adaptive themes",
      desc: "Light, dark, or matching your system — your space follows you."
    },
    %{
      icon: "hero-device-phone-mobile",
      title: "Everywhere you are",
      desc: "A responsive design that feels native on phone, tablet, and desktop."
    },
    %{
      icon: "hero-shield-check",
      title: "Private by default",
      desc: "Your ideas stay yours. No ads, no trackers, no noise."
    },
    %{
      icon: "hero-sparkles",
      title: "Gentle focus",
      desc: "Easy rhythm and calm surfaces that keep you in the flow."
    },
    %{
      icon: "hero-arrow-path",
      title: "Always in sync",
      desc: "Changes reflect live, so what you see is what's saved."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: schedule_tick()

    {:ok,
     assign(socket,
       page_title: "Home",
       countdown: @start_countdown,
       ticks: 0,
       signups: [],
       signup_error: nil,
       activity: [],
       features: @features,
       form: to_form(%{})
     )}
  end

  defp schedule_tick, do: Process.send_after(self(), :tick, @tick_interval)

  @impl true
  def handle_info(:tick, socket) do
    if connected?(socket), do: schedule_tick()

    ticks = socket.assigns.ticks + 1
    countdown = max(socket.assigns.countdown - 1, 0)

    {:noreply,
     socket
     |> assign(ticks: ticks, countdown: countdown)
     |> add_activity(%{kind: :tick, label: "Countdown tick → #{countdown}"})}
  end

  @impl true
  def handle_event("signup", %{"email" => email}, socket) do
    email = String.trim(email)

    if email == "" or not String.match?(email, @email_regex) do
      {:noreply, assign(socket, signup_error: "Please enter a valid email address.")}
    else
      {:noreply,
       socket
       |> assign(signup_error: nil, signups: [email | socket.assigns.signups], form: to_form(%{}))
       |> add_activity(%{kind: :signup, label: "New signup: #{email}"})}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp add_activity(socket, entry) do
    activity = Enum.take([entry | socket.assigns.activity], @max_activity)
    DateTime.utc_now()
    assign(socket, activity: activity)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <!-- Hero -->
      <section class="relative overflow-hidden border-b border-base-300">
        <div class="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(60%_60%_at_50%_0%,theme(colors.base-300/.4),transparent)]" />
        <div class="mx-auto max-w-5xl px-4 py-20 text-center sm:px-6 sm:py-28">
          <.eyebrow>Calm tools for busy minds</.eyebrow>
          <h1 class="mt-4 text-4xl font-semibold leading-tight tracking-tight sm:text-6xl">
            Make space for what matters.
          </h1>
          <p class="mx-auto mt-5 max-w-xl text-base text-base-content/70 sm:text-lg">
            Lumen is a gentle workspace for capturing ideas, staying organized, and
            keeping your mind light. Designed to disappear while you work.
          </p>
          <div class="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <.button navigate={~p"/about"} variant="primary" size="lg">
              Learn more <.icon name="hero-arrow-right" class="size-4" />
            </.button>
          </div>

          <div class="mt-14 inline-flex flex-col items-center gap-2 rounded-2xl border border-base-300 bg-base-100/60 px-8 py-6 backdrop-blur">
            <p class="text-xs uppercase tracking-widest text-base-content/50">Launching in</p>
            <p id="countdown" class="text-5xl font-bold tabular-nums text-primary sm:text-6xl">
              {@countdown}
            </p>
            <p class="text-xs text-base-content/50">seconds — 100 and counting down.</p>
          </div>
        </div>
      </section>

      <!-- Feature grid (composite) -->
      <section class="mx-auto max-w-5xl px-4 py-16 sm:px-6 sm:py-20">
        <.header level="h2" size="section">
          Designed for focus
          <:eyebrow>Features</:eyebrow>
          <:subtitle>
            Everything you need, nothing you don't. Built on a composite component
            in our design system.
          </:subtitle>
        </.header>

        <CompositeComponents.feature_grid items={@features} class="mt-8" />
      </section>

      <!-- Newsletter + stats + activity -->
      <section class="border-t border-base-300 bg-base-200/40">
        <div class="mx-auto grid max-w-5xl gap-10 px-4 py-16 sm:px-6 lg:grid-cols-2">
          <div>
            <h2 class="text-2xl font-semibold tracking-tight">Join the early list</h2>
            <p class="mt-2 text-sm text-base-content/70">
              Be first to know when Lumen opens up. We'll only email when there's
              something worth saying.
            </p>

            <form id="signup-form" phx-submit="signup" class="mt-6">
              <div class="flex flex-col gap-3 sm:flex-row">
                <.input
                  field={@form[:email]}
                  type="email"
                  name="email"
                  placeholder="you@example.com"
                  class="flex-1"
                  input_class="input-bordered"
                  autocomplete="email"
                />
                <.button type="submit" variant="primary">Sign up</.button>
              </div>
              <p id="signup-error" class="mt-2 text-sm text-error" role="alert">
                {if @signup_error, do: @signup_error}
              </p>
            </form>

            <div class="mt-8">
              <h3 class="text-sm font-semibold uppercase tracking-widest text-base-content/50">
                Recent signups
              </h3>
              <ul id="signups" class="mt-3 space-y-2">
                <li :for={email <- @signups} class="flex items-center gap-2 text-sm">
                  <span class="size-1.5 rounded-full bg-primary"></span>
                  <span>{email}</span>
                </li>
                <li :if={@signups == []} class="text-sm text-base-content/50">
                  No signups yet.
                </li>
              </ul>
            </div>
          </div>

          <div class="flex flex-col gap-8">
            <div id="stats" class="grid grid-cols-2 gap-4">
              <CompositeComponents.stat_card
                id="stat-signups"
                label="Signups"
                value={length(@signups)}
              />
              <CompositeComponents.stat_card id="stat-ticks" label="Ticks" value={@ticks} />
            </div>

            <div class="rounded-2xl border border-base-300 bg-base-100 p-5">
              <h3 class="text-sm font-semibold uppercase tracking-widest text-base-content/50">
                Activity
              </h3>
              <ul id="activity" class="mt-3 space-y-2">
                <li
                  :for={{entry, index} <- Enum.with_index(@activity)}
                  class="flex items-center gap-2 text-sm"
                  id={"activity-#{index}"}
                >
                  <.badge tone={(entry.kind == :signup && "ok") || "info"} size="xs">
                    {(entry.kind == :signup && "signup") || "tick"}
                  </.badge>
                  <span>{entry.label}</span>
                </li>
                <li :if={@activity == []} class="text-sm text-base-content/50">
                  Live activity will appear here.
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end

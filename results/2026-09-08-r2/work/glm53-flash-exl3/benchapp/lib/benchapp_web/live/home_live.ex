defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Lumina, the adaptive smart desk lamp. Carries the
  live countdown, the newsletter signup, the stats strip, and the
  activity feed.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval_ms 5_000
  @max_activity 10

  @features [
    %{
      icon: "hero-sun",
      title: "Adaptive daylight",
      description: "Lumina reads the ambient light and re-tunes its 2,400-LED halo every 250 ms."
    },
    %{
      icon: "hero-clock",
      title: "Circadian schedule",
      description:
        "Warm mornings, focused afternoons, wind-down evenings — set once, forget forever."
    },
    %{
      icon: "hero-wifi",
      title: "Works everywhere",
      description:
        "Wi-Fi, Thread, and Bluetooth LE. Pair it with your desk, your hub, or nothing at all."
    },
    %{
      icon: "hero-bolt",
      title: "Weeks of battery",
      description: "A 96 Wh cell runs the halo for 11 days of typical use, cord-free."
    },
    %{
      icon: "hero-microphone",
      title: "Speak or gesture",
      description:
        "Wave under the halo to dim, or just ask. On-device voice, no cloud round-trip."
    },
    %{
      icon: "hero-shield-check",
      title: "Private by design",
      description: "Sensors stay local. Lumina phones home exactly never — no account required."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Lumina",
        countdown: 100,
        ticks: 0,
        signups: [],
        error: nil,
        event_seq: 0,
        activity: [],
        form: to_form(%{"email" => ""}, as: :signup),
        features: @features
      )

    socket =
      if connected?(socket) do
        Process.send_after(self(), :tick, @tick_interval_ms)
        socket
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    email = String.trim(email)

    cond do
      not valid_email?(email) ->
        {:noreply,
         assign(socket,
           error: "Please enter a valid email address.",
           form: to_form(%{"email" => email}, as: :signup)
         )}

      email in socket.assigns.signups ->
        {:noreply,
         assign(socket,
           error: "You are already on the list.",
           form: to_form(%{"email" => email}, as: :signup)
         )}

      true ->
        {:noreply, add_signup(socket, email)}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    countdown =
      case socket.assigns.countdown do
        n when n <= 1 -> 100
        n -> n - 1
      end

    ticks = socket.assigns.ticks + 1

    socket =
      socket
      |> assign(countdown: countdown, ticks: ticks)
      |> push_activity("tick-#{ticks}", "Countdown ticked to #{countdown}")

    {:noreply, socket}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp add_signup(socket, email) do
    seq = socket.assigns.event_seq + 1

    socket
    |> assign(
      signups: [email | socket.assigns.signups],
      error: nil,
      event_seq: seq,
      form: to_form(%{"email" => ""}, as: :signup)
    )
    |> push_activity("signup-#{seq}", "#{email} joined the launch list")
  end

  defp push_activity(socket, id, text) do
    entry = %{id: id, text: text}

    socket
    |> assign(activity: Enum.take([entry | socket.assigns.activity], @max_activity))
  end

  defp valid_email?(email) do
    String.match?(email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl space-y-16 px-4 py-12 sm:px-6">
        <%!-- Hero --%>
        <section class="relative overflow-hidden rounded-3xl border border-base-300 bg-gradient-to-br from-primary/10 via-base-100 to-secondary/10 px-6 py-14 text-center sm:px-12">
          <.eyebrow class="text-primary">Launching soon</.eyebrow>
          <h1 class="mx-auto mt-4 max-w-2xl text-4xl font-bold leading-tight sm:text-5xl">
            Light that thinks ahead.
          </h1>
          <p class="mx-auto mt-4 max-w-xl text-base-content/70">
            Lumina is the adaptive desk lamp that tunes itself to your day —
            warmer at sunrise, sharper at crunch time, gone at midnight.
          </p>
          <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
            <.button variant="primary" href="#signup-form">Join the launch list</.button>
            <.button variant="ghost" navigate={~p"/about"}>Why Lumina?</.button>
          </div>
        </section>

        <%!-- Countdown --%>
        <section class="flex flex-col items-center gap-3 text-center">
          <.eyebrow>Early-bird window closes in</.eyebrow>
          <div
            id="countdown"
            class="rounded-2xl border border-base-300 bg-base-200 px-10 py-6 font-mono text-6xl font-bold tabular-nums text-primary transition-colors sm:text-7xl"
          >
            {@countdown}
          </div>
          <p class="text-sm text-base-content/60">seconds of beta access remaining</p>
        </section>

        <%!-- Stats strip --%>
        <section id="stats" class="grid grid-cols-2 gap-4">
          <div
            :for={
              {id, value, label, accent} <- [
                {"stat-signups", length(@signups), "people on the list", "text-primary"},
                {"stat-ticks", @ticks, "launch-clock ticks", "text-secondary"}
              ]
            }
            class="rounded-2xl border border-base-300 bg-base-100 p-6 text-center shadow-sm"
          >
            <p class={["text-4xl font-bold tabular-nums", accent]} id={id}>{value}</p>
            <p class="mt-1 text-sm text-base-content/60">{label}</p>
          </div>
        </section>

        <%!-- Signup + activity --%>
        <section class="grid gap-8 lg:grid-cols-2">
          <div class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm">
            <h2 class="text-xl font-semibold">Join the launch list</h2>
            <p class="mt-1 text-sm text-base-content/70">
              Be first in line when the first 500 lamps ship this winter.
            </p>
            <.form for={@form} id="signup-form" phx-submit="signup" class="mt-4">
              <.input
                field={@form[:email]}
                type="email"
                label="Email address"
                placeholder="you@example.com"
                input_class="max-w-none"
              />
              <div class="mt-4">
                <.button variant="primary" type="submit">Sign up</.button>
              </div>
            </.form>
            <p
              :if={@error}
              id="signup-error"
              role="alert"
              class="mt-3 rounded-field bg-error/10 px-3 py-2 text-sm text-error"
            >
              {@error}
            </p>

            <div class="mt-6">
              <h3 class="text-sm font-semibold uppercase tracking-wide text-base-content/60">
                Recent signups
              </h3>
              <ul id="signups" class="mt-2 space-y-1">
                <li
                  :for={email <- @signups}
                  class="flex items-center gap-2 rounded-field bg-base-200 px-3 py-1.5 text-sm"
                >
                  <JobyKit.CoreComponents.icon name="hero-envelope" class="size-4 text-primary" />
                  {email}
                </li>
              </ul>
              <p :if={@signups == []} class="mt-2 text-sm text-base-content/50">
                No one yet — be the first.
              </p>
            </div>
          </div>

          <div class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm">
            <h2 class="text-xl font-semibold">Live activity</h2>
            <ul id="activity" class="mt-4 space-y-2">
              <li
                :for={entry <- @activity}
                id={entry.id}
                class="flex items-center gap-2 rounded-field border border-base-300 px-3 py-2 text-sm"
              >
                <span class="size-1.5 rounded-full bg-primary" aria-hidden="true"></span>
                {entry.text}
              </li>
            </ul>
            <p :if={@activity == []} class="mt-4 text-sm text-base-content/50">
              The feed lights up with signups and countdown ticks.
            </p>
          </div>
        </section>

        <%!-- Feature grid --%>
        <section class="space-y-4">
          <div class="text-center">
            <.eyebrow class="text-primary">Features</.eyebrow>
            <h2 class="mt-2 text-3xl font-bold">Everything a desk lamp forgot to be</h2>
          </div>
          <CompositeComponents.feature_grid features={@features} />
        </section>
      </div>
    </Layouts.app>
    """
  end
end

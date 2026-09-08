defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The Fathom landing page: a hero, a live product countdown, a newsletter
  signup form, a stats strip, an activity feed, and a feature grid.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval 5_000
  @activity_limit 10
  @initial_countdown 100

  @features [
    %{
      icon: "hero-bolt",
      title: "Instant",
      body: "Turn it on and it works — no setup, no config, no tutorials."
    },
    %{
      icon: "hero-shield-check",
      title: "Private",
      body: "Your data stays yours. Encrypted end to end, always."
    },
    %{
      icon: "hero-chart-bar",
      title: "Insightful",
      body: "Live dashboards surface what matters the moment it changes."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :countdown_tick, @tick_interval)

    {:ok,
     assign(socket,
       page_title: "Fathom",
       countdown: @initial_countdown,
       ticks: 0,
       signups: [],
       activity: [],
       signup_error: nil,
       features: @features,
       form: to_form(%{}, as: :signup)
     )}
  end

  @impl true
  def handle_info(:countdown_tick, socket) do
    countdown = max(socket.assigns.countdown - 1, 0)
    ticks = socket.assigns.ticks + 1
    activity = add_activity(socket.assigns.activity, :tick, "Countdown ticked to #{countdown}")
    Process.send_after(self(), :countdown_tick, @tick_interval)

    {:noreply, assign(socket, countdown: countdown, ticks: ticks, activity: activity)}
  end

  @impl true
  def handle_event("subscribe", %{"signup" => %{"email" => email}}, socket) do
    email = String.trim(email)

    cond do
      email == "" or not valid_email?(email) ->
        {:noreply, assign(socket, signup_error: "Please enter a valid email address.")}

      email in socket.assigns.signups ->
        {:noreply, assign(socket, signup_error: "That email is already subscribed.")}

      true ->
        signups = [email | socket.assigns.signups]
        activity = add_activity(socket.assigns.activity, :signup, "#{email} subscribed")
        form = to_form(%{}, as: :signup)

        {:noreply,
         assign(socket,
           signups: signups,
           activity: activity,
           signup_error: nil,
           form: form
         )}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <%!-- Hero --%>
      <section class="relative overflow-hidden border-b border-base-300">
        <div class="pointer-events-none absolute inset-0 bg-gradient-to-b from-primary/10 to-transparent">
          <div class="absolute -right-24 -top-24 size-72 rounded-full bg-primary/10 blur-3xl" />
          <div class="absolute -left-24 top-1/2 size-60 rounded-full bg-secondary/10 blur-3xl" />
        </div>
        <div class="relative mx-auto max-w-6xl px-4 pb-20 pt-20 sm:px-6 sm:pt-28">
          <div class="max-w-2xl">
            <.eyebrow>The brightest way to run your day</.eyebrow>
            <h1 class="mt-4 text-4xl font-bold leading-tight tracking-tight text-base-content sm:text-6xl">
              Fathom
            </h1>
            <p class="mt-6 max-w-xl text-base leading-relaxed text-base-content/70 sm:text-lg">
              A home that thinks ahead. Fathom learns your rhythms and lights, warms, and
              protects your space automatically — beautifully, privately, instantly.
            </p>
            <div class="mt-10 flex flex-wrap gap-3">
              <.button navigate={~p"/about"} variant="primary" size="lg">
                Learn more <.icon name="hero-arrow-right" class="size-4" />
              </.button>
              <.button navigate={~p"/design"} variant="ghost" size="lg">
                Explore the interface
              </.button>
            </div>
          </div>
        </div>
      </section>

      <%!-- Countdown --%>
      <section class="border-b border-base-300 bg-base-200/40">
        <div class="mx-auto max-w-6xl px-4 py-12 text-center sm:px-6">
          <h2 class="text-sm font-semibold uppercase tracking-[0.18em] text-base-content/55">
            Launching in
          </h2>
          <p
            id="countdown"
            class="mt-4 text-6xl font-bold tabular-nums tracking-tight text-primary sm:text-8xl"
          >
            {@countdown}
          </p>
          <p class="mt-4 text-sm text-base-content/60">
            A fresh release ships every five seconds. You'll feel it here first.
          </p>
        </div>
      </section>

      <%!-- Stats strip --%>
      <section id="stats" class="border-b border-base-300">
        <div class="mx-auto grid max-w-6xl grid-cols-2 gap-4 px-4 py-10 sm:px-6">
          <div class="rounded-2xl border border-base-300 bg-base-100/70 p-6 text-center">
            <p id="stat-signups" class="text-4xl font-bold tabular-nums text-base-content">
              {length(@signups)}
            </p>
            <p class="mt-2 text-sm font-medium text-base-content/60">Signups</p>
          </div>
          <div class="rounded-2xl border border-base-300 bg-base-100/70 p-6 text-center">
            <p id="stat-ticks" class="text-4xl font-bold tabular-nums text-base-content">
              {@ticks}
            </p>
            <p class="mt-2 text-sm font-medium text-base-content/60">Countdown ticks</p>
          </div>
        </div>
      </section>

      <%!-- Newsletter signup --%>
      <section class="border-b border-base-300">
        <div class="mx-auto max-w-6xl px-4 py-14 sm:px-6">
          <div class="mx-auto max-w-lg">
            <div class="text-center">
              <h2 class="text-2xl font-semibold text-base-content">Join the launch list</h2>
              <p class="mt-2 text-sm text-base-content/60">
                Get early access and product news. No spam, ever.
              </p>
            </div>

            <.form for={@form} id="signup-form" phx-submit="subscribe" class="mt-8 space-y-4">
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                placeholder="you@example.com"
                input_class="font-sans"
              />
              <.button type="submit" variant="primary" class="w-full">
                Subscribe
              </.button>
            </.form>

            <%!--
              The error element is always present so messages have a stable
              anchor; it only carries a message once one exists.
            --%>
            <p id="signup-error" class="mt-3 text-center text-sm text-error" role="alert">
              {@signup_error || ""}
            </p>
          </div>

          <div class="mx-auto mt-14 max-w-lg">
            <h3 class="text-sm font-semibold uppercase tracking-[0.18em] text-base-content/55">
              Recent signups
            </h3>
            <ul id="signups" class="mt-4 space-y-2">
              <li
                :for={email <- @signups}
                class="flex items-center gap-3 rounded-xl border border-base-300 bg-base-100/60 px-4 py-2 text-sm text-base-content"
              >
                <.icon name="hero-check-circle" class="size-4 text-success" />
                {email}
              </li>
            </ul>
            <p :if={@signups == []} class="mt-4 text-sm text-base-content/50">
              No signups yet — be the first.
            </p>
          </div>
        </div>
      </section>

      <%!-- Feature grid --%>
      <section class="border-b border-base-300">
        <div class="mx-auto max-w-6xl px-4 py-16 sm:px-6">
          <div class="max-w-xl">
            <.eyebrow>Why Fathom</.eyebrow>
            <h2 class="mt-3 text-2xl font-semibold text-base-content sm:text-3xl">
              Thoughtful by design
            </h2>
            <p class="mt-3 text-sm text-base-content/60">
              Every detail of Fathom is tuned to feel effortless — from the first
              glance to the daily rhythm.
            </p>
          </div>
          <div class="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <CompositeComponents.feature_card
              :for={feature <- @features}
              icon={feature.icon}
              title={feature.title}
            >
              {feature.body}
            </CompositeComponents.feature_card>
          </div>
        </div>
      </section>

      <%!-- Activity feed --%>
      <section>
        <div class="mx-auto max-w-6xl px-4 py-16 sm:px-6">
          <div class="mx-auto max-w-lg">
            <h2 class="text-2xl font-semibold text-base-content">Live activity</h2>
            <p class="mt-2 text-sm text-base-content/60">
              Every countdown tick and every signup, newest first.
            </p>
            <ul id="activity" class="mt-6 space-y-2">
              <li
                :for={entry <- @activity}
                class="flex items-center gap-3 rounded-xl border border-base-300 bg-base-100/60 px-4 py-2 text-sm text-base-content"
              >
                <.icon
                  :if={entry.type == :signup}
                  name="hero-user-plus"
                  class="size-4 text-secondary"
                />
                <.icon :if={entry.type == :tick} name="hero-arrow-path" class="size-4 text-primary" />
                {entry.text}
              </li>
            </ul>
            <p :if={@activity == []} class="mt-4 text-sm text-base-content/50">
              Nothing yet — activity will appear here as it happens.
            </p>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp valid_email?(email) do
    Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email)
  end

  defp add_activity(activity, type, text) do
    [%{type: type, text: text} | activity] |> Enum.take(@activity_limit)
  end
end

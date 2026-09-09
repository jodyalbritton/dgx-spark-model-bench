defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Nimbus — hero, live countdown, newsletter signup,
  stats strip, activity feed, and the feature grid.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval_ms 5_000
  @countdown_start 100

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Home",
        countdown: @countdown_start,
        ticks: 0,
        signups: [],
        activity: [],
        signup_error: nil,
        form: to_form(%{}, as: :signup)
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

    socket =
      cond do
        not valid_email?(email) ->
          assign(socket, signup_error: "Please enter a valid email address.")

        email in socket.assigns.signups ->
          assign(socket, signup_error: "That email is already on the list.")

        true ->
          socket
          |> assign(signups: [email | socket.assigns.signups], signup_error: nil)
          |> add_activity(:signup, email)
          |> assign(:form, to_form(%{}, as: :signup))
      end

    {:noreply, socket}
  end

  def handle_event("validate", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    countdown =
      if socket.assigns.countdown <= 1, do: @countdown_start, else: socket.assigns.countdown - 1

    {:noreply,
     socket
     |> assign(countdown: countdown, ticks: socket.assigns.ticks + 1)
     |> add_activity(:tick, nil)}
  end

  defp add_activity(socket, :signup, email) do
    entry = %{id: "signup-#{System.unique_integer([:positive])}", text: "New signup: #{email}"}
    assign(socket, :activity, Enum.take([entry | socket.assigns.activity], 10))
  end

  defp add_activity(socket, :tick, _nil) do
    entry = %{id: "tick-#{System.unique_integer([:positive])}", text: "Countdown ticked"}
    assign(socket, :activity, Enum.take([entry | socket.assigns.activity], 10))
  end

  defp valid_email?(email), do: Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl space-y-16 px-4 py-12 sm:px-6">
        <%!-- Hero --%>
        <section class="flex flex-col items-center gap-6 rounded-3xl border border-base-300 bg-gradient-to-br from-primary/10 via-base-100 to-secondary/10 px-6 py-14 text-center sm:px-12">
          <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">
            Nimbus · weather intelligence
          </p>
          <h1 class="mx-auto max-w-2xl text-4xl font-bold leading-tight sm:text-5xl">
            The sky, decoded.
          </h1>
          <p class="mx-auto max-w-xl text-base text-base-content/70 sm:text-lg">
            Nimbus turns raw forecast feeds into decisions you can act on —
            hyperlocal, hourly, and honest about uncertainty.
          </p>
          <div class="flex flex-wrap items-center justify-center gap-3 pt-2">
            <.button navigate={~p"/design"} variant="primary">Explore the platform</.button>
            <.button href="#signup" variant="ghost">Join the beta</.button>
          </div>
        </section>

        <%!-- Live countdown --%>
        <section class="space-y-3 text-center">
          <p class="text-sm uppercase tracking-widest text-base-content/60">Next model refresh in</p>
          <div
            id="countdown"
            class="mx-auto w-fit rounded-2xl border border-primary/30 bg-primary/5 px-8 py-4 font-mono text-5xl font-bold tabular-nums text-primary"
            aria-live="polite"
          >
            {@countdown}
          </div>
        </section>

        <%!-- Stats strip --%>
        <section id="stats" class="grid gap-4 sm:grid-cols-2">
          <div class="rounded-2xl border border-base-300 bg-base-100/60 px-6 py-5 text-center">
            <div id="stat-signups" class="text-3xl font-bold tabular-nums">
              {length(@signups)}
            </div>
            <div class="text-sm text-base-content/60">Beta signups</div>
          </div>
          <div class="rounded-2xl border border-base-300 bg-base-100/60 px-6 py-5 text-center">
            <div id="stat-ticks" class="text-3xl font-bold tabular-nums">
              {@ticks}
            </div>
            <div class="text-sm text-base-content/60">Countdown ticks</div>
          </div>
        </section>

        <%!-- Newsletter signup --%>
        <section id="signup" class="space-y-4">
          <CompositeComponents.empty_state icon="hero-envelope" title="Get the beta digest">
            One email a week: model changelogs, forecast scores, and early access.
          </CompositeComponents.empty_state>

          <.form
            id="signup-form"
            for={@form}
            phx-submit="signup"
            phx-change="validate"
            novalidate
            class="mx-auto flex max-w-md flex-col gap-2 sm:flex-row"
          >
            <.input
              field={@form[:email]}
              type="email"
              name="signup[email]"
              placeholder="you@example.com"
              class="flex-1"
            />
            <.button type="submit" variant="primary" class="sm:shrink-0">Sign up</.button>
          </.form>

          <div id="signup-error" role="alert" class="text-center text-sm text-error">
            {@signup_error}
          </div>

          <div class="mx-auto max-w-md space-y-1 text-center">
            <h2 class="text-sm font-semibold uppercase tracking-widest text-base-content/60">
              Recent signups
            </h2>
            <ul id="signups" class="space-y-1 text-sm">
              <li
                :for={email <- @signups}
                class="rounded-field bg-base-200/60 px-3 py-1 font-mono text-xs"
              >
                {email}
              </li>
            </ul>
          </div>
        </section>

        <%!-- Activity feed --%>
        <section class="space-y-3">
          <.header level="h2">
            Live activity
            <:eyebrow>Feed</:eyebrow>
          </.header>
          <ul id="activity" class="space-y-2">
            <li
              :for={entry <- @activity}
              id={entry.id}
              class="rounded-field border border-base-300 bg-base-100/60 px-4 py-2 text-sm text-base-content/80"
            >
              {entry.text}
            </li>
          </ul>
        </section>

        <%!-- Feature grid --%>
        <section class="space-y-4">
          <.header level="h2">
            What Nimbus does
            <:eyebrow>Features</:eyebrow>
            <:subtitle>
              Rendered with the registered <code class="font-mono text-xs">feature_grid</code>
              composite.
            </:subtitle>
          </.header>

          <CompositeComponents.feature_grid features={[
            %{
              icon: "hero-bolt",
              title: "Minute-level forecasts",
              text: "Precipitation and wind windows down to the minute, refreshed every model cycle."
            },
            %{
              icon: "hero-map-pin",
              title: "Hyperlocal grid",
              text: "Street-scale interpolation between stations, so the forecast matches your block."
            },
            %{
              icon: "hero-shield-check",
              title: "Uncertainty, upfront",
              text: "Every number ships with a confidence band. No false precision, ever."
            },
            %{
              icon: "hero-bell-alert",
              title: "Smart alerts",
              text: "Threshold alerts that learn what you actually care about and go quiet otherwise."
            },
            %{
              icon: "hero-chart-bar",
              title: "Forecast scoring",
              text: "We grade our own predictions publicly — see exactly how last week went."
            },
            %{
              icon: "hero-code-bracket",
              title: "Developer API",
              text: "The same engine behind the app, exposed as a clean, versioned JSON API."
            }
          ]} />
        </section>
      </div>
    </Layouts.app>
    """
  end
end

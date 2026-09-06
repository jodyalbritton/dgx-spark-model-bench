defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The LumenLab landing page.

  Live state:

  * `countdown` — starts at 100, ticks down 1 every 5 seconds (element
    `#countdown`)
  * `stat-ticks` — number of countdown ticks so far (element
    `#stat-ticks`), read from shared state
  * `stat-signups` — number of signups (element `#stat-signups`), read
    from shared state
  * `signups` — recent signups, newest first (`#signups`)
  * `activity` — feed of ticks and signups, newest first, max 10
    (`#activity`, `<li>` entries)
  """

  use BenchappWeb, :live_view

  alias Benchapp.Signups
  alias BenchappWeb.FeatureComponents

  @tick_interval_ms 5_000
  @countdown_start 100
  @max_activity 10

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "LumenLab — Instruments for curious teams")
      |> assign(countdown: @countdown_start)
      |> assign(form: to_form(Signups.change_signup(), as: :signup))
      |> assign(signups: Signups.recent_signups())
      |> assign(activity: Signups.activities())
      |> assign(stat_signups: Signups.signup_count())
      |> assign(stat_ticks: Signups.tick_count())

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
  def handle_event("save", %{"signup" => %{"email" => email}}, socket) do
    case Signups.create_signup(%{"email" => email}) do
      {:ok, signup} ->
        Signups.add_activity(:signup, "#{signup.email} joined the beta")

        {:noreply,
         socket
         |> assign(form: to_form(Signups.change_signup(), as: :signup))
         |> assign(signups: Signups.recent_signups())
         |> assign(activity: Enum.take(Signups.activities(), @max_activity))
         |> assign(stat_signups: Signups.signup_count())}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :signup))}
    end
  end

  def handle_event(_other, _params, socket), do: {:noreply, socket}

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    countdown = max(socket.assigns.countdown - 1, 0)
    Signups.increment_ticks()
    Signups.add_activity(:tick, "Countdown ticked to #{countdown}")

    {:noreply,
     socket
     |> assign(countdown: countdown)
     |> assign(activity: Enum.take(Signups.activities(), @max_activity))
     |> assign(stat_ticks: Signups.tick_count())}
  end

  def handle_info(_other, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <%!-- Hero --%>
      <section class="relative overflow-hidden">
        <div
          class="pointer-events-none absolute inset-0 bg-gradient-to-b from-primary/10 via-transparent to-transparent"
          aria-hidden="true"
        >
        </div>
        <div class="mx-auto max-w-6xl px-4 py-20 text-center sm:px-6 sm:py-28">
          <p class="text-xs font-semibold uppercase tracking-[0.25em] text-primary">
            Shipping soon
          </p>
          <h1 class="mx-auto mt-4 max-w-3xl text-4xl font-bold tracking-tight text-base-content sm:text-6xl">
            Instruments for <span class="text-primary">curious teams</span>
          </h1>
          <p class="mx-auto mt-6 max-w-2xl text-lg leading-relaxed text-base-content/70">
            LumenLab turns raw team data into clear, beautiful signals —
            realtime dashboards, gentle nudges, and zero spreadsheets.
          </p>
          <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
            <JobyKit.CoreComponents.button
              variant="primary"
              size="lg"
              phx-click={JS.dispatch("lumen:focus-signup")}
            >
              Get early access
            </JobyKit.CoreComponents.button>
            <JobyKit.CoreComponents.button
              variant="ghost"
              size="lg"
              navigate={~p"/about"}
            >
              Learn more
            </JobyKit.CoreComponents.button>
          </div>

          <%!-- Countdown --%>
          <div class="mt-16 flex flex-col items-center gap-3">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-base-content/60">
              Launching in
            </p>
            <p
              id="countdown"
              class="text-7xl font-bold text-base-content sm:text-8xl"
              aria-live="polite"
            >
              {@countdown}
            </p>
            <p class="text-sm text-base-content/60">seconds remaining</p>
          </div>
        </div>
      </section>

      <%!-- Stats strip --%>
      <section id="stats" class="border-y border-base-300 bg-base-200/40">
        <div class="mx-auto grid max-w-6xl grid-cols-1 gap-6 px-4 py-8 text-center sm:grid-cols-2 sm:px-6">
          <div>
            <p class="text-4xl font-bold tabular-nums text-base-content">
              <span id="stat-signups">{@stat_signups}</span>
            </p>
            <p class="mt-1 text-sm font-medium text-base-content/60">
              people signed up
            </p>
          </div>
          <div>
            <p class="text-4xl font-bold tabular-nums text-base-content">
              <span id="stat-ticks">{@stat_ticks}</span>
            </p>
            <p class="mt-1 text-sm font-medium text-base-content/60">
              countdown ticks so far
            </p>
          </div>
        </div>
      </section>

      <%!-- Feature grid (composite: BenchappWeb.FeatureComponents.feature_grid) --%>
      <div class="mx-auto max-w-6xl px-4 py-20 sm:px-6">
        <FeatureComponents.feature_grid
          id="features"
          eyebrow="Why LumenLab"
          title="Everything in the box"
          lede="One page, zero setup: every panel below is live and driven by the same shared state."
        >
          <:feature icon="hero-bolt" title="Realtime first">
            Numbers update the moment they change — no refresh, no polling.
          </:feature>
          <:feature icon="hero-moon" title="Themes that stick">
            Light and dark modes, remembered across visits and tabs.
          </:feature>
          <:feature icon="hero-device-phone-mobile" title="Built for thumbs">
            The nav folds away, the grid stacks, nothing needs a pinch.
          </:feature>
          <:feature icon="hero-inbox" title="Gentle nudges">
            Digest emails that respect attention — one line per signal.
          </:feature>
          <:feature icon="hero-signal" title="Signals, not noise">
            We tune out churned metrics and surface what actually moved.
          </:feature>
          <:feature icon="hero-lock-closed" title="Private by default">
            Your workspace data stays yours, in your region, on request.
          </:feature>
        </FeatureComponents.feature_grid>
      </div>

      <%!-- Newsletter + activity --%>
      <section class="border-t border-base-300 bg-base-200/40">
        <div class="mx-auto grid max-w-6xl gap-10 px-4 py-16 sm:px-6 lg:grid-cols-2">
          <div>
            <h2 class="text-2xl font-semibold tracking-tight text-base-content">
              Join the beta
            </h2>
            <p class="mt-2 text-base text-base-content/70">
              Leave an email and we'll send a single launch note — no drip,
              no spam, unsubscribe in one click.
            </p>

            <.form
              id="signup-form"
              for={@form}
              phx-submit="save"
              class="mt-6"
            >
              <label class="form-control">
                <div class="label">
                  <span class="label-text font-medium">Email address</span>
                </div>
                <div class="join w-full">
                  <JobyKit.CoreComponents.input
                    field={@form[:email]}
                    type="email"
                    name="signup[email]"
                    placeholder="you@example.com"
                    class="join-item w-full"
                    aria-describedby="signup-error"
                  />
                  <JobyKit.CoreComponents.button
                    type="submit"
                    variant="primary"
                    class="join-item"
                  >
                    Sign up
                  </JobyKit.CoreComponents.button>
                </div>
              </label>
              <p id="signup-error" class="mt-2 text-sm text-error" role="alert">
                {signup_error_text(@form[:email])}
              </p>
            </.form>

            <h3 class="mt-10 text-sm font-semibold uppercase tracking-wider text-base-content/60">
              Recent signups
            </h3>
            <ul id="signups" class="mt-3 space-y-2">
              <li
                :for={signup <- @signups}
                id={signup.id}
                class="flex items-center gap-3 rounded-field border border-base-300 bg-base-100 px-3 py-2 text-sm"
              >
                <span class="grid size-7 shrink-0 place-items-center rounded-full bg-primary/10 font-semibold text-primary">
                  {String.upcase(String.first(signup.email))}
                </span>
                <span class="truncate text-base-content">{signup.email}</span>
              </li>
            </ul>
          </div>

          <div>
            <h2 class="text-2xl font-semibold tracking-tight text-base-content">
              Activity
            </h2>
            <p class="mt-2 text-base text-base-content/70">
              Everything happening right now, newest first.
            </p>
            <ul
              id="activity"
              aria-live="polite"
              class="mt-6 space-y-2 rounded-2xl border border-base-300 bg-base-100 p-4"
            >
              <li
                :for={entry <- @activity}
                id={entry.id}
                class="flex items-start gap-3 text-sm"
              >
                <span class={[
                  "mt-0.5 grid size-6 shrink-0 place-items-center rounded-full",
                  entry.kind == :signup && "bg-success/15 text-success",
                  entry.kind == :tick && "bg-info/15 text-info"
                ]}>
                  <JobyKit.CoreComponents.icon
                    name={(entry.kind == :signup && "hero-user-plus") || "hero-clock"}
                    class="size-3.5"
                  />
                </span>
                <span class="text-base-content/80">{entry.label}</span>
              </li>
            </ul>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp signup_error_text(field) do
    case field do
      %{errors: errors} when is_list(errors) ->
        errors
        |> Enum.map(fn {msg, _opts} -> msg end)
        |> Enum.uniq()
        |> Enum.join(", ")

      _ ->
        ""
    end
  end
end

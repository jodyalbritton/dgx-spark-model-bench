defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The Aster landing page. A hero, a live countdown, a newsletter
  signup, a stats strip, an activity feed, and a feature grid.

  The countdown and the signup form are fully live: the countdown ticks
  down every five seconds, and every signup (or validation error) is
  reflected in the course of the page without a reload.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval 5_000
  @max_activity 10
  @email_regex ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  @features [
    %{
      icon: "hero-bolt",
      title: "Instant sync",
      text: "Boards, briefs, and decisions update everywhere the moment you make them."
    },
    %{
      icon: "hero-shield-check",
      title: "Private by default",
      text: "Your work stays yours. Share only what you choose, on every board."
    },
    %{
      icon: "hero-squares-2x2",
      title: "Made for your flow",
      text: "Views that bend to how your team actually works — boards, lists, and more."
    },
    %{
      icon: "hero-cog-6-tooth",
      title: "Deep integrations",
      text: "Connect the tools you already use with one-click, out-of-the-box links."
    },
    %{
      icon: "hero-chart-bar",
      title: "Clarity at a glance",
      text: "Live summaries surface what changed and what needs you next."
    },
    %{
      icon: "hero-sparkles",
      title: "Delightful details",
      text: "Small moments that make long working sessions feel effortless."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, @tick_interval)

    {:ok,
     assign(socket,
       page_title: "Home",
       countdown: 100,
       ticks: 0,
       signups: [],
       activity: [],
       signup_error: nil,
       form: to_form(new_changeset(), as: :newsletter),
       features: @features
     )}
  end

  @impl true
  def handle_info(:tick, socket) do
    countdown = max(socket.assigns.countdown - 1, 0)
    ticks = socket.assigns.ticks + 1

    socket =
      socket
      |> assign(countdown: countdown, ticks: ticks)
      |> add_activity(:tick, "Countdown ticked to #{countdown}")

    Process.send_after(self(), :tick, @tick_interval)
    {:noreply, socket}
  end

  @impl true
  def handle_event("signup", params, socket) do
    email = params["email"] || get_in(params, ["newsletter", "email"]) || ""
    email = String.trim(email)

    cond do
      email == "" ->
        {:noreply, set_signup_error(socket, email, "Please enter your email address.")}

      not valid_email?(email) ->
        {:noreply,
         set_signup_error(socket, email, "That doesn't look like a valid email address.")}

      email in socket.assigns.signups ->
        {:noreply, set_signup_error(socket, email, "This email is already on the list.")}

      true ->
        socket =
          socket
          |> update(:signups, &[email | &1])
          |> add_activity(:signup, "New signup: #{email}")
          |> assign(:signup_error, nil)
          |> assign(:form, to_form(new_changeset(), as: :newsletter))

        {:noreply, socket}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp set_signup_error(socket, email, message) do
    socket
    |> assign(:form, to_form(new_changeset(%{"email" => email}), as: :newsletter))
    |> assign(:signup_error, message)
  end

  defp add_activity(socket, kind, text) do
    entry = %{kind: kind, text: text}

    socket
    |> update(:activity, fn list ->
      [entry | list] |> Enum.take(@max_activity)
    end)
  end

  defp valid_email?(email), do: Regex.match?(@email_regex, email)

  defp new_changeset(params \\ %{}) do
    {%{}, %{email: :string}}
    |> Ecto.Changeset.cast(params, [:email])
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl px-4 sm:px-6">
        <section class="relative overflow-hidden pb-16 pt-16 sm:pb-24 sm:pt-20">
          <div
            aria-hidden="true"
            class="pointer-events-none absolute inset-x-0 -top-24 -z-10 mx-auto size-[34rem] rounded-full bg-primary/20 blur-3xl"
          >
          </div>

          <div class="grid items-center gap-10 lg:grid-cols-2">
            <div class="space-y-6">
              <.header
                level="h1"
                size="page"
                title_class="text-4xl font-semibold tracking-tight sm:text-5xl"
              >
                The calm workspace for creative teams
                <:eyebrow>Aster</:eyebrow>
                <:subtitle>
                  Plan, track, and ship projects without the chaos. Aster is
                  the single, quiet home for your team's ideas and decisions.
                </:subtitle>
              </.header>

              <div class="flex flex-wrap items-center gap-4">
                <.button variant="primary" size="lg" href="#signup-form">
                  Join the waitlist <.icon name="hero-arrow-down" class="size-4" />
                </.button>
                <.badge tone="ok">Early access opening soon</.badge>
              </div>
              <p class="text-sm text-base-content/60">Free for teams up to 10 people.</p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2">
              <div class="col-span-2 rounded-2xl border border-base-300/60 bg-base-100/60 p-6 shadow-sm">
                <.eyebrow>Launch countdown</.eyebrow>
                <div id="countdown" class="mt-2 text-6xl font-semibold tabular-nums tracking-tight">
                  {@countdown}
                </div>
                <p class="mt-1 text-sm text-base-content/60">
                  Spots are released in waves. The countdown updates live.
                </p>
              </div>

              <.card>
                <:eyebrow>What you get</:eyebrow>
                <:title>Everything in one place</:title>
                Boards, briefs, docs, and decisions — together at last, with
                nothing to switch between.
              </.card>

              <.card>
                <:eyebrow>Built to last</:eyebrow>
                <:title>Works everywhere</:title>
                A responsive workspace that feels at home on any screen, in
                light or dark.
              </.card>
            </div>
          </div>
        </section>

        <section
          id="stats"
          class="grid gap-4 rounded-2xl border border-base-300/60 bg-base-100/60 p-6 sm:grid-cols-2"
        >
          <div class="flex items-center gap-3">
            <span class="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <.icon name="hero-users" class="size-5" />
            </span>
            <div>
              <div id="stat-signups" class="text-3xl font-semibold tabular-nums">
                {length(@signups)}
              </div>
              <p class="text-sm text-base-content/60">Waitlist signups</p>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <span class="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <.icon name="hero-clock" class="size-5" />
            </span>
            <div>
              <div id="stat-ticks" class="text-3xl font-semibold tabular-nums">{@ticks}</div>
              <p class="text-sm text-base-content/60">Countdown ticks</p>
            </div>
          </div>
        </section>

        <section class="grid gap-10 py-16 sm:py-20 lg:grid-cols-2">
          <div class="space-y-6">
            <.header level="h2">
              Join the waitlist
              <:eyebrow>Be first</:eyebrow>
              <:subtitle>
                Get early access and a lifetime founder discount. No spam.
              </:subtitle>
            </.header>

            <.form for={@form} id="signup-form" phx-submit="signup">
              <div class="flex flex-col gap-3 sm:flex-row">
                <div class="flex-1">
                  <.input
                    field={@form[:email]}
                    type="email"
                    label="Email"
                    placeholder="you@example.com"
                    autocomplete="email"
                    input_class={@signup_error && "input-error"}
                  />
                </div>
                <.button type="submit" variant="primary">Sign up</.button>
              </div>
              <div :if={@signup_error} id="signup-error" class="mt-3 text-sm text-error" role="alert">
                {assigns[:signup_error]}
              </div>
            </.form>

            <div>
              <h3 class="mb-3 text-sm font-semibold text-base-content/70">Recent signups</h3>
              <ul
                :if={@signups != []}
                id="signups"
                class="flex max-h-56 flex-col gap-2 overflow-y-auto"
              >
                <li :for={email <- @signups} class="flex items-center gap-2 text-sm">
                  <span class="size-1.5 rounded-full bg-primary" aria-hidden="true"></span>
                  <span class="truncate">{email}</span>
                </li>
              </ul>
              <p :if={@signups == []} class="text-sm text-base-content/50">
                No signups yet — be the first.
              </p>
            </div>
          </div>

          <div class="space-y-6">
            <.header level="h2">
              Live activity
              <:eyebrow>What's happening</:eyebrow>
              <:subtitle>Every signup and countdown tick, newest first.</:subtitle>
            </.header>

            <ul id="activity" class="flex flex-col gap-2">
              <li
                :for={entry <- @activity}
                class="flex items-center gap-3 rounded-xl border border-base-300/50 bg-base-100/50 px-4 py-3"
              >
                <span class={[
                  "size-2 shrink-0 rounded-full",
                  entry.kind == "signup" && "bg-primary",
                  entry.kind == "tick" && "bg-base-300"
                ]} />
                <span class="text-sm text-base-content/75">{entry.text}</span>
              </li>
              <li :if={@activity == []} class="text-sm text-base-content/50">
                Nothing yet — activity appears here as it happens.
              </li>
            </ul>
          </div>
        </section>

        <section class="space-y-8 pb-20">
          <.header level="h2">
            Everything your team needs
            <:eyebrow>Features</:eyebrow>
            <:subtitle>Thoughtful by design, effortless in practice.</:subtitle>
          </.header>

          <CompositeComponents.feature_grid :if={@features != []}>
            <:feature :for={feature <- @features} icon={feature.icon} title={feature.title}>
              {feature.text}
            </:feature>
          </CompositeComponents.feature_grid>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

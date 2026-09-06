defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The Nimbus landing page.

  A hero, a live countdown, a newsletter signup, a stats strip, and an
  activity feed. All state is in-memory in the LiveView process.
  """

  use BenchappWeb, :live_view

  @max_activity 10
  @tick_interval 5_000
  @email_regex ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :tick, @tick_interval)
    end

    {:ok,
     assign(socket,
       page_title: "Nimbus",
       countdown: 100,
       ticks: 0,
       signups: [],
       signup_error: nil,
       activity: [],
       form: to_form(%{}, as: :signup)
     )}
  end

  @impl true
  def handle_info(:tick, socket) do
    new_countdown = socket.assigns.countdown - 1

    socket =
      socket
      |> assign(:countdown, new_countdown)
      |> update(:ticks, &(&1 + 1))
      |> prepend_activity(%{kind: :tick, text: "Countdown ticked to #{new_countdown}"})

    Process.send_after(self(), :tick, @tick_interval)
    {:noreply, socket}
  end

  @impl true
  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    email = String.trim(email)

    cond do
      email == "" or not Regex.match?(@email_regex, email) ->
        {:noreply,
         assign(socket,
           form: to_form(%{"email" => email}, as: :signup),
           signup_error: "Please enter a valid email address."
         )}

      email in socket.assigns.signups ->
        {:noreply,
         assign(socket,
           form: to_form(%{"email" => email}, as: :signup),
           signup_error: "That email is already on the list."
         )}

      true ->
        {:noreply,
         socket
         |> update(:signups, &[email | &1])
         |> assign(:form, to_form(%{}, as: :signup))
         |> assign(:signup_error, nil)
         |> prepend_activity(%{kind: :signup, text: "New subscriber: #{email}"})}
    end
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp prepend_activity(socket, entry) do
    activity = Enum.take([entry | socket.assigns.activity], @max_activity)
    assign(socket, :activity, activity)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="relative isolate overflow-hidden">
        <div class="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(ellipse_at_top_left,oklch(70%_0.21_47.6/0.16),transparent_55%),radial-gradient(ellipse_at_bottom_right,oklch(60%_0.25_292.7/0.14),transparent_55%)]">
        </div>

        <div class="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
          <div class="mx-auto max-w-3xl text-center">
            <p class="mb-4 inline-flex items-center gap-2 rounded-full border border-base-300 bg-base-100/70 px-3 py-1 text-xs font-medium text-base-content/70 backdrop-blur">
              <span class="size-1.5 rounded-full bg-primary"></span> Hyperlocal weather intelligence
            </p>
            <h1 class="text-4xl font-bold leading-tight tracking-tight text-base-content sm:text-6xl">
              Know what the sky
              <span class="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                is planning
              </span>
              .
            </h1>
            <p class="mx-auto mt-6 max-w-xl text-lg text-base-content/70">
              Nimbus blends radar, satellites, and street-level sensors into a forecast
              that follows your route — not your zip code.
            </p>
            <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
              <.button variant="primary" size="lg" navigate={~p"/about"}>See how it works</.button>
              <.button variant="ghost" size="lg" href="#signup-form">Join the waitlist</.button>
            </div>
          </div>

          <div class="mt-16 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <div class="card border border-base-300 bg-base-100/70 backdrop-blur">
              <div class="card-body items-center justify-center text-center">
                <span class="font-mono text-5xl font-bold tabular-nums text-primary" id="countdown">
                  {@countdown}
                </span>
                <p class="text-sm text-base-content/60">seconds until the next drop</p>
              </div>
            </div>
            <div class="card border border-base-300 bg-base-100/70 backdrop-blur lg:col-span-2">
              <div class="card-body gap-4">
                <.stats_strip ticks={@ticks} signups={length(@signups)} />
                <.signup_form form={@form} error={@signup_error} />
                <div class="border-t border-base-300/60 pt-4">
                  <h3 class="mb-2 text-sm font-semibold text-base-content">Recent signups</h3>
                  <ul id="signups" class="space-y-1">
                    <li
                      :for={email <- @signups}
                      class="flex items-center gap-2 text-sm text-base-content/75"
                    >
                      <span class="size-1.5 rounded-full bg-success"></span>
                      <span class="font-mono text-xs">{email}</span>
                    </li>
                    <li :if={@signups == []} class="text-sm text-base-content/45">
                      No signups yet — be the first.
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="mx-auto max-w-6xl px-4 pb-20 sm:px-6">
        <BenchappWeb.CompositeComponents.feature_grid features={[
          %{
            icon: "hero-arrow-path",
            title: "Live radar",
            detail: "Rain cells tracked minute by minute across your whole region."
          },
          %{
            icon: "hero-sun",
            title: "Street-level precision",
            detail: "Ensemble models trained on thousands of local sensors."
          },
          %{
            icon: "hero-bolt",
            title: "Instant alerts",
            detail: "Lightning-fast push updates the moment conditions shift."
          },
          %{
            icon: "hero-map",
            title: "Route-aware",
            detail: "Forecasts that follow your drive, not just your start point."
          },
          %{
            icon: "hero-clipboard-document-list",
            title: "Historical climate",
            detail: "Thirty years of climate data behind every projection."
          },
          %{
            icon: "hero-shield-check",
            title: "Privacy first",
            detail: "Your location stays on-device. Always."
          }
        ]} />

        <section class="mt-14">
          <div class="mb-4 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-base-content">Live activity</h2>
            <span class="text-xs text-base-content/50">Newest first</span>
          </div>
          <ul id="activity" class="space-y-2">
            <li
              :for={entry <- @activity}
              class="flex items-center gap-3 rounded-lg border border-base-300 bg-base-100/60 px-4 py-2 text-sm"
            >
              <span class={[
                "size-2 shrink-0 rounded-full",
                entry.kind == :signup && "bg-success",
                entry.kind == :tick && "bg-primary"
              ]}></span>
              <span class="text-base-content/80">{entry.text}</span>
            </li>
            <li :if={@activity == []} class="px-1 py-2 text-sm text-base-content/50">
              No activity yet — sign up or watch the countdown.
            </li>
          </ul>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp stats_strip(assigns) do
    ~H"""
    <div id="stats" class="grid grid-cols-2 gap-3">
      <div class="rounded-xl border border-base-300/60 bg-base-100/60 p-3">
        <p class="font-mono text-2xl font-bold tabular-nums text-base-content" id="stat-signups">
          {@signups}
        </p>
        <p class="text-xs text-base-content/60">Signups</p>
      </div>
      <div class="rounded-xl border border-base-300/60 bg-base-100/60 p-3">
        <p class="font-mono text-2xl font-bold tabular-nums text-base-content" id="stat-ticks">
          {@ticks}
        </p>
        <p class="text-xs text-base-content/60">Countdown ticks</p>
      </div>
    </div>
    """
  end

  defp signup_form(assigns) do
    ~H"""
    <div>
      <h2 class="text-base font-semibold text-base-content">Join the waitlist</h2>
      <p class="mt-1 text-sm text-base-content/60">
        Be first to hear when Nimbus arrives in your city.
      </p>
      <.form
        for={@form}
        id="signup-form"
        phx-submit="signup"
        class="mt-3 flex flex-col gap-3 sm:flex-row"
      >
        <.input
          field={@form[:email]}
          type="email"
          placeholder="you@example.com"
          autocomplete="email"
          class="flex-1"
        />
        <.button type="submit" variant="primary">Notify me</.button>
      </.form>
      <p :if={@error} id="signup-error" class="mt-2 text-sm text-error" role="alert">
        {@error}
      </p>
    </div>
    """
  end
end

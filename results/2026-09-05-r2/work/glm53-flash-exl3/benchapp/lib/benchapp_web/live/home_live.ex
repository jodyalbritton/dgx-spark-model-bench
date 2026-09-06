defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Landing page for Solstice: hero, live countdown, newsletter signup,
  stats strip, activity feed, and a feature grid.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval_ms 5_000
  @countdown_start 100
  @activity_limit 10
  @email_regex ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  @features [
    %{
      icon: "hero-bolt",
      title: "Instant on",
      text: "Full-spectrum light the moment you sit down — no warm-up, no fumbling."
    },
    %{
      icon: "hero-moon",
      title: "Wind-down mode",
      text: "Melatonin-friendly amber as evening arrives, tuned to your local sunset."
    },
    %{
      icon: "hero-cpu-chip",
      title: "Learns your rhythm",
      text: "On-device tuning adapts to when you focus, rest, and recharge."
    },
    %{
      icon: "hero-wifi",
      title: "Quietly connected",
      text: "Syncs across every Solstice in your home without accounts or clouds."
    },
    %{
      icon: "hero-eye-slash",
      title: "Zero flicker",
      text: "Flicker-free drivers certified for eight-hour sessions at any brightness."
    },
    %{
      icon: "hero-leaf",
      title: "Built to last",
      text: "A recyclable aluminium body rated for 60,000 hours of light."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Solstice",
        features: @features,
        countdown: @countdown_start,
        ticks: 0,
        signups: [],
        activity: [],
        signup_error: nil,
        form: to_form(%{"email" => ""}, as: :signup)
      )

    if connected?(socket) do
      Process.send_after(self(), :tick, @tick_interval_ms)
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"signup" => %{"email" => email}}, socket) do
    email = String.trim(email)

    cond do
      not Regex.match?(@email_regex, email) ->
        {:noreply, assign(socket, signup_error: "Please enter a valid email address.")}

      email in socket.assigns.signups ->
        {:noreply,
         assign(socket,
           signup_error: "That address is already on the list.",
           form: to_form(%{"email" => email}, as: :signup)
         )}

      true ->
        {:noreply,
         socket
         |> assign(
           signups: [email | socket.assigns.signups],
           signup_error: nil,
           form: to_form(%{"email" => ""}, as: :signup)
         )
         |> add_activity("New signup: #{email}")}
    end
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick_interval_ms)

    {:noreply,
     socket
     |> assign(countdown: socket.assigns.countdown - 1, ticks: socket.assigns.ticks + 1)
     |> add_activity("Countdown tick — #{socket.assigns.countdown - 1} remaining")}
  end

  defp add_activity(socket, text) do
    entry = %{id: System.unique_integer([:positive]), text: text}
    assign(socket, activity: Enum.take([entry | socket.assigns.activity], @activity_limit))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div class="mx-auto max-w-5xl space-y-16 px-4 py-12 sm:px-6">
        <%!-- Hero --%>
        <section class="grid items-center gap-10 lg:grid-cols-2">
          <div class="space-y-6">
            <CompositeComponents.section_heading
              large
              eyebrow="Solstice · early access"
              title="The desk lamp that keeps pace with your rhythm."
            />
            <p class="max-w-prose text-lg text-base-content/70">
              Solstice reads your day and shapes its light to match — bright and
              crisp for deep work, warm and dim when it's time to come down.
              No apps to babysit. No accounts. Just better light.
            </p>
            <div class="flex flex-wrap items-center gap-3">
              <.button variant="primary" href="#signup-form">
                Join the early access
              </.button>
              <.button navigate={~p"/about"} variant="ghost">Read the story</.button>
            </div>
          </div>

          <div class="card bg-gradient-to-br from-primary/15 via-base-200 to-base-100 shadow-xl ring-1 ring-base-300">
            <div class="card-body items-center gap-2 py-14 text-center">
              <p class="text-xs font-semibold uppercase tracking-widest text-base-content/60">
                Early-bird places remaining
              </p>
              <p id="countdown" class="text-7xl font-black tabular-nums text-primary">
                {@countdown}
              </p>
              <p class="text-sm text-base-content/60">one spot opens up every five seconds</p>
            </div>
          </div>
        </section>

        <%!-- Stats strip --%>
        <section
          id="stats"
          class="stats stats-vertical w-full bg-base-100 shadow-sm ring-1 ring-base-300 sm:stats-horizontal"
        >
          <div class="stat">
            <div class="stat-title">Signups</div>
            <div id="stat-signups" class="stat-value text-primary">{length(@signups)}</div>
            <div class="stat-desc">people on the early-access list</div>
          </div>
          <div class="stat">
            <div class="stat-title">Countdown ticks</div>
            <div id="stat-ticks" class="stat-value">{@ticks}</div>
            <div class="stat-desc">since you opened this page</div>
          </div>
          <div class="stat">
            <div class="stat-title">Hours of light</div>
            <div class="stat-value">60k</div>
            <div class="stat-desc">rated lifetime per lamp</div>
          </div>
        </section>

        <%!-- Feature grid --%>
        <section class="space-y-6">
          <CompositeComponents.section_heading
            eyebrow="Features"
            title="Everything a desk lamp should be"
          />
          <CompositeComponents.feature_grid features={@features} />
        </section>

        <%!-- Newsletter + activity --%>
        <section class="grid gap-8 lg:grid-cols-2">
          <div class="space-y-4">
            <CompositeComponents.section_heading eyebrow="Newsletter" title="Get the launch email">
              One message when early access opens. No drip campaigns, ever.
            </CompositeComponents.section_heading>

            <.form id="signup-form" for={@form} phx-submit="save" class="space-y-2">
              <div class="join w-full">
                <.input
                  field={@form[:email]}
                  type="email"
                  placeholder="you@example.com"
                  aria-label="Email address"
                  class="join-item w-full"
                />
                <.button variant="primary" class="join-item">
                  Sign up
                </.button>
              </div>
              <p
                :if={@signup_error}
                id="signup-error"
                class="text-sm font-medium text-error"
                role="alert"
              >
                {@signup_error}
              </p>
            </.form>

            <div class="space-y-1">
              <h3 class="text-sm font-semibold uppercase tracking-widest text-base-content/60">
                Recent signups
              </h3>
              <ul id="signups" class="space-y-1 text-sm text-base-content/80">
                <li :for={email <- @signups} class="rounded-field bg-base-200 px-3 py-1.5 font-mono">
                  {email}
                </li>
                <li :if={@signups == []} class="text-base-content/50">No signups yet — be first.</li>
              </ul>
            </div>
          </div>

          <div class="space-y-4">
            <CompositeComponents.section_heading eyebrow="Live activity" title="Right now" />
            <div class="card bg-base-100 shadow-sm ring-1 ring-base-300">
              <div class="card-body py-4">
                <ul id="activity" class="space-y-2 text-sm">
                  <li
                    :for={entry <- @activity}
                    class="flex items-center gap-2 rounded-field bg-base-200/60 px-3 py-1.5"
                  >
                    <.icon name="hero-clock" class="size-4 shrink-0 text-primary" />
                    <span>{entry.text}</span>
                  </li>
                  <li :if={@activity == []} class="text-base-content/50">
                    Waiting for the first tick…
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

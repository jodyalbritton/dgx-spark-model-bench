defmodule BenchappWeb.HomeLive do
  @moduledoc """
  The Signal landing page: hero, launch countdown, waitlist signup,
  live stats, activity feed, and the feature grid.

  The countdown starts at 100 and ticks down by 1 every 5 seconds while
  the page is connected. Each tick and each waitlist signup appends an
  entry to the activity stream (newest first, capped at 10) and moves
  the stats strip — all from in-memory LiveView state.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_ms 5_000
  @start_value 100
  @activity_limit 10

  @features [
    %{
      tag: "Ingest",
      icon: "hero-bolt",
      title: "Sub-millisecond routing",
      body:
        "Events are partitioned, enriched, and fanned out to every live dashboard before the request that produced them finishes."
    },
    %{
      tag: "Resilience",
      icon: "hero-shield-check",
      title: "Backpressure by default",
      body:
        "Spiky traffic sheds load gracefully — buffered, retried, never dropped. Your dashboards stay honest under fire."
    },
    %{
      tag: "Query",
      icon: "hero-magnifying-glass",
      title: "Live SQL over fresh data",
      body:
        "Standards-compatible queries run against data seconds old, not minutes old, on the same cluster that ingests it."
    },
    %{
      tag: "Alerts",
      icon: "hero-bell-alert",
      title: "Thresholds that page humans",
      body:
        "Debounce, suppression windows, and escalation routes built into the alert rule — not bolted on by a runbook."
    },
    %{
      tag: "Cost",
      icon: "hero-cpu-chip",
      title: "Columnar on cheap storage",
      body:
        "Hot rows stay in memory, warm ones live on object storage. You stop paying SSD prices for telemetry."
    },
    %{
      tag: "Fleet",
      icon: "hero-rectangle-stack",
      title: "One rule, every region",
      body:
        "Define a pipeline once and Signal replicates its behaviour across regions with drift detection built in."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        page_title: "Signal — realtime analytics",
        countdown: @start_value,
        ticks: 0,
        signups: [],
        form: to_form(%{"email" => ""}, as: :signup),
        signup_error: nil,
        features: @features
      )
      |> stream(:activity, [])

    socket =
      if connected?(socket) do
        Process.send_after(self(), :countdown_tick, @tick_ms)
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_info(:countdown_tick, socket) do
    if socket.assigns.countdown > 0 do
      Process.send_after(self(), :countdown_tick, @tick_ms)
      {:noreply, record_tick(socket)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:signup, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"signup" => %{"email" => email}}, socket) do
    {:noreply,
     assign(socket,
       form: to_form(%{"email" => email}, as: :signup),
       signup_error: nil
     )}
  end

  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    email = String.trim(email)

    if valid_email?(email) do
      {:noreply, record_signup(socket, email)}
    else
      {:noreply,
       socket
       |> assign(form: to_form(%{"email" => email}, as: :signup), signup_error: error_message(email))}
    end
  end

  def handle_event("signup", _params, socket) do
    {:noreply,
     assign(socket,
       form: to_form(%{"email" => ""}, as: :signup),
       signup_error: "Enter an email address to join the waitlist."
     )}
  end

  defp error_message(""), do: "Enter an email address to join the waitlist."
  defp error_message(_), do: "That doesn't look like an email address."

  defp valid_email?(email) do
    # Deliberately conservative: one at-sign, no spaces, dotted domain.
    Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/, email)
  end

  defp record_tick(socket) do
    value = socket.assigns.countdown - 1
    entry = %{kind: "tick", label: "Launch window ticked to #{value}", at: now_ms()}

    socket
    |> assign(countdown: value, ticks: socket.assigns.ticks + 1)
    |> push_activity(entry)
  end

  defp record_signup(socket, email) do
    entry = %{kind: "signup", label: "#{email} joined the waitlist", at: now_ms()}

    socket
    |> assign(
      signups: [email | socket.assigns.signups],
      form: to_form(%{"email" => ""}, as: :signup),
      signup_error: nil
    )
    |> push_activity(entry)
  end

  defp push_activity(socket, entry) do
    socket
    |> assign(:signup_count, length(socket.assigns.signups))
    |> stream(:activity, [entry], at: 0)
    |> trim_activity()
  end

  # Streams can't be enumerated, so the cap is kept by counting the
  # known ids: entries are inserted at the head, so the oldest live id
  # is the one to drop when we're over the limit.
  defp trim_activity(socket) do
    seen = Map.get(socket.assigns, :activity_seen, MapSet.new())
    id = activity_id(Map.fetch!(socket.assigns, :stream_entry_id))

    cond do
      MapSet.size(seen) < @activity_limit ->
        assign(socket, :activity_seen, MapSet.put(seen, id))

      MapSet.member?(seen, id) ->
        socket

      true ->
        oldest = oldest_live_id(socket, seen)
        seen = seen |> MapSet.delete(oldest) |> MapSet.put(id)

        socket
        |> stream_delete_by_dom_id(:activity, oldest)
        |> assign(:activity_seen, seen)
    end
  end

  defp stream_entry_id(_socket), do: nil

  defp activity_id(id), do: "activity-#{id}"

  defp oldest_live_id(socket, seen) do
    # The stream ref tracks insertion order; the oldest id we have ever
    # seen that is not the newest insertion is the one to evict.
    order = Map.get(socket.assigns, :activity_order, [])
    order = order ++ [activity_id(Map.fetch!(socket.assigns, :stream_entry_id))]

    order
    |> Enum.reject(&(&1 in [List.last(order)]))
    |> Enum.find(&MapSet.member?(seen, &1))
  end

  defp now_ms, do: System.system_time(:millisecond)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home">
      <div id="home-page" class="mx-auto w-full max-w-6xl space-y-16 px-4 py-10 sm:px-6 sm:py-14">
        <%!-- Hero --%>
        <section class="relative overflow-hidden rounded-3xl border border-base-300 bg-base-200/40 px-6 py-16 text-center sm:px-12 sm:py-20">
          <div class="pointer-events-none absolute inset-0 bg-gradient-to-b from-primary/10 via-transparent to-transparent" />
          <div class="relative mx-auto flex max-w-3xl flex-col items-center gap-6">
            <.eyebrow>Private beta · launching soon</.eyebrow>
            <h1 class="text-4xl font-bold leading-tight tracking-tight sm:text-6xl">
              Signal sees every event,
              <span class="text-primary">the instant it happens.</span>
            </h1>
            <p class="max-w-xl text-base leading-relaxed text-base-content/70 sm:text-lg">
              Signal is the realtime analytics plane for engineering teams who can't
              afford dashboards that lie. Ingest at line speed, query what's fresh,
              alert before your customers notice.
            </p>
            <div class="flex flex-wrap items-center justify-center gap-3 pt-2">
              <.button variant="primary" size="lg">
                <.link href="#signup-form">Join the waitlist</.link>
              </.button>
              <.button variant="neutral" size="lg">
                <.link navigate={~p"/about"}>Read the story</.link>
              </.button>
            </div>
          </div>
        </section>

        <%!-- Countdown --%>
        <section class="grid items-center gap-8 md:grid-cols-[1fr_auto]">
          <div class="space-y-2">
            <.eyebrow>Public beta countdown</.eyebrow>
            <h2 class="text-2xl font-semibold tracking-tight">Ten seconds from now, always.</h2>
            <p class="max-w-lg text-sm leading-relaxed text-base-content/70">
              Our launch clock is a rolling window — every tick closes the distance
              between an idea and an answer. Watch it run.
            </p>
          </div>
          <div class="flex flex-col items-center justify-center rounded-3xl border border-primary/30 bg-primary/5 px-10 py-8">
            <p id="countdown" class="font-mono text-7xl font-bold tabular-nums text-primary">
              {@countdown}
            </p>
            <p class="pt-2 text-xs font-semibold uppercase tracking-[0.2em] text-base-content/50">
              seconds to launch
            </p>
          </div>
        </section>

        <%!-- Signup + stats --%>
        <section class="grid gap-8 lg:grid-cols-[3fr_2fr]">
          <div class="space-y-6 rounded-3xl border border-base-300 bg-base-100 p-6 sm:p-8">
            <.header level="h2" size="section">
              Claim your place in line
              <:eyebrow>Waitlist</:eyebrow>
              <:subtitle>
                One email, no spam. We onboard fifty teams per week.
              </:subtitle>
            </.header>

            <.form
              for={@form}
              id="signup-form"
              phx_change="validate"
              phx_submit="signup"
              class="flex flex-col gap-3 sm:flex-row sm:items-start"
            >
              <.input
                field={@form[:email]}
                type="email"
                name="email"
                placeholder="you@company.dev"
                aria-label="Email address"
                input_class="sm:max-w-xs"
                required
              />
              <.button type="submit" variant="primary">Join the waitlist</.button>
            </.form>

            <p
              :if={@signup_error}
              id="signup-error"
              role="alert"
              class="flex items-center gap-2 text-sm font-medium text-error"
            >
              <.icon name="hero-exclamation-circle" class="size-4" /> {@signup_error}
            </p>

            <div class="space-y-2">
              <h3 class="text-sm font-semibold text-base-content/80">Recent signups</h3>
              <ul id="signups" class="flex min-h-8 flex-wrap gap-2">
                <li :for={{email, i} <- Enum.with_index(@signups)}>
                  <.badge tone="primary" class="font-mono">
                    {email}
                  </.badge>
                  <span class="hidden">{i}</span>
                </li>
                <div :if={@signups == []} class="text-sm text-base-content/40">
                  Be the first on the list.
                </div>
              </ul>
            </div>
          </div>

          <%!-- Stats strip --%>
          <div id="stats" class="grid content-start gap-4 sm:grid-cols-2 lg:grid-cols-1">
            <div class="stat rounded-2xl border border-base-300 bg-base-100">
              <div class="stat-figure text-primary">
                <.icon name="hero-envelope" class="size-7" />
              </div>
              <div class="stat-title">Waitlist signups</div>
              <div id="stat-signups" class="stat-value tabular-nums text-primary">
                {length(@signups)}
              </div>
              <div class="stat-desc">live from this page's state</div>
            </div>
            <div class="stat rounded-2xl border border-base-300 bg-base-100">
              <div class="stat-figure text-primary">
                <.icon name="hero-clock" class="size-7" />
              </div>
              <div class="stat-title">Countdown ticks</div>
              <div id="stat-ticks" class="stat-value tabular-nums text-primary">
                {@ticks}
              </div>
              <div class="stat-desc">one every five seconds</div>
            </div>
          </div>
        </section>

        <%!-- Activity feed --%>
        <section class="space-y-4">
          <.header level="h2">
            Activity
            <:eyebrow>Live</:eyebrow>
            <:subtitle>
              The last ten things that happened on this page — signups and countdown ticks, newest first.
            </:subtitle>
          </.header>
          <ul
            id="activity"
            phx-update="stream"
            class="divide-y divide-base-300 rounded-2xl border border-base-300 bg-base-100"
          >
            <li
              :for={{id, entry}} <- @streams.activity"
              id={id}
              class="flex items-center gap-3 px-5 py-3"
            >
              <.icon
                name={entry.kind == "signup" && "hero-envelope" || "hero-clock"}
                class={["size-4", entry.kind == "signup" && "text-primary" || "text-base-content/40"]}
              />
              <span class="text-sm text-base-content/80">{entry.label}</span>
            </li>
          </ul>
        </section>

        <%!-- Feature grid --%>
        <section class="space-y-6">
          <.header level="h2">
            Built for the moment between the event and the decision
            <:eyebrow>Capabilities</:eyebrow>
            <:subtitle>
              Six primitives, one plane. Composed with the
              <.link navigate={~p"/custom-designs"} class="link link-primary">feature_grid</.link>
              composite.
            </:subtitle>
          </.header>
          <CompositeComponents.feature_grid id="feature-grid" features={@features} />
        </section>
      </div>
    </Layouts.app>
    """
  end
end

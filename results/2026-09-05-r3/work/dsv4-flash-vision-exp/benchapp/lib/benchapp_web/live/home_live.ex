defmodule BenchappWeb.HomeLive do
  @moduledoc """
  Hearth landing page.

  A hero, a live launch countdown, an early-access signup form, a stats
  strip, an activity feed, and a feature grid composed from registered
  composites. All interactive state lives in this LiveView — there is no
  database and no persistence.

  The countdown starts at 100 and decrements by 1 every five seconds,
  driven by a timer started in `mount/3`. Each tick (and each signup)
  also lands as an entry in the activity feed, which keeps the ten most
  recent items.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @tick_interval 5_000
  @max_activity 10
  @email_regex ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  @features [
    %{
      icon: "hero-users",
      title: "Shared everything",
      body:
        "One list for every errand, plan, and packing run. Everyone sees the same update, instantly."
    },
    %{
      icon: "hero-moon",
      title: "Quiet by design",
      body:
        "No feeds, no noise. Just the things your household cares about, in the order that matters."
    },
    %{
      icon: "hero-lock-closed",
      title: "Private by default",
      body:
        "Your space is yours alone. Invite-only, encrypted in transit, and never sold or mined."
    },
    %{
      icon: "hero-device-phone-mobile",
      title: "Every device",
      body:
        "Phone, tablet, or desktop — the hearth follows you from the kitchen table to the porch."
    },
    %{
      icon: "hero-bell",
      title: "Gentle reminders",
      body: "Timers and nudges that arrive when they're useful, and stay silent when they aren't."
    },
    %{
      icon: "hero-heart",
      title: "Built to last",
      body: "A home for your family's story: recipes, traditions, and plans that outlive any app."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Home")
     |> assign(countdown: 100)
     |> assign(ticks: 0)
     |> assign(signups: [])
     |> assign(activity: [])
     |> assign(signup_error: nil)
     |> assign(signup_form: to_form(%{"email" => ""}, as: :signup))
     |> assign(mobile_open: false)
     |> assign(features: @features)
     |> schedule_tick()}
  end

  @impl true
  def handle_info(:tick, socket) do
    ticks = socket.assigns.ticks + 1
    countdown = max(socket.assigns.countdown - 1, 0)

    {:noreply,
     socket
     |> assign(countdown: countdown, ticks: ticks)
     |> add_activity(%{kind: :tick, text: "Countdown tick ##{ticks} · now at #{countdown}"})
     |> schedule_tick()}
  end

  @impl true
  def handle_event("toggle-nav", _params, socket) do
    {:noreply, update(socket, :mobile_open, &(!&1))}
  end

  @impl true
  def handle_event("signup", %{"signup" => %{"email" => email}}, socket) do
    email = (email || "") |> String.trim()
    stored = Enum.map(socket.assigns.signups, &String.downcase/1)

    cond do
      email == "" ->
        {:noreply,
         socket
         |> put_signup_error("Please enter your email address.")
         |> put_signup_email(email)}

      not Regex.match?(@email_regex, email) ->
        {:noreply,
         socket
         |> put_signup_error("That doesn't look like a valid email — try again?")
         |> put_signup_email(email)}

      String.downcase(email) in stored ->
        {:noreply,
         socket
         |> put_signup_error("That address is already on the list.")
         |> put_signup_email(email)}

      true ->
        {:noreply,
         socket
         |> assign(signups: [email | socket.assigns.signups])
         |> assign(signup_error: nil)
         |> assign(signup_form: to_form(%{"email" => ""}, as: :signup))
         |> add_activity(%{kind: :signup, text: "#{email} joined the early-access list"})}
    end
  end

  def handle_event("signup", _params, socket) do
    {:noreply, put_signup_error(socket, "Please enter your email address.")}
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp put_signup_email(socket, email) do
    assign(socket, :signup_form, to_form(%{"email" => email}, as: :signup))
  end

  defp put_signup_error(socket, message) do
    assign(socket, :signup_error, message)
  end

  defp add_activity(socket, entry) do
    entry = Map.put(entry, :id, System.unique_integer([:positive]))

    update(socket, :activity, fn activity ->
      Enum.take([entry | activity], @max_activity)
    end)
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, @tick_interval)
    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="home" mobile_open={@mobile_open}>
      <div class="relative">
        <!-- Hero -->
        <section class="relative overflow-hidden">
          <div aria-hidden="true" class="pointer-events-none absolute inset-0 -z-10">
            <div class="hero-glow absolute inset-0"></div>
          </div>

          <div class="mx-auto max-w-5xl px-4 pb-16 pt-16 sm:px-6 sm:pb-24 sm:pt-24">
            <div class="mx-auto max-w-2xl text-center">
              <p class="mx-auto inline-flex items-center gap-2 rounded-full border border-primary/25 bg-primary/5 px-3.5 py-1.5 text-xs font-medium uppercase tracking-widest text-primary">
                <span class="relative flex size-1.5">
                  <span class="absolute inline-flex size-1.5 animate-ping rounded-full bg-primary opacity-60"></span>
                  <span class="relative inline-flex size-1.5 rounded-full bg-primary"></span>
                </span>
                Now in private beta
              </p>

              <h1 class="mt-6 text-4xl font-black leading-[1.05] tracking-tight text-balance sm:text-6xl">
                A calmer home, <span class="text-gradient">one list</span> at a time.
              </h1>

              <p class="mx-auto mt-6 max-w-xl text-base leading-relaxed text-base-content/70 sm:text-lg">
                Hearth keeps your family's shared notes, plans, and reminders in one
                warm, private place — synced for everyone, cluttered for no one.
              </p>

              <div class="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
                <.button href="#signup" variant="primary" size="lg" class="w-full sm:w-auto">
                  Join the early-access list <.icon name="hero-arrow-right" class="size-4" />
                </.button>
                <.button href="#features" variant="soft" size="lg" class="w-full sm:w-auto">
                  See how it works
                </.button>
              </div>
            </div>
          </div>
        </section>

        <!-- Live countdown + stats -->
        <section class="mx-auto max-w-5xl px-4 sm:px-6">
          <div class="grid gap-4 lg:grid-cols-5">
            <div class="relative overflow-hidden rounded-3xl border border-base-300 bg-base-100/70 p-8 sm:p-10 lg:col-span-3">
              <div
                aria-hidden="true"
                class="pointer-events-none absolute -right-16 -top-16 size-48 rounded-full bg-primary/10 blur-3xl"
              >
              </div>
              <.eyebrow>Live launch countdown</.eyebrow>
              <div class="mt-4 flex items-end gap-4">
                <span
                  id="countdown"
                  class="text-7xl font-black leading-none tabular-nums tracking-tight text-primary sm:text-8xl"
                >
                  {@countdown}
                </span>
                <span class="pb-1.5 text-sm leading-tight text-base-content/60">
                  seconds<br /> to public launch
                </span>
              </div>
              <p class="mt-5 text-xs text-base-content/50">
                The counter steps down every 5 seconds — watch it breathe.
              </p>
            </div>

            <div
              id="stats"
              class="grid grid-cols-2 gap-4 lg:col-span-2 lg:grid-cols-1 lg:content-center"
            >
              <CompositeComponents.stat_card
                label="Signups"
                value={length(@signups)}
                value_id="stat-signups"
              />
              <CompositeComponents.stat_card
                label="Countdown ticks"
                value={@ticks}
                value_id="stat-ticks"
              />
            </div>
          </div>
        </section>

        <!-- Signup -->
        <section id="signup" class="mx-auto max-w-5xl scroll-mt-24 px-4 py-20 sm:px-6">
          <div class="relative overflow-hidden rounded-3xl border border-primary/25 bg-gradient-to-b from-primary/8 to-transparent p-8 sm:p-12">
            <div class="grid items-center gap-8 lg:grid-cols-2">
              <CompositeComponents.section_header
                eyebrow="Early access"
                title="Be first through the door"
                subtitle="Join the early-access list and we'll send you an invite the moment your hearth is ready to light. No spam, no junk — just one warm hello."
              />

              <div>
                <.form for={@signup_form} id="signup-form" phx-submit="signup" class="space-y-4">
                  <div class="flex flex-col gap-3 sm:flex-row sm:items-start">
                    <div class="flex-1">
                      <.input
                        id="signup-email"
                        type="email"
                        field={@signup_form[:email]}
                        label="Email address"
                        placeholder="you@example.com"
                        autocomplete="email"
                        class="w-full"
                      />
                    </div>
                    <.button type="submit" variant="primary" class="sm:mt-6">
                      Join the list
                    </.button>
                  </div>

                  <p
                    :if={@signup_error}
                    id="signup-error"
                    role="alert"
                    class="flex items-center gap-2 text-sm font-medium text-error"
                  >
                    <.icon name="hero-exclamation-circle" class="size-4 shrink-0" />
                    {@signup_error}
                  </p>
                </.form>

                <div class="mt-6 border-t border-base-300 pt-5">
                  <.eyebrow>Recent signups</.eyebrow>
                  <ul id="signups" class="mt-3 flex flex-wrap gap-2">
                    <li
                      :for={email <- @signups}
                      class="inline-flex items-center gap-1.5 rounded-full border border-base-300 bg-base-100 px-3 py-1 text-xs font-medium text-base-content/70"
                    >
                      <.icon name="hero-check-circle" class="size-3.5 text-success" />
                      {email}
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- Features -->
        <section id="features" class="mx-auto max-w-5xl scroll-mt-24 px-4 pb-20 sm:px-6">
          <CompositeComponents.section_header
            eyebrow="Why Hearth"
            title="Everything your household needs, nothing it doesn't"
            subtitle="Every feature is built on one idea: your home's shared life should feel calm, not cluttered."
          />

          <div class="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <CompositeComponents.feature_card
              :for={feature <- @features}
              icon={feature.icon}
              title={feature.title}
              highlighted={feature.title == "Shared everything"}
              tone={feature.title == "Shared everything" && "primary"}
            >
              {feature.body}
            </CompositeComponents.feature_card>
          </div>
        </section>

        <!-- Activity feed -->
        <section class="mx-auto max-w-5xl px-4 pb-24 sm:px-6">
          <div class="grid gap-4 lg:grid-cols-2">
            <CompositeComponents.section_header
              eyebrow="Live feed"
              title="Watch the early-access doors open"
              subtitle="The newest signups and countdown ticks, as they happen — never more than the last ten."
            />

            <div class="rounded-3xl border border-base-300 bg-base-100/70 p-2">
              <ul id="activity" class="max-h-80 space-y-1 overflow-y-auto p-3">
                <li
                  :for={entry <- @activity}
                  class="flex items-center gap-3 rounded-2xl px-3 py-2.5 text-sm"
                >
                  <span
                    :if={entry.kind == :signup}
                    class="flex size-7 shrink-0 items-center justify-center rounded-full bg-success/15 text-success"
                  >
                    <.icon name="hero-check-circle" class="size-4" />
                  </span>
                  <span
                    :if={entry.kind == :tick}
                    class="flex size-7 shrink-0 items-center justify-center rounded-full bg-primary/12 text-primary"
                  >
                    <.icon name="hero-bolt" class="size-4" />
                  </span>
                  <span class="min-w-0 truncate text-base-content/75">{entry.text}</span>
                </li>
              </ul>
              <p
                :if={@activity == []}
                class="px-5 pb-4 pt-2 text-center text-xs text-base-content/40"
              >
                The feed will start filling up the moment someone signs up — or the next
                countdown tick lands.
              </p>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

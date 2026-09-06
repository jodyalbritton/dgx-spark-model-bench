defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The mission brief: why Lodestar exists, the flight rules the product is
  built from, the log of how it got here, and the crew.

  Same `Layouts.app` chrome as the landing page, and it reuses
  `CompositeComponents.feature_card` for the stack list rather than
  inventing a second card — that reuse is the point of registering the
  composite in the first place.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @flight_rules [
    %{
      title: "A window is a promise",
      detail:
        "If the board says 06:00-06:15, downstream teams may build on 06:15. Missing a window is a defect with an owner, not a shrug."
    },
    %{
      title: "No silent green",
      detail:
        "A run that cannot prove its inputs arrived is a no-go, even when the numbers look fine. Optimism is not a gate."
    },
    %{
      title: "The hold is the feature",
      detail:
        "Anyone on shift can stop a launch. The cost of a wrong hold is minutes; the cost of a wrong launch is a day of analyst trust."
    },
    %{
      title: "One log, read by everyone",
      detail:
        "Humans, the CLI, and the pager all read the same stream. If the log cannot explain an incident, the log is broken."
    }
  ]

  @log [
    %{
      title: "2023 · The 03:14 incident",
      detail:
        "A warehouse table published half-built for six hours because a cron job outran its upstream. Four of us were on the bridge that night."
    },
    %{
      title: "2024 · First launch board",
      detail:
        "Windows, go/no-go gates, and a hold button. Three teams put their critical path on it in a fortnight."
    },
    %{
      title: "2025 · Beats become telemetry",
      detail:
        "Every tick of every window landed in one append-only stream, and post-mortems stopped starting with an archaeology dig."
    },
    %{
      title: "2026 · Cohort 7",
      detail:
        "412 teams, 1.4M beats a day, and a boarding process you can watch from the landing page."
    }
  ]

  @stack [
    %{
      tag: "infra",
      icon: "hero-command-line",
      title: "Runs at the edge of your warehouse",
      body:
        "The conductor is a single BEAM node beside your orchestrator. Nothing leaves your network except the beats you choose to publish."
    },
    %{
      tag: "contract",
      icon: "hero-shield-check",
      title: "Gates are code",
      body:
        "Go/no-go rules live in a repository, get reviewed, and roll back like any other change your team owns."
    },
    %{
      tag: "surface",
      icon: "hero-circle-stack",
      title: "Board, CLI, webhook",
      body:
        "One stream, three readers. The page you are looking at is the same data the CLI tails and the webhook posts."
    }
  ]

  @crew [
    %{
      name: "Ines Okafor",
      role: "Flight director",
      note: "Ran data platform at two freight companies. Wrote the first hold button on a napkin."
    },
    %{
      name: "Tomas Berg",
      role: "Range safety",
      note: "Keeps the gates honest. Believes a green board should be boring."
    },
    %{
      name: "Priya Raman",
      role: "Telemetry",
      note: "Owns the beat stream. Has strong opinions about append-only logs and clock skew."
    }
  ]

  @facts [
    %{key: "Founded", value: "2023 · Lisbon + online"},
    %{key: "Crew", value: "19 across 6 timezones"},
    %{key: "Teams aboard", value: "412"},
    %{key: "Beats / day", value: "1,412,900"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Mission brief",
       facts: @facts,
       flight_rules: @flight_rules,
       log: @log,
       stack: @stack,
       crew: @crew
     )}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div id="about-page" class="mx-auto w-full max-w-6xl px-4 pb-20 sm:px-6">
        <section class="grid gap-10 pt-14 pb-4 lg:grid-cols-[1.2fr_0.8fr] lg:items-start lg:pt-20">
          <div class="hero-rise space-y-5">
            <.eyebrow class="font-mono">Mission brief · rev 7</.eyebrow>
            <h1 class="text-4xl font-semibold leading-[1.08] tracking-tight sm:text-5xl">
              We built the board we wanted during
              <span class="text-primary">the 03:14 incident.</span>
            </h1>
            <p class="max-w-2xl text-base leading-relaxed text-base-content/70">
              Lodestar is a small company of platform engineers who spent too
              many nights reconciling three schedulers, one optimistic
              dashboard, and a warehouse that had already told the truth. The
              product is that night, turned inside out: a launch board, a set of
              gates you can review, and one log nobody can edit.
            </p>
            <div class="flex flex-wrap gap-3 pt-1">
              <.button variant="primary" navigate={~p"/"}>
                Back to the launch board
              </.button>
              <.button variant="ghost" href="#crew">
                Meet the crew
              </.button>
            </div>
          </div>

          <div class="launch-grid relative rounded-box border border-base-300 bg-base-200/50 p-6">
            <div class="relative space-y-4">
              <.eyebrow class="font-mono">By the numbers</.eyebrow>
              <dl class="divide-y divide-base-300 text-sm">
                <div
                  :for={fact <- @facts}
                  class="flex items-baseline justify-between gap-4 py-2 first:pt-0 last:pb-0"
                >
                  <dt class="text-base-content/60">{fact.key}</dt>
                  <dd class="font-mono tabular-nums">{fact.value}</dd>
                </div>
              </dl>
            </div>
          </div>
        </section>

        <section class="mt-20 space-y-6">
          <.header level="h2">
            Four flight rules
            <:eyebrow>Principles · &lt;.card&gt;</:eyebrow>
            <:subtitle>
              Everything in the product is one of these wearing a different hat.
            </:subtitle>
          </.header>

          <div class="grid gap-4 lg:grid-cols-2">
            <.card :for={rule <- @flight_rules} prose class="justify-center">
              <:eyebrow>Rule</:eyebrow>
              <:title>{rule.title}</:title>
              <p>{rule.detail}</p>
            </.card>
          </div>
        </section>

        <section class="mt-20 space-y-6">
          <.header level="h2">
            The log so far
            <:eyebrow>History</:eyebrow>
          </.header>

          <ol class="relative space-y-6 border-l border-base-300 pl-6">
            <li :for={entry <- @log} class="relative">
              <span class="absolute -left-[1.72rem] top-1.5 size-3 rounded-full border-2 border-base-100 bg-primary" />
              <h3 class="font-mono text-xs uppercase tracking-[0.18em] text-base-content/50">
                {entry.title}
              </h3>
              <p class="mt-1 max-w-2xl text-sm leading-relaxed text-base-content/70">
                {entry.detail}
              </p>
            </li>
          </ol>
        </section>

        <section class="mt-20 space-y-6">
          <.header level="h2">
            What you install
            <:eyebrow>Stack · &lt;.feature_card&gt;</:eyebrow>
          </.header>

          <CompositeComponents.card_grid id="about-stack">
            <CompositeComponents.feature_card
              :for={item <- @stack}
              tag={item.tag}
              icon={item.icon}
              title={item.title}
            >
              {item.body}
            </CompositeComponents.feature_card>
          </CompositeComponents.card_grid>
        </section>

        <section id="crew" class="mt-20 space-y-6">
          <.header level="h2">
            The crew
            <:eyebrow>People</:eyebrow>
            <:subtitle>
              Nineteen people, six timezones, one on shift at any hour of the
              launch window.
            </:subtitle>
          </.header>

          <CompositeComponents.card_grid id="crew-grid">
            <.card :for={person <- @crew} variant="ghost" prose>
              <:eyebrow>{person.role}</:eyebrow>
              <:title>{person.name}</:title>
              <p>{person.note}</p>
              <:actions>
                <.badge tone="neutral" variant="outline">on shift</.badge>
              </:actions>
            </.card>
          </CompositeComponents.card_grid>
        </section>

        <section class="mt-20">
          <blockquote class="relative overflow-hidden rounded-box border border-base-300 bg-base-200/50 px-6 py-10 sm:px-12">
            <p class="max-w-3xl text-lg leading-relaxed text-base-content/80 sm:text-xl">
              “The first thing Lodestar changed was not the uptime. It was that
              nobody on my team said
              <span class="font-medium text-base-content">
                “I thought that job was yours”
              </span>
              again.”
            </p>
            <footer class="mt-4 font-mono text-xs uppercase tracking-[0.18em] text-base-content/50">
              Data lead · Cohort 3 · retail logistics
            </footer>
          </blockquote>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

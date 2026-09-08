defmodule BenchappWeb.AboutLive do
  @moduledoc """
  `/about` — Tidepool's origin story, method, and crew.

  Same layout as the landing page (`active_nav="about"` marks the nav link),
  so the chrome, theme control, and phone menu behave identically here. The
  capability tiles are the `feature_grid` composite again, in its two-column
  setting, which is the point of registering it.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.{Chrome, CompositeComponents}

  @principles [
    %{
      icon: "hero-scale",
      eyebrow: "Method",
      title: "Publish the uncertainty, not just the number",
      body:
        "A reading without its drift band is a rumour. Tidepool ships the band with the reading, always, including in the public tier.",
      tag: nil
    },
    %{
      icon: "hero-wrench-screwdriver",
      eyebrow: "Fleet",
      title: "A node you can service yourself",
      body:
        "Seals, probes, and mounts are stock parts with printed spares lists. A crew with a screwdriver keeps a site online.",
      tag: nil
    },
    %{
      icon: "hero-lock-closed",
      eyebrow: "Ownership",
      title: "The lab that collected it keeps it",
      body:
        "Public tiers publish a derived view. Raw series stay in the account that moored the buoy, exportable at any hour.",
      tag: nil
    }
  ]

  @crew [
    %{
      initials: "AO",
      name: "Dr. Ada Okonjo",
      role: "Sensor lead",
      note: "Fifteen years of moored-platform calibration in the North Atlantic."
    },
    %{
      initials: "RM",
      name: "Rafi Mehta",
      role: "Field operations",
      note: "Keeps six watersheds and their volunteer crews pointed at the same method."
    },
    %{
      initials: "JL",
      name: "June Li",
      role: "Platform",
      note: "Built the buffer that survives a week of dropped link on a 2 W radio."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> Chrome.assign_chrome()
     |> assign(page_title: "About", principles: @principles, crew: @crew)}
  end

  @impl true
  def handle_event("toggle_nav", _params, socket) do
    {:noreply, Chrome.toggle_nav(socket)}
  end

  # See the note in `BenchappWeb.HomeLive`: the theme flip belongs to the
  # client, but the control is a LiveView event target on every page.
  def handle_event("toggle_theme", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about" nav_open={@nav_open}>
      <div class="relative overflow-hidden border-b border-base-300/60">
        <div class="pointer-events-none absolute -left-20 -top-20 size-72 rounded-full bg-secondary/10 blur-3xl" />

        <div class="relative mx-auto max-w-4xl px-4 py-16 sm:px-6 lg:py-20">
          <.header level="h1" size="page">
            We got tired of arguing about a number nobody could re-derive
            <:eyebrow>About Tidepool</:eyebrow>
            <:subtitle>
              Tidepool Instruments builds moored water-quality telemetry for the
              small organisations that watch a shoreline closely — university
              labs, harbour councils, volunteer catchment groups. One method, one
              calibration record, from the probe to the published chart.
            </:subtitle>
          </.header>

          <div class="mt-10 grid gap-3 sm:grid-cols-3">
            <CompositeComponents.stat_readout
              icon="hero-water"
              label="Watersheds live"
              hint="since 2023"
              value={6}
            />
            <CompositeComponents.stat_readout
              icon="hero-bug"
              label="Sensor-days logged"
              hint="unbroken record"
              value={41_208}
            />
            <CompositeComponents.stat_readout
              icon="hero-map"
              label="Countries"
              hint="same method, six coasts"
              value={4}
            />
          </div>
        </div>
      </div>

      <div class="mx-auto max-w-6xl space-y-16 px-4 py-14 sm:px-6">
        <section class="space-y-5">
          <.header level="h2" size="page">
            Three things we refuse to compromise
            <:eyebrow>Principles</:eyebrow>
            <:subtitle>
              The same <code class="font-mono text-xs">feature_grid</code> composite
              as the landing page, set to two columns — registered in the app's
              design manifest, so this is the component, not a copy of it.
            </:subtitle>
          </.header>

          <CompositeComponents.feature_grid items={@principles} columns="2" id="principle-grid" />
        </section>

        <section class="grid gap-8 lg:grid-cols-[1fr_1.1fr]">
          <.header level="h2" size="page">
            The method, in one paragraph
            <:eyebrow>How it works</:eyebrow>
          </.header>

          <div class="space-y-4 text-base-content/75">
            <p class="leading-relaxed">
              A node samples at 1 Hz, buffers locally through a dropped radio
              link, and posts to the catchment account it belongs to. The
              platform applies the drift correction recorded at that node's
              last service, keeps the correction in the series metadata, and
              only then charts anything. If a sensor has drifted past its band,
              the chart says so and pages the crew that serviced it last.
            </p>
            <p class="leading-relaxed">
              Nothing here is clever for its own sake. The reason a harbour
              council can act on a Tidepool chart is that the same chart can be
              handed to a regulator with the service history attached — which is
              also the only reason a volunteer crew keeps going out in November.
            </p>
            <div class="flex flex-wrap gap-3 pt-2">
              <.button variant="primary" navigate={~p"/"}>Back to the launch page</.button>
              <.button variant="ghost" href={~p"/design"}>Inspect the component kit</.button>
            </div>
          </div>
        </section>

        <section class="space-y-5">
          <.header level="h2" size="page">
            A small crew
            <:eyebrow>Who builds it</:eyebrow>
          </.header>

          <div class="grid gap-4 sm:grid-cols-3">
            <.card :for={person <- @crew} variant="elevated" prose body_class="gap-3">
              <:title>
                <span class="flex items-center gap-3">
                  <span class="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary/10 font-mono text-sm font-semibold text-primary">
                    {person.initials}
                  </span>
                  <span class="min-w-0">
                    {person.name}
                    <span class="block text-xs font-normal text-base-content/55">{person.role}</span>
                  </span>
                </span>
              </:title>
              <p>{person.note}</p>
            </.card>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

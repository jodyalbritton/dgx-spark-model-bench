defmodule BenchappWeb.AboutLive do
  @moduledoc """
  About page for Lumen — the story, the team, and the roadmap.
  """

  use BenchappWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About — Lumen")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl space-y-12 px-4 py-12 sm:px-6">
        <JobyKit.CoreComponents.header size="page">
          About Lumen
          <:eyebrow>Our story</:eyebrow>
          <:subtitle>
            We build lighting for people who think for a living.
          </:subtitle>
        </JobyKit.CoreComponents.header>

        <section class="prose prose-base max-w-none text-base-content/80">
          <p>
            Lumen started in a spare bedroom in 2024, when our founder got
            tired of desk lamps designed for reading paper, not for six-hour
            deep-work sessions in front of a screen. The first prototype was a
            raspberry pi, a strip of LEDs, and a lot of hot glue.
          </p>
          <p>
            Two years later, Lumen is a purpose-built lamp: presence sensing,
            circadian-aware color curves, and a battery that lasts weeks. We
            manufacture in small batches, sell direct, and ship worldwide.
          </p>
        </section>

        <section class="grid gap-4 sm:grid-cols-3">
          <JobyKit.CoreComponents.card>
            <:eyebrow>2024</:eyebrow>
            <:title>Founded</:title>
            First prototype in a spare bedroom in Rotterdam.
          </JobyKit.CoreComponents.card>
          <JobyKit.CoreComponents.card>
            <:eyebrow>2025</:eyebrow>
            <:title>Batch one</:title>
            500 units sold out in nine minutes.
          </JobyKit.CoreComponents.card>
          <JobyKit.CoreComponents.card>
            <:eyebrow>2026</:eyebrow>
            <:title>Batch two</:title>
            Currently in production — reserve on the home page.
          </JobyKit.CoreComponents.card>
        </section>

        <section class="space-y-4">
          <JobyKit.CoreComponents.header level="h2">
            What we believe
            <:eyebrow>Principles</:eyebrow>
          </JobyKit.CoreComponents.header>
          <JobyKit.CoreComponents.list>
            <:item title="Calm technology">
              Your lamp should never demand attention — only give it.
            </:item>
            <:item title="Repairable by design">
              Every part is replaceable with a screwdriver and a spare.
            </:item>
            <:item title="Software that improves">
              Free firmware updates for the life of the lamp.
            </:item>
          </JobyKit.CoreComponents.list>
        </section>

        <div class="flex justify-center">
          <JobyKit.CoreComponents.button navigate={~p"/"} variant="primary" size="lg">
            Back to home
          </JobyKit.CoreComponents.button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

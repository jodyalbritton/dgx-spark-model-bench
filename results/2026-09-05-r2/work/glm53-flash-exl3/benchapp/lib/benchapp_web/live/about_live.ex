defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The story behind Solstice.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl space-y-10 px-4 py-12 sm:px-6">
        <div class="space-y-4">
          <CompositeComponents.section_heading
            large
            eyebrow="Our story"
            title="Why we built Solstice"
          />
          <p class="text-lg text-base-content/70">
            We spent years under light that fought our bodies instead of working
            with them — buzzing fluorescents at midnight, screens-lit rooms at
            dawn. Solstice started as a weekend project to fix our own desks,
            and grew into a lamp we think everyone deserves.
          </p>
        </div>

        <.card prose>
          <:title>Light with intent</:title>
          Every Solstice tunes its spectrum to the hour: cool and precise while
          you work, amber and soft as the sun goes down. The sensor package is
          computed entirely on the lamp — nothing about your day leaves your
          home.
        </.card>

        <.card prose>
          <:title>What's next</:title>
          Early access opens in waves of one hundred. Join the list on the
          home page and we'll email you when your wave is ready.
          <:actions>
            <.button navigate={~p"/"} variant="primary">Back to home</.button>
          </:actions>
        </.card>
      </div>
    </Layouts.app>
    """
  end
end

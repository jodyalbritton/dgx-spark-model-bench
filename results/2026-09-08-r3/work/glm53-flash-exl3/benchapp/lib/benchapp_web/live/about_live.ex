defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The about page for Nimbus.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About")}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl space-y-10 px-4 py-12 sm:px-6">
        <.header size="page">
          About Nimbus
          <:eyebrow>Our story</:eyebrow>
          <:subtitle>
            Nimbus was founded on a simple annoyance: weather apps that show
            one confident number for a sky that never makes up its mind.
          </:subtitle>
        </.header>

        <section class="space-y-4 text-base leading-relaxed text-base-content/80">
          <p>
            We started in a bike courier dispatch office, where a wrong
            forecast meant a soaked courier and a missed pickup. The tools
            we had were either too coarse to trust or too technical to use.
            So we built the thing we wanted: a forecast engine that shows
            its work, grades itself in public, and never pretends to know
            more than it does.
          </p>
          <p>
            Today Nimbus serves courier fleets, festivals, and five thousand
            rooftop gardeners. The engine runs on open model data, and every
            product decision still starts with the same question: would this
            have helped that dispatch office?
          </p>
        </section>

        <section class="space-y-4">
          <.header level="h2">
            What we believe
            <:eyebrow>Principles</:eyebrow>
          </.header>

          <CompositeComponents.feature_grid
            columns="two"
            features={[
              %{
                icon: "hero-eye",
                title: "Show your work",
                text: "Confidence bands, model sources, and public scorecards on every forecast."
              },
              %{
                icon: "hero-heart",
                title: "Small moments matter",
                text: "A dry commute, a saved picnic, a delivery on time. That's the whole point."
              },
              %{
                icon: "hero-globe-alt",
                title: "Open by default",
                text: "We build on open data and publish our scoring back to the community."
              },
              %{
                icon: "hero-lifebuoy",
                title: "Honest when wrong",
                text: "When the model busts, you hear it from us first — with what we're changing."
              }
            ]}
          />
        </section>

        <section class="rounded-2xl border border-primary/30 bg-primary/5 px-6 py-8 text-center">
          <h2 class="text-xl font-semibold">Come build with us</h2>
          <p class="mx-auto mt-2 max-w-md text-sm text-base-content/70">
            We're a small team of meteorologists, engineers, and designers —
            hiring across all three.
          </p>
          <div class="pt-4">
            <.button navigate={~p"/"} variant="primary">Back to the beta</.button>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

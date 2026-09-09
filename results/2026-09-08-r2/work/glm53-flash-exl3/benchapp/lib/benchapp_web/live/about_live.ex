defmodule BenchappWeb.AboutLive do
  @moduledoc "About Lumina and Lumina Labs."

  use BenchappWeb, :live_view

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
        <section class="text-center">
          <.eyebrow>Our story</.eyebrow>
          <h1 class="mt-3 text-4xl font-bold sm:text-5xl">Obsessed with better evenings</h1>
          <p class="mx-auto mt-4 max-w-xl text-base-content/70">
            Lumina Labs started in a dim attic in 2023, when our founders
            got tired of desk lamps that treated light as an on/off problem.
            Three years, four prototypes and one very patient cat later,
            Lumina is nearly here.
          </p>
        </section>

        <section class="grid gap-4 sm:grid-cols-3">
          <div
            :for={
              stat <- [
                {"2023", "founded in an attic"},
                {"2,400", "LEDs per halo"},
                {"0", "bytes sent to the cloud"}
              ]
            }
            class="rounded-2xl border border-base-300 bg-base-100 p-5 text-center"
          >
            <p class="text-3xl font-bold text-primary">{elem(stat, 0)}</p>
            <p class="mt-1 text-sm text-base-content/60">{elem(stat, 1)}</p>
          </div>
        </section>

        <section class="space-y-4">
          <h2 class="text-2xl font-semibold">What we believe</h2>
          <div class="space-y-3 text-base-content/80">
            <p>
              Light is a nutrient. Screens get all the attention, but the
              glow they sit in shapes your focus, your sleep, and your
              4&nbsp;p.m. slump. We think that glow should earn its place on
              your desk.
            </p>
            <p>
              Hardware should be quiet. Lumina has no login, no subscription
              and no telemetry. Set it once, and it simply gets on with the
              job of making your room feel like the time of day it is.
            </p>
            <p>
              Great things ship in small batches. The first run is 500 lamps,
              assembled and tested a few metres from the workbenches where
              they were designed.
            </p>
          </div>
        </section>

        <section class="rounded-3xl border border-base-300 bg-gradient-to-br from-secondary/10 to-primary/10 p-8 text-center">
          <h2 class="text-2xl font-semibold">Want the full picture?</h2>
          <p class="mx-auto mt-2 max-w-md text-sm text-base-content/70">
            The feature grid on the home page has the technical story — and
            the launch list is still open.
          </p>
          <div class="mt-6">
            <.button variant="primary" navigate={~p"/"}>Back to the launch</.button>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

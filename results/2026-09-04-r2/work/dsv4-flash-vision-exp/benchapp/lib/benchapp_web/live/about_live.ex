defmodule BenchappWeb.AboutLive do
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
      <div class="mx-auto max-w-3xl px-4 py-16 sm:px-6 sm:py-24">
        <.header size="page">
          About Lumen
          <:eyebrow>Our story</:eyebrow>
          <:subtitle>
            Lumen started with a simple belief: software should help you think,
            not get in the way.
          </:subtitle>
        </.header>

        <div class="mt-10 space-y-6 text-base leading-relaxed text-base-content/80">
          <p>
            We spend our days juggling notes, tasks, and half-formed ideas across a
            dozen apps. The tools meant to help us focus too often add to the noise.
            Lumen is our answer — a small, calm, thoughtful workspace that quietly
            holds your work so your mind can stay clear.
          </p>
          <p>
            We obsess over the small things: responsive layouts that feel native on
            a phone, themes that go easy on the eyes, and live updates that keep
            everything in sync. No ads, no dark patterns, no noise.
          </p>
        </div>

        <div class="mt-12 grid gap-4 sm:grid-cols-3">
          <CompositeComponents.stat_card label="seconds to launch" value={100} />
          <CompositeComponents.stat_card label="core features" value={6} />
          <CompositeComponents.stat_card label="trackers" value={0} />
        </div>

        <div class="mt-12">
          <h2 class="text-xl font-semibold tracking-tight">What we believe</h2>
          <ul class="mt-4 space-y-3">
            <li
              :for={
                belief <- [
                  "Less is more",
                  "Calm over speed",
                  "Privacy is a right",
                  "Design is for people"
                ]
              }
              class="flex items-center gap-3 text-base text-base-content/80"
            >
              <span class="size-1.5 rounded-full bg-primary"></span>
              {belief}
            </li>
          </ul>
        </div>

        <div class="mt-12 flex flex-col gap-3 sm:flex-row">
          <.button navigate={~p"/"} variant="primary">Back to the countdown</.button>
          <.button navigate={~p"/design"} variant="ghost">Browse our design system</.button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

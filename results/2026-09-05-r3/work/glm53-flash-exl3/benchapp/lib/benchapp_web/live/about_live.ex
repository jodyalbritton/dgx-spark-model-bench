defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The story behind Windrose: why the app is offline-first and how the
  private beta works.
  """

  use BenchappWeb, :live_view

  @principles [
    %{
      icon: "hero-wifi",
      title: "Signal is a bonus, not a requirement",
      text:
        "Every feature is designed to work at full capacity in airplane mode. Connectivity is used only to sync faster, never to unlock."
    },
    %{
      icon: "hero-clock",
      title: "Five seconds from pocket to trail",
      text:
        "No splash screens, no loading spinners. The last cached quad opens instantly, wherever you left off."
    },
    %{
      icon: "hero-shield-check",
      title: "Your tracks stay yours",
      text:
        "Windrose has no accounts and no analytics SDK. Exports happen when you export — nowhere else."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About Windrose", principles: @principles)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-3xl space-y-14 px-4 pb-16 sm:px-6">
        <%!-- Intro --%>
        <section class="space-y-5 pt-12 sm:pt-16">
          <span class="badge badge-outline gap-1.5 rounded-full border-primary/40 bg-primary/5 py-3 text-primary">
            <.icon name="hero-compass" class="size-3.5" /> About Windrose
          </span>
          <h1 class="text-4xl font-bold tracking-tight text-balance sm:text-5xl">
            Named for the rose that points home.
          </h1>
          <div class="space-y-4 text-lg leading-relaxed text-base-content/75">
            <p>
              Windrose started as a paper error. On a foggy October traverse, our founder's
              GPS app refused to open without bars — and the only working map was a
              hand-photocopied quad folded into a jacket pocket since 2011.
            </p>
            <p>
              We build the opposite of that app: maps, terrain, routing, and field notes that
              live entirely on the device, ready the moment the signal drops. The cloud is a
              convenience layer, not a lifeline.
            </p>
          </div>
        </section>

        <%!-- Principles --%>
        <section class="space-y-4">
          <.header level="h2">
            Three principles
            <:eyebrow>What we optimize for</:eyebrow>
          </.header>

          <div class="space-y-4">
            <.card :for={{principle, index} <- Enum.with_index(@principles, 1)}>
              <:eyebrow>{String.pad_leading("#{index}", 2, "0")}</:eyebrow>
              <:title>{principle.title}</:title>
              <p class="text-sm leading-relaxed text-base-content/70">{principle.text}</p>
            </.card>
          </div>
        </section>

        <%!-- The beta --%>
        <section class="space-y-4">
          <.header level="h2">
            How the beta works
            <:eyebrow>Early access</:eyebrow>
          </.header>

          <.card class="bg-gradient-to-br from-primary/10 to-base-100">
            <div class="space-y-4">
              <p class="text-sm leading-relaxed text-base-content/75">
                We hand out a hundred early-access keys, watched over by a beacon that pulses
                every five seconds. Each pulse claims one key; the counter on the landing page
                is the honest number, live. When a key is claimed, it lands in the activity
                feed for everyone watching.
              </p>
              <p class="text-sm leading-relaxed text-base-content/75">
                Requesting a key takes an email and ten seconds. We only use it to send your
                TestFlight or APK link — nothing else, ever.
              </p>
              <div class="flex flex-wrap gap-3">
                <.button variant="primary" navigate={~p"/"}>
                  Visit the beacon <.icon name="hero-arrow-left" class="size-4" />
                </.button>
                <.button variant="ghost" href="#beta-principles">
                  Read the principles
                </.button>
              </div>
            </div>
          </.card>
        </section>

        <%!-- The kit note --%>
        <section id="beta-principles" class="space-y-4">
          <.header level="h2">
            Built in the open
            <:eyebrow>Under the hood</:eyebrow>
          </.header>
          <.card>
            <p class="text-sm leading-relaxed text-base-content/70">
              This site runs on Phoenix LiveView and composes its interface from a registered
              design system. Every wrapper, composite, and domain component is catalogued with
              rendered previews — browse the inventory on
              <.link navigate={~p"/design"} class="link link-primary">/design</.link>
              and this app's own composites on <.link
                navigate={~p"/custom-designs"}
                class="link link-primary"
              >/custom-designs</.link>.
            </p>
          </.card>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

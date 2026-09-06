defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The Hearth about page: the story, the beliefs behind the product, and a
  final call to action. Same layout and chrome as every other page.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @principles [
    %{
      icon: "hero-home",
      title: "The home is the product",
      body:
        "Software is measured by the life it makes calmer. If a feature doesn't help a household live together more easily, it doesn't ship."
    },
    %{
      icon: "hero-lock-closed",
      title: "Privacy is the default",
      body:
        "Your list of plans and recipes belongs to you. We don't sell it, mine it, or use it to chase you around the web."
    },
    %{
      icon: "hero-arrow-right",
      title: "Quiet beats clever",
      body:
        "The best tool is the one you stop noticing. We remove, simplify, and polish until the friction disappears."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "About")
     |> assign(mobile_open: false)
     |> assign(principles: @principles)}
  end

  @impl true
  def handle_event("toggle-nav", _params, socket) do
    {:noreply, update(socket, :mobile_open, &(!&1))}
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about" mobile_open={@mobile_open}>
      <div class="relative overflow-hidden">
        <div aria-hidden="true" class="pointer-events-none absolute inset-0 -z-10">
          <div class="hero-glow absolute inset-0"></div>
        </div>

        <div class="mx-auto max-w-5xl px-4 py-16 sm:px-6 sm:py-24">
          <div class="mx-auto max-w-2xl text-center">
            <p class="text-xs font-medium uppercase tracking-widest text-primary">About Hearth</p>
            <h1 class="mt-4 text-4xl font-black leading-[1.05] tracking-tight text-balance sm:text-5xl">
              We started with a kitchen table
            </h1>
            <p class="mx-auto mt-6 max-w-xl text-base leading-relaxed text-base-content/70 sm:text-lg">
              Hearth began as a single shared list pinned to our fridge. It grew into a
              quiet, private place where a household's shared life — plans, notes,
              reminders, recipes — lives in one warm corner instead of a dozen
              scattered apps.
            </p>
          </div>

          <div class="mx-auto mt-16 max-w-3xl space-y-10">
            <section>
              <h2 class="text-xl font-bold tracking-tight">Our story</h2>
              <p class="mt-3 leading-relaxed text-base-content/70">
                Every household has the same problem: the people you live with are
                exactly who you can't coordinate with. The shopping list lives on a
                sticky note. The school run lives in a text thread. The weekend plan
                lives in someone's head. When we built Hearth, we wanted one shared
                surface that felt like home — not like another inbox demanding your
                attention.
              </p>
              <p class="mt-3 leading-relaxed text-base-content/70">
                So we made the thing we wished existed: a calm, private hub that a
                family opens when it needs to, and forgets about when it doesn't.
              </p>
            </section>

            <section>
              <h2 class="text-xl font-bold tracking-tight">What we believe</h2>
              <p class="mt-3 text-sm text-base-content/60">
                Three principles guide everything we build.
              </p>
              <div class="mt-6 grid gap-4 sm:grid-cols-3">
                <div
                  :for={principle <- @principles}
                  class="rounded-2xl border border-base-300 bg-base-100/60 p-6"
                >
                  <span class="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                    <.icon name={principle.icon} class="size-5" />
                  </span>
                  <h3 class="mt-4 text-sm font-semibold text-base-content">
                    {principle.title}
                  </h3>
                  <p class="mt-2 text-sm leading-relaxed text-base-content/65">
                    {principle.body}
                  </p>
                </div>
              </div>
            </section>

            <section class="rounded-3xl border border-primary/25 bg-gradient-to-b from-primary/8 to-transparent p-8 text-center sm:p-12">
              <CompositeComponents.section_header
                eyebrow="Come home"
                title="Pull up a chair"
                subtitle="Join the early-access list and see how a calmer home feels for yourself."
                align="center"
              />
              <div class="mt-6">
                <.button navigate={~p"/"} variant="primary" size="lg">
                  Back to the landing page <.icon name="hero-arrow-right" class="size-4" />
                </.button>
              </div>
            </section>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

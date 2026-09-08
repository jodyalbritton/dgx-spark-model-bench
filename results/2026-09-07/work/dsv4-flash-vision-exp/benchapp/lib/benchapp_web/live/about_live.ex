defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The Aster /about page — mission, story, and values. Shares the app
  layout with the rest of the site.
  """

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
      <div class="mx-auto max-w-3xl px-4 py-14 sm:px-6">
        <header class="space-y-5">
          <.eyebrow>About Aster</.eyebrow>
          <h1 class="text-4xl font-semibold tracking-tight sm:text-5xl">
            We're building the calm home for creative work.
          </h1>
          <p class="max-w-2xl text-lg leading-relaxed text-base-content/70">
            Teams move faster when the tools stay out of the way. Aster brings
            the thinking, the planning, and the shipping together into a single
            quiet place — so the work is what you remember, not the software.
          </p>
        </header>

        <section class="mt-14 space-y-6">
          <.header level="h2">
            Our story
            <:eyebrow>Where we started</:eyebrow>
          </.header>
          <p class="text-base-content/75">
            Aster began as a side project to keep our own team honest: one
            place for every brief, every decision, and every open thread. Once
            it proved itself, we couldn't keep it to ourselves.
          </p>
          <p class="text-base-content/75">
            Today we're a small, remote crew who believe good software is
            quiet, considered, and a little personal. We sweat the
            micro-interactions as much as the roadmap.
          </p>
        </section>

        <section class="mt-14">
          <.header level="h2">
            What we value
            <:eyebrow>Principles</:eyebrow>
          </.header>
          <.list title_class="font-semibold">
            <:item title="Clarity over noise">
              Every screen answers "what should I do next?" without asking.
            </:item>
            <:item title="Speed with calm">
              Fast to use, gentle to live with. Nothing blinks at you.
            </:item>
            <:item title="Built for real teams">
              Small by default, powerful when you grow. No bloated plans.
            </:item>
          </.list>
        </section>

        <section class="mt-14 rounded-2xl border border-base-300/60 bg-base-100/60 p-8">
          <.eyebrow>Get in touch</.eyebrow>
          <h2 class="mt-2 text-2xl font-semibold">Come say hello</h2>
          <p class="mt-2 text-base-content/70">
            Questions, ideas, or feedback — we read everything. Head to the
            homepage to join the waitlist and be first in line.
          </p>
          <.button navigate={~p"/"} variant="primary" class="mt-5" size="lg">
            Back to the homepage
          </.button>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

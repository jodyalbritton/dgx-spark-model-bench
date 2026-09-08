defmodule BenchappWeb.AboutLive do
  @moduledoc """
  How Cadence works, on the same layout as the landing page: the
  pipeline a release walks, the rules the team ships by, and a route
  back to the beta form.
  """
  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @pipeline [
    %{
      step: "01",
      title: "Watch the merge",
      body:
        "A GitHub or GitLab webhook lands on Cadence the moment a PR merges. Nothing to tag, nothing to annotate — commit messages and labels are already the spec."
    },
    %{
      step: "02",
      title: "Read the blast radius",
      body:
        "Cadence scores the change against three years of incident data for those paths: churn, ownership, and how often that file has been on the wrong end of a rollback."
    },
    %{
      step: "03",
      title: "Write the note",
      body:
        "Release notes are drafted from the diff and the linked issues, in the voice of the changelog you configured. A human edits them; nobody starts from a blank page."
    },
    %{
      step: "04",
      title: "Deliver and remember",
      body:
        "Notes go to the channel that owns the service, the changelog, and the API reference — with the risk score attached, so nobody has to ask what changed."
    }
  ]

  @principles [
    %{
      icon: "hero-minus",
      title: "Less machinery, not more",
      body:
        "One container, no queue cluster, no worker swarm to babysit. If a release note takes a pipeline to produce, it will not get read."
    },
    %{
      icon: "hero-lock-closed",
      title: "Your tokens stay yours",
      body:
        "Self-hosted installs never call out for git access, and the audit log is readable with plain SQL."
    },
    %{
      icon: "hero-clock",
      title: "Answer to the on-call, not the board",
      body:
        "Metrics exist to tell you where shipping hurts, not to rank teams. Nobody gets a leaderboard."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "About · Cadence",
       pipeline: @pipeline,
       principles: @principles
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <div class="mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
        <.header size="page">
          Release notes that write themselves
          <:eyebrow>About Cadence</:eyebrow>
          <:subtitle>
            Cadence is a small Elixir service that watches your merges, scores the
            risk, and tells your company what actually shipped. Three people build
            it, and all three of them are on call.
          </:subtitle>
          <:actions>
            <.button variant="primary" navigate={~p"/"}>See the countdown</.button>
          </:actions>
        </.header>

        <section class="mt-12 space-y-4">
          <.header level="h2">
            What happens to a release
            <:eyebrow>Pipeline</:eyebrow>
            <:subtitle>Four steps, and a human only touches the third one.</:subtitle>
          </.header>

          <.list>
            <:item
              :for={{entry, index} <- Enum.with_index(@pipeline)}
              title={
              "#{entry.step} · #{entry.title}"
            }
            >
              {entry.body}
              <div
                :if={index < length(@pipeline) - 1}
                aria-hidden="true"
                class="mt-3 h-px w-full bg-base-200"
              >
              </div>
            </:item>
          </.list>
        </section>

        <section class="mt-12 space-y-5">
          <.header level="h2">
            Rules we ship by
            <:eyebrow>Principles</:eyebrow>
            <:subtitle>
              Each one below is a <code class="font-mono text-xs">.feature_card</code>
              composite, registered in the manifest and previewed at <.link
                navigate={~p"/custom-designs"}
                class="link link-hover"
              >/custom-designs</.link>.
            </:subtitle>
          </.header>

          <div class="grid gap-4 md:grid-cols-3">
            <CompositeComponents.feature_card
              :for={principle <- @principles}
              icon={principle.icon}
              title={principle.title}
              tone="neutral"
            >
              {principle.body}
            </CompositeComponents.feature_card>
          </div>
        </section>

        <section class="mt-12">
          <.card variant="elevated">
            <div class="flex flex-col items-start justify-between gap-4 p-2 sm:flex-row sm:items-center sm:p-3">
              <div>
                <.eyebrow>Still reading?</.eyebrow>
                <h2 class="mt-2 text-xl font-semibold">The beta gate is counting down.</h2>
                <p class="mt-1 text-sm text-base-content/65">
                  Sign up on the landing page and we will send one email when your
                  wave opens.
                </p>
              </div>
              <.button variant="primary" navigate={~p"/"}>
                Back to the countdown <.icon name="hero-arrow-right" class="size-4" />
              </.button>
            </div>
          </.card>
        </section>
      </div>
    </Layouts.app>
    """
  end
end

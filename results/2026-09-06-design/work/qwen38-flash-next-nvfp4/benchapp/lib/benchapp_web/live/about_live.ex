defmodule BenchappWeb.AboutLive do
  @moduledoc """
  Who JobyCorp is and why the work is shared.
  """

  use BenchappWeb, :live_view

  alias BenchappWeb.CompositeComponents

  @profile [
    %{
      label: "what we run",
      body:
        "Analysis and benchmarks of local language models. The models run on hardware JobyCorp owns, in a runtime we choose and name."
    },
    %{
      label: "what we make",
      body:
        "Records: a fixed set of fields, each with the unit it is reported in, plus the method that produced them."
    },
    %{
      label: "who it is for",
      body:
        "Anyone who runs models locally and wants to know what they do before betting on them."
    },
    %{
      label: "what it costs to read",
      body: "Nothing. The research is shared with the community as it is published."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About", profile: @profile)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <CompositeComponents.content_column flow>
        <CompositeComponents.section_head
          level="h1"
          size="hero"
          lead="JobyCorp is a local AI research company. We run analysis and benchmarks of local language models on our own hardware, and we share the work with the community."
        >
          A local company that measures local models
        </CompositeComponents.section_head>

        <section class="space-y-8">
          <CompositeComponents.section_head running_head="company">
            What JobyCorp is
          </CompositeComponents.section_head>

          <CompositeComponents.spec_sheet>
            <:row :for={row <- @profile} label={row.label}>{row.body}</:row>
          </CompositeComponents.spec_sheet>
        </section>

        <section class="space-y-8">
          <CompositeComponents.section_head>Why the work is shared</CompositeComponents.section_head>
          <div class="max-w-prose space-y-5 text-base leading-relaxed text-base-content/70 md:text-lg">
            <p>
              A benchmark that only exists as a number is a claim about someone's hardware.
              A record — model, format, machine, units, method — is something you can check,
              argue with, or run again somewhere else.
            </p>
            <p>
              So that is what we publish, and we publish it to the community rather than
              behind a request form. Local models are run by people with their own machines
              and their own constraints; they deserve the whole measurement, not a headline.
            </p>
          </div>
        </section>

        <CompositeComponents.closing_call
          lead="The clearest answer to who we are is a piece of the work."
          href={~p"/research"}
          label="How JobyCorp tests, and what it publishes"
        >
          Start with a measurement
        </CompositeComponents.closing_call>
      </CompositeComponents.content_column>
    </Layouts.app>
    """
  end
end

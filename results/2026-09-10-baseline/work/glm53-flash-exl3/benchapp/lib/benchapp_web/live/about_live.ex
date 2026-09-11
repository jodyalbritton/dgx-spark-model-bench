defmodule BenchappWeb.AboutLive do
  @moduledoc "Who JobyCorp is and why the work is shared."

  use BenchappWeb, :live_view

  import BenchappWeb.JobyCorpComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "About") |> assign(:active_nav, "about")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav={@active_nav}>
      <.page_column>
        <section class="py-16 md:py-24">
          <div class="max-w-xl space-y-8">
            <h1 class="text-5xl font-semibold leading-[1.02] tracking-[-0.03em] md:text-7xl">
              Measurement is the work.
            </h1>
            <.body_text>
              JobyCorp is a local AI research company. We run benchmarks of
              local language models on hardware we own, and we publish what
              we find.
            </.body_text>
          </div>
        </section>

        <.data_section>
          <.section_head label="why the work is shared" heading="Published in full, on purpose" />
          <.spec_row term="openly">
            Research that stays behind a door cannot be checked. Every
            benchmark we run is shared openly with the community — the
            results, the method, and the reasoning behind both.
          </.spec_row>
          <.spec_row term="in full">
            Publishing the whole record is part of the method, not a
            gesture. Full results let other people reproduce a run,
            question it, and build on it — which is how the work gets
            better.
          </.spec_row>
        </.data_section>

        <.data_section>
          <.section_head label="the company" heading="Who we are" />
          <.body_text>
            We are a research company that measures things. Our own
            hardware runs the models, our own method shapes the tests, and
            the community reads the results. The work is the record, and
            the record is public.
          </.body_text>
          <.spec_row term="hardware">
            Our benchmarks run on machines we own and maintain, so every
            number we publish comes from a machine we can describe.
          </.spec_row>
        </.data_section>

        <.cta_section heading="See the method for yourself.">
          <.button navigate={~p"/research"} variant="primary">
            Read the research
          </.button>
        </.cta_section>
      </.page_column>
    </Layouts.app>
    """
  end
end

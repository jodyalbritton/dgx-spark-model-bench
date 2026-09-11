defmodule BenchappWeb.AboutLive do
  @moduledoc """
  Who JobyCorp is and why the work is shared.
  """

  use BenchappWeb, :live_view

  import BenchappWeb.CompositeComponents

  @shared [
    %{
      artifact: "records",
      form: "the full record of every run, fields and units intact"
    },
    %{artifact: "prompts", form: "the exact prompt set each result came from"},
    %{artifact: "method", form: "the protocol, versioned and kept fixed"},
    %{artifact: "hardware", form: "the device each run was measured on"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About", shared: @shared)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <.page_body>
        <section class="max-w-prose space-y-5 py-16 md:py-24">
          <h1 class="text-4xl font-semibold leading-[1.05] tracking-[-0.03em] md:text-6xl">
            A small lab that measures things
          </h1>
          <.lede>
            JobyCorp is a local AI research company. We run language models on hardware we own,
            measure what they do, and share the work openly with the community that builds and uses
            these models.
          </.lede>
          <.lede>
            We are not a product or a provider. The point of the work is the measurement: what a
            model actually does on a machine, described exactly enough for someone else to check it.
          </.lede>
        </section>

        <.section head="shared" title="What we share">
          <:lead>
            Everything a result depends on goes out with the result. Not a headline number — the
            whole record.
          </:lead>
          <.figure_table>
            <.table id="shared" rows={@shared} zebra={false}>
              <:col :let={s} label="artifact">
                <span class="font-mono text-sm">{s.artifact}</span>
              </:col>
              <:col :let={s} label="what we publish">
                <.prose_cell>{s.form}</.prose_cell>
              </:col>
            </.table>
          </.figure_table>
        </.section>

        <.section title="Why we share it">
          <:lead>
            A result is worth more shared than kept. Publishing the record lets the work be checked,
            reproduced, and argued with on the evidence.
          </:lead>
          <div class="max-w-prose space-y-4">
            <.spec_row label="trust">
              A number no one can check is worth little. The record lets a reader verify it or
              disagree on the evidence.
            </.spec_row>
            <.spec_row label="reproduce">
              With the prompts, seeds, and hardware named, a result is a starting point rather than
              a claim to take on faith.
            </.spec_row>
            <.spec_row label="common ground">
              Local models belong to a community. The measurements are meant to be a shared
              reference, not a competitive edge.
            </.spec_row>
          </div>
          <div class="pt-2">
            <.button navigate={~p"/research"} variant="primary" class="rounded-field">
              Read the research
            </.button>
          </div>
        </.section>
      </.page_body>
    </Layouts.app>
    """
  end
end

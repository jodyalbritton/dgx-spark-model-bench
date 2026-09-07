defmodule BenchappWeb.AboutLive do
  @moduledoc """
  Who JobyCorp is and why the work is shared.
  """

  use BenchappWeb, :live_view

  @in_full [
    %{what: "results", detail: "every number from every run, with the unit it is reported in"},
    %{what: "method", detail: "the prompts, the settings, and the steps of the run"},
    %{what: "hardware", detail: "the machines the models ran on, named in the record"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About", in_full: @in_full)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_nav="about">
      <.page_section narrow>
        <h1 class="text-4xl font-semibold leading-[1.05] tracking-[-0.03em] md:text-6xl">
          A local AI research company
        </h1>
        <.lead>
          JobyCorp runs analysis and benchmarks of local LLMs on its own hardware. The work is
          shared openly with the community — read it, check it, follow it.
        </.lead>
      </.page_section>

      <.page_section narrow>
        <.section_heading>Why the work is shared</.section_heading>
        <.lead>
          Because a published result is not a claim to take on faith. The method and the hardware
          sit next to every number, so a reader can see exactly where it came from.
        </.lead>
        <.lead>
          Sharing the work openly is also how it gets better. Anyone can read a run record, ask
          what the method missed, and hold the next run to a higher standard.
        </.lead>
      </.page_section>

      <.page_section ruled>
        <.section_heading head="in full">What published in full means</.section_heading>
        <div class="max-w-2xl overflow-x-auto">
          <.table
            id="in-full"
            rows={@in_full}
            zebra={false}
            size="sm"
            class="[&_thead_th]:bg-base-200 [&_th]:border-b [&_th]:border-base-300 [&_th]:font-mono [&_tbody_tr]:border-b [&_tbody_tr]:border-base-300"
          >
            <:col :let={item} label="part">
              <span class="font-mono">{item.what}</span>
            </:col>
            <:col :let={item} label="what that means">
              {item.detail}
            </:col>
          </.table>
        </div>
      </.page_section>

      <.page_section narrow>
        <.section_heading>Follow the work</.section_heading>
        <.lead>
          The research is the best thing on this site. It is where the runs, the measures, and the
          records live.
        </.lead>
        <div>
          <.button variant="primary" navigate={~p"/research"}>Read the research</.button>
        </div>
      </.page_section>
    </Layouts.app>
    """
  end
end

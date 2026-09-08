defmodule BenchappWeb.AboutLive do
  @moduledoc """
  The Fathom about page, on the app layout.
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
      <div class="mx-auto max-w-3xl px-4 py-16 sm:px-6">
        <.header size="page">
          About Fathom
          <:eyebrow>Our story</:eyebrow>
          <:subtitle>
            We're a small team obsessed with making the everyday feel effortless.
          </:subtitle>
        </.header>

        <div class="mt-10 space-y-4 text-base-content/80">
          <p>
            Fathom began with a simple observation: the best technology is the kind
            you forget is there. We wanted a home that quietly learns your rhythms
            and adapts — warming a room before you wake, dimming the lights as the
            evening winds down, and keeping the air fresh without a single schedule
            to program.
          </p>
          <p>
            Every device we make is built around privacy. Your data stays on your
            devices, encrypted end to end, and never leaves your home. The result
            is a system that feels personal precisely because it never shares your
            details with anyone else.
          </p>
          <p>
            We're just getting started, and we'd love to have you along for the
            ride. Join the launch list on the home page to be first in line.
          </p>
        </div>

        <div class="mt-12 flex flex-wrap gap-3">
          <.button navigate={~p"/"} variant="primary">Back home</.button>
          <.button navigate={~p"/design"} variant="ghost">Explore the interface</.button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

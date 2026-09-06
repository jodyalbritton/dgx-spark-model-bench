defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content — the nav and the flash
  container are wired in here so every page gets them for free.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-dvh flex flex-col bg-base-100">
      <header class="sticky top-0 z-40 w-full border-b border-base-300/60 bg-base-100/80 shadow-sm backdrop-blur-md">
        <div class="mx-auto flex h-16 w-full max-w-6xl items-center justify-between gap-6 px-4 sm:px-6">
          <.link
            navigate={~p"/"}
            class="flex items-center gap-2.5 text-base-content transition-opacity hover:opacity-80"
          >
            <span class="flex size-8 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-secondary text-primary-content shadow-md">
              <.icon name="hero-bolt" class="size-4" />
            </span>
            <span class="text-lg font-bold tracking-tight">Benchapp</span>
          </.link>

          <nav class="hidden items-center gap-1 md:flex" aria-label="Main navigation">
            <.link
              navigate={~p"/"}
              class={[
                "rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                (@active_nav == "home" &&
                   "bg-base-200 text-base-content") ||
                  "text-base-content/70 hover:bg-base-200/60 hover:text-base-content"
              ]}
            >
              Home
            </.link>
            <.link
              navigate={~p"/design"}
              class={[
                "rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                (@active_nav == "design" &&
                   "bg-base-200 text-base-content") ||
                  "text-base-content/70 hover:bg-base-200/60 hover:text-base-content"
              ]}
            >
              Design
            </.link>
            <.link
              navigate={~p"/custom-designs"}
              class={[
                "rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                (@active_nav == "custom" &&
                   "bg-base-200 text-base-content") ||
                  "text-base-content/70 hover:bg-base-200/60 hover:text-base-content"
              ]}
            >
              Components
            </.link>
          </nav>

          <div class="flex items-center gap-2">
            <JobyKit.CoreComponents.theme_toggle />
            <.link navigate={~p"/design"} class="hidden sm:block">
              <.button variant="primary" size="sm" class="shadow-md">
                Get started
              </.button>
            </.link>
          </div>
        </div>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

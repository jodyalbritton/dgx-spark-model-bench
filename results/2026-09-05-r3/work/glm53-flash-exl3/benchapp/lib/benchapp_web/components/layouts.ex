defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content — the responsive
  `main-nav`, the theme control, the footer, and the flash container are
  wired in here so every page gets them for free.
  """

  use BenchappWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <div class="sticky top-0 z-40 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <div class="relative mx-auto w-full max-w-5xl px-4 sm:px-6">
          <BenchappWeb.NavComponents.main_nav active={@active_nav} />
        </div>
      </div>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex max-w-5xl flex-col gap-3 px-4 py-6 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p class="flex items-center gap-2">
            <span class="font-semibold text-base-content/80">Windrose</span>
            <span aria-hidden="true" class="opacity-40">·</span>
            offline-first trail maps &amp; field notes
          </p>
          <p class="flex gap-2 font-mono">
            <.link navigate={~p"/about"} class="link link-hover">/about</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link navigate={~p"/design"} class="link link-hover">/design</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>
          </p>
        </div>
      </footer>

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

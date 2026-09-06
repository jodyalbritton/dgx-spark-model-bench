defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  render and supply only their content — the nav, the theme control,
  the footer, and the flash container are wired in here so every page
  gets them for free.

  The chrome owns its own surface: the sticky bar draws the background
  and border edge-to-edge, and `BenchappWeb.CompositeComponents.main_nav/1`
  inside it draws neither.
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
        <div class="mx-auto w-full max-w-6xl px-4 sm:px-6">
          <BenchappWeb.CompositeComponents.main_nav active={@active_nav} />
        </div>

        <div id="mobile-nav" hidden class="border-t border-base-300 md:hidden">
          <ul class="menu gap-1 px-4 py-3 sm:px-6">
            <li>
              <.link
                navigate={~p"/"}
                aria-current={@active_nav == "home" && "page"}
                class={["rounded-field font-medium", @active_nav == "home" && "menu-active"]}
              >
                Launch
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/about"}
                aria-current={@active_nav == "about" && "page"}
                class={["rounded-field font-medium", @active_nav == "about" && "menu-active"]}
              >
                About
              </.link>
            </li>
          </ul>
        </div>
      </div>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex w-full max-w-6xl flex-col gap-3 px-4 py-6 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>Lumen — a fictional product, shipped as a demo.</p>
          <p class="flex gap-2 font-mono">
            <.link navigate={~p"/design"} class="link link-hover">/design</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link href={~p"/design.json"} class="link link-hover">/design.json</.link>
          </p>
        </div>
      </footer>

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

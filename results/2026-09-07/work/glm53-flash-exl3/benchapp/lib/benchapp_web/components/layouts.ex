defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content. `app/1` draws the
  sticky top navigation (`#main-nav`), the theme control, and the flash
  container so every page gets them for free.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  @nav_links [
    %{label: "Home", path: "/", key: "home"},
    %{label: "About", path: "/about", key: "about"},
    %{label: "Design", path: "/design", key: "design"},
    %{label: "Custom designs", path: "/custom-designs", key: "custom-designs"}
  ]

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :nav_links, @nav_links)

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <div class="sticky top-0 z-40 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <nav
          id="main-nav"
          aria-label="Main"
          class="mx-auto flex w-full max-w-5xl items-center justify-between gap-4 px-4 py-3 sm:px-6"
        >
          <.link navigate={~p"/"} class="flex items-center gap-2 text-lg font-bold tracking-tight">
            <span class="flex size-8 items-center justify-center rounded-full bg-primary/15 text-primary">
              <.icon name="hero-sparkles" class="size-5" />
            </span>
            Fernline
          </.link>

          <div class="hidden items-center gap-1 md:flex">
            <.nav_link :for={link <- @nav_links} link={link} active={@active_nav == link.key} />
          </div>

          <div id="theme-toggle" class="flex items-center gap-2">
            <JobyKit.CoreComponents.theme_toggle />
            <.button
              id="nav-toggle"
              type="button"
              variant="ghost"
              shape="square"
              size="sm"
              class="md:hidden"
              aria-controls="mobile-menu"
              aria-expanded="false"
              aria-label="Toggle navigation menu"
              phx-click={
                JS.toggle(to: "#mobile-menu")
                |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: "#nav-toggle")
              }
              phx-window-keydown={JS.hide(to: "#mobile-menu")}
              phx-key="escape"
            >
              <.icon name="hero-bars-3" class="size-5 md:hidden" />
            </.button>
          </div>
        </nav>

        <div id="mobile-menu" class="hidden border-t border-base-300 md:hidden">
          <div class="mx-auto flex w-full max-w-5xl flex-col gap-1 px-4 py-3 sm:px-6">
            <.nav_link
              :for={link <- @nav_links}
              link={link}
              active={@active_nav == link.key}
              class="w-full rounded-lg px-3 py-2"
            />
          </div>
        </div>
      </div>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex max-w-5xl flex-col gap-3 px-4 py-6 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>Fernline · keeps every leaf accounted for</p>
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

  attr :link, :map, required: true
  attr :active, :boolean, default: false
  attr :class, :any, default: nil

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@link.path}
      aria-current={@active && "page"}
      class={[
        "text-sm font-medium transition-colors hover:text-primary",
        @active && "text-primary",
        !@active && "text-base-content/70",
        @class
      ]}
    >
      {@link.label}
    </.link>
    """
  end
end

defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash} active_nav="home">...` from
  inside their LiveView render and supply only their content. The sticky
  top navigation (with working mobile menu and theme control) and the
  footer are wired in here so every page gets them for free.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  @nav_links [
    %{key: "home", label: "Home", to: "/"},
    %{key: "about", label: "About", to: "/about"},
    %{key: "design", label: "Design", to: "/design"},
    %{key: "custom-designs", label: "Components", to: "/custom-designs"}
  ]

  def app(assigns) do
    assigns = assign(assigns, :nav_links, @nav_links)

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100 text-base-content">
      <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <nav
          id="main-nav"
          class="mx-auto flex w-full max-w-6xl items-center justify-between gap-4 px-4 py-3 sm:px-6"
          aria-label="Main navigation"
        >
          <a href="/" class="flex shrink-0 items-center gap-2" aria-label="Lumen home">
            <span class="flex size-8 items-center justify-center rounded-xl bg-primary text-primary-content shadow-sm">
              <.icon name="hero-bolt" class="size-5" />
            </span>
            <span class="text-lg font-semibold tracking-tight">Lumen</span>
          </a>

          <div class="hidden items-center gap-1 md:flex">
            <.nav_link
              :for={link <- @nav_links}
              to={link.to}
              current={@active_nav == link.key}
            >
              {link.label}
            </.nav_link>
          </div>

          <div class="flex items-center gap-2">
            <.theme_toggle id="theme-toggle" />
            <.button
              id="nav-toggle"
              type="button"
              variant="ghost"
              shape="square"
              class="md:hidden"
              aria-label="Toggle menu"
              aria-expanded="false"
              phx-click={JS.toggle_class("hidden", to: "#mobile-menu")}
            >
              <.icon name="hero-bars-3" class="size-5" />
            </.button>
          </div>
        </nav>

        <div id="mobile-menu" class="hidden border-t border-base-300 bg-base-100 px-4 py-3 md:hidden">
          <div class="flex flex-col gap-1">
            <.nav_link
              :for={link <- @nav_links}
              to={link.to}
              current={@active_nav == link.key}
              mobile
            >
              {link.label}
            </.nav_link>
          </div>
        </div>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex max-w-6xl flex-col gap-3 px-4 py-6 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>© {Date.utc_today().year} Lumen Labs. All rights reserved.</p>
          <p class="flex gap-2 font-mono">
            <.link navigate={~p"/design"} class="link link-hover">/design</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>
          </p>
        </div>
      </footer>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  attr :to, :string, required: true
  attr :current, :boolean, default: false
  attr :mobile, :boolean, default: false
  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@to}
      aria-current={@current && "page"}
      class={[
        "rounded-lg px-3 py-2 text-sm font-medium transition-colors",
        @mobile && "w-full text-left",
        @current && "bg-base-200 text-base-content",
        !@current && "text-base-content/70 hover:bg-base-200/70 hover:text-base-content"
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end

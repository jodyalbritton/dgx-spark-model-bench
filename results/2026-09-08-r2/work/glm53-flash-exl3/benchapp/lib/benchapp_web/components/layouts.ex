defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render. The chrome — nav, theme control, footer — is wired
  in here so every page gets it for free.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  defp nav_links do
    [
      %{key: "home", label: "Home", path: ~p"/"},
      %{key: "about", label: "About", path: ~p"/about"},
      %{key: "design", label: "Design", path: ~p"/design"},
      %{key: "custom-designs", label: "Custom Designs", path: ~p"/custom-designs"}
    ]
  end

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :nav_links, nav_links())

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <nav
          id="main-nav"
          class="mx-auto flex h-16 w-full max-w-5xl items-center gap-2 px-4 sm:px-6"
          aria-label="Main navigation"
        >
          <.link navigate={~p"/"} class="flex items-center gap-2 font-semibold text-lg">
            <span class="flex size-8 items-center justify-center rounded-full bg-gradient-to-br from-primary to-secondary text-primary-content">
              <JobyKit.CoreComponents.icon name="hero-sun" class="size-4" />
            </span>
            Lumina
          </.link>

          <ul class="ml-auto hidden items-center gap-1 md:flex">
            <li :for={link <- @nav_links}>
              <.link
                navigate={link.path}
                aria-current={@active_nav == link.key && "page"}
                class={[
                  "rounded-field px-3 py-2 text-sm font-medium transition-colors hover:bg-base-200",
                  @active_nav == link.key && "menu-active text-primary"
                ]}
              >
                {link.label}
              </.link>
            </li>
          </ul>

          <div class="ml-auto flex items-center gap-1 md:ml-0">
            <JobyKit.CoreComponents.button
              id="theme-toggle"
              variant="ghost"
              shape="square"
              size="sm"
              aria-label="Toggle dark mode"
              phx-click={JS.dispatch("lumina:toggle-theme")}
            >
              <JobyKit.CoreComponents.icon name="hero-moon" class="size-4" />
            </JobyKit.CoreComponents.button>

            <JobyKit.CoreComponents.button
              id="nav-toggle"
              variant="ghost"
              shape="square"
              size="sm"
              class="md:hidden"
              aria-label="Toggle menu"
              aria-controls="mobile-menu"
              aria-expanded="false"
              phx-click={JS.toggle(to: "#mobile-menu", in: "block", out: "hidden")}
            >
              <JobyKit.CoreComponents.icon name="hero-bars-3" class="size-5" />
            </JobyKit.CoreComponents.button>
          </div>
        </nav>

        <div id="mobile-menu" class="hidden border-t border-base-300 bg-base-100 md:hidden">
          <ul class="menu w-full gap-1 px-4 py-3">
            <li :for={link <- @nav_links}>
              <.link
                navigate={link.path}
                aria-current={@active_nav == link.key && "page"}
                class={["rounded-field", @active_nav == link.key && "menu-active"]}
              >
                {link.label}
              </.link>
            </li>
          </ul>
        </div>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex max-w-5xl flex-col gap-3 px-4 py-8 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>Lumina — light that thinks ahead. © 2026 Lumina Labs.</p>
          <p class="flex gap-2 font-mono">
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

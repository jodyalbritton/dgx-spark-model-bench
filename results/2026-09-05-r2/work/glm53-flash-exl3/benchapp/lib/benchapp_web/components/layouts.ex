defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content — the nav, the theme
  control, and the flash container are wired in here so every page
  gets them for free.
  """
  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  embed_templates "layouts/*"

  @nav_links [
    %{key: "home", label: "Home", href: "/"},
    %{key: "about", label: "About", href: "/about"},
    %{key: "design", label: "Design", href: "/design"},
    %{key: "custom-designs", label: "Custom Designs", href: "/custom-designs"}
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
        <nav id="main-nav" class="mx-auto flex w-full max-w-5xl items-center gap-2 px-4 py-2 sm:px-6">
          <.link
            navigate={~p"/"}
            class="flex items-center gap-2 text-lg font-semibold tracking-tight"
          >
            <span class="flex size-7 items-center justify-center rounded-full bg-primary text-primary-content">
              <.icon name="hero-bolt" class="size-4" />
            </span>
            Solstice
          </.link>

          <ul class="ml-auto hidden items-center gap-1 md:flex">
            <li :for={link <- @nav_links}>
              <.link
                navigate={link.href}
                aria-current={@active_nav == link.key && "page"}
                class={[
                  "rounded-field px-3 py-2 text-sm font-medium transition-colors hover:bg-base-200",
                  @active_nav == link.key && "menu-active bg-base-200"
                ]}
              >
                {link.label}
              </.link>
            </li>
          </ul>

          <div class="ml-auto flex items-center gap-1 md:ml-2">
            <CoreComponents.theme_toggle id="theme-toggle" />
            <.button
              shape="square"
              variant="ghost"
              size="sm"
              id="nav-toggle"
              type="button"
              aria-label="Toggle navigation menu"
              aria-expanded="false"
              aria-controls="nav-mobile"
              class="md:hidden"
            >
              <.icon name="hero-bars-3" class="size-5" />
            </.button>
          </div>
        </nav>

        <ul
          id="nav-mobile"
          class="hidden border-t border-base-300 bg-base-100 px-4 pb-3 pt-1 md:hidden"
        >
          <li :for={link <- @nav_links}>
            <.link
              navigate={link.href}
              aria-current={@active_nav == link.key && "page"}
              class={[
                "block rounded-field px-3 py-2 text-sm font-medium transition-colors hover:bg-base-200",
                @active_nav == link.key && "menu-active bg-base-200"
              ]}
            >
              {link.label}
            </.link>
          </li>
        </ul>
      </div>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex max-w-5xl flex-col gap-3 px-4 py-6 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>Solstice · light that keeps pace with you.</p>
          <p class="flex gap-2 font-mono">
            <.link navigate={~p"/design"} class="link link-hover">/design</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>
          </p>
        </div>
      </footer>

      <CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

defmodule BenchappWeb.Layouts do
  @moduledoc """
  Page chrome for Benchapp.

  `app/1` owns the sticky `#main-nav` bar — brand, page links, theme
  control, and the phone-width menu toggle — plus the footer and the flash
  container, so pages compose `<Layouts.app flash={@flash} active_nav="...">`
  and supply only their content.

  Two details the nav depends on:

    * The active page is marked with `aria-current="page"` and styled with
      theme tokens only, so the treatment survives a theme swap.
    * Below `md` the menu collapses behind `#nav-toggle`, but it stays in
      the document (`max-md:hidden`, not an `if`) so the links remain
      crawlable and assertable at every width. `BenchappWeb.Chrome` owns
      that open/closed state.

  The chrome owns its own surface: the sticky bar draws the background and
  border edge-to-edge, and the nav inside it draws neither. Splitting that
  between the two is what produces a seam where the bar's max-width ends.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  @nav_links [
    %{key: "home", label: "Overview", href: "/"},
    %{key: "about", label: "About", href: "/about"},
    %{key: "design", label: "Design", href: "/design"},
    %{key: "custom-designs", label: "Components", href: "/custom-designs"}
  ]

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil

  attr :nav_open, :boolean,
    default: false,
    doc: "Whether the phone-width menu is expanded. Owned by `BenchappWeb.Chrome`."

  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :nav_links, @nav_links)

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <header class="sticky top-0 z-40 border-b border-base-300/80 bg-base-100/85 backdrop-blur">
        <div class="mx-auto w-full max-w-6xl px-4 sm:px-6">
          <nav id="main-nav" aria-label="Main" class="relative flex items-center gap-2 py-3">
            <.link
              navigate={~p"/"}
              class="flex items-center gap-2 px-1 text-base font-semibold tracking-tight transition-opacity hover:opacity-75"
            >
              <span class="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary text-primary-content shadow-sm">
                <.icon name="hero-water" class="size-5" />
              </span>
              Tidepool
            </.link>

            <ul
              id="nav-menu"
              class={[
                "ml-2 flex items-center gap-1 max-md:absolute max-md:inset-x-0 max-md:top-full max-md:z-50 max-md:flex-col max-md:items-stretch max-md:gap-1 max-md:rounded-b-2xl max-md:border max-md:border-base-300 max-md:bg-base-100 max-md:p-3 max-md:shadow-lg",
                !@nav_open && "max-md:hidden"
              ]}
            >
              <li :for={link <- @nav_links}>
                <.link
                  navigate={link.href}
                  aria-current={@active_nav == link.key && "page"}
                  class={[
                    "block rounded-full px-3 py-2 text-sm transition-colors max-md:rounded-xl",
                    @active_nav == link.key && "bg-primary/10 font-semibold text-primary",
                    @active_nav != link.key &&
                      "text-base-content/70 hover:bg-base-200 hover:text-base-content"
                  ]}
                >
                  {link.label}
                </.link>
              </li>
            </ul>

            <div class="ml-auto flex items-center gap-1">
              <.button
                id="theme-toggle"
                variant="ghost"
                size="sm"
                shape="square"
                phx-click="toggle_theme"
                aria-label="Switch colour theme"
                title="Switch colour theme"
              >
                <.icon name="hero-sun" class="size-4 dark:hidden" />
                <.icon name="hero-moon" class="hidden size-4 dark:block" />
              </.button>

              <.button
                id="nav-toggle"
                variant="ghost"
                size="sm"
                shape="square"
                phx-click="toggle_nav"
                phx-value-open={!@nav_open}
                aria-controls="nav-menu"
                aria-expanded={to_string(@nav_open)}
                aria-label="Show navigation menu"
                class="md:hidden"
              >
                <.icon name={if @nav_open, do: "hero-x-mark", else: "hero-bars-3"} class="size-5" />
              </.button>
            </div>
          </nav>
        </div>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300 bg-base-200/40">
        <div class="mx-auto flex max-w-6xl flex-col gap-4 px-4 py-8 text-sm sm:flex-row sm:items-end sm:justify-between sm:px-6">
          <div class="max-w-sm space-y-2">
            <p class="flex items-center gap-2 font-semibold text-base-content">
              <span class="flex size-6 items-center justify-center rounded-md bg-primary/15 text-primary">
                <.icon name="hero-water" class="size-4" />
              </span>
              Tidepool Instruments
            </p>
            <p class="text-base-content/60">
              Buoy-grade water telemetry for community labs. A fictional product,
              built as the demo surface for this app's component kit.
            </p>
          </div>
          <div class="flex flex-wrap items-center gap-x-4 gap-y-2 font-mono text-xs text-base-content/55">
            <.link navigate={~p"/about"} class="link link-hover">About</.link>
            <.link navigate={~p"/design"} class="link link-hover">/design</.link>
            <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>
            <.link href={~p"/design.json"} class="link link-hover">/design.json</.link>
          </div>
        </div>
      </footer>

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

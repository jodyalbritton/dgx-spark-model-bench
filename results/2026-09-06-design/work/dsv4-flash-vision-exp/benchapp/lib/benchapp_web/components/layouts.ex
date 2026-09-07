defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content — the nav, the theme
  control, the footer, and the flash container are wired in here so
  every page gets them for free.

  The chrome owns its own surface: the sticky bar draws the background
  and hairline edge-to-edge and the nav draws neither. The nav marks the
  current page's link with `aria-current="page"`, collapses to a toggle
  button at phone widths, and carries the kit's theme toggle at every
  width.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  @nav_links [
    %{key: "home", label: "Home", href: "/"},
    %{key: "research", label: "Research", href: "/research"},
    %{key: "about", label: "About", href: "/about"}
  ]

  defp nav_links, do: @nav_links

  defp name_current?(active, key), do: active == key

  attr :flash, :map, required: true
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <div class="sticky top-0 z-40 border-b border-base-300 bg-base-100">
        <div class="mx-auto w-full max-w-6xl px-6 md:px-8">
          <nav id="main-nav" class="flex h-16 items-center justify-between gap-x-6">
            <.link navigate={~p"/"} class="flex items-center gap-2.5">
              <span aria-hidden="true" class="inline-block size-2.5 border border-secondary"></span>
              <span class="text-lg font-semibold tracking-tight">JobyCorp</span>
            </.link>

            <div class="flex items-center gap-1 md:gap-2">
              <ul class="hidden items-center gap-8 md:flex">
                <li :for={link <- nav_links()}>
                  <.link
                    navigate={link.href}
                    aria-current={name_current?(@active_nav, link.key) && "page"}
                    class={[
                      "text-sm font-medium transition-colors duration-150",
                      name_current?(@active_nav, link.key) && "text-primary",
                      !name_current?(@active_nav, link.key) &&
                        "text-base-content hover:text-primary"
                    ]}
                  >
                    {link.label}
                  </.link>
                </li>
              </ul>

              <.theme_toggle id="theme-toggle" />

              <.button
                id="nav-toggle"
                type="button"
                variant="ghost"
                shape="square"
                size="sm"
                aria-controls="nav-menu"
                aria-label="Toggle navigation"
                class="md:hidden"
                phx-click={JS.toggle(to: "#nav-menu")}
              >
                <.icon name="hero-bars-3" class="size-5" />
              </.button>
            </div>
          </nav>

          <div id="nav-menu" class="hidden pb-5 md:!hidden">
            <ul class="flex flex-col pt-1">
              <li :for={link <- nav_links()}>
                <.link
                  navigate={link.href}
                  aria-current={name_current?(@active_nav, link.key) && "page"}
                  class={[
                    "block border-b border-base-300/60 py-2.5 text-sm font-medium transition-colors duration-150 last:border-b-0",
                    name_current?(@active_nav, link.key) && "text-primary",
                    !name_current?(@active_nav, link.key) &&
                      "text-base-content hover:text-primary"
                  ]}
                >
                  {link.label}
                </.link>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto w-full max-w-6xl px-6 py-10 md:px-8">
          <div class="flex flex-col gap-6 md:flex-row md:items-baseline md:justify-between md:gap-12">
            <p class="flex items-center gap-2.5">
              <span aria-hidden="true" class="inline-block size-2.5 border border-secondary"></span>
              <span class="font-semibold tracking-tight">JobyCorp</span>
            </p>
            <ul class="flex flex-wrap gap-x-8 gap-y-3 text-sm">
              <li :for={link <- nav_links()}>
                <.link
                  navigate={link.href}
                  class="text-base-content/70 transition-colors duration-150 hover:text-primary"
                >
                  {link.label}
                </.link>
              </li>
            </ul>
            <p class="max-w-sm text-sm leading-relaxed text-base-content/70">
              Runs local language models on its own hardware and publishes the results in full.
            </p>
          </div>
        </div>
      </footer>

      <.flash_group flash={@flash} />
    </div>
    """
  end
end

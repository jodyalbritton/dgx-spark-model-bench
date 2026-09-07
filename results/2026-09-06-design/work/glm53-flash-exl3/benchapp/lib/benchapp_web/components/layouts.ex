defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  render and supply only their content — the JobyCorp nav, the theme
  control, and the footer are wired in here so every page gets them.

  The header is one row on a hairline: the wordmark on the left, the
  three page links in the middle, the theme control on the right. Below
  `md` the page links collapse behind the nav toggle. The footer is one
  row above a hairline: the wordmark, the page links, and one sentence
  saying what JobyCorp does.
  """

  use BenchappWeb, :html

  embed_templates "layouts/*"

  @nav_links [
    %{key: "home", label: "Home", href: "/"},
    %{key: "research", label: "Research", href: "/research"},
    %{key: "about", label: "About", href: "/about"}
  ]

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :nav_links, @nav_links)

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100">
        <div class="relative mx-auto flex h-14 w-full max-w-6xl items-center justify-between gap-4 px-6 md:px-8">
          <.link
            navigate={~p"/"}
            class="flex flex-none items-center gap-2.5 text-base font-semibold tracking-tight text-base-content"
          >
            <span class="wordmark-mark" aria-hidden="true"></span> JobyCorp
          </.link>

          <nav
            id="main-nav"
            aria-label="Main"
            class="max-md:absolute max-md:inset-x-0 max-md:top-full max-md:border-b max-md:border-base-300 max-md:bg-base-100 max-md:px-6 max-md:pb-5 max-md:pt-3"
          >
            <ul class="flex flex-col gap-3 md:flex-row md:items-center md:gap-6">
              <li :for={link <- @nav_links}>
                <.link
                  navigate={link.href}
                  aria-current={if @active_nav == link.key, do: "page"}
                  class={[
                    "text-sm font-medium transition-colors duration-150",
                    if(@active_nav == link.key,
                      do: "text-primary",
                      else: "text-base-content hover:text-primary"
                    )
                  ]}
                >
                  {link.label}
                </.link>
              </li>
            </ul>
          </nav>

          <div class="flex flex-none items-center gap-1.5">
            <.theme_toggle id="theme-toggle" />
            <.button
              id="nav-toggle"
              type="button"
              variant="ghost"
              shape="square"
              size="sm"
              class="md:hidden"
              aria-expanded="false"
              aria-controls="main-nav"
              aria-label="Menu"
            >
              <.icon name="hero-bars-3" class="nav-icon-open size-5" />
              <.icon name="hero-x-mark" class="nav-icon-close size-5" />
            </.button>
          </div>
        </div>
      </header>

      <main class="flex-1">
        <div class="mx-auto w-full max-w-6xl px-6 md:px-8">
          {render_slot(@inner_block)}
        </div>
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex w-full max-w-6xl flex-col gap-6 px-6 py-10 md:flex-row md:items-baseline md:justify-between md:px-8">
          <div class="space-y-3">
            <p class="flex items-center gap-2.5 text-base font-semibold tracking-tight">
              <span class="wordmark-mark" aria-hidden="true"></span> JobyCorp
            </p>
            <p class="max-w-xs text-sm text-base-content/70">
              Benchmarks of local LLMs, run on our own hardware and published in full.
            </p>
          </div>

          <nav aria-label="Footer">
            <ul class="flex flex-wrap gap-x-6 gap-y-2 text-sm">
              <li :for={link <- @nav_links}>
                <.link
                  navigate={link.href}
                  class="text-base-content/70 underline underline-offset-4 decoration-1 transition-colors duration-150 hover:text-primary"
                >
                  {link.label}
                </.link>
              </li>
            </ul>
          </nav>
        </div>
      </footer>

      <.flash_group flash={@flash} />
    </div>
    """
  end
end

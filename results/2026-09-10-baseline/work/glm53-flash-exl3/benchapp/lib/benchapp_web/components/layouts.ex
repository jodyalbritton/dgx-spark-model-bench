defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for JobyCorp's site. Pages compose
  `<Layouts.app flash={@flash}>...` from inside their LiveView render and
  supply only their content — the navigation, the theme control, the
  footer, and the flash container are wired in here so every page gets
  them for free.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  @links [
    %{key: "home", label: "Home", href: "/"},
    %{key: "research", label: "Research", href: "/research"},
    %{key: "about", label: "About", href: "/about"}
  ]

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :links, @links)

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100">
        <nav
          id="main-nav"
          data-active={@active_nav}
          class="mx-auto flex max-w-6xl items-center gap-6 px-6 py-4 md:px-8"
          aria-label="Main"
        >
          <.link
            navigate="/"
            class="flex items-center gap-2 font-semibold tracking-tight text-base-content"
          >
            <span class="wordmark-mark" aria-hidden="true"></span> JobyCorp
          </.link>

          <ul id="nav-links" class="hidden items-center gap-6 md:flex">
            <li :for={link <- @links}>
              <.link
                navigate={link.href}
                aria-current={@active_nav == link.key && "page"}
                class={[
                  "text-sm transition-colors duration-150 hover:text-primary",
                  @active_nav == link.key && "text-primary"
                ]}
              >
                {link.label}
              </.link>
            </li>
          </ul>

          <div class="ml-auto flex items-center gap-2">
            <JobyKit.CoreComponents.theme_toggle />
            <JobyKit.CoreComponents.button
              id="nav-toggle"
              type="button"
              variant="ghost"
              shape="square"
              size="sm"
              class="md:hidden"
              aria-expanded="false"
              aria-controls="nav-links"
              aria-label="Toggle navigation"
              data-nav-toggle
            >
              <.icon name="hero-bars-3" class="size-5" />
            </JobyKit.CoreComponents.button>
          </div>
        </nav>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto max-w-6xl space-y-4 px-6 py-8 md:px-8">
          <div class="flex flex-wrap items-center justify-between gap-x-8 gap-y-2">
            <p class="flex items-center gap-2 font-semibold tracking-tight">
              <span class="wordmark-mark" aria-hidden="true"></span> JobyCorp
            </p>
            <ul class="flex gap-6 text-sm">
              <li :for={link <- @links}>
                <.link
                  navigate={link.href}
                  class="transition-colors duration-150 hover:text-primary"
                >
                  {link.label}
                </.link>
              </li>
            </ul>
          </div>
          <p class="max-w-prose text-sm text-base-content/70">
            JobyCorp runs benchmarks of local language models on its own
            hardware and publishes the results in full.
          </p>
        </div>
      </footer>

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

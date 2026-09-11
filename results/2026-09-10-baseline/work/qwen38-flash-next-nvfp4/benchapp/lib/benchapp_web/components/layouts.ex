defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content — the nav, the theme
  control, the footer, and the flash container are wired in here so
  every page gets them for free. Pass `active_nav` (the current page key)
  so the nav marks the current link.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  defp nav_links do
    [
      %{key: "home", label: "Home", href: ~p"/"},
      %{key: "research", label: "Research", href: ~p"/research"},
      %{key: "about", label: "About", href: ~p"/about"}
    ]
  end

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :nav, nav_links())

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100">
        <nav
          id="main-nav"
          aria-label="Primary"
          class="mx-auto flex max-w-6xl items-center gap-6 px-6 py-4 md:px-8"
        >
          <.link navigate={~p"/"} class="flex items-center gap-2">
            <span class="wordmark-mark" aria-hidden="true"></span>
            <span class="text-lg font-semibold tracking-tight">JobyCorp</span>
          </.link>

          <div class="ml-auto flex items-center gap-4">
            <ul class="hidden items-center gap-6 text-sm md:flex">
              <li :for={link <- @nav}>
                <.link
                  navigate={link.href}
                  aria-current={@active_nav == link.key && "page"}
                  class={[
                    "transition-colors duration-150",
                    if(@active_nav == link.key,
                      do: "font-medium text-primary",
                      else: "text-base-content/80 hover:text-primary"
                    )
                  ]}
                >
                  {link.label}
                </.link>
              </li>
            </ul>

            <JobyKit.CoreComponents.theme_toggle id="theme-toggle" />

            <.button
              id="nav-toggle"
              type="button"
              shape="square"
              variant="ghost"
              class="md:hidden"
              aria-label="Toggle navigation"
              aria-controls="mobile-menu"
              aria-expanded="false"
              phx-click={
                JS.toggle_class("hidden", to: "#mobile-menu")
                |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: "#nav-toggle")
              }
            >
              <.icon name="hero-bars-3" class="size-5" />
            </.button>
          </div>
        </nav>

        <div id="mobile-menu" class="hidden border-t border-base-300 md:hidden">
          <ul class="mx-auto max-w-6xl space-y-1 px-6 py-3 text-sm">
            <li :for={link <- @nav}>
              <.link
                navigate={link.href}
                aria-current={@active_nav == link.key && "page"}
                class={[
                  "block py-2 transition-colors duration-150",
                  if(@active_nav == link.key,
                    do: "font-medium text-primary",
                    else: "text-base-content/80 hover:text-primary"
                  )
                ]}
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
        <div class="mx-auto flex max-w-6xl flex-col gap-4 px-6 py-8 md:flex-row md:items-center md:justify-between md:px-8">
          <div class="flex items-center gap-2">
            <span class="wordmark-mark" aria-hidden="true"></span>
            <span class="font-semibold tracking-tight">JobyCorp</span>
          </div>
          <p class="text-sm text-base-content/70 md:max-w-md">
            We run language models on our own hardware, measure them, and publish the results in full.
          </p>
          <ul class="flex gap-5 text-sm">
            <li :for={link <- @nav}>
              <.link
                navigate={link.href}
                class="text-base-content/80 hover:text-primary transition-colors duration-150"
              >
                {link.label}
              </.link>
            </li>
          </ul>
        </div>
      </footer>

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash} active_nav="...">...` from
  inside their LiveView render and supply only their content — the nav,
  the theme control, the footer, and the flash container are wired in
  here so every page gets them for free.

  The chrome owns its own surface: the sticky bar draws the background
  and border edge-to-edge, and the nav inside it draws neither.

  ## Navigation

  `main_nav/1` (rendered by `app/1`) is the app's single nav bar:

    * `id="main-nav"` on the `<nav>` element, links marked with
      `aria-current="page"` for the active page
    * desktop links inline; phone widths collapse them into a panel
      behind the `#nav-toggle` button
    * the kit's theme control carries `id="theme-toggle"` and stays
      reachable at every width
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  defp nav_links do
    [
      %{key: "home", label: "Home", href: ~p"/"},
      %{key: "about", label: "About", href: ~p"/about"},
      %{key: "design", label: "Design", href: ~p"/design"},
      %{key: "custom-designs", label: "Custom Designs", href: ~p"/custom-designs"}
    ]
  end

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <div class="sticky top-0 z-40 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <div class="mx-auto w-full max-w-6xl px-4 sm:px-6">
          <.main_nav active={@active_nav} />
        </div>
      </div>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex max-w-6xl flex-col gap-3 px-4 py-6 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>Cadence · release notes for teams that ship on Fridays.</p>
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

  attr :active, :string, default: nil

  def main_nav(assigns) do
    ~H"""
    <nav
      id="main-nav"
      aria-label="Main"
      class="flex w-full items-center justify-between gap-2 py-2"
    >
      <.link
        navigate={~p"/"}
        class="flex shrink-0 items-center gap-2 text-base font-semibold normal-case"
      >
        <span class="flex size-7 items-center justify-center rounded-lg bg-primary text-primary-content">
          <.icon name="hero-bolt" class="size-4" />
        </span>
        Cadence
      </.link>

      <ul class="hidden items-center gap-1 md:flex" aria-label="Primary">
        <li :for={link <- nav_links()}>
          <.link
            navigate={link.href}
            aria-current={@active == link.key && "page"}
            class={[
              "rounded-field px-3 py-2 text-sm transition-colors hover:bg-base-200",
              @active == link.key && "bg-base-200 font-semibold text-base-content"
            ]}
          >
            {link.label}
          </.link>
        </li>
      </ul>

      <div class="flex items-center gap-2">
        <JobyKit.CoreComponents.theme_toggle id="theme-toggle" />
        <.button
          id="nav-toggle"
          type="button"
          variant="ghost"
          shape="square"
          class="md:hidden"
          aria-controls="nav-menu"
          aria-label="Toggle navigation menu"
          phx-click={JS.toggle_class("hidden", to: "#nav-menu")}
        >
          <.icon name="hero-bars-3" class="size-5" />
        </.button>
      </div>
    </nav>

    <div id="nav-menu" class="hidden md:hidden!">
      <ul class="menu gap-1 pb-3" aria-label="Mobile">
        <li :for={link <- nav_links()}>
          <.link
            navigate={link.href}
            aria-current={@active == link.key && "page"}
            class={@active == link.key && "menu-active"}
          >
            {link.label}
          </.link>
        </li>
      </ul>
    </div>
    """
  end
end

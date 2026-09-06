defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content — the top navigation,
  the theme control, the footer, and the flash container are wired in
  here so every page gets them for free.

  `main_nav/1` is this app's site header: a brand, a desktop link
  cluster, a phone-width disclosure menu, and the kit's theme toggle.
  It marks the current page's link with `aria-current="page"`.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  @nav_links [
    %{key: "home", label: "Home", href: ~p"/"},
    %{key: "about", label: "About", href: ~p"/about"},
    %{key: "design", label: "Design System", href: ~p"/design"},
    %{key: "custom-designs", label: "Components", href: ~p"/custom-designs"}
  ]

  attr :active, :string, default: nil, doc: "The `:key` of the link to mark current."
  attr :rest, :global

  slot :theme, doc: "Trailing controls — typically the kit theme toggle."

  @doc """
  The app's primary navigation bar.

      <.main_nav active="home">
        <:theme><.theme_toggle id="theme-toggle" /></:theme>
      </.main_nav>

  Desktop widths show the full link row; phone widths collapse it behind
  the `nav-toggle` disclosure button, whose open state is held in a
  colocated hook (a class toggle plus `aria-expanded` bookkeeping).
  """
  def main_nav(assigns) do
    ~H"""
    <nav
      id="main-nav"
      data-component="BenchappWeb.Layouts.main_nav"
      class="relative mx-auto flex w-full max-w-6xl items-center gap-2 px-4 py-3 sm:px-6"
      {@rest}
    >
      <.link navigate={~p"/"} class="flex items-center gap-2 text-base font-bold tracking-tight">
        <span class="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-content">
          <.icon name="hero-bolt" class="size-5" />
        </span>
        <span>SIGNAL</span>
      </.link>

      <%!-- Desktop link row --%>
      <ul class="menu menu-horizontal ml-6 hidden gap-1 px-0 [md:flex]">
        <li :for={link <- @nav_links}>
          <.link
            navigate={link.href}
            aria-current={@active == link.key && "page"}
            class={[
              "rounded-field font-medium",
              @active == link.key && "menu-active"
            ]}
          >
            {link.label}
          </.link>
        </li>
      </ul>

      <div class="flex flex-1 items-center justify-end gap-2">
        {render_slot(@theme)}
        <%!-- Phone-only disclosure toggle --%>
        <button
          id="nav-toggle"
          type="button"
          class="btn btn-ghost btn-square [md:hidden]"
          aria-controls="main-nav-links"
          aria-expanded="false"
          aria-label="Toggle navigation menu"
          phx-hook=".NavToggle"
        >
          <.icon name="hero-bars-3" class="size-6" />
        </button>
      </div>

      <%!-- Collapsed link row, phone widths --%>
      <ul
        id="main-nav-links"
        class="menu absolute inset-x-0 top-full z-50 hidden flex-col gap-1 border-b border-base-300 bg-base-100/95 px-4 py-3 backdrop-blur [md:!hidden]"
      >
        <li :for={link <- @nav_links}>
          <.link
            navigate={link.href}
            aria-current={@active == link.key && "page"}
            class={[
              "rounded-field font-medium",
              @active == link.key && "menu-active"
            ]}
          >
            {link.label}
          </.link>
        </li>
      </ul>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".NavToggle">
        export default {
          mounted() {
            this.el.addEventListener("click", () => {
              const menu = document.getElementById("main-nav-links")
              if (!menu) return
              const open = menu.classList.toggle("hidden") === false
              this.el.setAttribute("aria-expanded", String(open))
            })
          }
        }
      </script>
    </nav>
    """
  end

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <div class="sticky top-0 z-40 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <.main_nav active={@active_nav}>
          <:theme><.theme_toggle id="theme-toggle" /></:theme>
        </.main_nav>
      </div>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex max-w-6xl flex-col gap-3 px-4 py-6 text-xs text-base-content/60 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>Signal — realtime analytics that keep pace with your fleet.</p>
          <p class="flex gap-2 font-mono">
            <.link navigate={~p"/design"} class="link link-hover">/design</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>
            <span aria-hidden="true" class="opacity-40">·</span>
            <.link href={~p"/design.json"} class="link link-hover">/design.json</.link>
          </p>
        </div>
      </footer>

      <.flash_group flash={@flash} />
    </div>
    """
  end
end

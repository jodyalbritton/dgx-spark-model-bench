defmodule BenchappWeb.NavComponents do
  @moduledoc """
  App chrome navigation built for this product.

  `main_nav/1` is the responsive top navigation: a horizontal menu on
  desktop, and at phone widths the links collapse behind a `#nav-toggle`
  button (a colocated hook toggles the panel and keeps `aria-expanded`
  honest). The current page's link carries `aria-current="page"`.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @links [
    %{key: "home", label: "Home", href: "/"},
    %{key: "about", label: "About", href: "/about"},
    %{key: "design", label: "Design", href: "/design"},
    %{key: "custom-designs", label: "Custom Designs", href: "/custom-designs"}
  ]

  @doc """
  The top navigation bar. `active` is the `:key` of the current page's
  link (`"home"`, `"about"`, `"design"`, `"custom-designs"`).

      <.main_nav active="home" />

  Renders a `<nav id="main-nav">`. At `md` and up the links are a
  horizontal menu; below that they live in a dropdown panel toggled by
  `#nav-toggle`. Theme switching sits in the bar at both widths via
  `JobyKit.CoreComponents.theme_toggle/1`.
  """
  attr :active, :string, default: nil, doc: "The `:key` of the link to mark current."
  attr :class, :any, default: nil
  attr :rest, :global

  def main_nav(assigns) do
    assigns = assign(assigns, :links, @links)

    ~H"""
    <nav
      id="main-nav"
      data-component="BenchappWeb.NavComponents.main_nav"
      class={["navbar gap-2 px-0", @class]}
      aria-label="Main"
      {@rest}
    >
      <div class="flex flex-1 items-center gap-2">
        <.link
          navigate={~p"/"}
          class="flex items-center gap-2 text-lg font-semibold tracking-tight text-base-content"
        >
          <span class="flex size-8 items-center justify-center rounded-box bg-primary/15 text-primary">
            <CoreComponents.icon name="hero-compass" class="size-5" />
          </span>
          <span>Windrose</span>
        </.link>
      </div>

      <ul class="menu menu-horizontal hidden gap-1 px-1 md:flex">
        <li :for={link <- @links}>
          <.link
            navigate={link.href}
            aria-current={link.key == @active && "page"}
            class={["rounded-field", link.key == @active && "menu-active"]}
          >
            {link.label}
          </.link>
        </li>
      </ul>

      <div class="flex items-center gap-1">
        <CoreComponents.theme_toggle id="theme-toggle" class="join-sm" />
        <CoreComponents.button
          id="nav-toggle"
          type="button"
          size="sm"
          variant="ghost"
          shape="square"
          class="md:hidden"
          phx-hook=".NavToggle"
          aria-controls="nav-menu"
          aria-expanded="false"
          aria-label="Toggle navigation menu"
        >
          <CoreComponents.icon name="hero-bars-3" class="size-5" />
        </CoreComponents.button>
      </div>

      <ul
        id="nav-menu"
        class={[
          "menu absolute inset-x-0 top-full z-50 flex-col gap-1 rounded-box border border-base-300",
          "bg-base-100 p-2 shadow-lg md:hidden",
          "hidden"
        ]}
      >
        <li :for={link <- @links}>
          <.link
            navigate={link.href}
            aria-current={link.key == @active && "page"}
            class={["rounded-field", link.key == @active && "menu-active"]}
          >
            {link.label}
          </.link>
        </li>
      </ul>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".NavToggle">
        export default {
          mounted() {
            const menu = document.getElementById("nav-menu")
            if (!menu) return

            const close = () => {
              menu.classList.add("hidden")
              this.el.setAttribute("aria-expanded", "false")
            }

            const toggle = () => {
              const hidden = menu.classList.toggle("hidden")
              this.el.setAttribute("aria-expanded", String(!hidden))
            }

            this.onToggle = toggle
            this.onMenuClick = (event) => {
              if (event.target.closest("a")) close()
            }
            this.onOutsideClick = (event) => {
              if (!event.target.closest("#main-nav")) close()
            }

            this.el.addEventListener("click", this.onToggle)
            menu.addEventListener("click", this.onMenuClick)
            document.addEventListener("click", this.onOutsideClick)
          },
          destroyed() {
            this.el.removeEventListener("click", this.onToggle)
            document.removeEventListener("click", this.onOutsideClick)
          }
        }
      </script>
    </nav>
    """
  end
end

defmodule JobyKit.NavComponent do
  @moduledoc """
  Small kit-shipped navigation primitives. The `simple_nav/1` function
  component renders a daisyUI navbar suitable for the greenfield
  bootstrap (`mix joby_kit.bootstrap`) — Home / Design / Custom Designs —
  with an active-state highlight and an `:actions` slot for trailing
  controls such as `JobyKit.CoreComponents.theme_toggle/1`.

  Hosts can use it anywhere: a layout, a LiveView render, or a function
  component template. Pass `links:` to override the default link list.

  ## Surface belongs to the layout

  `simple_nav/1` renders no background, border, or outer spacing. A nav
  that painted its own surface could not sit inside a layout's own
  sticky bar without the two disagreeing — a translucent bar with an
  opaque nav inside it shows the seam wherever the nav's max-width ends.
  Give the surface to the container:

      <div class="sticky top-0 z-40 border-b border-base-300 bg-base-100">
        <div class="mx-auto w-full max-w-6xl px-4">
          <.simple_nav active="home" brand="MyApp" />
        </div>
      </div>
  """

  use Phoenix.Component

  @default_links [
    %{key: "home", label: "Home", href: "/"},
    %{key: "design", label: "Design", href: "/design"},
    %{key: "custom-designs", label: "Custom Designs", href: "/custom-designs"}
  ]

  attr :active, :string, default: nil, doc: "The `:key` of the link to mark current."
  attr :brand, :string, default: "JobyKit"
  attr :brand_href, :string, default: "/"

  attr :links, :list,
    default: @default_links,
    doc: "Maps of `%{key:, label:, href:}`. Replaces the default three."

  attr :class, :any, default: nil
  attr :rest, :global

  slot :actions, doc: "Trailing controls, e.g. a theme toggle or account menu."

  def simple_nav(assigns) do
    ~H"""
    <nav data-component="JobyKit.NavComponent.simple_nav" class={["navbar gap-2", @class]} {@rest}>
      <div class="flex-1">
        <.link navigate={@brand_href} class="btn btn-ghost px-2 text-lg font-semibold normal-case">
          {@brand}
        </.link>
      </div>

      <ul class="menu menu-horizontal gap-1 px-1">
        <li :for={link <- @links}>
          <.link
            navigate={link.href}
            aria-current={@active == link.key && "page"}
            class={["rounded-field", @active == link.key && "menu-active"]}
          >
            {link.label}
          </.link>
        </li>
      </ul>

      <div :if={@actions != []} class="flex items-center gap-2 pl-1">
        {render_slot(@actions)}
      </div>
    </nav>
    """
  end
end

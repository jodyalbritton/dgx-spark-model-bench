defmodule BenchappWeb.ChromeComponents do
  @moduledoc """
  Site chrome for Lodestar: the top navigation, the theme control inside
  it, and the page footer.

  These are the composites `Layouts.app/1` composes on every page, which
  is why they live in a component module rather than inline in the
  layout — the nav in particular is shared by all four pages and carries
  the accessibility contract (aria-current, aria-controls, aria-expanded)
  that markup pasted into a layout tends to drift on.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @links [
    %{key: "home", label: "Home", href: "/"},
    %{key: "about", label: "About", href: "/about"},
    %{key: "design", label: "Design", href: "/design"},
    %{key: "custom-designs", label: "Components", href: "/custom-designs"}
  ]

  @doc """
  The site's primary navigation.

  Desktop gets an inline link row; phone widths collapse the same links
  behind `#nav-toggle`. `#main-nav` is the landmark tests and agents
  anchor on, and the active link carries `aria-current="page"`.

      <ChromeComponents.site_nav active="home" />
  """
  attr :active, :string, default: nil, doc: "The `:key` of the current page's link."
  attr :brand, :string, default: "Lodestar"
  attr :brand_href, :string, default: "/"

  attr :links, :list,
    default: @links,
    doc: "Maps of `%{key:, label:, href:}`. Replaces the default four."

  attr :class, :any, default: nil
  attr :rest, :global

  def site_nav(assigns) do
    toggle_menu =
      JS.toggle_class("hidden flex", to: "#nav-menu")
      |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: "#nav-toggle")

    assigns = assign(assigns, :toggle_menu, toggle_menu)

    ~H"""
    <nav
      id="main-nav"
      data-component="BenchappWeb.ChromeComponents.site_nav"
      aria-label="Main"
      class={[
        "mx-auto flex w-full max-w-6xl flex-col gap-1 px-4 sm:px-6",
        "lg:flex-row lg:items-center lg:gap-x-6",
        @class
      ]}
      {@rest}
    >
      <%!-- One row on a phone (brand left, controls right); `lg:contents`
            dissolves this wrapper at desktop so brand, links, and controls
            share one line. --%>
      <div class="flex items-center justify-between gap-3 py-3 lg:contents">
        <.link
          navigate={@brand_href}
          class="group flex items-center gap-2.5 text-base font-semibold tracking-tight lg:order-1"
        >
          <span class="flex size-8 items-center justify-center rounded-field bg-primary text-primary-content shadow-sm transition-transform group-hover:-rotate-6">
            <CoreComponents.icon name="hero-rocket-launch" class="size-4" />
          </span>
          <span class="font-mono uppercase tracking-[0.2em]">{@brand}</span>
        </.link>

        <div class="flex items-center gap-1.5 lg:order-3">
          <.theme_switch id="theme-toggle" />
          <CoreComponents.button
            id="nav-toggle"
            type="button"
            variant="ghost"
            shape="square"
            class="lg:hidden"
            phx-click={@toggle_menu}
            aria-controls="nav-menu"
            aria-expanded="false"
            aria-label="Toggle navigation menu"
          >
            <CoreComponents.icon name="hero-bars-3" class="size-5" />
          </CoreComponents.button>
        </div>
      </div>

      <ul
        id="nav-menu"
        class="hidden flex-col gap-1 pb-3 lg:order-2 lg:flex lg:flex-1 lg:flex-row lg:items-center lg:gap-1 lg:pb-0"
      >
        <li :for={link <- @links}>
          <.link
            navigate={link.href}
            aria-current={@active == link.key && "page"}
            class={[
              "block rounded-field px-3 py-2 text-sm font-medium transition-colors lg:inline-block",
              @active == link.key &&
                "bg-base-200 text-base-content shadow-inner lg:border-b-2 lg:border-primary",
              @active != link.key && "text-base-content/65 hover:bg-base-200/70 hover:text-base-content"
            ]}
          >
            {link.label}
          </.link>
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  One-button light/dark switch.

  The three-way segmented control the kit ships is the right control for a
  design page; in a product nav a single toggle that reads as the current
  mode is faster to hit. The root carries `phx-hook="ThemeSwitch"` (see
  `assets/js/app.js`) and the `id` callers address — `#theme-toggle` — while
  the control inside stays the kit's `<.button>`.

  The hook does not own the preference: it marks the root with the theme it
  is switching *to* and replays the `phx:set-theme` event that the theme
  script in `root.html.heex` already listens for, so storage and
  `data-theme-source` keep a single writer.
  """
  attr :id, :string, default: "theme-toggle"
  attr :class, :any, default: nil
  attr :rest, :global

  def theme_switch(assigns) do
    ~H"""
    <span
      id={@id}
      data-component="BenchappWeb.ChromeComponents.theme_switch"
      phx-hook="ThemeSwitch"
      class={["inline-flex", @class]}
      {@rest}
    >
      <CoreComponents.button
        type="button"
        variant="ghost"
        shape="square"
        aria-label="Switch between light and dark theme"
        title="Switch theme"
      >
        <CoreComponents.icon name="hero-sun" class="size-4 dark:hidden" />
        <CoreComponents.icon name="hero-moon" class="hidden size-4 dark:block" />
      </CoreComponents.button>
    </span>
    """
  end

  @doc """
  Page footer: product line on the left, the three component surfaces on
  the right, so the design inventory stays reachable from every page.
  """
  attr :class, :any, default: nil
  attr :rest, :global

  def site_footer(assigns) do
    ~H"""
    <footer
      data-component="BenchappWeb.ChromeComponents.site_footer"
      class={["border-t border-base-300 bg-base-200/40", @class]}
      {@rest}
    >
      <div class="mx-auto flex w-full max-w-6xl flex-col gap-4 px-4 py-8 sm:flex-row sm:items-center sm:justify-between sm:px-6">
        <div class="space-y-1">
          <p class="font-mono text-xs uppercase tracking-[0.22em] text-base-content/70">
            Lodestar · Flight Systems
          </p>
          <p class="text-xs text-base-content/50">
            Demonstration product. Crew manifest and telemetry are held in process memory only.
          </p>
        </div>
        <nav class="flex flex-wrap items-center gap-x-4 gap-y-1 font-mono text-xs">
          <.link navigate={~p"/about"} class="link link-hover">/about</.link>
          <.link navigate={~p"/design"} class="link link-hover">/design</.link>
          <span aria-hidden="true" class="opacity-30">·</span>
          <.link navigate={~p"/custom-designs"} class="link link-hover">/custom-designs</.link>
          <span aria-hidden="true" class="opacity-30">·</span>
          <.link href={~p"/design.json"} class="link link-hover">/design.json</.link>
        </nav>
      </div>
    </footer>
    """
  end
end

defmodule BenchappWeb.CompositeComponents do
  @moduledoc """
  Generic, multi-primitive composites for this app.

  Composites live one layer above core wrappers: they bundle a small set
  of `JobyKit.CoreComponents` primitives into a higher-level pattern that
  appears more than once across the app. Examples: empty states, page
  headers with breadcrumbs, callouts, hero blocks.

  Every composite follows the JobyKit wrapper contract:

    1. Declare every prop with `attr` (use `values:` for variant enums).
    2. Carry `data-component="BenchappWeb.CompositeComponents.<name>"`
       on the root element.
    3. Accept `attr :rest, :global` for id/class/aria-*/phx-* pass-through.
    4. Internals compose `JobyKit.CoreComponents` (or other registered
       wrappers) — never raw `<button>`/`<input>`/`<textarea>`.
    5. Register the composite in `BenchappWeb.DesignManifest`
       (`category: :composite`) so it surfaces on `/custom-designs` and
       in `/design.json`.

  The `empty_state/1` below ships pre-registered as a worked example.
  Use it as a template when you add your own composites: copy the
  attribute / slot / `data-component` shape, then register the new entry
  in the manifest.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @doc """
  The app's top navigation bar. Renders the brand, a set of page links,
  a trailing theme control, and a phone-width menu behind a toggle.

  Contract notes:

    * The `<nav>` root carries `id="main-nav"` so callers and tests can
      target it.
    * The link matching `active` is marked `aria-current="page"` (on the
      desktop menu, which is always present in the DOM).
    * `id="nav-toggle"` is the button that reveals the phone menu; it is
      `md:hidden` so it only appears below the desktop breakpoint.
    * `id="theme-toggle"` is the segmented theme control, shown at every
      width.
  """
  attr :active, :string, default: nil, doc: "The `:key` of the current page's link."
  attr :brand, :string, default: "Lumen"
  attr :rest, :global

  def main_nav(assigns) do
    links = [
      %{key: "home", label: "Home", href: ~p"/"},
      %{key: "about", label: "About", href: ~p"/about"},
      %{key: "design", label: "Design", href: ~p"/design"},
      %{key: "custom-designs", label: "Custom Designs", href: ~p"/custom-designs"}
    ]

    assigns = assign(assigns, :links, links)

    ~H"""
    <nav
      id="main-nav"
      data-component="BenchappWeb.CompositeComponents.main_nav"
      class="w-full"
      {@rest}
    >
      <div class="mx-auto flex w-full max-w-6xl items-center gap-2 px-4 sm:px-6">
        <.link
          navigate={~p"/"}
          class="btn btn-ghost -ml-2 px-2 text-lg font-semibold normal-case tracking-tight"
        >
          {@brand}
        </.link>

        <ul class="menu menu-horizontal ml-2 hidden gap-1 px-1 md:flex">
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

        <div class="flex-1" />

        <JobyKit.CoreComponents.theme_toggle id="theme-toggle" />

        <CoreComponents.button
          id="nav-toggle"
          type="button"
          variant="ghost"
          size="sm"
          shape="square"
          class="md:hidden"
          aria-label="Toggle navigation menu"
          aria-controls="nav-menu"
          phx-click={JS.toggle_class("hidden", to: "#nav-menu")}
        >
          <CoreComponents.icon name="hero-bars-3" class="size-5" />
        </CoreComponents.button>
      </div>

      <div id="nav-menu" class="mx-auto hidden w-full max-w-6xl px-4 sm:px-6 md:hidden">
        <ul class="menu gap-1 pb-3">
          <li :for={link <- @links}>
            <.link navigate={link.href} class="rounded-field">
              {link.label}
            </.link>
          </li>
        </ul>
      </div>
    </nav>
    """
  end

  @doc """
  A responsive feature grid: renders a list of feature tiles as a
  `<.card>` per feature, laid out in a responsive grid.

      <.feature_grid features={[
        %{icon: "hero-bolt", title: "Instant", body: "..."},
        ...
      ]} />

  Each feature map supports `:icon`, `:title`, `:body`, and an optional
  `:tag` (rendered as the card eyebrow).
  """
  attr :features, :list, required: true, doc: "List of `%{icon:, title:, body:, tag:}` maps."
  attr :rest, :global

  def feature_grid(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_grid"
      class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3"
      {@rest}
    >
      <CoreComponents.card :for={feature <- @features} variant="elevated" class="h-full">
        <:eyebrow :if={Map.has_key?(feature, :tag)}>{feature.tag}</:eyebrow>
        <:title>
          <span class="flex items-center gap-2">
            <CoreComponents.icon name={feature.icon} class="size-5 text-primary" />
            {feature.title}
          </span>
        </:title>
        <span class="text-sm leading-relaxed text-base-content/70">{feature.body}</span>
      </CoreComponents.card>
    </div>
    """
  end

  @doc """
  An empty-state callout: centered icon, title, supporting text, and an
  optional action slot. Use to fill an otherwise-empty container — an
  unfilled list, a search with no results, a fresh dashboard.

      <.empty_state icon="hero-inbox" title="No messages yet">
        Start a conversation with a teammate to see it here.
        <:action>
          <CoreComponents.button variant="primary">New message</CoreComponents.button>
        </:action>
      </.empty_state>
  """
  attr :icon, :string,
    default: "hero-sparkles",
    doc: "Heroicon name to display above the title."

  attr :title, :string, required: true
  attr :tone, :string, values: ~w(neutral primary), default: "neutral"
  attr :rest, :global

  slot :inner_block, doc: "Supporting copy beneath the title."
  slot :action, doc: "Optional call-to-action (typically a `<.button>`)."

  def empty_state(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.empty_state"
      class={[
        "flex flex-col items-center justify-center gap-3 rounded-2xl border border-dashed px-6 py-10 text-center",
        @tone == "neutral" && "border-base-300 bg-base-100/40 text-base-content/70",
        @tone == "primary" && "border-primary/30 bg-primary/5 text-base-content"
      ]}
      {@rest}
    >
      <span class={[
        "flex size-12 items-center justify-center rounded-full",
        @tone == "neutral" && "bg-base-200 text-base-content/60",
        @tone == "primary" && "bg-primary/10 text-primary"
      ]}>
        <CoreComponents.icon name={@icon} class="size-6" />
      </span>
      <h3 class="text-base font-semibold text-base-content">{@title}</h3>
      <div :if={@inner_block != []} class="max-w-sm text-sm text-base-content/65">
        {render_slot(@inner_block)}
      </div>
      <div :if={@action != []} class="pt-1">
        {render_slot(@action)}
      </div>
    </div>
    """
  end
end

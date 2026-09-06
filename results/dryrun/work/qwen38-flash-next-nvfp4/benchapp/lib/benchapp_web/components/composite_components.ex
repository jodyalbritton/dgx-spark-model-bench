defmodule BenchappWeb.CompositeComponents do
  @moduledoc """
  Generic, multi-primitive composites for this app.

  Composites live one layer above core wrappers: they bundle a small set
  of `JobyKit.CoreComponents` primitives into a higher-level pattern that
  appears more than once across the app.

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
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @nav_links [
    %{key: "home", label: "Launch", href: ~p"/"},
    %{key: "about", label: "About", href: ~p"/about"}
  ]

  @doc """
    The site's primary navigation bar: brand, desktop links with
    `aria-current="page"` on the active route, a theme toggle, and a
    phone-width menu toggle that opens the `#mobile-nav` panel rendered
    by the app layout.

        <.main_nav active="home" />
    """
  attr :active, :string, default: nil, doc: "The `:key` of the link to mark current."
  attr :brand, :string, default: "Lumen"
  attr :brand_href, :string, default: ~p"/"
  attr :links, :list, default: @nav_links, doc: "Links with `key`, `label`, `href`."
  attr :class, :any, default: nil
  attr :rest, :global

  def main_nav(assigns) do
    ~H"""
    <nav
      id="main-nav"
      data-component="BenchappWeb.CompositeComponents.main_nav"
      class={["flex items-center gap-2 py-2.5", @class]}
      {@rest}
    >
      <.link
        navigate={@brand_href}
        class="flex items-center gap-2 text-lg font-semibold tracking-tight"
        aria-label={"#{@brand} home"}
      >
        <span class="flex size-8 items-center justify-center rounded-xl bg-primary/15 text-primary">
          <CoreComponents.icon name="hero-sun" class="size-5" />
        </span>
        <span>{@brand}</span>
      </.link>

      <ul class="menu menu-horizontal ml-4 hidden gap-1 px-0 md:menu">
        <li :for={link <- @links}>
          <.link
            navigate={link.href}
            aria-current={link.key == @active && "page"}
            class={[
              "rounded-field font-medium text-base-content/70",
              link.key == @active && "menu-active text-base-content"
            ]}
          >
            {link.label}
          </.link>
        </li>
      </ul>

      <div class="flex flex-1 items-center justify-end gap-2 pl-1">
        <CoreComponents.button
          navigate={~p"/"}
          variant="primary"
          size="sm"
          class="hidden md:inline-flex"
        >
          Join the launch list
        </CoreComponents.button>
        <CoreComponents.theme_toggle id="theme-toggle" />
        <.nav_toggle id="nav-toggle" target="mobile-nav" class="md:hidden" />
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".NavToggle">
        export default {
          mounted() {
            this.el.addEventListener("click", () => {
              const panel = document.getElementById(this.el.dataset.navTarget);
              if (!panel) return;
              panel.toggleAttribute("hidden");
              this.el.setAttribute("aria-expanded", String(!panel.hasAttribute("hidden")));
            });
          }
        };
      </script>
    </nav>
    """
  end

  @doc """
    Phone-width hamburger button that toggles a menu panel by id.
    Carries `aria-expanded` / `aria-controls`, and drives the panel via
    the colocated `.NavToggle` hook so it works without a server round-trip.

        <.nav_toggle id="nav-toggle" target="mobile-nav" />
    """
  attr :id, :string, required: true
  attr :target, :string, required: true, doc: "DOM id of the panel to open/close."
  attr :label, :string, default: "Open menu"
  attr :class, :any, default: nil
  attr :rest, :global

  def nav_toggle(assigns) do
    ~H"""
    <CoreComponents.button
      id={@id}
      type="button"
      variant="ghost"
      shape="square"
      aria-label={@label}
      aria-expanded="false"
      aria-controls={@target}
      data-nav-target={@target}
      phx-hook=".NavToggle"
      class={@class}
      {@rest}
    >
      <CoreComponents.icon name="hero-bars-3" class="size-5" />
    </CoreComponents.button>
    """
  end

  @doc """
    A feature card for the landing-page grid: icon tile, title, body,
    and a tone-driven accent.

        <.feature_card
          icon="hero-bolt"
          title="Ambient sync"
          tone="primary"
        >
          Copy that follows you between surfaces.
        </.feature_card>
    """
  attr :icon, :string, required: true, doc: "Heroicon name for the tile."
  attr :title, :string, required: true
  attr :tone, :string, values: ~w(primary accent secondary), default: "primary"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block, required: true, doc: "Supporting copy beneath the title."

  def feature_card(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.feature_card"
      class={[
        "group relative flex flex-col gap-3 overflow-hidden rounded-2xl border border-base-300 bg-base-100 p-6 transition-all duration-300 hover:-translate-y-1 hover:border-primary/40 hover:shadow-xl hover:shadow-primary/5",
        @class
      ]}
      {@rest}
    >
      <span
        class={[
          "pointer-events-none absolute -right-10 -top-10 size-28 rounded-full opacity-0 blur-2xl transition-opacity duration-300 group-hover:opacity-40",
          @tone == "primary" && "bg-primary",
          @tone == "accent" && "bg-accent",
          @tone == "secondary" && "bg-secondary"
        ]}
        aria-hidden="true"
      />
      <span
        class={[
          "flex size-11 items-center justify-center rounded-xl",
          @tone == "primary" && "bg-primary/10 text-primary",
          @tone == "accent" && "bg-accent/10 text-accent",
          @tone == "secondary" && "bg-secondary/10 text-secondary"
        ]}
      >
        <CoreComponents.icon name={@icon} class="size-5" />
      </span>
      <h3 class="text-base font-semibold text-base-content">{@title}</h3>
      <p class="text-sm leading-6 text-base-content/65">{render_slot(@inner_block)}</p>
    </div>
    """
  end

  @doc """
    A countdown readout: the remaining number plus a label, styled for
    the landing-page hero and stats contexts.

        <.countdown_display id="countdown" value={@countdown} label="days of early access" />
    """
  attr :id, :string, default: nil
  attr :value, :integer, required: true
  attr :label, :string, default: "left in the launch window"
  attr :size, :string, values: ~w(lg sm), default: "lg"
  attr :class, :any, default: nil
  attr :rest, :global

  def countdown_display(assigns) do
    ~H"""
    <div
      data-component="BenchappWeb.CompositeComponents.countdown_display"
      class={["flex items-baseline gap-2", @class]}
      {@rest}
    >
      <span
        id={@id}
        class={[
          "font-mono font-bold tabular-nums text-transparent bg-clip-text bg-gradient-to-br from-primary to-accent",
          @size == "lg" && "text-5xl sm:text-6xl",
          @size == "sm" && "text-2xl"
        ]}
      >
        {@value}
      </span>
      <span class="max-w-[8rem] text-xs font-medium uppercase tracking-widest text-base-content/50">
        {@label}
      </span>
    </div>
    """
  end

  @doc """
    One row in the launch activity feed: kind badge, copy, and relative
    time. Newest first — the caller owns ordering and trimming.

        <.activity_entry kind="signup" text="new signup: dana@example.com" time="just now" />
    """
  attr :kind, :string, values: ~w(signup tick), required: true
  attr :text, :string, required: true
  attr :time, :string, default: "just now"
  attr :class, :any, default: nil
  attr :rest, :global

  def activity_entry(assigns) do
    ~H"""
    <li
      data-component="BenchappWeb.CompositeComponents.activity_entry"
      class={["flex items-center gap-3 px-4 py-3", @class]}
      {@rest}
    >
      <CoreComponents.badge
        tone={@kind == "signup" && "ok" || "warn"}
        size="xs"
        class="shrink-0 uppercase"
      >
        {@kind}
      </CoreComponents.badge>
      <span class="min-w-0 flex-1 truncate text-sm text-base-content/80">{@text}</span>
      <span class="shrink-0 font-mono text-xs text-base-content/40">{@time}</span>
    </li>
    """
  end

  @doc """
    A centered empty-state callout: icon, title, supporting text, and an
    optional action slot.

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

  @doc "The nav link table shared by the nav composite and the layout's mobile panel."
  def nav_links, do: @nav_links
end

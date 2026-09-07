defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb — JobyCorp's page chrome.

  Pages compose `<Layouts.app flash={@flash} active_nav="home">...` from
  inside their LiveView render and supply only their content. The
  navigation bar, the theme control, and the footer are wired in here so
  every page gets them for free, and every page says which one it is with
  `active_nav`.

  The header is one row on a hairline: the mark and wordmark, the three
  page links, the theme control. Below `md` the page links fold behind the
  nav toggle; the theme control stays in the row, because a visitor on a
  phone is allowed to change the light too.
  """
  use BenchappWeb, :html

  embed_templates "layouts/*"

  # The three pages of the site, in nav order. Built in a function because
  # verified routes only expand inside one.
  defp nav_links do
    [
      %{key: "home", label: "Home", href: ~p"/"},
      %{key: "research", label: "Research", href: ~p"/research"},
      %{key: "about", label: "About", href: ~p"/about"}
    ]
  end

  @doc """
  The JobyCorp wordmark: a 10 px square outlined in the trace colour, then
  the name, linking home.
  """
  attr :class, :any, default: nil

  def wordmark(assigns) do
    ~H"""
    <.link
      navigate={~p"/"}
      class={[
        "flex items-center gap-2.5 font-semibold tracking-tight text-base-content",
        @class
      ]}
    >
      <span class="inline-block size-2.5 shrink-0 border-2 border-secondary" aria-hidden="true"></span>
      <span>JobyCorp</span>
    </.link>
    """
  end

  @doc """
  A page link in the chrome. `variant="nav"` is the bar's control — a
  padded target that turns to the accent on the current page;
  `variant="inline"` is a text link for the footer.
  """
  attr :href, :string, required: true
  attr :label, :string, required: true
  attr :current, :boolean, default: false
  attr :variant, :string, values: ~w(nav inline), default: "nav"

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      aria-current={@current && "page"}
      class={[
        "transition-colors duration-150 hover:text-primary",
        @variant == "nav" &&
          "block rounded-field px-3 py-2 text-sm text-base-content",
        @variant == "inline" && "text-sm text-base-content",
        @current && "font-medium text-primary"
      ]}
    >
      {@label}
    </.link>
    """
  end

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :nav_links, nav_links())

    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100">
        <div class="mx-auto w-full max-w-6xl px-6 md:px-8">
          <nav id="main-nav" aria-label="Pages">
            <div class="flex items-center gap-4 py-3.5">
              <.wordmark />

              <ul id="nav-links" class="ml-auto hidden items-center gap-1 md:flex">
                <li :for={link <- @nav_links}>
                  <.nav_link
                    href={link.href}
                    label={link.label}
                    current={@active_nav == link.key}
                  />
                </li>
              </ul>

              <div class="ml-auto flex items-center gap-2 md:ml-2">
                <.theme_toggle id="theme-toggle" class="shrink-0" />
                <.button
                  id="nav-toggle"
                  type="button"
                  variant="ghost"
                  size="sm"
                  shape="square"
                  class="md:hidden"
                  aria-label="Pages"
                  aria-controls="nav-links-phone"
                  aria-expanded="false"
                  phx-click={
                    JS.toggle_class("hidden", to: "#nav-links-phone")
                    |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: "#nav-toggle")
                  }
                >
                  <.icon name="hero-bars-3" class="size-5" />
                </.button>
              </div>
            </div>

            <div class="md:hidden">
              <ul
                id="nav-links-phone"
                class="hidden flex-col gap-1 border-t border-base-300 py-2"
              >
                <li :for={link <- @nav_links}>
                  <.nav_link
                    href={link.href}
                    label={link.label}
                    current={@active_nav == link.key}
                  />
                </li>
              </ul>
            </div>
          </nav>
        </div>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <footer class="border-t border-base-300">
        <div class="mx-auto flex w-full max-w-6xl flex-col gap-5 px-6 py-10 md:flex-row md:items-center md:gap-8 md:px-8">
          <.wordmark />

          <ul class="flex flex-wrap items-center gap-x-5 gap-y-2" aria-label="Pages">
            <li :for={link <- @nav_links}>
              <.nav_link href={link.href} label={link.label} variant="inline" />
            </li>
          </ul>

          <p class="text-sm text-base-content/70 md:ml-auto md:text-right">
            JobyCorp runs local language models on its own hardware and publishes the
            results in full.
          </p>
        </div>
      </footer>

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

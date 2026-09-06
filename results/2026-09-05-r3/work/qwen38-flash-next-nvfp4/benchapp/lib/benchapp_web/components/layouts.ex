defmodule BenchappWeb.Layouts do
  @moduledoc """
  Layouts for BenchappWeb.

  Pages compose `<Layouts.app flash={@flash}>...` from inside their
  LiveView render and supply only their content — the nav, the theme
  control, the footer, and the flash container are wired in here so every
  page gets them for free.

  The chrome owns its own surface: the sticky `header` draws the
  background and border edge-to-edge, and `site_nav/1` inside it draws
  neither. Splitting that between the two is what produces a seam where
  the nav's max-width ends.

  The nav, theme switch, and footer are registered composites in
  `BenchappWeb.ChromeComponents` rather than markup pasted in here,
  because all four pages share them and the accessibility contract
  (`aria-current`, `aria-controls`, `aria-expanded`) is easier to keep
  honest in one place. Pass `active_nav:` from each page to mark the
  current link.
  """
  use BenchappWeb, :html

  alias BenchappWeb.ChromeComponents

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :active_nav, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-dvh flex-col bg-base-100">
      <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100/90 backdrop-blur">
        <ChromeComponents.site_nav active={@active_nav} brand="Lodestar" />
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <ChromeComponents.site_footer />

      <JobyKit.CoreComponents.flash_group flash={@flash} />
    </div>
    """
  end
end

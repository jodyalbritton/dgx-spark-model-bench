defmodule BenchappWeb.Chrome do
  @moduledoc """
  Shared state for the page chrome that `BenchappWeb.Layouts.app/1` draws —
  currently the phone-width navigation menu.

  The menu is server-rendered rather than toggled by a script: the links
  stay in the document at every width, and `#nav-toggle` behaves like any
  other LiveView control, so it is drivable from `Phoenix.LiveViewTest`.

  Every LiveView that renders `<Layouts.app>` calls `assign_chrome/1` in
  `mount/3` and delegates `"toggle_nav"` to `toggle_nav/1`.
  """

  @doc "Assigns the chrome state a page needs before it renders the layout."
  def assign_chrome(socket) do
    Phoenix.Component.assign(socket, :nav_open, false)
  end

  @doc "Opens the collapsed phone menu, or collapses it if it is open."
  def toggle_nav(socket) do
    Phoenix.Component.assign(socket, :nav_open, not nav_open?(socket))
  end

  @doc "Whether the phone menu is currently expanded."
  def nav_open?(socket) do
    Map.get(socket.assigns, :nav_open, false)
  end
end

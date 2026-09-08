defmodule BenchappWeb.NavigationTest do
  @moduledoc """
  The `#main-nav` chrome: current-page marking, the phone menu behind
  `#nav-toggle`, the `#theme-toggle` target, and the composite the design
  page advertises.
  """
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.LiveTestHelpers
  import Phoenix.LiveViewTest

  test "exactly one link is current, per page", %{conn: conn} do
    for {path, href} <- [
          {~p"/", "/"},
          {~p"/about", "/about"},
          {~p"/design", "/design"},
          {~p"/custom-designs", "/custom-designs"}
        ] do
      {:ok, view, _html} = live(conn, path)

      html = render(view) |> IO.iodata_to_binary()
      assert html =~ ~s|aria-current="page"|
      assert html =~ ~s|href="#{href}"|
      assert current_marks(view) == 1
    end
  end

  test "the menu is in the document and collapsed behind #nav-toggle at rest", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert has_element?(view, ~S|#nav-toggle[aria-controls="nav-menu"]|)
    assert html =~ ~s|aria-expanded="false"|
    assert length(texts(view, "#nav-menu a")) == 4

    # Collapsed only below `md`, and still present in the document.
    assert html =~ "max-md:hidden"
    assert html =~ "md:hidden"
  end

  test "#nav-toggle expands the menu, and collapses it again", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    html = render_click(view, "toggle_nav")
    assert html =~ ~s|aria-expanded="true"|
    refute html =~ "max-md:hidden"

    html = render_click(view, "toggle_nav")
    assert html =~ ~s|aria-expanded="false"|
    assert html =~ "max-md:hidden"
  end

  test "#theme-toggle answers a click on every page", %{conn: conn} do
    for path <- [~p"/", ~p"/about", ~p"/design", ~p"/custom-designs"] do
      {:ok, view, _html} = live(conn, path)

      assert has_element?(view, "#theme-toggle")
      assert has_element?(view, ~S|#theme-toggle[aria-label="Switch colour theme"]|)
      assert render_click(view, "toggle_theme") =~ "Tidepool"
    end
  end

  test "the feature grid is registered with a preview and shows on /custom-designs", %{conn: conn} do
    data_component = "BenchappWeb.CompositeComponents.feature_grid"
    entry = BenchappWeb.DesignManifest.fetch(BenchappWeb.CompositeComponents, :feature_grid)

    assert %{} = entry
    assert entry.data_component == data_component
    assert is_function(entry.preview, 1)

    {:ok, _view, html} = live(conn, ~p"/custom-designs")

    assert html =~ data_component
    assert html =~ "feature_grid"
  end
end

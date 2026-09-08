defmodule BenchappWeb.AboutLiveTest do
  @moduledoc """
  `/about`: the shared layout, marked current in the nav, built from the same
  registered composites.
  """
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.LiveTestHelpers
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/about")
    {:ok, view: view, html: html}
  end

  test "renders on the shared layout", %{view: view, html: html} do
    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "h1")
    assert html =~ "re-derive"
    assert html =~ "Tidepool"
  end

  test "marks the About link as the current page", %{view: view} do
    assert render(view) |> IO.iodata_to_binary() =~ ~s|aria-current="page"|
    assert current_marks(view) == 1
  end

  test "reuses the registered feature grid composite", %{view: view} do
    assert has_element?(view, "#principle-grid")
    assert has_element?(view, ~S|[data-component="BenchappWeb.CompositeComponents.feature_grid"]|)
  end

  test "the nav offers a live link back to the landing page", %{view: view} do
    assert has_element?(view, ~S|#nav-menu a[href="/"]|)
    assert render(view) |> IO.iodata_to_binary() =~ ~s|data-phx-link="redirect"|
  end
end

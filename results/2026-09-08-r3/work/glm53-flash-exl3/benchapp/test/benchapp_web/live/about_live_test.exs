defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page within the shared layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "nav a[aria-current=page]", "About")
    assert has_element?(view, "h1", "About Nimbus")
  end

  test "is linked from the navigation on the home page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#nav-menu a[href='/about']", "About")

    {:ok, about_view, _html} = live(conn, ~p"/about")
    assert has_element?(about_view, "h1", "About Nimbus")
  end
end

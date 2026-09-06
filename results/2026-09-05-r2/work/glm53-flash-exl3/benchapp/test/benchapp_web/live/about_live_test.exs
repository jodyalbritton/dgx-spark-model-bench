defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page on the shared layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "h1", "Why we built Solstice")
    assert has_element?(view, "#main-nav a[aria-current='page']", "About")
  end

  test "nav is present with theme and mobile toggles", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "#main-nav a[href='/']", "Home")
  end
end

defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page on the shared layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "h1", "Obsessed with better evenings")
  end

  test "marks the about nav link as current", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/about")

    assert has_element?(view, ~s|#main-nav a[aria-current="page"]|, "About")
  end

  test "about is linked from the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#main-nav a[href='/about']", "About")
  end
end

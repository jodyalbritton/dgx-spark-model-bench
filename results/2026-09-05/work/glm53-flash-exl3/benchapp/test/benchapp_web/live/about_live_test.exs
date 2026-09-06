defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page with nav highlighting", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "h1", "About Zephyr")
    assert has_element?(view, ~s|#main-nav a[aria-current="page"]|, "About")
  end

  test "is linked from the home nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ~s|#main-nav a[href="/about"]|)
  end
end

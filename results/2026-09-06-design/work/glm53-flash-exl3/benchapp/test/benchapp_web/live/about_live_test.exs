defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/about")

    assert has_element?(view, "h1", "A local AI research company")
    assert has_element?(view, "#in-full")
    assert html =~ "Why the work is shared"
    assert has_element?(view, "a[href='/research']", "Read the research")
  end

  test "marks the current page in the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "#main-nav a[aria-current='page']", "About")
  end
end

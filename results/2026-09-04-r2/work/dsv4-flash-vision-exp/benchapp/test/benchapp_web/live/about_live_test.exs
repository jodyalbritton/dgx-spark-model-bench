defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/about")

    assert html =~ "About Lumen"
    assert html =~ "design system"
  end

  test "about page is linked from the nav", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert html =~ "/about"
    assert has_element?(view, "#main-nav")
  end

  test "about page marks its own nav link as current", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/about")

    assert html =~ "aria-current=\"page\""
  end
end

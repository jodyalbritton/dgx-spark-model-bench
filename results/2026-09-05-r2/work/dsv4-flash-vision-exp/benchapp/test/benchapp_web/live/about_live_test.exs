defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page on the app layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#main-nav a[aria-current='page']", "About")
    assert has_element?(view, "#theme-toggle")
  end

  test "about page is linked from the home navigation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view
           |> element("#main-nav a[href='/about']")
           |> render() =~ "About"
  end
end

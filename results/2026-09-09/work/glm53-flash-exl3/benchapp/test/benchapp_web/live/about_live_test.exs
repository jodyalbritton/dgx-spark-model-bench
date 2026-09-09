defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page on the shared layout", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/about")

    assert view |> element("h1") |> render() =~ "About Vela"
    assert has_element?(view, "#main-nav")
    assert html =~ ~s(aria-current="page")
  end

  test "nav marks about as current and home links back", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/about")

    # The about link carries aria-current on the about page, the home link doesn't.
    assert html =~ ~r/href="\/about"(?=[^>]*aria-current="page")/
    refute html =~ ~r/href="\/"(?=[^>]*aria-current="page")/

    {:ok, _home_view, home_html} = live(conn, ~p"/")

    assert home_html =~ ~r/href="\/"(?=[^>]*aria-current="page")/
    refute home_html =~ ~r/href="\/about"(?=[^>]*aria-current="page")/
  end
end

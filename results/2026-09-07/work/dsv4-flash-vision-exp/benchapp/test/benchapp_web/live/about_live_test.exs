defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders the about page on the shared layout", %{conn: conn} do
    {:ok, view, html} = live(conn, "/about")
    assert html =~ "About Aster"
    assert view |> element("h1") |> render() =~ "calm home"
    assert view |> has_element?("#main-nav")
  end

  test "marks the About link as current", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/about")
    assert html =~ ~s(aria-current="page")
  end
end

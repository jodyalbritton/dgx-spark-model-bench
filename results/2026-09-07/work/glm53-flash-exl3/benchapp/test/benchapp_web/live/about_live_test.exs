defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/about")

    assert html =~ "A houseplant company that keeps its data at home."
    assert has_element?(view, "#main-nav")
  end

  test "marks the about nav link as current page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert render(view) =~ ~s(aria-current="page")
  end

  test "is linked from the home page nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view |> element("#main-nav") |> render() =~ ~p"/about"
  end
end

defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "h1", "About Lumen")
  end

  test "is linked from the main nav", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ ~p"/about"
  end

  test "nav marks the current page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert view
           |> element(~s{#main-nav a[aria-current='page']})
           |> render()
           |> String.contains?("About")
  end
end

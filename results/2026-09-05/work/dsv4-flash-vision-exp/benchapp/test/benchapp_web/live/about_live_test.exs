defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page with story and values", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/about")

    assert html =~ "Weather that knows your street"
    assert html =~ "What we believe"
    assert html =~ "Precision"
    assert html =~ "Trust"
  end

  test "marks the about link current in the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, ~s(nav#main-nav a[href="/about"][aria-current="page"]))
    refute has_element?(view, ~s(nav#main-nav a[href="/"][aria-current="page"]))
  end

  test "has a link back to the landing page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/about")

    assert html =~ "Back to the landing page"
  end
end

defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  test "renders the About page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "h1", "We believe dashboards")
    assert render(view) =~ "Our principles"
  end

  test "shares the main layout chrome", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/about")

    assert html =~ "LumenLab"
    assert html =~ "main-nav"
    assert html =~ ~s(aria-current="page")
  end

  test "is linked from the nav", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ ~s(href="/about")
  end
end

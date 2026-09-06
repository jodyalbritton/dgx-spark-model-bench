defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page on the shared layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "#nav-toggle")

    # The About link is marked current on this page.
    assert has_element?(view, "#main-nav a[aria-current=page]")
    assert element(view, ~s{#main-nav a[aria-current=page]}) |> render() =~ "About"

    assert view |> render() =~ "We started with a kitchen table"
    assert view |> render() =~ "Our story"
    assert view |> render() =~ "What we believe"
  end

  test "is reachable from the landing page nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#main-nav")
    assert element(view, "#main-nav a", "About") |> render() =~ "About"
  end

  test "mobile menu opens and closes behind the nav toggle", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/about")

    refute has_element?(view, "#mobile-nav")

    view |> element("#nav-toggle") |> render_click()
    assert has_element?(view, "#mobile-nav")

    view |> element("#nav-toggle") |> render_click()
    refute has_element?(view, "#mobile-nav")
  end
end

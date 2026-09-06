defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.ViewHTML

  test "renders the about page on the shared layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "main")
    assert text(render(view), "h1") =~ "About Lumen"
  end

  test "nav links to /about and marks it current", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")
    html = render(view)

    assert has_element?(view, ~S|#main-nav a[href="/about"]|)
    assert has_element?(view, ~S|#main-nav a[aria-current="page"][href="/about"]|)
    assert count(html, "#main-nav a[aria-current='page']") == 1
  end

  test "the about link is not marked current on the home page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    html = render(view)

    assert has_element?(view, ~S|#main-nav a[aria-current="page"][href="/"]|)
    refute present?(html, ~S|#main-nav a[href="/about"][aria-current="page"]|)
  end

  test "the nav offers a working home link (live navigation)", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert {:error, {:live_redirect, %{to: "/"}}} =
             view |> element(~S|#main-nav ul.menu-horizontal a[href="/"]|) |> render_click()
  end
end

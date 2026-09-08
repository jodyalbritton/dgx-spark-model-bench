defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page on the shared layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "main h1", "Release notes that write themselves")
    assert has_element?(view, "main h2", "What happens to a release")
  end

  test "the nav marks /about as the current page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, ~S|#main-nav a[href="/about"][aria-current="page"]|)
    refute has_element?(view, ~S|#main-nav a[href="/"][aria-current="page"]|)
  end

  test "the nav marks / as current on the landing page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ~S|#main-nav a[href="/"][aria-current="page"]|)
    refute has_element?(view, ~S|#main-nav a[href="/about"][aria-current="page"]|)
  end

  test "navigates to the about page from the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element(~S|#main-nav a[href="/about"]|)
    |> render_click()

    assert_redirect(view, ~p"/about")
  end
end

defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "about page renders on the shared layout", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "h1", "Named for the rose that points home")
    assert view |> has_element?("#main-nav a[href='/about']")
  end

  test "the nav marks About as the current page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    current =
      view
      |> element("#main-nav")
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(~s(a[aria-current="page"]))
      |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))

    assert Enum.uniq(current) == ["About"]
  end

  test "the nav links home, design, and custom designs alongside about", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")

    for href <- ["/", "/design", "/custom-designs"] do
      assert view |> has_element?(~s(#main-nav a[href='#{href}']))
    end

    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "#nav-toggle")
  end
end

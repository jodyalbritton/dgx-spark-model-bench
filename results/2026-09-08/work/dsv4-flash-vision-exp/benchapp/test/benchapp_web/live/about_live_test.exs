defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  test "renders the about page on the app layout", %{conn: conn} do
    {:ok, view, html} = live(conn, "/about")

    assert html =~ ~s(id="main-nav")
    assert html =~ "About Fathom"
    assert has_element?(view, "#main-nav")
  end

  test "marks the about nav link with aria-current when on the about page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/about")

    about_link =
      LazyHTML.from_fragment(html) |> LazyHTML.query(~s|nav#main-nav a[aria-current="page"]|)

    assert Enum.count(about_link) == 1
    assert Enum.map(about_link, &LazyHTML.text/1) |> List.first() =~ "About"
  end

  test "the home nav link is marked on the home page instead", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    current =
      LazyHTML.from_fragment(html) |> LazyHTML.query(~s|nav#main-nav a[aria-current="page"]|)

    assert Enum.count(current) == 1
    assert Enum.map(current, &LazyHTML.text/1) |> List.first() =~ "Home"
  end

  test "links to the about page from the home page nav", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    nav_html =
      html
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("#main-nav")
      |> Enum.map(&LazyHTML.text/1)
      |> List.first()

    assert nav_html =~ "About"
  end
end

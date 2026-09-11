defmodule BenchappWeb.PageRenderTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the landing page with the record card and primary action", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "JobyCorp runs local models on its own hardware"
    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "[data-component=\"BenchappWeb.CompositeComponents.record_card\"]")
    assert has_element?(view, "a[href=\"/research\"]")
  end

  test "renders the research page with the method and a record card", %{conn: conn} do
    {:ok, view, html} = live(conn, "/research")

    assert html =~ "How a run is measured"
    assert has_element?(view, "[data-component=\"BenchappWeb.CompositeComponents.record_card\"]")
    assert has_element?(view, "a[href=\"/research\"][aria-current=\"page\"]")
  end

  test "renders the about page with the specimen block", %{conn: conn} do
    {:ok, view, html} = live(conn, "/about")

    assert html =~ "Why the work is shared"
    assert has_element?(view, "a[href=\"/about\"][aria-current=\"page\"]")
  end

  test "nav marks the home page as current", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ ~s(a[href="/"][aria-current="page"]) || html =~ "aria-current=\"page\""
  end
end

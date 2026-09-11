defmodule BenchappWeb.PageTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the landing page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, "[data-component='BenchappWeb.CompositeComponents.record_card']")
    assert has_element?(view, "a[href='/'][aria-current='page']")
    assert has_element?(view, "footer")
  end

  test "renders the research page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/research")

    assert has_element?(view, "a[href='/research'][aria-current='page']")
    assert has_element?(view, "[data-component='BenchappWeb.CompositeComponents.record_card']")
    assert has_element?(view, "#main-nav a[href='/']")
  end

  test "renders the about page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/about")

    assert has_element?(view, "a[href='/about'][aria-current='page']")
    assert has_element?(view, "#main-nav a[href='/research']")
  end
end

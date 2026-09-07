defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the landing page", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "h1", "Local LLMs, measured on our own hardware.")

    assert has_element?(
             view,
             "[data-component='BenchappWeb.CompositeComponents.record_card']"
           )

    assert has_element?(view, "a[href='/research']", "Read the research")
    assert html =~ "published in full"

    for demo <- ["/design", "/custom-designs"] do
      refute html =~ demo
    end
  end

  test "marks the current page in the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#main-nav a[aria-current='page']", "Home")
    refute has_element?(view, "#main-nav a[aria-current='page']", "Research")
  end
end

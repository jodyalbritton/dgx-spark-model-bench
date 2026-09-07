defmodule BenchappWeb.ResearchLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the research page", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/research")

    assert has_element?(view, "h1", "What we measure, and how")
    assert has_element?(view, "#measures")

    assert has_element?(
             view,
             "[data-component='BenchappWeb.CompositeComponents.record_card']"
           )

    assert html =~ "How a result is produced"
    assert has_element?(view, "a[href='/about']", "Why we share the work")
  end

  test "marks the current page in the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/research")

    assert has_element?(view, "#main-nav a[aria-current='page']", "Research")
  end
end

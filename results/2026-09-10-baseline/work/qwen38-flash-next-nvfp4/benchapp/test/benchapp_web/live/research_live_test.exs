defmodule BenchappWeb.ResearchLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the research page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/research")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "h1")
    assert has_element?(view, ~s{[data-component="BenchappWeb.CompositeComponents.record_card"]})
    assert has_element?(view, ~s{[data-component="BenchappWeb.CompositeComponents.figure_table"]})
    assert has_element?(view, "#fixed")
  end

  test "marks the current page in the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/research")
    assert has_element?(view, ~s{#main-nav a[aria-current="page"][href="/research"]})
  end
end

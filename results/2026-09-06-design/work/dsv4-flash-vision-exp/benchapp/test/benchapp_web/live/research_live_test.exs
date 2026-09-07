defmodule BenchappWeb.ResearchLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the research page" do
    {:ok, view, _html} = live(build_conn(), "/research")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#main-nav a[aria-current='page']")
    assert has_element?(view, "h1", "What we publish and how we test")
    assert has_element?(view, ~s{[data-component="BenchappWeb.CompositeComponents.record_card"]})
    assert has_element?(view, "#research-measured-table")
  end
end

defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the landing page" do
    {:ok, view, _html} = live(build_conn(), "/")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, "#main-nav a[href='/research']")
    assert has_element?(view, "#main-nav a[aria-current='page']")
    assert has_element?(view, "h1", "JobyCorp measures local language models")
    assert has_element?(view, ~s{[data-component="BenchappWeb.CompositeComponents.record_card"]})
  end
end

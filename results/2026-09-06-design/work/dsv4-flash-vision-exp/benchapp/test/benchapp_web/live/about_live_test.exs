defmodule BenchappWeb.AboutLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the about page" do
    {:ok, view, _html} = live(build_conn(), "/about")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#main-nav a[aria-current='page']")
    assert has_element?(view, "h1", "Local models, measured and shared")
    assert has_element?(view, "#published-table")
  end
end

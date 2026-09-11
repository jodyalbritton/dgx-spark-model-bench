defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the landing page chrome and content", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "#theme-toggle")
    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, "h1")
    assert has_element?(view, ~s{[data-component="BenchappWeb.CompositeComponents.record_card"]})
    assert has_element?(view, ~s{a[href="/research"]})
  end

  test "marks the current page in the nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, ~s{#main-nav a[aria-current="page"][href="/"]})
  end

  test "does not link to the kit inspection routes", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    refute html =~ ~s{href="/design"}
    refute html =~ "/custom-designs"
    refute html =~ "/design.json"
  end
end

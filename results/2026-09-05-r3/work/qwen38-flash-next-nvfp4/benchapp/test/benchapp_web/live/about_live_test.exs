defmodule BenchappWeb.AboutLiveTest do
  @moduledoc """
  The `/about` page: same chrome as the landing page, the nav's
  `aria-current` moved to it, and the registered composite reused rather
  than re-invented.
  """
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import BenchappWeb.LaunchHelpers

  @feature_card ~S|[data-component="BenchappWeb.CompositeComponents.feature_card"]|

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/about")
    {:ok, view: view}
  end

  test "renders the mission brief inside the app layout", %{view: view} do
    assert has_element?(view, "#about-page")
    assert has_element?(view, "#main-nav")
    assert has_element?(view, "main #about-page")
    assert page_title(view) =~ "Mission brief"
  end

  test "the nav marks About as the current page", %{view: view} do
    assert has_element?(view, ~S|#main-nav a[href="/about"][aria-current="page"]|)
    refute has_element?(view, ~S|#main-nav a[href="/"][aria-current="page"]|)
    refute has_element?(view, ~S|#main-nav a[href="/design"][aria-current="page"]|)
  end

  test "the nav reaches every page at both widths", %{view: view} do
    for href <- ~w(/ /about /design /custom-designs) do
      assert has_element?(view, "#nav-menu a[href=\"#{href}\"]")
    end

    assert has_element?(view, "#nav-toggle")
    assert has_element?(view, ~S|#nav-toggle[aria-controls="nav-menu"]|)
    assert has_element?(view, "#theme-toggle")
  end

  test "the launch board is one live-navigation away", %{view: view} do
    assert has_element?(view, ~S|#main-nav a[href="/"][data-phx-link="redirect"]|)

    {:ok, board, _html} = live(build_conn(), ~p"/")
    assert has_element?(board, "#countdown")
    assert has_element?(board, "#signup-form")
  end

  test "the stack list reuses the registered feature composite", %{view: view} do
    assert count(view, "#about-stack #{@feature_card}") == 3
  end

  test "the page reads as a mission brief, not a second landing page", %{view: view} do
    assert render(view) =~ "03:14"
    assert has_element?(view, "#crew")
    assert text(view, "#crew") =~ "Flight director"
  end

  test "the home page marks itself current instead", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, ~S|#main-nav a[href="/"][aria-current="page"]|)
    refute has_element?(view, ~S|#main-nav a[href="/about"][aria-current="page"]|)
    assert countdown(view) == "100"
  end
end

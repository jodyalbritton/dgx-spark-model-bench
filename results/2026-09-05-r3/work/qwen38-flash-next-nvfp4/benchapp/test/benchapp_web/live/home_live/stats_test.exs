defmodule BenchappWeb.HomeLive.StatsTest do
  @moduledoc """
  The telemetry strip. Both readings are derived from LiveView state — the
  signup counter and the beat counter — so each case moves one of them and
  asserts the other stays put.
  """
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import BenchappWeb.LaunchHelpers

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/?tick_ms=60000")
    {:ok, view: view}
  end

  test "the strip carries both live readings", %{view: view} do
    assert has_element?(view, "#stats")
    assert has_element?(view, "#stats #stat-signups")
    assert has_element?(view, "#stats #stat-ticks")
  end

  test "both readings open at zero", %{view: view} do
    assert reading(view, "stat-signups") == "0"
    assert reading(view, "stat-ticks") == "0"
  end

  test "accepted signups move the manifest reading only", %{view: view} do
    signup(view, "ada@flightdeck.dev")
    signup(view, "grace@flightdeck.dev")

    assert reading(view, "stat-signups") == "2"
    assert reading(view, "stat-ticks") == "0"
  end

  test "beats move the tick reading only", %{view: view} do
    beat(view, 3)

    assert reading(view, "stat-ticks") == "3"
    assert reading(view, "stat-signups") == "0"
  end

  test "the strip follows a refused address nowhere", %{view: view} do
    signup(view, "not-an-email")
    assert reading(view, "stat-signups") == "0"

    signup(view, "ada@flightdeck.dev")
    signup(view, "ada@flightdeck.dev")
    assert reading(view, "stat-signups") == "1"
  end

  test "the two readings count independent things at once", %{view: view} do
    signup(view, "ada@flightdeck.dev")
    beat(view, 2)
    signup(view, "grace@flightdeck.dev")
    beat(view, 1)

    assert reading(view, "stat-signups") == "2"
    assert reading(view, "stat-ticks") == "3"
    assert countdown(view) == "97"
  end
end

defmodule BenchappWeb.HomeLive.ActivityFeedTest do
  @moduledoc """
  The flight log: one `<li>` per beat and per signup, newest first, ten rows
  deep. Every assertion counts `#activity > li`, so an entry that isn't an
  `li` can't pass.
  """
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import BenchappWeb.LaunchHelpers

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/?tick_ms=60000")
    {:ok, view: view}
  end

  test "an idle board logs nothing", %{view: view} do
    assert has_element?(view, "#activity")
    assert count(view, "#activity > li") == 0
  end

  test "each beat logs one row, newest first", %{view: view} do
    beat(view, 2)
    rows = feed(view, "activity")

    assert length(rows) == 2
    assert hd(rows) =~ "T-98"
    assert List.last(rows) =~ "T-99"
  end

  test "each signup logs one row", %{view: view} do
    signup(view, "ada@flightdeck.dev")
    rows = feed(view, "activity")

    assert length(rows) == 1
    assert hd(rows) =~ "ada@flightdeck.dev"
  end

  test "beats and signups share the log in arrival order", %{view: view} do
    beat(view, 1)
    signup(view, "ada@flightdeck.dev")
    beat(view, 1)
    rows = feed(view, "activity")

    assert length(rows) == 3
    assert Enum.at(rows, 0) =~ "T-98"
    assert Enum.at(rows, 1) =~ "ada@flightdeck.dev"
    assert Enum.at(rows, 2) =~ "T-99"
  end

  test "a refused address logs no row", %{view: view} do
    signup(view, "not-an-email")
    assert count(view, "#activity > li") == 0

    signup(view, "ada@flightdeck.dev")
    signup(view, "ada@flightdeck.dev")
    assert count(view, "#activity > li") == 1
  end

  test "the log holds ten rows at most", %{view: view} do
    beat(view, 14)
    rows = feed(view, "activity")

    assert length(rows) == 10
    assert hd(rows) =~ "T-86"
    assert List.last(rows) =~ "T-95"
  end

  test "every child of the log is an li", %{view: view} do
    beat(view, 2)
    signup(view, "ada@flightdeck.dev")

    assert count(view, "#activity > li") == 3
    assert count(view, "#activity > *") == 3
  end
end

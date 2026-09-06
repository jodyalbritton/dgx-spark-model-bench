defmodule BenchappWeb.HomeLive.CountdownTest do
  @moduledoc """
  The launch board: 100 beats, one step per beat, and a floor at zero.

  Tests mount with `?tick_ms=60000` so the only beats that land are the
  ones `beat/2` sends — the five-second default would otherwise be free to
  fire mid-assertion on a loaded machine. The last case mounts the real URL
  to hold the shipping cadence in place.
  """
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import BenchappWeb.LaunchHelpers

  alias BenchappWeb.HomeLive

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/?tick_ms=60000")
    {:ok, view: view}
  end

  test "the board opens at one hundred", %{view: view} do
    assert has_element?(view, "#countdown")
    assert countdown(view) == "100"
  end

  test "each beat steps the board down by one", %{view: view} do
    beat(view)
    assert countdown(view) == "99"

    beat(view, 4)
    assert countdown(view) == "95"
  end

  test "the board never goes below zero and beats stop landing", %{view: view} do
    beat(view, 100)
    assert countdown(view) == "0"
    assert reading(view, "stat-ticks") == "100"

    beat(view, 3)
    assert countdown(view) == "0"
    assert reading(view, "stat-ticks") == "100"
  end

  test "the shipped cadence is five seconds and the board says so", %{conn: conn} do
    assert HomeLive.tick_interval_ms() == 5_000

    {:ok, view, _html} = live(conn, ~p"/")
    assert countdown(view) == "100"
    assert render(view) =~ "one beat = 5s"
  end
end

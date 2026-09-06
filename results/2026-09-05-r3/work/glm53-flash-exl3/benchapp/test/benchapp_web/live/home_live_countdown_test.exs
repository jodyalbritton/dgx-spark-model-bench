defmodule BenchappWeb.HomeLiveCountdownTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "countdown starts at 100 and ticks down by one every tick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view |> element("#countdown") |> render() =~ "100"
    assert view |> element("#stat-ticks") |> render() =~ "0"

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert view |> element("#countdown") |> render() =~ "99"
    assert view |> element("#stat-ticks") |> render() =~ "1"

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert view |> element("#countdown") |> render() =~ "98"
    assert view |> element("#stat-ticks") |> render() =~ "2"
  end

  test "each tick adds one activity entry, newest first", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert view |> has_element?("#activity li", "Beacon check-in #2")
    assert view |> has_element?("#activity li", "Beacon check-in #1")

    ids =
      view
      |> element("#activity")
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(~s(li[data-phx-stream]))
      |> Enum.map(&(&1 |> LazyHTML.attribute("id") |> List.first()))

    assert ids == ["activity-2", "activity-1"]
  end

  test "activity feed holds at most 10 entries", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..12 do
      send(view.pid, :tick)
    end

    _ = :sys.get_state(view.pid)

    ids =
      view
      |> element("#activity")
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(~s(li[data-phx-stream]))
      |> Enum.map(&(&1 |> LazyHTML.attribute("id") |> List.first()))

    assert length(ids) == 10
    # newest first: tick 12 survived at the top, ticks 1 and 2 were pruned
    assert List.first(ids) == "activity-12"
    refute "activity-1" in ids
    refute "activity-2" in ids
  end
end

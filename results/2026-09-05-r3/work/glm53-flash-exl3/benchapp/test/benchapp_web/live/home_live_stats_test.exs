defmodule BenchappWeb.HomeLiveStatsTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "stats strip renders both counters", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stats")
    assert view |> element("#stat-signups") |> render() =~ "0"
    assert view |> element("#stat-ticks") |> render() =~ "0"
  end

  test "stats are computed from live state as signups and ticks happen", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "ridge@example.com"}})

    assert view |> element("#stat-signups") |> render() =~ "1"

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert view |> element("#stat-ticks") |> render() =~ "1"
    assert view |> element("#stat-signups") |> render() =~ "1"

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "vale@example.com"}})

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert view |> element("#stat-signups") |> render() =~ "2"
    assert view |> element("#stat-ticks") |> render() =~ "2"
  end

  test "activity feed logs one entry per signup and one per tick, newest first", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "ridge@example.com"}})

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "vale@example.com"}})

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    ids =
      view
      |> element("#activity")
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(~s(li[data-phx-stream]))
      |> Enum.map(&(&1 |> LazyHTML.attribute("id") |> List.first()))

    assert ids == ["activity-4", "activity-3", "activity-2", "activity-1"]

    assert view |> has_element?("#activity li", "vale@example.com requested beta access")
    assert view |> has_element?("#activity li", "ridge@example.com requested beta access")
    assert view |> has_element?("#activity li", "Beacon check-in #2")
    assert view |> has_element?("#activity li", "Beacon check-in #1")
  end
end

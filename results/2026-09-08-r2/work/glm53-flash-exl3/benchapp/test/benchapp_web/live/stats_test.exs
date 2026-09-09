defmodule BenchappWeb.HomeLive.StatsTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "stats strip renders signups and ticks from live state", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#stats")
    assert element(view, "#stat-signups") |> render() =~ "0"
    assert element(view, "#stat-ticks") |> render() =~ "0"

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    view
    |> element("#signup-form")
    |> render_submit(%{signup: %{email: "ada@example.com"}})

    assert element(view, "#stat-signups") |> render() =~ "1"
    assert element(view, "#stat-ticks") |> render() =~ "1"
  end
end

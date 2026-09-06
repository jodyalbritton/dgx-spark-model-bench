defmodule BenchappWeb.HomeLive.StatsTest do
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.ViewHTML

  defp submit(view, email) do
    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => email}})
  end

  test "stats strip exists and starts at zero", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#stats")
    assert text(render(view), "#stat-signups") == "0"
    assert text(render(view), "#stat-ticks") == "0"
  end

  test "signups stat reflects live signup state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    submit(view, "a@example.com")
    assert text(render(view), "#stat-signups") == "1"

    submit(view, "b@example.com")
    assert text(render(view), "#stat-signups") == "2"

    # invalid submissions do not move the counter
    submit(view, "nope")
    assert text(render(view), "#stat-signups") == "2"
  end

  test "ticks stat reflects live countdown state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    assert text(render(view), "#stat-ticks") == "1"

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    assert text(render(view), "#stat-ticks") == "2"

    # ticks and signups stay independent
    assert text(render(view), "#stat-signups") == "0"
  end
end

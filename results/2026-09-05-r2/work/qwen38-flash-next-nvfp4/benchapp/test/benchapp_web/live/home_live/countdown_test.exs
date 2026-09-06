defmodule BenchappWeb.HomeLive.CountdownTest do
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.ViewHTML

  test "countdown starts at 100", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#countdown")
    assert text(render(view), "#countdown") == "100"
  end

  test "decreases by one on each tick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    assert text(render(view), "#countdown") == "99"

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    assert text(render(view), "#countdown") == "98"
  end

  test "never goes below zero", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..105 do
      send(view.pid, :tick)
    end

    _ = :sys.get_state(view.pid)
    assert text(render(view), "#countdown") == "0"
  end
end

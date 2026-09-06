defmodule BenchappWeb.HomeLive.ActivityTest do
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.ViewHTML

  test "feed starts empty", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#activity")
    assert count(render(view), "#activity li") == 0
  end

  test "logs one entry per signup and one per tick, newest first", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "turing@example.com"}})

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    html = render(view)
    assert count(html, "#activity li") == 2

    # newest (the tick) first, the signup last
    assert text(html, "#activity li:first-child") =~ "Countdown"
    assert text(html, "#activity li:last-child") =~ "turing@example.com"
  end

  test "caps the feed at 10 entries", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..14 do
      send(view.pid, :tick)
    end

    _ = :sys.get_state(view.pid)
    assert count(render(view), "#activity li") == 10
  end
end

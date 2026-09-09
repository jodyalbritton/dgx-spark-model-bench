defmodule BenchappWeb.HomeLive.CountdownTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "starts at 100", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert element(view, "#countdown") |> render() =~ "100"
  end

  test "ticks down one per tick, recording the tick in stats and activity", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert element(view, "#countdown") |> render() =~ "99"
    assert element(view, "#stat-ticks") |> render() =~ "1"
    assert has_element?(view, "#activity li", "Countdown ticked to 99")
  end

  test "wraps back to 100 after reaching 1", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    Enum.each(1..100, fn tick ->
      send(view.pid, :tick)
      _ = :sys.get_state(view.pid)
      assert element(view, "#stat-ticks") |> render() =~ Integer.to_string(tick)
    end)

    assert element(view, "#countdown") |> render() =~ "100"
  end

  test "a real scheduled tick arrives about every five seconds", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    pid = view.pid

    eventually(fn ->
      :sys.get_state(pid).socket.assigns.countdown == 99
    end)

    assert :sys.get_state(pid).socket.assigns.countdown == 99
  end

  defp eventually(fun, tries \\ 24) do
    if fun.() do
      :ok
    else
      Process.sleep(500)
      eventually(fun, tries - 1)
    end
  end
end

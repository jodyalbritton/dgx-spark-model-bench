defmodule BenchappWeb.HomeLiveCountdownTest do
  use BenchappWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import ExUnit.CaptureLog

  setup do
    Benchapp.Signups.reset!()
    :ok
  end

  test "countdown starts at 100", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert element(view, "#countdown") |> render() =~ "100"
  end

  test "countdown decreases by 1 after 5 seconds, updating live", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert element(view, "#countdown") |> render() =~ "99"
  end

  test "countdown never goes below zero", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..3, do: send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert element(view, "#countdown") |> render() =~ "97"
  end
end

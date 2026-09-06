defmodule BenchappWeb.HomeLiveStatsTest do
  use BenchappWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  setup do
    Benchapp.Signups.reset!()
    :ok
  end

  test "stats start at zero", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert element(view, "#stat-signups") |> render() =~ "0"
    assert element(view, "#stat-ticks") |> render() =~ "0"
  end

  test "stat-signups increments after a signup", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form", signup: %{email: "grace@example.com"})
    |> render_submit()

    _ = :sys.get_state(view.pid)
    assert element(view, "#stat-signups") |> render() =~ "1"
  end

  test "stat-ticks increments with each countdown tick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    send(view.pid, :tick)
    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    assert element(view, "#stat-ticks") |> render() =~ "2"
  end
end

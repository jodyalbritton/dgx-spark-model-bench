defmodule BenchappWeb.HomeLive.CountdownTest do
  @moduledoc """
  The launch-window countdown: starts at 100, one window per five seconds,
  the number lives in `#countdown`.
  """
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.LiveTestHelpers
  import Phoenix.LiveViewTest

  test "renders the countdown at its start value", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#countdown")
    assert countdown_value(view) == 100
  end

  test "decrements by one on the five-second tick and counts the tick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    # The interval is 5_000ms in every environment, so this waits it out
    # rather than stubbing it — see BenchappWeb.LiveTestHelpers.await_view/2.
    await_view(view, fn _html -> countdown_value(view) == 99 end)

    assert texts(view, "#stat-ticks") == ["1"]
  end

  test "keeps counting down with the tick tally in step", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    await_view(view, fn _html -> countdown_value(view) <= 98 end, 13_000)

    ticks = texts(view, "#stat-ticks") |> hd() |> String.to_integer()

    assert ticks == 100 - countdown_value(view)
  end
end

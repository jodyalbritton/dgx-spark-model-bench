defmodule BenchappWeb.HomeLive.StatsTest do
  @moduledoc """
  The `#stats` strip: `#stat-signups` counts the live pilot list,
  `#stat-ticks` counts the countdown's ticks — both read from the state the
  page renders.
  """
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.LiveTestHelpers
  import Phoenix.LiveViewTest

  test "reports zero signups and zero ticks at rest", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stats")
    assert texts(view, "#stat-signups") == ["0"]
    assert texts(view, "#stat-ticks") == ["0"]
  end

  test "the signup figure tracks the list as addresses arrive", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    signup(view, "one@lab.org")
    assert texts(view, "#stat-signups") == ["1"]

    signup(view, "two@lab.org")
    assert texts(view, "#stat-signups") == ["2"]

    # A refused address must not move the figure.
    signup(view, "one@lab.org")
    assert texts(view, "#stat-signups") == ["2"]
  end

  test "the tick figure moves with the countdown", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    await_view(view, fn _html -> texts(view, "#stat-ticks") == ["1"] end)

    assert countdown_value(view) == 99
  end

  test "both figures move together but count different things", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    signup(view, "solo@lab.org")
    await_view(view, fn _html -> texts(view, "#stat-ticks") == ["1"] end)

    assert texts(view, "#stat-signups") == ["1"]
    assert texts(view, "#stat-ticks") == ["1"]
  end
end

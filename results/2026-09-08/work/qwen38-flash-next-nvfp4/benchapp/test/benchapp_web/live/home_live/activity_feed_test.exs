defmodule BenchappWeb.HomeLive.ActivityFeedTest do
  @moduledoc """
  The fleet log: `#activity` holds `<li>` entries, newest first, at most ten,
  one per signup and one per tick.
  """
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.LiveTestHelpers
  import Phoenix.LiveViewTest

  test "starts empty", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#activity")
    assert texts(view, "#activity li") == []
  end

  test "a signup logs one entry naming the address", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    signup(view, "ada@lab.org")
    entries = texts(view, "#activity li")

    assert length(entries) == 1
    assert hd(entries) =~ "ada@lab.org"
  end

  test "a tick logs one entry", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    await_view(view, fn _html -> texts(view, "#activity li") != [] end)

    assert [newest | _] = texts(view, "#activity li")
    assert newest =~ "Sync cycle"
  end

  test "signups and ticks share one log, newest at the top", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    await_view(view, fn _html -> texts(view, "#activity li") != [] end)
    signup(view, "late@lab.org")

    entries = texts(view, "#activity li")

    assert length(entries) == 2
    assert hd(entries) =~ "late@lab.org"
    assert List.last(entries) =~ "Sync cycle"
  end

  test "the feed holds at most ten entries", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for index <- 1..12 do
      signup(view, "crew#{index}@lab.org")
    end

    entries = texts(view, "#activity li")

    assert length(entries) == 10
    assert hd(entries) =~ "crew12@lab.org"
    refute Enum.any?(entries, &(&1 =~ "crew1@lab.org"))
    assert texts(view, "#stat-signups") == ["12"]
  end
end

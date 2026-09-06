defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias BenchappWeb.Presence

  setup do
    name = test_process_name()
    start_supervised!({Presence, name: name})
    Application.put_env(:benchapp, :presence_server, name)
    {:ok, name: name}
  end

  defp test_process_name, do: :"presence_#{System.unique_integer([:positive])}"

  test "renders hero and nav", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "h1", "Zephyr")
    assert has_element?(view, "#countdown")
  end

  test "countdown starts at 100 and decreases by 1 every 5 seconds", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#countdown", "100")

    send(view.pid, :tick)
    render(view)
    assert has_element?(view, "#countdown", "99")

    send(view.pid, :tick)
    render(view)
    assert has_element?(view, "#countdown", "98")
  end

  test "valid signup is added to the recent signups list", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "ada@example.com"}})

    assert has_element?(view, "#signups li", "ada@example.com")
    refute has_element?(view, "#signup-error")
    assert has_element?(view, "#stat-signups", "1")
  end

  test "invalid signup shows an error and is not added", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "not-an-email"}})

    assert has_element?(view, "#signup-error")
    assert has_element?(view, "#stat-signups", "0")
    refute has_element?(view, "#signups li")
  end

  test "duplicate signup shows an error and is not added twice", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "ada@example.com"}})

    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "ada@example.com"}})

    assert has_element?(view, "#signup-error")
    assert has_element?(view, "#stat-signups", "1")
    signups = render(view) |> LazyHTML.from_fragment() |> LazyHTML.query("#signups li")
    assert Enum.count(signups) == 1
  end

  test "stats strip tracks signups and ticks", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stat-signups", "0")
    assert has_element?(view, "#stat-ticks", "0")

    send(view.pid, :tick)
    send(view.pid, :tick)
    render(view)
    assert has_element?(view, "#stat-ticks", "2")

    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "ada@example.com"}})

    assert has_element?(view, "#stat-signups", "1")
  end

  test "activity feed records one entry per signup and per tick, newest first", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    send(view.pid, :tick)

    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "ada@example.com"}})

    send(view.pid, :tick)
    render(view)

    entries =
      render(view)
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("#activity li")
      |> Enum.to_list()
      |> Enum.map(&LazyHTML.text/1)

    assert length(entries) == 3
    assert Enum.at(entries, 0) =~ "ticked to 98"
    assert Enum.at(entries, 1) =~ "ada@example.com"
    assert Enum.at(entries, 2) =~ "ticked to 99"
  end

  test "activity feed is capped at 10 entries", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..12, do: send(view.pid, :tick)
    render(view)

    entries = render(view) |> LazyHTML.from_fragment() |> LazyHTML.query("#activity li")
    assert Enum.count(entries) == 10
  end
end

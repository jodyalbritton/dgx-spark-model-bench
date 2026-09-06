defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the hero and landing content", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert has_element?(view, "h1", "The desk lamp that keeps pace with")
    assert html =~ "Solstice"
    assert has_element?(view, "#countdown")
    assert has_element?(view, "#stats")
    assert has_element?(view, "#signup-form")
    assert has_element?(view, "#activity")
  end

  test "countdown starts at 100 and ticks down once per tick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#countdown", "100")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    render(view)
    assert has_element?(view, "#countdown", "99")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    render(view)
    assert has_element?(view, "#countdown", "98")
  end

  test "stat-ticks counts ticks from live state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stat-ticks", "0")

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    render(view)
    assert has_element?(view, "#stat-ticks", "1")
  end

  test "valid email signup is added to recent signups and stats update", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view
           |> form("#signup-form")
           |> render_submit(signup: %{email: "ada@example.com"})

    assert has_element?(view, "#signups li", "ada@example.com")
    assert has_element?(view, "#stat-signups", "1")
    refute has_element?(view, "#signup-error")
    assert has_element?(view, "#activity li", "New signup: ada@example.com")
  end

  test "invalid email shows an error and is not added", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view
           |> form("#signup-form")
           |> render_submit(signup: %{email: "not-an-email"})

    assert has_element?(view, "#signup-error")
    refute has_element?(view, "#signups li", "not-an-email")
    assert has_element?(view, "#stat-signups", "0")
  end

  test "duplicate email shows an error and is not added twice", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> form("#signup-form") |> render_submit(signup: %{email: "ada@example.com"})

    view |> form("#signup-form") |> render_submit(signup: %{email: "ada@example.com"})

    assert has_element?(view, "#signup-error", "already on the list")
    assert has_element?(view, "#stat-signups", "1")
  end

  test "activity feed holds at most ten entries, newest first", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> form("#signup-form") |> render_submit(signup: %{email: "ada@example.com"})

    for _ <- 1..12, do: send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    _ = render(view)

    activity_html = view |> element("#activity") |> render()

    # 13 events (1 signup + 12 ticks) capped at 10 entries
    assert String.split(activity_html, "<li", trim: true) |> length() == 11
    assert activity_html =~ "88 remaining"
    assert activity_html =~ "97 remaining"
    refute activity_html =~ "99 remaining"
  end
end

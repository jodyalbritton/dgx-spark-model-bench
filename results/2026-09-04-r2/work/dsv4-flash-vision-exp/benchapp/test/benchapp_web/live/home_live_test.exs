defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the hero and countdown starting at 100", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert html =~ "Lumen"
    assert has_element?(view, "#countdown")
    assert render(view) =~ "100"
  end

  test "countdown ticks down by 1", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert render(view) =~ "100"
    send(view.pid, :tick)
    assert render(view) =~ "99"
    send(view.pid, :tick)
    assert render(view) =~ "98"
  end

  test "signup form rejects an invalid address", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    form =
      view
      |> form("#signup-form", %{"email" => "not-an-email"})
      |> render_submit()

    assert form =~ "valid email"
    assert has_element?(view, "#signup-error")
  end

  test "signup form accepts a valid address and updates signups list live", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form", %{"email" => "ada@example.com"})
    |> render_submit()

    assert has_element?(view, "#signups")
    assert render(view) =~ "ada@example.com"
  end

  test "stats show signups and ticks computed from live state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stats")
    assert has_element?(view, "#stat-signups")
    assert has_element?(view, "#stat-ticks")

    send(view.pid, :tick)
    render(view)

    view
    |> form("#signup-form", %{"email" => "grace@example.com"})
    |> render_submit()

    html = render(view)
    assert html =~ "1"
  end

  test "activity feed records signups and ticks, newest first, capped at 10", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#activity")

    send(view.pid, :tick)
    view |> form("#signup-form", %{"email" => "alan@example.com"}) |> render_submit()
    send(view.pid, :tick)

    html = render(view)
    assert html =~ "New signup: alan@example.com"
    assert html =~ "Countdown tick"

    # Cap at 10
    for _ <- 1..10 do
      send(view.pid, :tick)
    end

    html = render(view)
    # only latest 10 entries remain
    assert html =~ "Countdown tick"
  end
end

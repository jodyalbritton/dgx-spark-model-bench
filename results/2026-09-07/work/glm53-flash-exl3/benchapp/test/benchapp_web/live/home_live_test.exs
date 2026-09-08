defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "countdown" do
    test "starts at 100 and ticks down by 1", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert element(view, "#countdown") |> render() =~ "100"

      send(view.pid, :tick)
      _ = render(view)
      assert element(view, "#countdown") |> render() =~ "99"
    end

    test "each tick appends an activity entry and increments stat-ticks", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      send(view.pid, :tick)
      _ = render(view)

      assert element(view, "#stat-ticks") |> render() =~ "1"
      assert element(view, "#activity") |> render() =~ "Countdown ticked to 99"
    end
  end

  describe "signup form" do
    test "renders the form and an empty recent-signups list", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#signup-form")
      assert element(view, "#stat-signups") |> render() =~ "0"
    end

    test "invalid email shows error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      render_submit(view, "signup", %{"signup" => %{"email" => "not-an-email"}})

      assert has_element?(view, "#signup-error", "That doesn't look like an email address.")
      assert element(view, "#stat-signups") |> render() =~ "0"
    end

    test "valid email is added without reload", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      render_submit(view, "signup", %{"signup" => %{"email" => "fern@fan.example"}})

      assert element(view, "#signups") |> render() =~ "fern@fan.example"
      assert element(view, "#stat-signups") |> render() =~ "1"

      assert element(view, "#activity") |> render() =~
               "fern@fan.example joined the early-access list"
    end

    test "duplicate email shows error and is not added twice", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      render_submit(view, "signup", %{"signup" => %{"email" => "fern@fan.example"}})
      render_submit(view, "signup", %{"signup" => %{"email" => "fern@fan.example"}})

      assert has_element?(view, "#signup-error", "You're already on the list.")
      assert element(view, "#stat-signups") |> render() =~ "1"
    end
  end

  describe "stats strip" do
    test "reflects signups and ticks from live state", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#stats")
      render_submit(view, "signup", %{"signup" => %{"email" => "moss@fan.example"}})
      send(view.pid, :tick)
      _ = render(view)

      assert element(view, "#stat-signups") |> render() =~ "1"
      assert element(view, "#stat-ticks") |> render() =~ "1"
    end
  end

  describe "activity feed" do
    test "entries are newest-first and capped at 10", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      for _ <- 1..12, do: send(view.pid, :tick)
      _ = render(view)

      html = element(view, "#activity") |> render()
      refute html =~ "ticked to 98"
      assert html =~ "ticked to 97"
    end
  end
end

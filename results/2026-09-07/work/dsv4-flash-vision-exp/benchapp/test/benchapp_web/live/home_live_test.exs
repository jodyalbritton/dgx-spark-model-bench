defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "countdown" do
    test "starts at 100 and ticks down", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      assert view |> element("#countdown") |> render() =~ "100"

      send(view.pid, :tick)
      assert view |> element("#countdown") |> render() =~ "99"
    end

    test "increments the tick counter", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      assert view |> element("#stat-ticks") |> render() =~ "0"

      send(view.pid, :tick)
      assert view |> element("#stat-ticks") |> render() =~ "1"
    end
  end

  describe "signup form" do
    test "shows an error for an invalid address and does not add it", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view
             |> form("#signup-form", newsletter: %{email: "not-an-email"})
             |> render_submit() =~ "valid email address"

      assert view |> element("#signup-error") |> render() =~ "valid email address"
      assert view |> element("#stat-signups") |> render() =~ "0"
    end

    test "adds a valid address to the signups list without a reload", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view
             |> form("#signup-form", newsletter: %{email: "ada@example.com"})
             |> render_submit()

      assert view |> element("#stat-signups") |> render() =~ "1"
      assert view |> element("#signups") |> render() =~ "ada@example.com"
    end

    test "rejects a duplicate address", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#signup-form", newsletter: %{email: "ada@example.com"})
      |> render_submit()

      assert view
             |> form("#signup-form", newsletter: %{email: "ada@example.com"})
             |> render_submit() =~ "already on the list"

      assert view |> element("#stat-signups") |> render() =~ "1"
    end
  end

  describe "stats" do
    test "computes signup count and tick count from live state", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view |> element("#stat-signups") |> render() =~ "0"
      assert view |> element("#stat-ticks") |> render() =~ "0"

      send(view.pid, :tick)
      assert view |> element("#stat-ticks") |> render() =~ "1"

      view
      |> form("#signup-form", newsletter: %{email: "grace@example.com"})
      |> render_submit()

      assert view |> element("#stat-signups") |> render() =~ "1"
    end
  end

  describe "activity feed" do
    test "records an entry per tick, newest first", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      send(view.pid, :tick)
      html = render(view)
      assert html =~ "Countdown ticked to 99"

      send(view.pid, :tick)
      html = render(view)
      assert html =~ "Countdown ticked to 98"
      # newest first: "ticked to 98" appears before "ticked to 99"
      idx_98 = :binary.match(html, "ticked to 98") |> elem(0)
      idx_99 = :binary.match(html, "ticked to 99") |> elem(0)
      assert idx_98 < idx_99
    end

    test "records one entry per signup", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#signup-form", newsletter: %{email: "ada@example.com"})
      |> render_submit()

      assert view |> element("#activity") |> render() =~ "New signup: ada@example.com"
    end

    test "caps the feed at 10 entries", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      for _ <- 1..15 do
        send(view.pid, :tick)
        render(view)
      end

      html = render(view)
      count = length(Regex.scan(~r/Countdown ticked to/, html))
      assert count == 10
    end
  end
end

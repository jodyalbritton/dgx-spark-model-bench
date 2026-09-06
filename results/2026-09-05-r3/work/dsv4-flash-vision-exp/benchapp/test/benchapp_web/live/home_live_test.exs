defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "navigation chrome" do
    test "renders the nav, theme toggle, and current-page marker", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "#main-nav")
      assert has_element?(view, "#nav-toggle")
      assert has_element?(view, "#theme-toggle")

      # The current page's link is marked with aria-current="page".
      assert has_element?(view, "#main-nav a[aria-current=page]")
      assert element(view, ~s{#main-nav a[aria-current=page]}) |> render() =~ "Home"
    end

    test "mobile menu opens and closes behind the nav toggle", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      refute has_element?(view, "#mobile-nav")

      view |> element("#nav-toggle") |> render_click()
      assert has_element?(view, "#mobile-nav")

      view |> element("#nav-toggle") |> render_click()
      refute has_element?(view, "#mobile-nav")
    end
  end

  describe "countdown" do
    test "starts at 100 and steps down by 1 on each tick", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert element(view, "#countdown") |> render() =~ "100"
      assert element(view, "#stat-ticks") |> render() =~ "0"

      send(view.pid, :tick)
      _ = :sys.get_state(view.pid)

      assert element(view, "#countdown") |> render() =~ "99"
      assert element(view, "#stat-ticks") |> render() =~ "1"
    end
  end

  describe "signup form" do
    test "an invalid address shows an error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#signup-form", signup: %{email: "not-an-email"})
      |> render_submit()

      assert element(view, "#signup-error") |> render() =~ "valid email"
      refute has_element?(view, "#signups li")
      assert element(view, "#stat-signups") |> render() =~ "0"
    end

    test "a valid address is added to the recent signups list", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#signup-form", signup: %{email: "ada@hearth.app"})
      |> render_submit()

      refute has_element?(view, "#signup-error")
      assert element(view, "#signups") |> render() =~ "ada@hearth.app"
      assert element(view, "#stat-signups") |> render() =~ "1"

      # It lands in the activity feed too.
      assert element(view, "#activity li") |> render() =~ "ada@hearth.app"
    end

    test "the same address submitted twice shows an error and is not added again", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#signup-form", signup: %{email: "ada@hearth.app"})
      |> render_submit()

      view
      |> form("#signup-form", signup: %{email: "ada@hearth.app"})
      |> render_submit()

      assert element(view, "#signup-error") |> render() =~ "already on the list"
      assert element(view, "#stat-signups") |> render() =~ "1"
    end
  end

  describe "stats strip" do
    test "tracks signups and countdown ticks from live state", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "#stats")
      assert element(view, "#stat-signups") |> render() =~ "0"
      assert element(view, "#stat-ticks") |> render() =~ "0"

      for _ <- 1..3 do
        send(view.pid, :tick)
      end

      _ = :sys.get_state(view.pid)

      assert element(view, "#stat-ticks") |> render() =~ "3"
      assert element(view, "#countdown") |> render() =~ "97"

      view
      |> form("#signup-form", signup: %{email: "grace@hearth.app"})
      |> render_submit()

      assert element(view, "#stat-signups") |> render() =~ "1"
    end
  end

  describe "activity feed" do
    test "records one entry per tick, newest first", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      send(view.pid, :tick)
      send(view.pid, :tick)
      _ = :sys.get_state(view.pid)

      # Newest tick appears at the top.
      assert element(view, "#activity li:first-child") |> render() =~ "tick #2"
    end

    test "keeps at most ten entries", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      for _ <- 1..14 do
        send(view.pid, :tick)
      end

      _ = :sys.get_state(view.pid)

      feed = element(view, "#activity") |> render()
      lis = Regex.scan(~r/<li\b/, feed) |> length()

      assert lis == 10
      # Newest entry on top.
      assert element(view, "#activity li:first-child") |> render() =~ "tick #14"
    end

    test "carries entries for both signups and ticks", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      send(view.pid, :tick)
      _ = :sys.get_state(view.pid)

      view
      |> form("#signup-form", signup: %{email: "linus@hearth.app"})
      |> render_submit()

      feed = element(view, "#activity") |> render()

      assert feed =~ "linus@hearth.app"
      assert feed =~ "tick #1"
    end
  end
end

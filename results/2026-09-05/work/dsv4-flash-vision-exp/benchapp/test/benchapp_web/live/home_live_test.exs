defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "layout and nav" do
    test "renders the landing page with a hero", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ "Know what the sky"
      assert html =~ "Nimbus"
      assert has_element?(view, ~s(nav#main-nav a[href="/"][aria-current="page"]))
    end

    test "has a main-nav with a toggle and theme toggle", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ ~s(id="main-nav")
      assert html =~ ~s(id="nav-toggle")
      assert html =~ ~s(id="theme-toggle")
      assert html =~ ~s(id="mobile-menu")
    end
  end

  describe "countdown" do
    test "starts at 100 and renders the countdown element", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#countdown")
      assert element(view, "#countdown") |> render() =~ "100"
    end

    test "decrements on each tick and records ticks", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ ~s(id="countdown")

      send(view.pid, :tick)
      assert element(view, "#countdown") |> render() =~ "99"
      assert element(view, "#stat-ticks") |> render() =~ "1"
    end
  end

  describe "stats" do
    test "renders the stats strip", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ ~s(id="stats")
      assert html =~ ~s(id="stat-signups")
      assert html =~ ~s(id="stat-ticks")
    end

    test "stat-ticks updates after a tick", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert element(view, "#stat-ticks") |> render() =~ "0"

      send(view.pid, :tick)
      assert element(view, "#stat-ticks") |> render() =~ "1"
      assert element(view, "#stat-signups") |> render() =~ "0"
    end
  end

  describe "signup form" do
    test "renders the signup form with an email input", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ ~s(id="signup-form")
      assert html =~ ~s(id="signups")
    end

    test "invalid email shows an error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "not-an-email"})
      |> render_submit()

      assert element(view, "#signup-error") |> render() =~ "valid email"
      assert render(view) =~ "No signups yet"
    end

    test "valid email is added to recent signups", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      assert element(view, "#signups") |> render() =~ "ada@example.com"
      assert element(view, "#stat-signups") |> render() =~ "1"
    end

    test "duplicate email shows an error and is not added twice", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      assert element(view, "#signup-error") |> render() =~ "already"
      assert element(view, "#stat-signups") |> render() =~ "1"
    end
  end

  describe "activity feed" do
    test "renders the activity feed", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ ~s(id="activity")
    end

    test "a signup adds an activity entry", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      assert element(view, "#activity") |> render() =~ "New subscriber: ada@example.com"
    end
  end

  describe "feature grid" do
    test "renders the feature grid composite", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Live radar"
      assert html =~ "Privacy first"
      assert html =~ ~s(data-component="BenchappWeb.CompositeComponents.feature_grid")
    end
  end
end

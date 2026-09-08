defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "countdown" do
    test "starts at 100", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#countdown", "100")
    end

    test "decreases by 1 per tick, five seconds apart", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      send(view.pid, :tick)
      assert has_element?(view, "#countdown", "99")

      send(view.pid, :tick)
      assert has_element?(view, "#countdown", "98")
    end

    test "tick increments stat-ticks", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#stat-ticks", "0")
      send(view.pid, :tick)
      assert has_element?(view, "#stat-ticks", "1")
    end
  end

  describe "signup form" do
    test "renders form and email input", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#signup-form")
      assert has_element?(view, "#signup-form input[type='email']")
    end

    test "invalid email shows error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "not-an-email"})
      |> render_submit()

      assert has_element?(view, "#signup-error", "valid email")
      refute has_element?(view, "#signups li", "not-an-email")
      assert has_element?(view, "#stat-signups", "0")
    end

    test "valid email is added without a reload", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      assert has_element?(view, "#signups li", "ada@example.com")
      assert has_element?(view, "#stat-signups", "1")
      refute has_element?(view, "#signup-error", "valid email")
      refute has_element?(view, "#signup-error", "already")
    end

    test "duplicate email shows error and is not added twice", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      assert has_element?(view, "#signup-error", "already")
      assert view |> element("#signups") |> render() |> String.contains?("ada@example.com")
      assert has_element?(view, "#stat-signups", "1")
    end
  end

  describe "stats" do
    test "reflects signups from live state", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#stat-signups", "0")

      view
      |> form("#signup-form", signup: %{email: "grace@example.com"})
      |> render_submit()

      assert has_element?(view, "#stat-signups", "1")
    end
  end

  describe "activity feed" do
    test "records signups and ticks, newest first", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      send(view.pid, :tick)
      send(view.pid, :tick)

      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

      assert has_element?(view, "#activity li", "ada@example.com")
      assert has_element?(view, "#activity li", "ticked over")

      html = view |> element("#activity") |> render()
      [newest | rest] = html |> String.split(~s(id="activity-)) |> tl()
      assert newest =~ "ada@example.com"
      assert rest |> hd() =~ "ticked over"
    end

    test "caps the feed at 10 entries", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      for _ <- 1..12, do: send(view.pid, :tick)

      count =
        view
        |> element("#activity")
        |> render()
        |> then(&Regex.scan(~r/id="activity-/, &1))
        |> length()

      assert count == 10
    end
  end

  describe "feature grid" do
    test "renders the composite feature grid", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "[data-component='BenchappWeb.CompositeComponents.feature_grid']")
    end
  end
end

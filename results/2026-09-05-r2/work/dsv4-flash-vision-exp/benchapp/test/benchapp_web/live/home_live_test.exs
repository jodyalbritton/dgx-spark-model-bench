defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "countdown" do
    test "renders the initial value of 100", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      assert has_element?(view, "#countdown", "100")
    end

    test "decrements by 1 and updates live when a tick fires", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      send(view.pid, :tick)
      _ = :sys.get_state(view.pid)

      assert has_element?(view, "#countdown", "99")
    end
  end

  describe "signup form" do
    test "an invalid address shows an error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "not-an-email"})
      |> render_submit()

      assert has_element?(view, "#signup-error")
      assert count_lis(render(view), "signups") == 0
      assert has_element?(view, "#stat-signups", "0")
    end

    test "a valid address is added to recent signups without reload", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#signup-form", signup: %{email: "jane@example.com"})
      |> render_submit()

      assert has_element?(view, "#signups", "jane@example.com")
      assert has_element?(view, "#stat-signups", "1")
      assert count_lis(render(view), "signups") == 1
    end

    test "submitting the same address twice shows an error and is not added again", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      params = %{signup: %{email: "jane@example.com"}}

      view |> form("#signup-form", params) |> render_submit()
      assert has_element?(view, "#stat-signups", "1")

      view |> form("#signup-form", params) |> render_submit()

      assert has_element?(view, "#signup-error")
      assert has_element?(view, "#stat-signups", "1")
      assert count_lis(render(view), "signups") == 1
    end
  end

  describe "stats" do
    test "stat-signups counts signups and stat-ticks counts ticks", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> form("#signup-form", signup: %{email: "mary@example.com"}) |> render_submit()
      send(view.pid, :tick)
      send(view.pid, :tick)
      _ = :sys.get_state(view.pid)

      assert has_element?(view, "#stat-signups", "1")
      assert has_element?(view, "#stat-ticks", "2")
    end
  end

  describe "activity feed" do
    test "records one entry per signup and per tick, newest first", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> form("#signup-form", signup: %{email: "ada@example.com"}) |> render_submit()
      send(view.pid, :tick)
      _ = :sys.get_state(view.pid)

      assert has_element?(view, "#activity li")
      # The most recent entry is the tick, so the first list item is newest-first.
      assert element(view, "#activity li:first-child") |> render() =~ "ticked"
      assert count_lis(render(view), "activity") == 2
    end

    test "keeps at most 10 entries", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      for _ <- 1..12 do
        send(view.pid, :tick)
      end

      _ = :sys.get_state(view.pid)
      assert count_lis(render(view), "activity") == 10
    end
  end

  defp count_lis(html, ul_id) do
    case Regex.run(~r/<ul id="#{ul_id}"[^>]*>(.*?)<\/ul>/s, html) do
      [_, body] -> body |> String.split("<li") |> length() |> Kernel.-(1)
      _ -> 0
    end
  end
end

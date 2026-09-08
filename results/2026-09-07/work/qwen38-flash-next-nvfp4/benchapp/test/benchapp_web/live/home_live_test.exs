defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  # The countdown steps every 5 seconds for real visitors; `config/test.exs`
  # parks that timer, so these tests drive `:tick` themselves.

  defp tick(view) do
    send(view.pid, :tick)
    render(view)
  end

  defp signup(view, email) do
    view |> element("#signup-form") |> render_submit(%{"signup" => %{"email" => email}})
  end

  # `query/2` is the selector API LiveViewTest's own DOM helpers use.
  defp count_of(view, selector), do: view |> doc() |> LazyHTML.query(selector) |> Enum.count()

  defp doc(view), do: view |> render() |> LazyHTML.from_document()

  describe "countdown" do
    test "starts at 100 in #countdown", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#countdown", "100")
      refute has_element?(view, "#countdown", "99")
    end

    test "steps down by one on every tick", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      tick(view)
      assert has_element?(view, "#countdown", "99")
      refute has_element?(view, "#countdown", "100")

      tick(view)
      assert has_element?(view, "#countdown", "98")
      refute has_element?(view, "#countdown", "99")
    end

    test "holds at zero once the gate closes", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      Enum.each(1..100, fn _ -> tick(view) end)
      assert has_element?(view, "#stat-ticks", "100")
      refute has_element?(view, "#countdown", "1")

      tick(view)
      assert has_element?(view, "#stat-ticks", "100")
      refute has_element?(view, "#countdown", "1")
    end
  end

  describe "signup form" do
    test "has one email input", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#signup-form")
      assert has_element?(view, ~S|#signup-form input[type="email"]|)
      assert count_of(view, "#signup-form input") == 1
    end

    test "an invalid address shows #signup-error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      signup(view, "not-an-email")

      assert has_element?(view, "#signup-error", "not a valid email")
      assert has_element?(view, "#signups-empty")
      assert count_of(view, "#signups li") == 1
      assert count_of(view, "#stat-signups") == 1
      refute has_element?(view, "#stat-signups", "1")
    end

    test "an empty address is rejected", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      signup(view, "")

      assert has_element?(view, "#signup-error", "is required")
      assert has_element?(view, "#signups-empty")
    end

    test "a valid address is added to #signups without a reload", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      signup(view, "Ada@Example.com")

      refute has_element?(view, "#signup-error")
      refute has_element?(view, "#signups-empty")
      assert has_element?(view, "#signups li", "ada@example.com")
      assert count_of(view, "#signups li") == 1
      assert has_element?(view, "#stat-signups", "1")
    end

    test "the same address twice shows the error and is not added again", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      signup(view, "ada@example.com")
      signup(view, "ada@example.com")

      assert has_element?(view, "#signup-error", "already on the list")
      assert count_of(view, "#signups li") == 1
      assert has_element?(view, "#stat-signups", "1")
      refute has_element?(view, "#stat-signups", "2")
    end

    test "a second distinct address is accepted", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      signup(view, "ada@example.com")
      signup(view, "grace@example.com")

      refute has_element?(view, "#signup-error")
      assert count_of(view, "#signups li") == 2
      assert has_element?(view, "#stat-signups", "2")
    end
  end

  describe "stats strip" do
    test "#stats reports signup and tick counts from live state", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#stats")
      assert count_of(view, "#stat-signups") == 1
      assert count_of(view, "#stat-ticks") == 1
      refute has_element?(view, "#stat-signups", "1")
      refute has_element?(view, "#stat-ticks", "1")

      signup(view, "ada@example.com")
      tick(view)

      assert has_element?(view, "#stat-signups", "1")
      assert has_element?(view, "#stat-ticks", "1")
    end
  end

  describe "activity feed" do
    test "records one entry per signup and per tick, newest first", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute has_element?(view, "#activity li")

      tick(view)
      signup(view, "ada@example.com")

      assert count_of(view, "#activity li") == 2
      assert has_element?(view, "#activity li:first-child", "New signup")
      assert has_element?(view, "#activity li:last-child", "Countdown step #1")
    end

    test "keeps at most ten entries", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      Enum.each(1..12, fn _ -> tick(view) end)

      assert count_of(view, "#activity li") == 10
      assert has_element?(view, "#activity li:first-child", "Countdown step #12")
      assert has_element?(view, "#activity li:last-child", "Countdown step #3")
    end
  end
end

defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  describe "countdown" do
    test "renders at 100 and decrements on each tick", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      assert html =~ ~s(id="countdown")
      assert element(view, "#countdown") |> render() =~ "100"

      send(view.pid, :countdown_tick)
      assert_until(view, "#countdown", "99")

      send(view.pid, :countdown_tick)
      assert_until(view, "#countdown", "98")
    end
  end

  describe "newsletter signup" do
    test "invalid email shows an error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      form = form(view, "#signup-form", signup: %{email: "not-an-email"})
      render_submit(form)

      assert has_element?(view, "#signup-error")
      assert element(view, "#signup-error") |> render() =~ "valid email"
      assert element(view, "#stat-signups") |> render() =~ "0"
      refute has_element?(view, "#signups li")
    end

    test "valid email is added to the recent signups list without a reload", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      form = form(view, "#signup-form", signup: %{email: "ada@example.com"})
      render_submit(form)

      assert has_element?(view, "#signups li")
      assert element(view, "#signups") |> render() =~ "ada@example.com"
      assert element(view, "#stat-signups") |> render() =~ "1"
    end

    test "a duplicate address shows an error and is not added again", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      form = form(view, "#signup-form", signup: %{email: "ada@example.com"})
      render_submit(form)
      assert element(view, "#stat-signups") |> render() =~ "1"

      form = form(view, "#signup-form", signup: %{email: "ada@example.com"})
      render_submit(form)

      assert element(view, "#signup-error") |> render() =~ "already"
      assert element(view, "#stat-signups") |> render() =~ "1"
      assert element(view, "#signups") |> render() =~ "ada@example.com"
    end
  end

  describe "stats strip" do
    test "stat-signups and stat-ticks reflect live state", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      assert html =~ ~s(id="stats")
      assert element(view, "#stat-signups") |> render() =~ "0"
      assert element(view, "#stat-ticks") |> render() =~ "0"

      send(view.pid, :countdown_tick)
      assert_until(view, "#stat-ticks", "1")

      form = form(view, "#signup-form", signup: %{email: "grace@example.com"})
      render_submit(form)

      assert element(view, "#stat-signups") |> render() =~ "1"
    end
  end

  describe "activity feed" do
    test "logs one entry per tick and per signup, newest first", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      send(view.pid, :countdown_tick)
      assert_until(view, "#activity li", "Countdown")

      form = form(view, "#signup-form", signup: %{email: "ada@example.com"})
      render_submit(form)

      texts = li_texts(view)
      assert Enum.at(texts, 0) =~ "ada@example.com"
      assert Enum.at(texts, 1) =~ "Countdown"
    end

    test "keeps at most ten entries", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      for _ <- 1..12 do
        send(view.pid, :countdown_tick)
      end

      assert_until_count(view, "#activity li", 10)
    end
  end

  defp li_texts(view) do
    view
    |> render()
    |> LazyHTML.from_fragment()
    |> LazyHTML.query("#activity li")
    |> Enum.map(&LazyHTML.text/1)
  end

  defp assert_until(view, selector, text, attempts \\ 20) do
    cond do
      attempts == 0 ->
        flunk("expected #{selector} to contain #{inspect(text)}")

      element(view, selector) |> render() =~ text ->
        :ok

      true ->
        Process.sleep(50)
        assert_until(view, selector, text, attempts - 1)
    end
  end

  defp assert_until_count(view, selector, count, attempts \\ 20) do
    rendered =
      view
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(selector)
      |> Enum.count()

    cond do
      attempts == 0 ->
        flunk("expected #{selector} to eventually render #{count} elements")

      rendered == count ->
        :ok

      true ->
        Process.sleep(50)
        assert_until_count(view, selector, count, attempts - 1)
    end
  end
end

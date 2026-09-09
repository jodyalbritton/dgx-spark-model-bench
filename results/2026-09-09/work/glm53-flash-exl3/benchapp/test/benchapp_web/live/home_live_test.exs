defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  defp live_home(conn), do: live(conn, ~p"/")

  defp sync!(view) do
    _ = :sys.get_state(view.pid)
    render(view)
  end

  describe "countdown" do
    test "starts at 100 and ticks down by one", %{conn: conn} do
      {:ok, view, html} = live_home(conn)

      assert html =~ ~s(id="countdown")
      assert view |> element("#countdown") |> render() =~ "100"

      send(view.pid, :tick)
      _html = sync!(view)

      assert view |> element("#countdown") |> render() =~ "99"
    end

    test "counts ticks in stats and activity", %{conn: conn} do
      {:ok, view, _html} = live_home(conn)

      send(view.pid, :tick)
      send(view.pid, :tick)
      _html = sync!(view)

      assert view |> element("#stat-ticks") |> render() =~ "2"
      assert view |> element("#activity") |> render() =~ "ticked"
    end

    test "processes ticks from live state", %{conn: conn} do
      {:ok, view, _html} = live_home(conn)

      send(view.pid, :tick)
      _html = sync!(view)

      assert view |> element("#stat-ticks") |> render() =~ "1"
      assert view |> element("#countdown") |> render() =~ "99"
    end
  end

  describe "signup form" do
    test "valid email is added and shown without reload", %{conn: conn} do
      {:ok, view, _html} = live_home(conn)

      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "ada@example.com"}})

      assert view |> element("#signups") |> render() =~ "ada@example.com"
      assert view |> element("#stat-signups") |> render() =~ "1"
      assert view |> element("#activity") |> render() =~ "joined the launch list"
      refute has_element?(view, "#signup-error")
    end

    test "invalid email shows an error and is not added", %{conn: conn} do
      {:ok, view, _html} = live_home(conn)

      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "not-an-email"}})

      assert has_element?(view, "#signup-error")
      assert view |> element("#signup-error") |> render() =~ "valid email"
      refute has_element?(view, "#signups")
      assert view |> element("#stat-signups") |> render() =~ "0"
    end

    test "duplicate email shows an error and is not added twice", %{conn: conn} do
      {:ok, view, _html} = live_home(conn)

      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "ada@example.com"}})
      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "ada@example.com"}})

      assert view |> element("#signup-error") |> render() =~ "already"
      assert view |> element("#stat-signups") |> render() =~ "1"
      signups_html = view |> element("#signups") |> render()
      assert signups_html =~ "ada@example.com"
    end
  end

  describe "stats strip" do
    test "shows zeroed stats on mount", %{conn: conn} do
      {:ok, _view, html} = live_home(conn)

      assert html =~ ~s(id="stats")
      assert html =~ ~s(id="stat-signups")
      assert html =~ ~s(id="stat-ticks")
    end
  end
end

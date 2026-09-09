defmodule BenchappWeb.HomeLiveTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  # Drive the timer deterministically in tests: the real 5-second
  # interval is exercised by the browser-facing behavior, while here we
  # send the same :tick message the timer sends.
  defp tick(view) do
    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    view
  end

  defp items(html, selector) do
    html
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(selector)
    |> Enum.to_list()
  end

  test "renders the landing hero and nav", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert has_element?(view, "#main-nav")
    assert has_element?(view, "nav a[aria-current=page]", "Home")
    assert has_element?(view, "#countdown", "100")
    assert has_element?(view, "#theme-toggle")
    assert html =~ "Nimbus"
  end

  test "countdown starts at 100 and decreases by 1 per tick", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#countdown", "100")

    assert tick(view) |> has_element?("#countdown", "99")
    assert tick(view) |> has_element?("#countdown", "98")
  end

  test "stats strip reflects live state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stat-signups", "0")
    assert has_element?(view, "#stat-ticks", "0")

    tick(view)
    assert has_element?(view, "#stat-ticks", "1")

    render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "a@example.com"}})
    assert has_element?(view, "#stat-signups", "1")
    assert has_element?(view, "#stat-ticks", "1")
  end

  describe "newsletter signup" do
    test "valid email is added without reload", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "ada@example.com"}})

      assert has_element?(view, "#signups li", "ada@example.com")
    end

    test "invalid email shows an error and is not added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "not-an-email"}})

      assert has_element?(view, "#signup-error", "valid email")
      assert render(element(view, "#signups")) |> items("li") |> Enum.empty?()
    end

    test "duplicate email shows an error and is not added twice", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "ada@example.com"}})
      render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "ada@example.com"}})

      assert has_element?(view, "#signup-error", "already")
      assert length(render(element(view, "#signups")) |> items("li")) == 1
    end
  end

  test "activity feed records signups and ticks, newest first, capped at 10", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    render_submit(element(view, "#signup-form"), %{"signup" => %{"email" => "ada@example.com"}})
    tick(view)

    entries = render(element(view, "#activity")) |> items("li")
    assert length(entries) == 2
    assert entries |> hd() |> LazyHTML.text() =~ "ticked"

    for _ <- 1..12, do: tick(view)
    assert length(render(element(view, "#activity")) |> items("li")) == 10
  end
end

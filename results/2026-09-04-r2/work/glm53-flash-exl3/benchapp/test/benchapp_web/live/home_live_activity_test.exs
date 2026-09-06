defmodule BenchappWeb.HomeLiveActivityTest do
  use BenchappWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  setup do
    Benchapp.Signups.reset!()
    :ok
  end

  test "feed renders <li> entries, newest first", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form", signup: %{email: "linus@example.com"})
    |> render_submit()

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    html = render(view)
    doc = LazyHTML.from_fragment(html)
    labels = doc |> LazyHTML.filter("#activity li") |> Enum.map(&LazyHTML.text(&1))

    assert length(labels) >= 2
    assert hd(labels) =~ "ticked"
    assert Enum.any?(labels, &(&1 =~ "linus@example.com"))
  end

  test "feed is capped at 10 entries", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..12, do: send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    doc = LazyHTML.from_fragment(render(view))
    entries = LazyHTML.filter(doc, "#activity li")

    assert length(entries) == 10
  end

  test "a signup adds one entry to the feed", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    before =
      render(view)
      |> LazyHTML.from_fragment()
      |> LazyHTML.filter("#activity li")
      |> length()

    view
    |> form("#signup-form", signup: %{email: "marie@example.com"})
    |> render_submit()

    _ = :sys.get_state(view.pid)

    after_html =
      render(view)
      |> LazyHTML.from_fragment()
      |> LazyHTML.filter("#activity li")
      |> length()

    assert after_html == before + 1
    assert has_element?(view, "#activity li", "marie@example.com joined the beta")
  end
end

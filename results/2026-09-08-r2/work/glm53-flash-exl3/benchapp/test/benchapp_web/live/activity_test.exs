defmodule BenchappWeb.HomeLive.ActivityTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "activity entries are newest first, one per signup and per tick, capped at 10", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#signup-form")
    |> render_submit(%{signup: %{email: "ada@example.com"}})

    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    html = view |> element("#activity") |> render()
    assert count_li(html) == 2

    # newest first: the tick entry precedes the earlier signup entry
    assert html =~ ~r/tick-1.*signup-1/s

    # cap at 10 entries
    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)
    send(view.pid, :tick)
    _ = :sys.get_state(view.pid)

    Enum.each(1..12, fn n ->
      view
      |> element("#signup-form")
      |> render_submit(%{signup: %{email: "user#{n}@example.com"}})
    end)

    assert count_li(view |> element("#activity") |> render()) == 10
    assert has_element?(view, "#activity li", "user12@example.com")
  end

  defp count_li(html), do: length(Regex.scan(~r/<li/, html))
end

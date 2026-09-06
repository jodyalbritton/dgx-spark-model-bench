defmodule BenchappWeb.LaunchHelpers do
  @moduledoc """
  Shared drivers and readers for the launch-board tests.

  The countdown runs on a five-second `Process.send_after/3`, which no test
  should wait on: `beat/2` sends the message that timer would have sent and
  syncs on the process, so the next read sees every beat.

  Reads go through `LazyHTML` over `render/1`, because
  `Phoenix.LiveViewTest` gives you `element/2` and `has_element?/2` but no
  "every match" or "this node's text" helper. Note `LazyHTML.query/2` is the
  searching function — `filter/2` narrows nodes you already hold and matches
  nothing from a document root. Selectors are keyed to the ids the page
  publishes (`#countdown`, `#stat-signups-value`, `#activity > li`), so prose
  edits never break a test and an entry that isn't an `<li>` cannot slip in.
  """

  import Phoenix.LiveViewTest, only: [render: 1, element: 2, render_submit: 2, render_change: 2]

  @doc "Steps the countdown `times` beats and returns the re-rendered page."
  def beat(view, times \\ 1) do
    Enum.each(1..times, fn _ -> send(view.pid, :beat) end)
    # Confirms the LiveView has processed every beat before we read it back.
    _ = :sys.get_state(view.pid)
    render(view)
  end

  @doc "Submits `email` through `#signup-form` and returns the rendered page."
  def signup(view, email) do
    view |> element("#signup-form") |> render_submit(%{"signup" => %{"email" => email}})
  end

  @doc "Drives `phx-change` on `#signup-form`."
  def type_email(view, email) do
    view |> element("#signup-form") |> render_change(%{"signup" => %{"email" => email}})
  end

  @doc "The bare number inside `#countdown`."
  def countdown(view), do: text(view, "#countdown")

  @doc "The bare reading inside a stats tile, e.g. `reading(view, \"stat-signups\")`."
  def reading(view, id), do: text(view, "##{id}-value")

  @doc "Collapsed text of the first node matching `selector`, or `nil`."
  def text(view, selector) do
    case first(view, selector) do
      nil -> nil
      node -> node |> LazyHTML.text() |> collapse()
    end
  end

  @doc "How many nodes match `selector`."
  def count(view, selector) do
    view |> document() |> LazyHTML.query(selector) |> Enum.count()
  end

  @doc "Text of every row in a feed, in DOM order (newest first)."
  def feed(view, id) do
    view
    |> document()
    |> LazyHTML.query("##{id} > li")
    |> Enum.map(&(&1 |> LazyHTML.text() |> collapse()))
  end

  @doc """
  The email field's `value`. An empty field renders no `value` attribute, so
  a cleared form reads back as `""`.
  """
  def email_field_value(view) do
    case first(view, "#signup-form input[type=email]") do
      nil -> nil
      input -> attribute(input, "value") || ""
    end
  end

  defp first(view, selector) do
    view |> document() |> LazyHTML.query(selector) |> Enum.at(0, nil)
  end

  defp document(view), do: view |> render() |> LazyHTML.from_fragment()

  defp attribute(node, name) do
    case LazyHTML.attribute(node, name) do
      [] -> nil
      [value | _] when is_binary(value) -> value
      value when is_binary(value) -> value
    end
  end

  defp collapse(text), do: text |> String.replace(~r/\s+/u, " ") |> String.trim()
end

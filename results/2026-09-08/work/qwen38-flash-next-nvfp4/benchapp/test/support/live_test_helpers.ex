defmodule BenchappWeb.LiveTestHelpers do
  @moduledoc """
  Shared helpers for the landing page's LiveView tests: waiting on the
  countdown's real timer, and reading the page back through the element ids
  the components declare.

  `Phoenix.LiveViewTest` has no "text of every match" API, and this build of
  `LazyHTML` only queries whole documents, so `texts/2` scans the rendered
  HTML for the id-scoped region it needs. The ids are the contract; that is
  why the components carry them.
  """
  import ExUnit.Assertions, only: [flunk: 1]
  import Phoenix.LiveViewTest

  @doc """
  Polls `view` until `matcher` accepts it, then returns the latest render.

  The countdown is a plain `Process.send_after` at five seconds and the
  interval is the same in `:test` on purpose (see `BenchappWeb.HomeLive`),
  and `Phoenix.LiveViewTest` cannot advance a wall-clock timer. A test that
  watches a tick therefore waits for it the way a browser does — bounded, so
  a stopped timer fails the test instead of hanging the suite.
  """
  def await_view(view, matcher, timeout_ms \\ 9_000) do
    deadline = System.monotonic_time(:millisecond) + timeout_ms
    poll(view, matcher, deadline, timeout_ms)
  end

  defp poll(view, matcher, deadline, timeout_ms) do
    html = render(view)

    cond do
      matcher.(html) ->
        html

      System.monotonic_time(:millisecond) >= deadline ->
        flunk(
          "LiveView never reached a matching state within #{timeout_ms}ms — " <>
            "the five-second timer is the usual suspect."
        )

      true ->
        Process.sleep(100)
        poll(view, matcher, deadline, timeout_ms)
    end
  end

  @doc """
  One entry per match: inner text for `#id` or `#id tag`, and the attribute
  string per match for a void tag such as `#signup-form input`.
  """
  def texts(view, selector) do
    view |> render() |> texts_from(selector)
  end

  @doc "Same as `texts/2`, over an already rendered page."
  def texts_from(html, selector) do
    html = IO.iodata_to_binary(html)

    case String.split(selector, " ", parts: 2) do
      ["#" <> id] ->
        html |> container(id) |> visible_texts()

      ["#" <> id, tag] ->
        html
        |> container(id)
        |> matches(tag)

      [tag] ->
        matches(html, tag)

      _ ->
        flunk("texts_from/2 expects a tag, \"#id\", or \"#id tag\", got: #{inspect(selector)}")
    end
  end

  @doc "The `#countdown` figure as an integer."
  def countdown_value(view), do: view |> texts("#countdown") |> hd() |> String.to_integer()

  @doc """
  How many links in `#nav-menu` carry `aria-current="page"`.

  Counted on the container's raw markup — the ids and the ARIA marker are
  what the chrome promises, so this reads them rather than their text.
  """
  def current_marks(view) do
    view
    |> render()
    |> IO.iodata_to_binary()
    |> raw_container("nav-menu")
    |> String.split(~s|aria-current="page"|)
    |> length()
    |> Kernel.-(1)
  end

  @doc "Submits `email` through the pilot-list form."
  def signup(view, email) do
    view |> element("#signup-form") |> render_submit(%{"signup" => %{"email" => email}})
  end

  # The element with this id, up to its own closing tag. No container on this
  # page nests a same-named container, so the non-greedy match is exact.
  defp container(html, id) do
    case Regex.run(
           ~r/<([a-z0-9]+)[^>]*\bid="#{Regex.escape(id)}"[^>]*>(.*?)<\/\1>/s,
           html
         ) do
      [_, _tag, inner] -> inner
      _ -> ""
    end
  end

  # Same slice as `container/2`, but with the tags left on.
  defp raw_container(html, id) do
    case Regex.run(
           ~r/<([a-z0-9]+)[^>]*\bid="#{Regex.escape(id)}"[^>]*>(.*?)<\/\1>/s,
           html
         ) do
      [_, _tag, inner] -> inner
      _ -> ""
    end
  end

  @void_tags ~w(input img br hr)

  defp matches(inner, tag) when tag in @void_tags do
    Regex.scan(~r/<#{tag}\b([^>]*)>/, inner) |> Enum.map(&(&1 |> Enum.at(1) |> String.trim()))
  end

  defp matches(inner, tag) do
    Regex.scan(~r/<#{tag}\b[^>]*>(.*?)<\/#{tag}>/s, inner)
    |> Enum.map(&(&1 |> Enum.at(1) |> strip()))
  end

  defp visible_texts(inner), do: [strip(inner)]

  defp strip(html) do
    html
    |> String.replace(~r/<[^>]*>/s, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end

defmodule BenchappWeb.ViewHTML do
  @moduledoc """
  Small LazyHTML-backed helpers for asserting on LiveView output without
  matching raw HTML strings. Uses `LazyHTML.query/2` so selectors match
  nested elements (LazyHTML's `filter/2` only narrows the current node
  set).
  """

  @doc "Trimmed visible text of the (single) element matching `selector`."
  def text(rendered_html, selector) do
    rendered_html
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(selector)
    |> LazyHTML.text()
    |> String.trim()
  end

  @doc "Number of elements matching `selector`."
  def count(rendered_html, selector) do
    rendered_html
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(selector)
    |> Enum.count()
  end

  @doc "True when the element matching `selector` is present."
  def present?(rendered_html, selector) do
    count(rendered_html, selector) > 0
  end
end

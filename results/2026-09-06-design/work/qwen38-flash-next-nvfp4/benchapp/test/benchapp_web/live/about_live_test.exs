defmodule BenchappWeb.AboutLiveTest do
  @moduledoc "Render tests for the about page."
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    {:ok, view, html} = live(conn, "/about")
    {:ok, view: view, html: html, doc: LazyHTML.from_fragment(html)}
  end

  test "says who JobyCorp is", %{view: view} do
    assert render(element(view, "h1")) =~ "local"
    assert render(view) =~ "local AI research company"
  end

  test "says why the work is shared", %{view: view} do
    assert render(view) =~ "Why the work is shared"
    assert render(view) =~ "publish"
  end

  test "carries a figure, not only prose", %{doc: doc} do
    sheet = LazyHTML.query(doc, "[data-component='BenchappWeb.CompositeComponents.spec_sheet']")

    assert Enum.count(LazyHTML.query(sheet, "div")) >= 4
    assert sheet |> LazyHTML.text() |> String.trim() =~ "what we run"
  end

  test "points back at the research", %{view: view} do
    assert has_element?(view, "main a[href='/research']")
  end

  test "carries no generator demo copy", %{html: html} do
    refute html =~ "built with"
    refute html =~ "/design"
  end
end

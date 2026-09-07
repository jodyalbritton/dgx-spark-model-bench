defmodule BenchappWeb.ResearchLiveTest do
  @moduledoc "Render tests for the research page."
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    {:ok, view, html} = live(conn, "/research")
    {:ok, view: view, html: html, doc: LazyHTML.from_fragment(html)}
  end

  test "opens on what the page is for", %{view: view} do
    assert render(element(view, "h1")) =~ "How we test"
  end

  test "shows a record card beside the fields it carries", %{doc: doc} do
    card = LazyHTML.query(doc, "#research-record")

    assert [data_component] = LazyHTML.attribute(card, "data-component")
    assert data_component == "BenchappWeb.CompositeComponents.record_card"
    assert card |> LazyHTML.text() |> String.trim() =~ "prompt set"
    assert card |> LazyHTML.text() |> String.trim() =~ "repeats"
  end

  test "sets out the method as a sequence and the publication as a figure", %{view: view} do
    assert render(view) =~ "1. Pin the setup"
    assert render(view) =~ "5. Publish the record"
    assert has_element?(view, "#publications")
    assert has_element?(view, "table tbody tr", "limits")
  end

  test "hands the visitor on to the company behind it", %{view: view} do
    assert has_element?(view, "main a[href='/about']")
  end

  test "invents no results", %{html: html} do
    refute html =~ "tokens/s*"
    refute html =~ "99.9"
    refute html =~ "/design"
  end
end

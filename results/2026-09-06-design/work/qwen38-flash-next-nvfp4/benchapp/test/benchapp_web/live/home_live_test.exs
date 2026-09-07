defmodule BenchappWeb.HomeLiveTest do
  @moduledoc "Render tests for the landing page."
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    {:ok, view: view, html: html, doc: LazyHTML.from_fragment(html)}
  end

  test "states what JobyCorp does in one sentence", %{view: view} do
    assert render(element(view, "h1")) =~ "local language models"
    assert render(element(view, "h1")) =~ "publish every"
  end

  test "puts a record card beside the statement", %{doc: doc} do
    card = LazyHTML.query(doc, "#hero-record")

    assert [data_component] = LazyHTML.attribute(card, "data-component")
    assert data_component == "BenchappWeb.CompositeComponents.record_card"
    assert card |> LazyHTML.text() |> String.trim() =~ "ttft"
    assert card |> LazyHTML.text() |> String.trim() =~ "tokens/s"
  end

  test "shows what a run measures and what it runs on", %{view: view, html: html} do
    assert has_element?(view, "#measures")
    assert html =~ "power at wall"
    assert html =~ "Local models, local hardware"
  end

  test "closes by inviting the visitor to read the research", %{view: view} do
    assert has_element?(view, "a[href='/research']")
    assert has_element?(view, "main a[href='/research']", "How JobyCorp tests")
  end

  test "carries no generator demo copy", %{html: html} do
    refute html =~ "built with"
    refute html =~ "/design"
    refute html =~ "Custom Designs"
  end
end

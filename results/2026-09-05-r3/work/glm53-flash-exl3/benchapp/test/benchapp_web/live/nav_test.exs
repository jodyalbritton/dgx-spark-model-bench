defmodule BenchappWeb.NavTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "main-nav" do
    test "marks the current page with aria-current on the home page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      current =
        view
        |> element("#main-nav")
        |> render()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query(~s(a[aria-current="page"]))
        |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))

      assert Enum.uniq(current) == ["Home"]
    end

    test "marks Design as current on /design", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/design")

      current =
        view
        |> element("#main-nav")
        |> render()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query(~s(a[aria-current="page"]))
        |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))

      assert Enum.uniq(current) == ["Design"]
    end

    test "provides the mobile toggle and the theme toggle", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      toggle =
        view
        |> element("#nav-toggle")
        |> render()
        |> LazyHTML.from_fragment()

      assert LazyHTML.attribute(toggle, "aria-controls") == ["nav-menu"]
      assert LazyHTML.attribute(toggle, "aria-expanded") == ["false"]
      assert has_element?(view, "#nav-menu")
      assert has_element?(view, "#theme-toggle")
    end
  end

  test "home page renders the hero, beta panel, and feature grid", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#hero")
    assert has_element?(view, "#signup-form")
    assert has_element?(view, "#countdown")
    assert has_element?(view, "#activity")
    assert has_element?(view, "[data-component='BenchappWeb.CompositeComponents.feature_grid']")
  end
end

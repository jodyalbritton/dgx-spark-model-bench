defmodule BenchappWeb.HomeLive.SignupTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "a valid email is added to the recent signups without a reload", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#signup-form")
    |> render_submit(%{signup: %{email: "ada@example.com"}})

    assert has_element?(view, "#signups li", "ada@example.com")
    refute has_element?(view, "#signup-error")
  end

  test "an invalid email shows an error and is not added", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#signup-form")
    |> render_submit(%{signup: %{email: "not-an-email"}})

    assert has_element?(view, "#signup-error")
    refute has_element?(view, "#signups li")
  end

  test "a duplicate email shows an error and is not added twice", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#signup-form")
    |> render_submit(%{signup: %{email: "ada@example.com"}})

    view
    |> element("#signup-form")
    |> render_submit(%{signup: %{email: "ada@example.com"}})

    assert has_element?(view, "#signup-error")
    assert has_element?(view, "#signups li", "ada@example.com")
    assert length(Regex.scan(~r/<li/, view |> element("#signups") |> render())) == 1
  end

  test "signup updates the stats strip and logs an activity entry", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#signup-form")
    |> render_submit(%{signup: %{email: "grace@example.com"}})

    assert element(view, "#stat-signups") |> render() =~ "1"
    assert has_element?(view, "#activity li", "grace@example.com joined the launch list")
  end
end

defmodule BenchappWeb.HomeLiveSignupTest do
  use BenchappWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  setup do
    Benchapp.Signups.reset!()
    :ok
  end

  test "shows an error for an invalid email", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    html =
      view
      |> form("#signup-form", signup: %{email: "not-an-email"})
      |> render_submit()

    assert html =~ "has invalid format"
    assert Benchapp.Signups.signup_count() == 0
  end

  test "adds a valid email to the signups list without a reload", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view
           |> form("#signup-form", signup: %{email: "ada@example.com"})
           |> render_submit() =~ "ada@example.com"

    assert has_element?(view, "#signups li", "ada@example.com")
    assert Benchapp.Signups.signup_count() == 1
  end

  test "rejects a duplicate email", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form", signup: %{email: "ada@example.com"})
    |> render_submit()

    html =
      view
      |> form("#signup-form", signup: %{email: "ada@example.com"})
      |> render_submit()

    assert html =~ "Already signed up"
    assert Benchapp.Signups.signup_count() == 1
  end
end

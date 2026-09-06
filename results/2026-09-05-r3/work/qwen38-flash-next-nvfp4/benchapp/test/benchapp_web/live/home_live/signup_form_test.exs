defmodule BenchappWeb.HomeLive.SignupFormTest do
  @moduledoc """
  The crew manifest: one email field, a refusal that shows up in
  `#signup-error`, and a list that grows without a reload.
  """
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import BenchappWeb.LaunchHelpers

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/?tick_ms=60000")
    {:ok, view: view}
  end

  test "the form exposes exactly one email input and defers to the server", %{view: view} do
    assert has_element?(view, "#signup-form")
    assert count(view, "#signup-form input") == 1
    assert has_element?(view, "#signup-form input[type=email]")

    # Without `novalidate` the browser blocks a malformed address before it
    # reaches the LiveView, and `#signup-error` could never appear.
    assert has_element?(view, "#signup-form[novalidate]")
  end

  test "a valid address joins the manifest in place", %{view: view} do
    signup(view, "ada@flightdeck.dev")

    assert count(view, "#signups > li") == 1
    assert view |> feed("signups") |> hd() =~ "ada@flightdeck.dev"
    refute has_element?(view, "#signup-error")
    assert reading(view, "stat-signups") == "1"
  end

  test "the field is cleared after a seat is taken", %{view: view} do
    signup(view, "ada@flightdeck.dev")
    assert email_field_value(view) == ""
  end

  test "a malformed address is refused and joins nothing", %{view: view} do
    signup(view, "not-an-email")

    assert has_element?(view, "#signup-error")
    assert text(view, "#signup-error") != ""
    assert count(view, "#signups > li") == 0
    assert reading(view, "stat-signups") == "0"
    assert email_field_value(view) == "not-an-email"
  end

  test "a blank address is refused", %{view: view} do
    signup(view, "")

    assert has_element?(view, "#signup-error")
    assert count(view, "#signups > li") == 0
    assert reading(view, "stat-signups") == "0"
  end

  test "the same address twice is refused and stored once", %{view: view} do
    signup(view, "ada@flightdeck.dev")
    signup(view, "ada@flightdeck.dev")

    assert has_element?(view, "#signup-error")
    assert count(view, "#signups > li") == 1
    assert reading(view, "stat-signups") == "1"
  end

  test "case and padding do not buy a second seat", %{view: view} do
    signup(view, "ada@flightdeck.dev")
    signup(view, "  ADA@flightdeck.DEV ")

    assert has_element?(view, "#signup-error")
    assert count(view, "#signups > li") == 1
    assert view |> feed("signups") |> hd() =~ "ada@flightdeck.dev"
  end

  test "typing clears the standing error", %{view: view} do
    signup(view, "not-an-email")
    assert has_element?(view, "#signup-error")

    type_email(view, "grace@flightdeck.dev")
    refute has_element?(view, "#signup-error")
  end

  test "each accepted address also logs a flight-log row", %{view: view} do
    signup(view, "ada@flightdeck.dev")
    signup(view, "grace@flightdeck.dev")

    assert count(view, "#activity > li") == 2
    assert view |> feed("activity") |> hd() =~ "grace@flightdeck.dev"
  end
end

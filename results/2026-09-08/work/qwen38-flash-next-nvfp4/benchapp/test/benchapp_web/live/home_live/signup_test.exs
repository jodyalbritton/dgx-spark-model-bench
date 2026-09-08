defmodule BenchappWeb.HomeLive.SignupTest do
  @moduledoc """
  The pilot-list form: `#signup-form`, one email input, `#signup-error` for
  rejections, and `#signups` for the list that grows in place.
  """
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.LiveTestHelpers
  import Phoenix.LiveViewTest

  test "the form holds exactly one email input", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#signup-form")
    assert has_element?(view, ~S|#signup-form input[type="email"]|)
    assert length(texts(view, "#signup-form input")) == 1
  end

  test "an invalid address is refused with an error and adds nothing", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    signup(view, "nope-not-an-email")

    assert has_element?(view, "#signup-error")
    assert texts(view, "#signup-error") |> hd() =~ "email address"
    assert texts(view, "#signups li") == []
  end

  test "a valid address joins the recent list without a reload", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert texts(view, "#signups li") == []

    signup(view, "ada@lab.org")

    assert texts(view, "#signups li") == ["ada@lab.org"]
    refute has_element?(view, "#signup-error")
    assert has_element?(view, "#signup-form")
  end

  test "the same address twice is refused and stored once", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    signup(view, "ada@lab.org")
    signup(view, "ada@lab.org")

    assert texts(view, "#signups li") == ["ada@lab.org"]
    assert texts(view, "#signup-error") |> hd() =~ "already"
  end

  test "case and surrounding spaces do not make a second signup", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    signup(view, "Ada@Lab.org")
    signup(view, "  ada@lab.org  ")

    assert texts(view, "#signups li") == ["ada@lab.org"]
    assert has_element?(view, "#signup-error")
  end

  test "several addresses stack newest first", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    signup(view, "first@lab.org")
    signup(view, "second@lab.org")
    signup(view, "third@lab.org")

    assert texts(view, "#signups li") == ["third@lab.org", "second@lab.org", "first@lab.org"]
  end
end

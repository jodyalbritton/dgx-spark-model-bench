defmodule BenchappWeb.HomeLiveSignupTest do
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias BenchappWeb.HomeLiveSignupTest.Helpers

  test "a valid email is added to the recent signups list without a reload", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "hiker@example.com"}})

    assert view |> has_element?("#signups li", "hiker@example.com")
    assert view |> element("#stat-signups") |> render() =~ "1"

    # one activity entry for the signup
    assert view |> has_element?("#activity li", "hiker@example.com requested beta access")

    # form resets and no error is shown
    assert view |> element("#signup-form input") |> render() =~ ~s(value="")
    refute view |> has_element?("#signup-error")
  end

  test "an invalid email shows an error and is not added", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "not-an-email"}})

    assert view |> has_element?("#signup-error", "email address")
    assert Helpers.emails(view) == []
    assert view |> element("#stat-signups") |> render() =~ "0"
    refute view |> has_element?("#activity li", "not-an-email")
  end

  test "an empty email shows an error and is not added", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => ""}})

    assert view |> has_element?("#signup-error")
    assert Helpers.emails(view) == []
  end

  test "the same address submitted twice shows the error and is not added again", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "hiker@example.com"}})

    view
    |> form("#signup-form")
    |> render_submit(%{"signup" => %{"email" => "hiker@example.com"}})

    assert view |> has_element?("#signup-error", "already on the list")
    assert view |> element("#stat-signups") |> render() =~ "1"
    assert Helpers.emails(view) |> Enum.count(&(&1 == "hiker@example.com")) == 1
  end

  defmodule Helpers do
    @moduledoc false
    import Phoenix.LiveViewTest

    @doc "Text of each signup `<li>` (stream children of `#signups`)."
    def emails(view) do
      view
      |> element("#signups")
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query(~s(li[data-phx-stream]))
      |> Enum.map(&li_text/1)
    end

    defp li_text(li), do: li |> LazyHTML.text() |> String.trim()
  end
end

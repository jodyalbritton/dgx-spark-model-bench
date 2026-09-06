defmodule BenchappWeb.HomeLive.SignupTest do
  use BenchappWeb.ConnCase, async: true

  import BenchappWeb.ViewHTML

  defp submit(view, email) do
    view
    |> element("#signup-form")
    |> render_submit(%{"signup" => %{"email" => email}})
  end

  test "renders one email input", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#signup-form input[type=email]")
  end

  test "valid email is added to recent signups without a reload", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute present?(render(view), "#signup-error")

    submit(view, "ada@example.com")

    html = render(view)
    refute present?(html, "#signup-error")
    assert text(html, "#signups li[data-signup]") =~ "ada@example.com"
    assert count(html, "#signups li[data-signup]") == 1
  end

  test "invalid email shows an error and is not added", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    submit(view, "not-an-email")

    html = render(view)
    assert present?(html, "#signup-error")
    assert text(html, "#signup-error") != ""
    assert count(html, "#signups li[data-signup]") == 0
  end

  test "submitting the same address twice shows an error and is not duplicated", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    submit(view, "grace@example.com")
    assert count(render(view), "#signups li[data-signup]") == 1

    submit(view, "grace@example.com")

    html = render(view)
    assert present?(html, "#signup-error")
    assert count(html, "#signups li[data-signup]") == 1
  end

  test "error clears once a valid address is submitted", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    submit(view, "broken")
    assert present?(render(view), "#signup-error")

    submit(view, "lin@example.com")
    refute present?(render(view), "#signup-error")
  end
end

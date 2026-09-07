defmodule BenchappWeb.SiteChromeTest do
  @moduledoc """
  The chrome every page shares: the navigation bar, its phone toggle, the
  theme control, and the footer. Checked on all three pages, because the
  nav's current-page marking has to be right on each of them.
  """
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "every page carries the bar, its toggle, and the theme control" do
    for {path, label} <- pages() do
      {:ok, view, html} = live(build_conn(), path)
      doc = LazyHTML.from_fragment(html)

      assert has_element?(view, "#main-nav"), "#{path} has no nav"
      assert has_element?(view, "#nav-toggle"), "#{path} has no nav toggle"
      assert has_element?(view, "#theme-toggle"), "#{path} has no theme toggle"

      # the bar and the folded phone menu both mark this page current
      for menu <- ["#nav-links", "#nav-links-phone"] do
        marked = LazyHTML.query(doc, "#{menu} [aria-current='page']")

        assert marked |> LazyHTML.text() |> String.trim() == label,
               "#{path} marks the wrong link current in #{menu}"
      end
    end
  end

  test "the phone menu starts folded and the toggle points at it", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    doc = LazyHTML.from_fragment(html)

    assert [classes | _] = LazyHTML.attribute(LazyHTML.query(doc, "#nav-links-phone"), "class")
    assert classes =~ "hidden"
    assert Enum.count(LazyHTML.query(doc, "#nav-toggle")) == 1
    assert has_element?(view, "#nav-links-phone a[href='/research']")
  end

  test "no page links to the design catalogue" do
    for {path, _label} <- pages() do
      {:ok, _view, html} = live(build_conn(), path)
      refute html =~ "/design", path
      refute html =~ "/custom-designs", path
      refute html =~ "design.json", path
    end
  end

  test "the footer belongs to JobyCorp and says what it does", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    footer = view |> element("footer") |> render()

    assert footer =~ "JobyCorp"
    assert footer =~ "publishes the"
    assert footer =~ "results in full"
    refute footer =~ "built with"
    refute footer =~ "JobyKit"
    assert has_element?(view, "footer a[href='/research']")
  end

  defp pages, do: [{"/", "Home"}, {"/research", "Research"}, {"/about", "About"}]
end

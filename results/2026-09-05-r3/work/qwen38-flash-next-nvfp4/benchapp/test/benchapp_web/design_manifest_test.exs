defmodule BenchappWeb.DesignManifestTest do
  @moduledoc """
  The wrapper contract for the composites this app added: registered,
  carrying `data-component` and `attr :rest, :global`, previewed, and
  rendered on the component page.
  """
  use BenchappWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias BenchappWeb.{ChromeComponents, CompositeComponents, DesignManifest}

  @composites [
    {CompositeComponents, :feature_card},
    {CompositeComponents, :card_grid},
    {CompositeComponents, :stat_tile},
    {CompositeComponents, :feed_row},
    {CompositeComponents, :empty_state},
    {ChromeComponents, :site_nav},
    {ChromeComponents, :theme_switch},
    {ChromeComponents, :site_footer}
  ]

  @feature_card ~S|[data-component="BenchappWeb.CompositeComponents.feature_card"]|

  test "every composite this app uses is registered as a composite" do
    registered = DesignManifest.entries() |> Enum.map(&{&1.module, &1.function})

    for composite <- @composites do
      assert composite in registered, "#{inspect(composite)} is missing from DesignManifest"

      entry = DesignManifest.fetch(elem(composite, 0), elem(composite, 1))
      assert entry.category == :composite

      assert entry.data_component ==
               "#{inspect(elem(composite, 0))}.#{elem(composite, 1)}"
    end
  end

  test "every registered wrapper accepts global pass-through" do
    for {module, function} <- @composites do
      attrs = module.__components__()[function].attrs

      assert Enum.any?(attrs, &(&1.name == :rest and &1.type == :global)),
             "#{inspect(module)}.#{function}/1 cannot pass id/class/aria-* through"
    end
  end

  test "the feature grid's composite ships a design preview" do
    entry = DesignManifest.fetch(CompositeComponents, :feature_card)
    assert is_function(entry.preview, 1)
    assert %Phoenix.LiveView.Rendered{} = entry.preview.(%{})
  end

  test "the component page renders the composite and its preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/custom-designs")

    assert page_title(view) =~ "Custom Designs"
    assert has_element?(view, "#custom-designs-page")
    assert has_element?(view, "#custom-designs-page #{@feature_card}")
  end

  test "the kit page is untouched and still renders", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/design")

    assert page_title(view) =~ "Design System"
    assert has_element?(view, "#design-system-page")

    assert has_element?(view, ~S|[data-component="JobyKit.CoreComponents.card"]|)

    refute has_element?(
             view,
             "#design-system-page #{@feature_card}"
           )
  end

  test "the manifest endpoint serves the new composites" do
    conn = get(build_conn(), ~p"/design.json")
    body = json_response(conn, 200)
    served = Enum.map(body["components"], & &1["data_component"])

    assert "BenchappWeb.CompositeComponents.feature_card" in served
    assert "BenchappWeb.ChromeComponents.site_nav" in served
  end
end

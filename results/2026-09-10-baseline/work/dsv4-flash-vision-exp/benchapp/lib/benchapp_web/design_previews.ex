defmodule BenchappWeb.DesignPreviews do
  @moduledoc """
  Preview functions for **this app's** components, referenced by
  `BenchappWeb.DesignManifest`.

  The kit's own components are previewed by `JobyKit.Previews`, so
  `/design` shows the same examples in every JobyKit app. You only write
  previews for what you add.

  Each public function takes `assigns` (typically `%{}`) and returns a
  small HEEx rendering the component with sensible defaults. The
  manifest registers these via `preview: &BenchappWeb.DesignPreviews.X_preview/1`,
  and `JobyKit.SignatureComponent` invokes them inside the per-component
  card's collapsible Preview section.

  Naming convention: every preview function ends in `_preview` so they
  don't collide with the imported component functions of the same name
  (e.g. `button` vs `button_preview`).

  The previews call `JobyKit.CoreComponents` directly via the
  `CoreComponents` alias so the rendered HTML matches what the manifest
  declares — no dependency on the host's `<App>Web.CoreComponents`
  resolution.
  """

  use BenchappWeb, :html

  alias BenchappWeb.CompositeComponents

  def composite_preview(assigns) do
    ~H"""
    <div class="grid gap-6">
      <CompositeComponents.container class="!py-4">
        <div class="space-y-4">
          <CompositeComponents.section
            class="!border-t-0"
            running_head="measurements"
            heading="What a run measures"
          >
            <CompositeComponents.prose>
              The heading, running head, and body arrived together from one composite.
            </CompositeComponents.prose>
          </CompositeComponents.section>

          <CompositeComponents.two_column>
            <:content>
              <div class="space-y-3">
                <CompositeComponents.mono_label>content</CompositeComponents.mono_label>
                <CompositeComponents.prose>
                  Two columns: reading on the left, the figure on the right.
                </CompositeComponents.prose>
              </div>
            </:content>
            <:figure>
              <CompositeComponents.record_card
                title="run record"
                rows={[
                  %{field: "model", unit: "identifier"},
                  %{field: "throughput", unit: "tokens / s"},
                  %{field: "latency", unit: "ms / token"}
                ]}
              >
                <:caption>Field names and units only.</:caption>
              </CompositeComponents.record_card>
            </:figure>
          </CompositeComponents.two_column>
        </div>
      </CompositeComponents.container>
    </div>
    """
  end
end

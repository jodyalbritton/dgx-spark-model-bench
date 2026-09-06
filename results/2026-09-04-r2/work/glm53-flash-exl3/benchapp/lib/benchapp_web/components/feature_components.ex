defmodule BenchappWeb.FeatureComponents do
  @moduledoc """
  Domain composites for LumenLab. Registered in
  `BenchappWeb.DesignManifest` with `category: :domain`, so they surface
  on `/custom-designs` and carry a preview on `/design`.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @doc """
  A responsive feature grid: an eyebrow + heading + optional lede above a
  grid of feature cards.

      <.feature_grid title="Everything in the box">
        <:feature icon="hero-bolt" title="Realtime first">
          Every number on the page is live, not a screenshot.
        </:feature>
      </.feature_grid>
  """
  attr :id, :string, default: nil
  attr :eyebrow, :string, default: nil
  attr :title, :string, required: true
  attr :lede, :string, default: nil
  attr :columns, :integer, values: [2, 3, 4], default: 3
  attr :class, :any, default: nil
  attr :rest, :global

  slot :feature, required: true do
    attr :icon, :string, required: true
    attr :title, :string, required: true
  end

  def feature_grid(assigns) do
    ~H"""
    <section
      data-component="BenchappWeb.FeatureComponents.feature_grid"
      id={@id}
      class={["space-y-8", @class]}
      {@rest}
    >
      <div class="max-w-2xl">
        <p
          :if={@eyebrow}
          class="text-xs font-semibold uppercase tracking-[0.2em] text-primary"
        >
          {@eyebrow}
        </p>
        <h2 class="mt-2 text-3xl font-semibold tracking-tight text-base-content">
          {@title}
        </h2>
        <p :if={@lede} class="mt-3 text-base text-base-content/70">
          {@lede}
        </p>
      </div>

      <div class={[
        "grid gap-4 sm:grid-cols-2",
        @columns == 3 && "lg:grid-cols-3",
        @columns == 4 && "lg:grid-cols-4"
      ]}>
        <div
          :for={feature <- @feature}
          class="group rounded-2xl border border-base-300 bg-base-100 p-6 transition-all duration-200 hover:-translate-y-0.5 hover:border-primary/40 hover:shadow-lg hover:shadow-primary/5"
        >
          <span class="grid size-11 place-items-center rounded-xl bg-primary/10 text-primary transition-colors group-hover:bg-primary group-hover:text-primary-content">
            <CoreComponents.icon name={feature.icon} class="size-5" />
          </span>
          <h3 class="mt-4 font-semibold text-base-content">{feature.title}</h3>
          <div class="mt-1.5 text-sm leading-relaxed text-base-content/70">
            {render_slot(feature)}
          </div>
        </div>
      </div>
    </section>
    """
  end
end

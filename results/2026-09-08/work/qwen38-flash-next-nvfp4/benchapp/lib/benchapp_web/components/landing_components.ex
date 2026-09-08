defmodule BenchappWeb.LandingComponents do
  @moduledoc """
  Domain composites for Tidepool's landing page.

  These are the blocks that mean something only in this product's terms —
  the fleet activity feed, and the live panel that frames it. Anything a
  second product area could reuse belongs in `BenchappWeb.CompositeComponents`
  instead.
  """

  use BenchappWeb, :html

  alias JobyKit.CoreComponents

  @doc """
  The newest-first activity log: one `<li>` per event, capped by the caller.

      <.activity_feed id="activity" entries={@activity} />

  Each entry is `%{id:, kind:, text:}` where `kind` is `:signup` or
  `:tick`, which picks the glyph. The list element itself carries
  `id="activity"`, so `#activity li` is the feed — an empty state renders
  beside it, never inside it, so an entry count stays an entry count.
  """
  attr :entries, :list, required: true, doc: "Maps of `%{id:, kind:, text:}`, newest first."

  attr :class, :any, default: nil
  attr :rest, :global

  def activity_feed(assigns) do
    assigns = assign(assigns, :glyphs, %{signup: "hero-envelope", tick: "hero-arrow-path"})

    ~H"""
    <ul
      data-component="BenchappWeb.LandingComponents.activity_feed"
      class={["divide-y divide-base-300/70", @class]}
      {@rest}
    >
      <li :for={entry <- @entries} id={"activity-" <> entry.id} class="flex items-start gap-3 py-2.5">
        <span class="mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-full bg-base-200 text-base-content/60">
          <CoreComponents.icon name={Map.fetch!(@glyphs, entry.kind)} class="size-3.5" />
        </span>
        <span class="min-w-0 flex-1 text-sm leading-snug text-base-content/80">
          <span class="break-words">{entry.text}</span>
        </span>
        <CoreComponents.badge
          :if={entry.kind == :signup}
          tone="ok"
          size="xs"
          class="mt-0.5 shrink-0"
        >
          new
        </CoreComponents.badge>
      </li>
    </ul>
    """
  end
end

defmodule JobyKit.SignatureComponent do
  @moduledoc """
  Per-component signature card rendered inside the JobyKit design index.

  Takes a single manifest `:entry` (as returned by
  `c:JobyKit.Manifest.entries/0`) and renders the agent-facing card:
  label, data-component identifier, status pills, summary, collapsible
  preview, attrs table, slots list, and source link.

  All structural data attributes (`data-component-signature`,
  `data-module`, `data-function`, `data-data-component`,
  `data-daisy-basis`, `data-attr`, `data-slot`, etc.) are stable so
  scrapers can reliably parse the rendered DOM.
  """

  use Phoenix.Component

  attr :entry, :map, required: true

  def signature_card(assigns) do
    ~H"""
    <article
      id={"jobykit-component-" <> slug(@entry)}
      data-component-signature
      data-module={inspect(@entry.module)}
      data-function={Atom.to_string(@entry.function)}
      data-data-component={@entry.data_component}
      data-daisy-basis={@entry.daisy_basis}
      class="flex flex-col gap-3 rounded-xl border border-base-300/70 bg-base-200/35 p-4"
    >
      <header class="flex flex-wrap items-start justify-between gap-2">
        <div class="min-w-0">
          <p class="text-sm font-semibold text-base-content">{@entry.label}</p>
          <code class="block break-all font-mono text-[0.7rem] text-base-content/60">
            {@entry.data_component}
          </code>
        </div>
        <div :if={@entry.daisy_basis} class="flex shrink-0 flex-wrap gap-1.5">
          <span class="badge badge-info badge-soft">daisy: {@entry.daisy_basis}</span>
        </div>
      </header>

      <p :if={@entry.summary} class="text-xs leading-relaxed text-base-content/75">
        {@entry.summary}
      </p>

      <details
        class="group rounded-lg border border-base-300/60 bg-base-100/70"
        data-component-preview
      >
        <summary class="flex cursor-pointer list-none items-center justify-between rounded-lg px-3 py-2 text-[0.65rem] font-semibold uppercase tracking-[0.18em] text-base-content/55 transition-colors hover:bg-base-200/40 [&::-webkit-details-marker]:hidden">
          <span>Preview</span>
          <span class="hero-chevron-down-mini size-4 text-base-content/55 transition-transform group-open:rotate-180" />
        </summary>
        <div class="px-3 pt-1 pb-3">
          <%= if @entry.preview do %>
            {render_preview(@entry.preview)}
          <% else %>
            <p class="text-xs italic text-base-content/45">
              No canonical preview yet.
            </p>
          <% end %>
        </div>
      </details>

      <dl
        :if={@entry.attrs != []}
        class="grid gap-1.5 rounded-lg border border-base-300/60 bg-base-100/70 p-3 text-[0.72rem]"
      >
        <p class="text-[0.6rem] font-semibold uppercase tracking-[0.18em] text-base-content/45">
          Attrs
        </p>
        <div
          :for={attr <- @entry.attrs}
          data-attr={attr.name}
          data-type={attr.type}
          data-required={if(attr.required, do: "true", else: "false")}
          class="grid grid-cols-[minmax(0,1fr)_auto] items-baseline gap-2"
        >
          <dt class="font-mono text-base-content">
            {attr.name}<span :if={attr.required} class="text-error"> *</span>
          </dt>
          <dd class="min-w-0 text-right text-base-content/65">
            <span class="font-mono">{attr.type}</span>
            <span
              :if={attr.default && not long_default?(attr.default)}
              class="ml-2 font-mono text-base-content/55"
            >
              = {attr.default}
            </span>
          </dd>
          <%!-- A long default (a link list, a capture, a nested map) sized the
          `auto` track past the container and collided with the attr name.
          Give it the full-width treatment `values:` already uses. --%>
          <dd
            :if={attr.default && long_default?(attr.default)}
            class="col-span-2 font-mono text-[0.66rem] break-words text-base-content/55"
          >
            = {attr.default}
          </dd>
          <dd
            :if={attr.values}
            class="col-span-2 font-mono text-[0.66rem] break-words text-base-content/55"
          >
            values: [{Enum.join(attr.values, " | ")}]
          </dd>
        </div>
      </dl>

      <ul
        :if={@entry.slots != []}
        class="grid gap-1 rounded-lg border border-base-300/60 bg-base-100/70 p-3 text-[0.72rem]"
      >
        <p class="text-[0.6rem] font-semibold uppercase tracking-[0.18em] text-base-content/45">
          Slots
        </p>
        <li
          :for={slot <- @entry.slots}
          data-slot={slot.name}
          data-required={if(slot.required, do: "true", else: "false")}
          class="font-mono text-base-content"
        >
          :{slot.name}<span :if={slot.required} class="text-error"> *</span>
        </li>
      </ul>

      <footer class="flex flex-wrap items-center justify-between gap-2 text-[0.7rem] text-base-content/55">
        <span :if={@entry.source} class="font-mono">
          {@entry.source}<span :if={@entry.line}>:{@entry.line}</span>
        </span>
      </footer>
    </article>
    """
  end

  # One broken preview used to take down the whole catalogue: previews are
  # rendered inline, so a `KeyError` from a preview that reads an assign
  # 500s every other component's card along with it. Contain it and say
  # which one failed — the page stays useful and the message points at the
  # preview to fix.
  defp render_preview(fun) when is_function(fun, 1) do
    fun.(%{})
  rescue
    error ->
      assigns = %{message: Exception.message(error)}

      ~H"""
      <p class="text-xs text-error">
        This preview raised: {@message}
      </p>
      """
  end

  defp render_preview(_), do: nil

  # Past this, an inline default competes with the attr name for the row.
  @inline_default_limit 28
  defp long_default?(default), do: String.length(to_string(default)) > @inline_default_limit

  defp slug(%{module: module, function: function}) do
    module
    |> inspect()
    |> String.replace(".", "-")
    |> Kernel.<>("-" <> Atom.to_string(function))
    |> String.downcase()
  end
end

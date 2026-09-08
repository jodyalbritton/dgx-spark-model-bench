defmodule JobyKit.CoreComponents do
  @moduledoc """
  Core wrapper components shipped by JobyKit. Each component:

    * Carries `data-component="JobyKit.CoreComponents.<name>"` on its
      root element.
    * Declares every prop with `attr` (variant/size enums via `values:`).
    * Accepts `attr :rest, :global` so callers can pass id/class/aria-*/
      phx-* through.
    * Composes daisyUI primitives + theme tokens internally; the `class`
      attr (where exposed) is **additive**, layered on top of the
      wrapper's identity classes.

  Hosts register these against `JobyKit.CoreComponents` in their
  manifest:

      component JobyKit.CoreComponents, :button,
        category: :core,
        daisy_basis: "btn",
        summary: "Standard text button.",
        preview: &MyAppWeb.DesignPreviews.button_preview/1

  And expose them by `import`ing this module into their `core_components`
  / `html_helpers` (or `_web.ex`) so call sites can use the `<.button>`
  form.

  ## Components

    * `flash/1`, `flash_group/1` — toast-style flashes
    * `badge/1` — status chip with a semantic tone
    * `button/1` — text/link button with variant, size, and shape
    * `card/1` — content surface with eyebrow/title/actions slots
    * `eyebrow/1` — small uppercase label
    * `header/1` — page or section header
    * `icon/1` — Heroicon span
    * `input/1` — form input (text, email, select, textarea, checkbox…)
    * `list/1` — generic list
    * `modal/1` — server-driven dialog
    * `table/1` — table with col/action slots, stream-aware
    * `theme_toggle/1` — system / light / dark control

  Plus the JS helpers `show/2`, `hide/2`, and the i18n-free
  `translate_error/1`.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  # --------------------------------------------------------------- icon

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles — outline, solid, and mini. Default is
  outline; pass `name="hero-foo-solid"` or `name="hero-foo-mini"` for the
  others. The host must have the Heroicons CSS plugin installed (Phoenix
  ships this by default in `assets/vendor/heroicons.js`).

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"
  attr :rest, :global

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span data-component="JobyKit.CoreComponents.icon" class={[@name, @class]} {@rest} />
    """
  end

  # Without this the caller gets a bare FunctionClauseError pointing at
  # the kit, which says nothing about the actual mistake.
  def icon(%{name: name}) do
    raise ArgumentError, """
    unknown icon #{inspect(name)}.

    `<.icon>` renders Heroicons, whose names start with "hero-". Try
    #{inspect("hero-" <> to_string(name))}, or browse https://heroicons.com.
    """
  end

  # ------------------------------------------------------------- button

  @doc """
  Standard text button. Renders as `<button>` by default, or `<.link>`
  when `href`/`navigate`/`patch` is passed via `:rest`.

      <.button>Send</.button>
      <.button variant="primary" size="sm">Save</.button>
      <.button navigate={~p"/dashboard"}>Home</.button>

  `type` passes through, so a non-submitting button inside a form is
  `<.button type="button">`. Omitted, the browser default applies —
  `submit` inside a form.

  ## Tone

  `variant` carries meaning, not just colour — `danger` is how a
  destructive action reads as destructive:

      <.button variant="danger">Delete workspace</.button>
      <.button variant="ghost">Dismiss</.button>

  The default (`nil`) is the soft-primary treatment, also nameable as
  `soft` when the value is computed at runtime.

  ## Icon-only buttons

  `shape` sizes the button to a single glyph. Always give it an
  accessible name, since there is no text to read:

      <.button shape="circle" variant="ghost" aria-label="Close">
        <.icon name="hero-x-mark" class="size-4" />
      </.button>
  """
  attr :rest, :global,
    include: ~w(href navigate patch method download name value disabled type form)

  attr :class, :any, default: nil

  attr :variant, :string,
    values: ~w(soft primary neutral ghost danger),
    doc: "Tone. Defaults to the soft-primary treatment; `danger` for destructive actions."

  attr :size, :string, values: ~w(xs sm md lg), default: "md", doc: "Control height."

  attr :shape, :string,
    values: ~w(circle square),
    doc: "Square off an icon-only button. Give it an aria-label."

  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    variants = %{
      nil => "btn-primary btn-soft",
      "soft" => "btn-primary btn-soft",
      "primary" => "btn-primary",
      "neutral" => "btn-neutral",
      "ghost" => "btn-ghost",
      "danger" => "btn-error"
    }

    sizes = %{"xs" => "btn-xs", "sm" => "btn-sm", "md" => nil, "lg" => "btn-lg"}
    shapes = %{nil => nil, "circle" => "btn-circle", "square" => "btn-square"}

    assigns =
      assign(assigns, :class_list, [
        "btn",
        Map.fetch!(variants, assigns[:variant]),
        Map.fetch!(sizes, assigns.size),
        Map.fetch!(shapes, assigns[:shape]),
        assigns.class
      ])

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link
        data-component="JobyKit.CoreComponents.button"
        class={@class_list}
        {@rest}
      >
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button data-component="JobyKit.CoreComponents.button" class={@class_list} {@rest}>
        {render_slot(@inner_block)}
      </button>
      """
    end
  end

  # ------------------------------------------------------------ eyebrow

  @doc """
  Small uppercase label that sits above a heading or leads a data pair.

      <.eyebrow>Workspace</.eyebrow>

  This is the most-duplicated string in the fleet: one app carried 326
  hand-typed instances of the same mono-uppercase treatment, with letter
  spacing drifting across nine values and six font sizes because every
  one was written by hand. One definition, one look.

  `card/1` and `header/1` render their `:eyebrow` slots through this, so
  the three stay identical by construction.
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def eyebrow(assigns) do
    ~H"""
    <p
      data-component="JobyKit.CoreComponents.eyebrow"
      class={[
        "text-[0.7rem] font-semibold uppercase tracking-[0.18em] text-base-content/55",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </p>
    """
  end

  # -------------------------------------------------------------- badge

  @badge_tones %{
    "neutral" => "badge-neutral",
    "ok" => "badge-success",
    "warn" => "badge-warning",
    "danger" => "badge-error",
    "info" => "badge-info"
  }

  @doc """
  Status chip with a semantic tone.

      <.badge tone="ok">Healthy</.badge>
      <.badge tone="danger" variant="solid">Failed</.badge>

  `tone` names the *state*, not a colour, so the palette stays consistent
  across apps and themes. It deliberately shares `neutral` and `danger`
  with `button/1` — the same word means the same thing wherever it
  appears.

  This exists because it was missing: one app maintained five separate
  tone-to-class functions mapping the same ok/warn/critical/neutral set
  to border+bg+text triples, and one of them had been copied verbatim
  into a second file — the exact drift the kit's own guidance warns
  about.
  """
  attr :tone, :string,
    values: ~w(neutral ok warn danger info),
    default: "neutral",
    doc: "The state being reported, not a colour."

  attr :variant, :string, values: ~w(soft solid outline), default: "soft"
  attr :size, :string, values: ~w(xs sm md lg), default: "sm"
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def badge(assigns) do
    variants = %{"soft" => "badge-soft", "solid" => nil, "outline" => "badge-outline"}
    sizes = %{"xs" => "badge-xs", "sm" => "badge-sm", "md" => nil, "lg" => "badge-lg"}

    assigns =
      assign(assigns, :class_list, [
        "badge",
        Map.fetch!(@badge_tones, assigns.tone),
        Map.fetch!(variants, assigns.variant),
        Map.fetch!(sizes, assigns.size),
        assigns.class
      ])

    ~H"""
    <span data-component="JobyKit.CoreComponents.badge" class={@class_list} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  # --------------------------------------------------------------- card

  @doc """
  daisyUI card with optional eyebrow, title, and actions slots.

      <.card>
        <:eyebrow>/design</:eyebrow>
        <:title>Kit-curated wrappers</:title>
        Body content goes here.
        <:actions><.button>Open</.button></:actions>
      </.card>

  ## Body content

  The body renders as direct children of `card-body`, so the card's own
  `gap` spaces whatever you put there — no inner wrapper to fight.

  The card takes no opinion on body typography. `prose={true}` opts into
  the muted small-text treatment for cards that really are prose;
  `body_class` sets it yourself.

      <.card prose>Explanatory copy.</.card>
      <.card body_class="text-base">Dense data, styled by the caller.</.card>
  """
  attr :class, :any, default: nil
  attr :body_class, :any, default: nil, doc: "Utilities for the card-body element."

  attr :variant, :string,
    values: ~w(bordered ghost elevated),
    default: "bordered",
    doc: "Surface treatment."

  attr :prose, :boolean,
    default: false,
    doc: "Apply the muted small-text treatment to body content."

  attr :rest, :global

  slot :eyebrow
  slot :title
  slot :actions
  slot :inner_block, required: true

  def card(assigns) do
    variants = %{
      "bordered" => "card-border border-base-300 bg-base-100",
      "ghost" => "border border-base-300/40 bg-base-100/60 backdrop-blur",
      "elevated" => "border border-base-300/60 bg-base-100 shadow-sm"
    }

    assigns = assign(assigns, :variant_class, Map.fetch!(variants, assigns.variant))

    ~H"""
    <article
      data-component="JobyKit.CoreComponents.card"
      class={[
        "card transition-shadow duration-200 hover:shadow-md hover:shadow-base-300/40",
        @variant_class,
        @class
      ]}
      {@rest}
    >
      <div class={[
        "card-body gap-2",
        @prose && "text-sm leading-relaxed text-base-content/70",
        @body_class
      ]}>
        <.eyebrow :if={@eyebrow != []}>{render_slot(@eyebrow)}</.eyebrow>
        <h3 :if={@title != []} class="card-title text-lg font-semibold leading-tight">
          {render_slot(@title)}
        </h3>
        {render_slot(@inner_block)}
        <div :if={@actions != []} class="card-actions">
          {render_slot(@actions)}
        </div>
      </div>
    </article>
    """
  end

  # ------------------------------------------------------------- header

  @doc """
  Page or section header, with optional eyebrow, subtitle, and actions.

      <.header>
        Team settings
        <:eyebrow>Workspace</:eyebrow>
        <:subtitle>Manage members and their permissions.</:subtitle>
        <:actions><.button variant="primary">Invite</.button></:actions>
      </.header>

  `level` picks the heading element so a section header doesn't emit a
  second `<h1>`; `size` picks the type scale independently, and
  `title_class` overrides it outright when the app has its own display
  face. The header carries no outer spacing — the parent owns that.
  """
  attr :class, :any, default: nil
  attr :title_class, :any, default: nil, doc: "Replaces the heading's type scale."
  attr :level, :string, values: ~w(h1 h2 h3), default: "h1"
  attr :size, :string, values: ~w(page section), default: "section"
  attr :rest, :global

  slot :inner_block, required: true
  slot :eyebrow
  slot :subtitle
  slot :actions

  def header(assigns) do
    sizes = %{
      "page" => "text-3xl font-semibold leading-tight tracking-tight",
      "section" => "text-lg font-semibold leading-8"
    }

    assigns = assign(assigns, :size_class, Map.fetch!(sizes, assigns.size))

    ~H"""
    <header
      data-component="JobyKit.CoreComponents.header"
      class={[@actions != [] && "flex items-center justify-between gap-6", @class]}
      {@rest}
    >
      <div>
        <.eyebrow :if={@eyebrow != []}>{render_slot(@eyebrow)}</.eyebrow>
        <.dynamic_tag tag_name={@level} class={@title_class || @size_class}>
          {render_slot(@inner_block)}
        </.dynamic_tag>
        <p :if={@subtitle != []} class="text-sm text-base-content/70">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div :if={@actions != []} class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  # --------------------------------------------------------------- list

  @doc """
  Generic data list, one row per `:item` slot.

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  attr :class, :any, default: nil

  attr :title_class, :any,
    default: nil,
    doc: "Replaces the title's type treatment. The default is `font-bold`."

  attr :rest, :global

  slot :item, required: true do
    attr :title, :string, required: true
  end

  # `title_class` replaces rather than appends: the bold default was the
  # reason this component went unused — an app whose lists are mono
  # labels could not get out from under it, so it hand-rolled the markup
  # instead. daisy's `list` wants `ul`/`li.list-row`, so the element
  # stays a list even though the content is title/value pairs.
  def list(assigns) do
    ~H"""
    <ul data-component="JobyKit.CoreComponents.list" class={["list", @class]} {@rest}>
      <li :for={item <- @item} class="list-row">
        <div class="list-col-grow">
          <div class={@title_class || "font-bold"}>{item.title}</div>
          <div>{render_slot(item)}</div>
        </div>
      </li>
    </ul>
    """
  end

  # -------------------------------------------------------------- table

  @doc """
  Generic table with `:col` slots and an optional `:action` slot.

  `:rows` takes a plain list or a LiveView stream (see
  `Phoenix.LiveView.stream/4`).

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
        <:empty>No users yet.</:empty>
      </.table>

  ## Streams enumerate as `{dom_id, item}`

  A stream yields tuples, so destructure in the slot — or hand the
  unwrapping to `row_item`:

      <:col :let={{_id, user}} label="id">{user.id}</:col>
      <.table id="users" rows={@stream} row_item={fn {_id, u} -> u end}>

  ## Styling hooks

  `zebra={false}` drops the striping, `size` sets density, and the
  action cell carries `data-table-actions` so a host override can target
  it precisely instead of guessing with `:last-child`.
  """
  attr :id, :string,
    required: true,
    doc: "Identifies the row container. Streams require it; it lands on `<tbody>`."

  attr :table_id, :string,
    default: nil,
    doc: "Optional id for the `<table>` element itself, since `id` is taken."

  attr :rows, :any,
    required: true,
    doc:
      "A list, or a LiveView stream from `Phoenix.LiveView.stream/4` " <>
        "(which enumerates as `{dom_id, item}`)."

  attr :class, :any, default: nil
  attr :zebra, :boolean, default: true, doc: "Row striping. Turn off for dense data."
  attr :size, :string, values: ~w(xs sm md lg), default: "md"
  attr :row_id, :any, default: nil
  attr :row_click, :any, default: nil
  attr :row_item, :any, default: &Function.identity/1
  attr :rest, :global

  slot :col, required: true do
    attr :label, :string
  end

  slot :action
  slot :empty, doc: "Rendered in place of the body when there are no rows."

  def table(assigns) do
    sizes = %{"xs" => "table-xs", "sm" => "table-sm", "md" => nil, "lg" => "table-lg"}

    assigns =
      assigns
      |> assign(:size_class, Map.fetch!(sizes, assigns.size))
      |> then(fn assigns ->
        with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
          assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
        end
      end)
      |> then(&assign(&1, :empty?, &1.empty != [] and empty_rows?(&1.rows)))

    ~H"""
    <table
      id={@table_id}
      data-component="JobyKit.CoreComponents.table"
      class={["table", @zebra && "table-zebra", @size_class, @class]}
      {@rest}
    >
      <thead>
        <tr>
          <th :for={col <- @col}>{col[:label]}</th>
          <th :if={@action != []}>
            <span class="sr-only">Actions</span>
          </th>
        </tr>
      </thead>
      <tbody id={@id} phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}>
        <tr :if={@empty?}>
          <td colspan={length(@col) + if(@action != [], do: 1, else: 0)}>
            {render_slot(@empty)}
          </td>
        </tr>
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
          <td
            :for={col <- @col}
            phx-click={@row_click && @row_click.(row)}
            class={@row_click && "hover:cursor-pointer"}
          >
            {render_slot(col, @row_item.(row))}
          </td>
          <td
            :if={@action != []}
            data-table-actions
            class="w-0 font-semibold whitespace-nowrap"
          >
            <div class="flex gap-4">
              <%= for action <- @action do %>
                {render_slot(action, @row_item.(row))}
              <% end %>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  # A stream is only known-empty when its pending inserts are empty and it
  # isn't resetting; anything else we treat as "has rows" so the empty state
  # can't flash over live content.
  defp empty_rows?(%Phoenix.LiveView.LiveStream{inserts: inserts}), do: inserts == []
  defp empty_rows?(rows) when is_list(rows), do: rows == []
  defp empty_rows?(rows), do: Enum.empty?(rows)

  # -------------------------------------------------------------- modal

  @doc """
  Dialog whose visibility is driven by the server.

      <.modal id="confirm" show={@confirming?} on_cancel={JS.push("cancel")}>
        <:title>Delete workspace</:title>
        This removes every peer and session in it. It cannot be undone.
        <:actions>
          <.button variant="ghost" phx-click={JS.push("cancel")}>Keep it</.button>
          <.button variant="danger" phx-click={JS.push("delete")}>Delete</.button>
        </:actions>
      </.modal>

  `show` is a plain assign rather than client-side state, so the dialog
  can't disagree with the LiveView that owns it, and reconnecting
  restores the right thing.

  ## Dismissal

  `on_cancel` runs for all three ways out — the close button, the
  backdrop, and Escape — so there is one path to handle instead of the
  separate close/dismiss handlers apps ended up writing. The keydown
  listener is only attached while the dialog is open, so closed dialogs
  on the page cost nothing and can't swallow the key.

  Set `dismissable={false}` for a dialog that must be resolved through
  its actions; that drops the close button, the backdrop handler, and
  the Escape binding together.

  ## Previews

  `.modal` is `position: fixed`, so rendering one inside a preview card
  would cover the page. `static` renders just the box, in flow, for
  design pages and documentation.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, :any, default: nil, doc: "JS command or event run on any dismissal."
  attr :dismissable, :boolean, default: true
  attr :static, :boolean, default: false, doc: "Render in flow instead of as an overlay."
  attr :class, :any, default: nil
  attr :box_class, :any, default: nil, doc: "Utilities for the modal box."
  attr :rest, :global

  slot :title
  slot :inner_block, required: true
  slot :actions

  # daisy's `modal-box` is `opacity: 0; scale: .95` until a `modal-open`
  # parent reveals it, so a box standing on its own needs both undone —
  # otherwise it renders present-but-invisible.
  def modal(%{static: true} = assigns) do
    ~H"""
    <div
      id={@id}
      data-component="JobyKit.CoreComponents.modal"
      class={["modal-box relative opacity-100 scale-100", @box_class, @class]}
      {@rest}
    >
      <.modal_body
        id={@id}
        title={@title}
        body={@inner_block}
        actions={@actions}
        dismissable={false}
        on_cancel={nil}
      />
    </div>
    """
  end

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      data-component="JobyKit.CoreComponents.modal"
      class={["modal", @show && "modal-open", @class]}
      role="dialog"
      aria-modal={@show && "true"}
      aria-labelledby={@title != [] && "#{@id}-title"}
      phx-window-keydown={@show && @dismissable && @on_cancel}
      phx-key="escape"
      {@rest}
    >
      <div class={["modal-box relative", @box_class]}>
        <.modal_body
          id={@id}
          title={@title}
          body={@inner_block}
          actions={@actions}
          dismissable={@dismissable}
          on_cancel={@on_cancel}
        />
      </div>
      <div
        :if={@dismissable}
        class="modal-backdrop"
        phx-click={@on_cancel}
        aria-hidden="true"
      />
    </div>
    """
  end

  # Slots are forwarded as plain lists so both clauses share one body.
  attr :id, :string, required: true
  attr :dismissable, :boolean, required: true
  attr :on_cancel, :any, required: true
  attr :title, :list, default: []
  attr :body, :list, default: []
  attr :actions, :list, default: []

  defp modal_body(assigns) do
    ~H"""
    <.button
      :if={@dismissable}
      type="button"
      shape="circle"
      variant="ghost"
      size="sm"
      class="absolute right-3 top-3"
      phx-click={@on_cancel}
      aria-label="Close"
    >
      <.icon name="hero-x-mark" class="size-4" />
    </.button>

    <h3 :if={@title != []} id={"#{@id}-title"} class="text-lg font-semibold leading-tight">
      {render_slot(@title)}
    </h3>

    {render_slot(@body)}

    <div :if={@actions != []} class="modal-action">
      {render_slot(@actions)}
    </div>
    """
  end

  # -------------------------------------------------------- theme_toggle

  # `active_class` is spelled out per entry rather than built from `value`.
  # Tailwind scans source as text and cannot evaluate interpolation — an
  # interpolated variant compiles to a literal `[data-theme=#{theme}]`
  # rule, so the segments render but never highlight. Keep these literal.
  @themes [
    %{
      value: "system",
      icon: "hero-computer-desktop",
      label: "Match system theme",
      active_class:
        "[[data-theme-source=system]_&]:text-primary [[data-theme-source=system]_&]:opacity-100"
    },
    %{
      value: "light",
      icon: "hero-sun",
      label: "Light theme",
      active_class:
        "[[data-theme-source=user][data-theme=light]_&]:text-primary " <>
          "[[data-theme-source=user][data-theme=light]_&]:opacity-100"
    },
    %{
      value: "dark",
      icon: "hero-moon",
      label: "Dark theme",
      active_class:
        "[[data-theme-source=user][data-theme=dark]_&]:text-primary " <>
          "[[data-theme-source=user][data-theme=dark]_&]:opacity-100"
    }
  ]

  @doc """
  Segmented system / light / dark theme control.

      <.theme_toggle />

  Pairs with the theme script Phoenix puts in `root.html.heex`, which
  applies the stored choice before first paint and listens for the
  `phx:set-theme` event these buttons dispatch. Selection state is read
  straight off `<html data-theme>` / `data-theme-source` in CSS, so the
  control stays correct without round-tripping through the server.

  Generated apps get this in their layout. If you are installing into an
  existing app, make sure `root.html.heex` carries that script — without
  it the buttons dispatch into nothing.
  """
  attr :class, :any, default: nil
  attr :rest, :global

  def theme_toggle(assigns) do
    assigns = assign(assigns, :themes, @themes)

    ~H"""
    <div
      data-component="JobyKit.CoreComponents.theme_toggle"
      class={["join", @class]}
      role="group"
      aria-label="Color theme"
      {@rest}
    >
      <.button
        :for={theme <- @themes}
        type="button"
        size="sm"
        variant="ghost"
        shape="square"
        class={["join-item opacity-50 transition-opacity hover:opacity-80", theme.active_class]}
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme={theme.value}
        aria-label={theme.label}
        title={theme.label}
      >
        <.icon name={theme.icon} class="size-4" />
      </.button>
    </div>
    """
  end

  # -------------------------------------------------------------- flash

  @doc """
  Renders a single flash notice as a daisyUI `alert`.

  Positioning belongs to the container, not the notice: `flash_group/1`
  supplies the single `toast` that stacks every notice. Rendered on its
  own, `flash/1` sits inline wherever you put it.

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} title="Heads up">Something happened</.flash>
  """
  attr :id, :string, default: nil
  attr :flash, :map, default: %{}
  attr :title, :string, default: nil

  attr :kind, :atom,
    values: [:info, :success, :warning, :error],
    required: true,
    doc: "Which flash key to read and how to style it."

  attr :class, :any, default: nil
  attr :rest, :global

  slot :inner_block

  def flash(assigns) do
    # NOT `assign_new/3`: `attr :id` already puts `:id` in assigns (as nil when
    # the caller omits it), so the key is always present and assign_new never
    # fires. That left `@id` nil, which rendered the toast with no id *and*
    # made the dismiss handler `JS.hide(to: "#")` — an invalid selector that
    # throws in the browser on every click.
    assigns = assign(assigns, :id, assigns.id || "flash-#{assigns.kind}")

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      data-component="JobyKit.CoreComponents.flash"
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role={if @kind == :error, do: "alert", else: "status"}
      class={[
        "alert w-80 sm:w-96 max-w-80 sm:max-w-96 text-wrap pointer-events-auto",
        flash_tone_class(@kind),
        @class
      ]}
      {@rest}
    >
      <.icon name={flash_icon(@kind)} class="size-5 shrink-0" />
      <div>
        <p :if={@title} class="font-semibold">{@title}</p>
        <p>{msg}</p>
      </div>
      <div class="flex-1" />
      <button type="button" class="group self-start cursor-pointer" aria-label="close">
        <.icon name="hero-x-mark" class="size-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  # `:info` and `:error` are Phoenix's own flash keys; `:success` and
  # `:warning` are here because apps use them constantly and previously
  # could not — the enum rejected them, so the kit's flash was unusable
  # for a whole class of message and hosts hand-rolled alerts instead.
  defp flash_tone_class(:info), do: "alert-info"
  defp flash_tone_class(:success), do: "alert-success"
  defp flash_tone_class(:warning), do: "alert-warning"
  defp flash_tone_class(:error), do: "alert-error"

  defp flash_icon(:info), do: "hero-information-circle"
  defp flash_icon(:success), do: "hero-check-circle"
  defp flash_icon(:warning), do: "hero-exclamation-triangle"
  defp flash_icon(:error), do: "hero-exclamation-circle"

  @doc """
  Renders the standard flash group: `:info` and `:error` flashes plus
  the disconnected/server-error toasts wired to `phx-disconnected` /
  `phx-connected`. Hosts call this from their root layout.

  This is the single `toast` container for the page — every notice
  stacks inside it. The container is click-through
  (`pointer-events-none`) so the empty corner never intercepts clicks;
  each notice re-enables pointer events for its own dismiss handler.
  """
  attr :id, :string, default: "flash-group"
  attr :flash, :map, required: true
  attr :class, :any, default: nil
  attr :rest, :global

  def flash_group(assigns) do
    ~H"""
    <div
      id={@id}
      data-component="JobyKit.CoreComponents.flash_group"
      aria-live="polite"
      class={["toast toast-top toast-end z-50 pointer-events-none", @class]}
      {@rest}
    >
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  # -------------------------------------------------------------- input

  @doc """
  Renders a form input with label and error messages.

  Pass `field={@form[:foo]}` for the common case; the input pulls id,
  name, value, and errors from the form field. Otherwise pass `name`,
  `value`, `errors` explicitly.

  Supported types: text, email, password, number, search, tel, url,
  date, datetime-local, month, time, week, color, file, hidden,
  checkbox, select, textarea.

      <.input field={@form[:email]} type="email" label="Email" />
      <.input field={@form[:role]} type="select" options={["Admin": "admin"]} />

  ## Class composition

  `class` and any global attributes land on the **root** `<fieldset>`,
  the same as every other kit wrapper — use it for layout (grid
  placement, width, margins). `input_class` adds utilities to the
  control itself, on top of the daisyUI class set the wrapper composes
  (`input` / `select` / `textarea` / `checkbox`).

      <.input field={@form[:email]} class="col-span-2" input_class="font-mono" />

  The wrapper carries **no outer margin**. Spacing belongs to the
  parent — reach for `space-y-*` or `gap-*` on the container.

  Width works through the root: the control is always `w-full`, so
  constrain the root and the control follows.

      <.input field={@form[:code]} class="w-32" />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField

  attr :errors, :list, default: []
  attr :checked, :boolean
  attr :prompt, :string, default: nil
  attr :options, :list
  attr :multiple, :boolean, default: false

  attr :class, :any,
    default: nil,
    doc: "Utilities for the root fieldset — layout, width, spacing."

  attr :input_class, :any, default: nil, doc: "Utilities for the control itself."

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error/1))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input
      type="hidden"
      data-component="JobyKit.CoreComponents.input"
      id={@id}
      name={@name}
      value={@value}
      {@rest}
    />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <fieldset class={["fieldset", @class]} data-component="JobyKit.CoreComponents.input">
      <label for={@id}>
        <input
          type="hidden"
          name={@name}
          value="false"
          disabled={@rest[:disabled]}
          form={@rest[:form]}
        />
        <span class="label">
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            class={["checkbox checkbox-sm", @input_class]}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && error_id(@id)}
            {@rest}
          />{@label}
        </span>
      </label>
      <.error_list errors={@errors} id={error_id(@id)} />
    </fieldset>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <fieldset class={["fieldset", @class]} data-component="JobyKit.CoreComponents.input">
      <label for={@id}>
        <span :if={@label} class="label">{@label}</span>
        <select
          id={@id}
          name={@name}
          class={["w-full select", @errors != [] && "select-error", @input_class]}
          multiple={@multiple}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && error_id(@id)}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
      </label>
      <.error_list errors={@errors} id={error_id(@id)} />
    </fieldset>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <fieldset class={["fieldset", @class]} data-component="JobyKit.CoreComponents.input">
      <label for={@id}>
        <span :if={@label} class="label">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={["w-full textarea", @errors != [] && "textarea-error", @input_class]}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && error_id(@id)}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.error_list errors={@errors} id={error_id(@id)} />
    </fieldset>
    """
  end

  def input(assigns) do
    ~H"""
    <fieldset class={["fieldset", @class]} data-component="JobyKit.CoreComponents.input">
      <label for={@id}>
        <span :if={@label} class="label">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          multiple={@type == "file" && @multiple}
          class={["w-full input", @errors != [] && "input-error", @input_class]}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && error_id(@id)}
          {@rest}
        />
      </label>
      <.error_list errors={@errors} id={error_id(@id)} />
    </fieldset>
    """
  end

  defp error_id(nil), do: nil
  defp error_id(id), do: "#{id}-error"

  attr :errors, :list, required: true
  attr :id, :string, default: nil

  # One container per field so `aria-describedby` has a single target,
  # however many messages there are.
  defp error_list(assigns) do
    ~H"""
    <div :if={@errors != []} id={@id}>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  attr :rest, :global
  slot :inner_block, required: true

  defp error(assigns) do
    # No top margin: the daisy `fieldset` root is a grid with its own gap.
    ~H"""
    <p class="flex gap-2 items-center text-sm text-error" {@rest}>
      <.icon name="hero-exclamation-circle" class="size-5" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  # ----------------------------------------------------------- helpers

  @doc """
  JS command for fading an element in.
  """
  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  @doc """
  JS command for fading an element out.
  """
  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """
  Translate an Ecto error tuple `{msg, opts}` into a plain string by
  interpolating `%{key}` placeholders. No Gettext dependency — hosts
  that need i18n should override this function (or wrap `<.input>`).

  Opts whose placeholder isn't present in the message are never
  stringified, so non-`String.Chars` values (`type: {:array, :string}`,
  `validation: :cast`, and friends — which Ecto attaches to every cast
  error) pass through harmlessly.
  """
  def translate_error({msg, opts}) when is_binary(msg) and is_list(opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      # The function form is deliberate: it defers `to_string/1` until a
      # placeholder actually matches. Calling it eagerly raises
      # `Protocol.UndefinedError` on the tuple/list opts Ecto attaches to
      # array and composite-typed fields, 500ing the whole form.
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  def translate_error(msg) when is_binary(msg), do: msg
end

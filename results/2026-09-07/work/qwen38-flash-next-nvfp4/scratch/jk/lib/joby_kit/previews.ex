defmodule JobyKit.Previews do
  @moduledoc """
  Canonical previews for the kit's own components.

  These live in the kit, not in each host, because `/design` promises to
  be identical across every JobyKit consumer. Previously the previews
  for kit components were generated into `<App>Web.DesignPreviews` and
  owned by the host, so they diverged the moment anyone edited them —
  and they never picked up components added in a later kit release. Two
  apps on the same kit version showed different buttons for the same
  `<.button>`, with different prose beside them.

  Hosts write previews for *their* components. The kit writes previews
  for the kit's.
  """

  use Phoenix.Component

  alias JobyKit.CoreComponents
  alias JobyKit.NavComponent

  def button(assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.row>
        <CoreComponents.button>Default</CoreComponents.button>
        <CoreComponents.button variant="primary">Primary</CoreComponents.button>
        <CoreComponents.button variant="neutral">Neutral</CoreComponents.button>
        <CoreComponents.button variant="ghost">Ghost</CoreComponents.button>
        <CoreComponents.button variant="danger">Delete</CoreComponents.button>
      </.row>
      <.row>
        <CoreComponents.button size="xs">XS</CoreComponents.button>
        <CoreComponents.button size="sm">Small</CoreComponents.button>
        <CoreComponents.button size="lg">Large</CoreComponents.button>
        <CoreComponents.button shape="circle" variant="ghost" aria-label="Close">
          <CoreComponents.icon name="hero-x-mark" class="size-4" />
        </CoreComponents.button>
        <CoreComponents.button shape="square" variant="ghost" aria-label="Edit">
          <CoreComponents.icon name="hero-pencil-square" class="size-4" />
        </CoreComponents.button>
      </.row>
    </div>
    """
  end

  def badge(assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <.row>
        <CoreComponents.badge tone="ok">Healthy</CoreComponents.badge>
        <CoreComponents.badge tone="warn">Degraded</CoreComponents.badge>
        <CoreComponents.badge tone="danger">Failed</CoreComponents.badge>
        <CoreComponents.badge tone="info">Queued</CoreComponents.badge>
        <CoreComponents.badge>Unknown</CoreComponents.badge>
      </.row>
      <.row>
        <CoreComponents.badge tone="ok" variant="solid">Solid</CoreComponents.badge>
        <CoreComponents.badge tone="ok" variant="outline">Outline</CoreComponents.badge>
        <CoreComponents.badge tone="ok" size="lg">Large</CoreComponents.badge>
      </.row>
    </div>
    """
  end

  def card(assigns) do
    ~H"""
    <div class="grid gap-3 sm:grid-cols-2">
      <CoreComponents.card prose>
        <:eyebrow>Bordered</:eyebrow>
        <:title>Default card</:title>
        Padded content surface backed by daisyUI's <code class="font-mono text-xs">card</code>.
        <:actions><CoreComponents.button size="sm">Action</CoreComponents.button></:actions>
      </CoreComponents.card>
      <CoreComponents.card variant="elevated" prose>
        <:eyebrow>Elevated</:eyebrow>
        <:title>Card with shadow</:title>
        Lifts on hover via the wrapper's transition.
      </CoreComponents.card>
    </div>
    """
  end

  def eyebrow(assigns) do
    ~H"""
    <div>
      <CoreComponents.eyebrow>Workspace</CoreComponents.eyebrow>
      <p class="text-sm text-base-content/70">Sits above a heading or leads a data pair.</p>
    </div>
    """
  end

  def icon(assigns) do
    ~H"""
    <div class="flex items-center gap-3 text-base-content/80">
      <CoreComponents.icon name="hero-sparkles" />
      <CoreComponents.icon name="hero-arrow-right" class="size-5" />
      <CoreComponents.icon name="hero-bolt" class="size-7 text-primary" />
    </div>
    """
  end

  def input(assigns) do
    assigns = Map.put(assigns, :form, Phoenix.Component.to_form(%{"email" => ""}, as: :preview))

    ~H"""
    <div class="flex max-w-md flex-col gap-3">
      <CoreComponents.input field={@form[:email]} type="email" label="Email" />
      <CoreComponents.input
        name="bio"
        value=""
        type="textarea"
        label="Bio"
        placeholder="Tell us about yourself"
      />
      <CoreComponents.input
        name="role"
        value=""
        type="select"
        label="Role"
        options={[Admin: "admin", Member: "member"]}
      />
    </div>
    """
  end

  def flash(assigns) do
    assigns =
      Map.put(assigns, :preview_flash, %{
        "info" => "Saved.",
        "success" => "Deploy finished.",
        "warning" => "Running low on quota.",
        "error" => "Try again."
      })

    ~H"""
    <div class="flex flex-col gap-2">
      <CoreComponents.flash kind={:info} flash={@preview_flash} />
      <CoreComponents.flash kind={:success} flash={@preview_flash} />
      <CoreComponents.flash kind={:warning} flash={@preview_flash} />
      <CoreComponents.flash kind={:error} flash={@preview_flash} title="Heads up" />
    </div>
    """
  end

  def header(assigns) do
    ~H"""
    <CoreComponents.header level="h2">
      Team settings
      <:eyebrow>Workspace</:eyebrow>
      <:subtitle>Manage members and their permissions.</:subtitle>
      <:actions>
        <CoreComponents.button variant="primary" size="sm">Invite</CoreComponents.button>
      </:actions>
    </CoreComponents.header>
    """
  end

  def list(assigns) do
    ~H"""
    <CoreComponents.list>
      <:item title="Status">Active</:item>
      <:item title="Plan">Team</:item>
      <:item title="Seats">12 of 20 used</:item>
    </CoreComponents.list>
    """
  end

  def modal(assigns) do
    ~H"""
    <CoreComponents.modal id="jobykit-modal-preview" static>
      <:title>Delete workspace</:title>
      <p class="text-sm text-base-content/70">
        This removes every peer and session in it. It cannot be undone.
      </p>
      <:actions>
        <CoreComponents.button variant="ghost" size="sm">Keep it</CoreComponents.button>
        <CoreComponents.button variant="danger" size="sm">Delete</CoreComponents.button>
      </:actions>
    </CoreComponents.modal>
    """
  end

  def table(assigns) do
    assigns =
      Map.put(assigns, :rows, [
        %{id: 1, name: "Ada Lovelace", role: "Owner"},
        %{id: 2, name: "Alan Turing", role: "Member"}
      ])

    ~H"""
    <CoreComponents.table id="jobykit-preview-table" rows={@rows} size="sm">
      <:col :let={row} label="Name">{row.name}</:col>
      <:col :let={row} label="Role">{row.role}</:col>
      <:action :let={row}>
        <CoreComponents.button size="xs">Edit {row.id}</CoreComponents.button>
      </:action>
      <:empty>No members yet.</:empty>
    </CoreComponents.table>
    """
  end

  def theme_toggle(assigns) do
    ~H"""
    <div class="flex items-center gap-3">
      <CoreComponents.theme_toggle />
      <span class="text-xs text-base-content/60">Try it — the whole page follows.</span>
    </div>
    """
  end

  def simple_nav(assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-100 px-2">
      <NavComponent.simple_nav
        brand="Preview"
        active="design"
        links={[
          %{key: "home", label: "Home", href: "/"},
          %{key: "design", label: "Design", href: "/design"}
        ]}
      >
        <:actions>
          <CoreComponents.theme_toggle />
        </:actions>
      </NavComponent.simple_nav>
    </div>
    """
  end

  # A row of demo items — the one layout that recurs here.
  slot :inner_block, required: true

  defp row(assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-2">
      {render_slot(@inner_block)}
    </div>
    """
  end
end

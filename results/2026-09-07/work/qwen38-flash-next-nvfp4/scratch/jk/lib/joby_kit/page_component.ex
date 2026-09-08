defmodule JobyKit.PageComponent do
  @moduledoc """
  Function components that render the JobyKit design surfaces.

  Two surfaces are exposed:

    * `page_component/1` — JobyKit's curated `/design` page. Renders the
      decision tree, wrapper contract, **every entry whose module the kit
      owns**, and the daisyUI catalogue. Identical across every JobyKit
      consumer; this is the agentic-first contract surface.

    * `custom_page_component/1` — host-defined composites and domain
      components. Renders **every entry the kit does not own**, plus a
      slim breadcrumb back to `/design`. Hosts mount this at any path
      they like (`/custom-designs`, `/composites`, etc.).

  The split is by module ownership, not by declared category. Category is
  a host-chosen atom, so keying the pages off it meant an app could
  register its own component as `:core` and have it appear on the kit's
  page as though JobyKit shipped it. Category now groups entries within
  whichever page owns them.

  Both consume the same manifest module (`use JobyKit.Manifest`) but
  filter differently. The JSON endpoint
  (`JobyKit.ManifestController`) returns *all* entries — kit core +
  composites + domain — so agents have a single source of truth.

  Hosts wrap these components in their own LiveView render and supply
  page chrome (layout, headers, navigation).
  """

  use Phoenix.Component

  alias JobyKit.Contract
  alias JobyKit.DaisyCatalogue
  alias JobyKit.SignatureComponent

  attr :manifest, :atom, required: true
  attr :custom_path, :string, default: nil

  def page_component(assigns) do
    # The kit's own manifest, not the host's. The host's manifest still
    # supplies daisy_overrides below, since an app can wrap primitives
    # the kit doesn't.
    entries_by_category = JobyKit.KitManifest.by_category()

    assigns =
      assigns
      |> assign(:entries_by_category, entries_by_category)
      |> assign(:catalogue, DaisyCatalogue.merged(assigns.manifest))
      |> assign(:build_order, Contract.build_order())
      |> assign(:rules, Contract.rules())
      |> assign(:taxonomy, Contract.taxonomy())

    ~H"""
    <div class="space-y-8" data-jobykit-page="kit">
      <.decision_tree_section build_order={@build_order} taxonomy={@taxonomy} />
      <.agent_redirect_section :if={@custom_path} custom_path={@custom_path} />
      <.wrapper_contract_section rules={@rules} />
      <.component_index_section
        manifest={JobyKit.KitManifest}
        entries_by_category={@entries_by_category}
        title="Core wrappers"
        description="JobyKit's curated wrapper inventory — one wrapper per daisyUI primitive. Composites and domain components live on the host's custom-designs page and in the JSON manifest."
      />
      <.daisy_catalogue_section catalogue={@catalogue} />
    </div>
    """
  end

  attr :custom_path, :string, required: true

  defp agent_redirect_section(assigns) do
    ~H"""
    <section
      id="design-system-agent-redirect"
      data-jobykit-section="agent-redirect"
      class="rounded-2xl border border-warning/40 bg-warning/10 p-5"
    >
      <p class="text-xs uppercase tracking-[0.18em] text-warning/85">Adding a new component?</p>
      <h3 class="mt-2 text-lg font-semibold text-base-content">
        Don't add it here. Register it on the custom-designs page instead.
      </h3>
      <p class="mt-2 max-w-3xl text-sm leading-relaxed text-base-content/75">
        This page is the kit's curated catalogue — every JobyKit consumer sees the same
        wrapper inventory and contract. App-specific components don't belong here.
        Register them in this app's manifest with category
        <code class="font-mono text-xs">:composite</code> or
        <code class="font-mono text-xs">:domain</code> and they will appear on the
        custom-designs page. The JSON manifest at <code class="font-mono text-xs">/design.json</code>
        combines both surfaces so agents have a single source of truth regardless of which
        page rendered which entry.
      </p>
      <p class="mt-3">
        <a
          href={@custom_path}
          class="link link-hover text-sm font-semibold text-warning"
        >
          → Open the custom-designs page ({@custom_path})
        </a>
      </p>
    </section>
    """
  end

  @doc """
  Host page renderer for composites and domain components.

  Filters the manifest to only `:composite` and `:domain` entries
  (anything that is not `:core`). The kit's `/design` page never
  surfaces these — that's by design, so the kit's catalogue stays
  uniform across every consumer. Use this component on a separate
  route (typically `/custom-designs`) to give your composites and
  domain components their own discoverable surface.
  """
  attr :manifest, :atom, required: true
  attr :back_to, :string, default: "/design"
  attr :title, :string, default: "Custom designs"

  attr :description, :string,
    default:
      "Composites and domain components defined by this app. The kit's curated wrapper inventory and the wrapper contract live on /design."

  def custom_page_component(assigns) do
    entries_by_category = entries_owned_by(assigns.manifest, :host)

    assigns = assign(assigns, :entries_by_category, entries_by_category)

    ~H"""
    <div class="space-y-8" data-jobykit-page="custom">
      <section
        id="design-system-custom-breadcrumb"
        data-jobykit-section="custom-breadcrumb"
        class="rounded-2xl border border-base-300/70 bg-base-100/80 p-5"
      >
        <p class="text-xs uppercase tracking-[0.18em] text-base-content/55">
          Custom designs
        </p>
        <h2 class="mt-2 text-lg font-semibold text-base-content">{@title}</h2>
        <p class="mt-2 max-w-3xl text-sm leading-relaxed text-base-content/65">
          {@description}
        </p>
        <p class="mt-3 text-sm">
          <a href={@back_to} class="link link-hover text-primary/85">
            ← Kit catalogue and contract at {@back_to}
          </a>
        </p>
      </section>

      <.component_index_section
        manifest={@manifest}
        entries_by_category={@entries_by_category}
        title="Composites and domain components"
      />
    </div>
    """
  end

  # Which page an entry lands on is decided by **who owns the module**,
  # not by the category the host declared.
  #
  # /design goes further and renders `JobyKit.KitManifest` directly, so
  # the kit surface does not depend on the host manifest at all — see
  # that module for why. This filter is what keeps kit components off
  # the *custom* page when a host also registers them, which every
  # install before 0.3.2 did.
  #
  # Category is a free atom the host picks, so the old split let an app
  # register its own component as `:core` and have it render on /design —
  # the page whose whole promise is "identical across every JobyKit
  # consumer". Found in the wild: an app had two of its own components
  # sitting on the kit page, reading as stock to anyone (or any agent)
  # looking at it. Ownership is not a matter of opinion, so it should not
  # be a matter of convention either.
  #
  # Category still groups entries *within* a page.
  defp entries_owned_by(manifest, :host) do
    manifest.by_category()
    |> Enum.map(fn {category, entries} ->
      {category, Enum.reject(entries, &kit_owned?(&1.module))}
    end)
    |> Enum.reject(fn {_category, entries} -> entries == [] end)
  end

  # An explicit list, not a `JobyKit.` prefix check. "What the kit
  # provides" is finite and knowable, and prefix-matching would hand the
  # kit page to anything a host chose to namespace under JobyKit —
  # including the kit's own test fixtures, which stand in for host
  # modules. Add a module here when the kit starts shipping components
  # from it; `kit_component_modules/0` is public so hosts and tests can
  # ask the same question the page asks.
  @kit_component_modules [JobyKit.CoreComponents, JobyKit.NavComponent]

  @doc """
  The modules whose components `page_component/1` treats as kit-provided.

  Everything else a manifest registers belongs on the custom-designs
  page, whatever category it declares.
  """
  @spec kit_component_modules() :: [module()]
  def kit_component_modules, do: @kit_component_modules

  defp kit_owned?(module), do: module in @kit_component_modules

  attr :build_order, :list, required: true
  attr :taxonomy, :list, required: true

  defp decision_tree_section(assigns) do
    ~H"""
    <section
      id="design-system-decision-tree"
      data-jobykit-section="decision-tree"
      class="rounded-2xl border border-primary/30 bg-primary/5 p-5"
    >
      <div class="space-y-5">
        <div>
          <p class="text-xs uppercase tracking-[0.18em] text-primary/80">Build order</p>
          <h3 class="mt-2 text-lg font-semibold text-base-content">
            Five steps, in order, every time you need a UI thing.
          </h3>
          <p class="mt-2 max-w-3xl text-sm leading-relaxed text-base-content/70">
            App code only ever calls wrappers. If a wrapper does not exist, build one before
            using the markup directly. The goal:
            <span class="font-semibold">every interface element in the product is a component</span>,
            never a bare daisyUI class string or raw Tailwind utility soup.
          </p>
        </div>

        <ol id="design-decision-tree" class="grid gap-2 text-sm text-base-content/80 lg:grid-cols-5">
          <li
            :for={step <- @build_order}
            data-step={step.step}
            class={[
              "rounded-2xl px-4 py-3",
              decision_step_classes(step.tone)
            ]}
          >
            <p class={["text-[0.65rem] font-semibold uppercase tracking-[0.16em]", step_eyebrow(step.tone)]}>
              Step {step.step}
            </p>
            <p class="mt-1 font-semibold text-base-content">{step.title}</p>
            <p class="mt-1 text-xs leading-relaxed text-base-content/65">{step.description}</p>
          </li>
        </ol>

        <div
          id="design-module-taxonomy"
          class="rounded-2xl border border-base-300/70 bg-base-100/70 p-4"
        >
          <p class="text-xs uppercase tracking-[0.18em] text-base-content/55">Module taxonomy</p>
          <dl class="mt-3 grid gap-3 text-sm md:grid-cols-3">
            <div :for={layer <- @taxonomy} data-layer={layer.layer}>
              <dt class="font-semibold text-base-content">{layer.title}</dt>
              <dd class="mt-1 text-xs text-base-content/65">{layer.body}</dd>
            </div>
          </dl>
        </div>
      </div>
    </section>
    """
  end

  defp decision_step_classes(:warning),
    do: "border border-warning/40 bg-warning/10"

  defp decision_step_classes(:error),
    do: "border border-error/40 bg-error/10"

  defp decision_step_classes(_),
    do: "border border-base-300/70 bg-base-100/70"

  defp step_eyebrow(:warning), do: "text-warning/80"
  defp step_eyebrow(:error), do: "text-error/80"
  defp step_eyebrow(_), do: "text-base-content/55"

  attr :rules, :list, required: true

  defp wrapper_contract_section(assigns) do
    ~H"""
    <section
      id="design-system-wrapper-contract"
      data-jobykit-section="wrapper-contract"
      class="rounded-2xl border border-base-300/70 bg-base-100/80 p-5"
    >
      <div>
        <p class="text-xs uppercase tracking-[0.18em] text-base-content/55">Wrapper contract</p>
        <h3 class="mt-2 text-lg font-semibold text-base-content">
          Every component must satisfy this checklist
        </h3>
        <p class="mt-2 max-w-3xl text-sm leading-relaxed text-base-content/65">
          A component that fails any rule is not "usable" and should be fixed before adoption.
          Lints can enforce the structural rules; visual rules require review.
        </p>
      </div>

      <ol id="design-wrapper-contract" class="mt-5 grid gap-3 text-sm md:grid-cols-2">
        <li
          :for={rule <- @rules}
          data-rule={rule.key}
          class="rounded-2xl border border-base-300/70 bg-base-200/35 px-4 py-3"
        >
          <p class="font-semibold text-base-content">{rule.title}</p>
          <p class="mt-1 text-xs text-base-content/65">{rule.body}</p>
        </li>
      </ol>
    </section>
    """
  end

  attr :manifest, :atom, required: true
  attr :entries_by_category, :list, required: true
  attr :title, :string, default: "Components"
  attr :description, :string, default: nil

  defp component_index_section(assigns) do
    ~H"""
    <section
      id="design-system-index"
      data-jobykit-section="component-index"
      class="space-y-6"
    >
      <div>
        <p class="text-xs uppercase tracking-[0.18em] text-base-content/55">Components</p>
        <h2 class="mt-2 text-2xl font-semibold leading-tight">{@title}</h2>
        <p :if={@description} class="mt-2 max-w-3xl text-sm leading-relaxed text-base-content/65">
          {@description}
        </p>
        <p class="mt-2 max-w-3xl text-xs text-base-content/55">
          Built from <code class="font-mono text-xs">{inspect(@manifest)}</code>. The same data is
          served as JSON at <code class="font-mono text-xs">/design.json</code> for agent
          consumption.
        </p>
      </div>

      <article
        :for={{category, entries} <- @entries_by_category}
        id={"design-category-" <> Atom.to_string(category)}
        data-category={category}
        class="rounded-2xl border border-base-300/70 bg-base-100/70 p-5 shadow-sm"
      >
        <header class="mb-4 flex flex-wrap items-baseline justify-between gap-3">
          <div>
            <h3 class="text-lg font-semibold text-base-content">
              {@manifest.category_label(category)}
            </h3>
            <p class="mt-1 text-sm text-base-content/65">
              {@manifest.category_description(category)}
            </p>
          </div>
          <p class="text-xs uppercase tracking-[0.16em] text-base-content/45">
            {length(entries)} components
          </p>
        </header>

        <div class="grid gap-3 xl:grid-cols-2">
          <SignatureComponent.signature_card :for={entry <- entries} entry={entry} />
        </div>
      </article>
    </section>
    """
  end

  attr :catalogue, :list, required: true

  defp daisy_catalogue_section(assigns) do
    ~H"""
    <section
      id="design-system-daisyui"
      data-jobykit-section="daisy-catalogue"
      class="space-y-4"
    >
      <div>
        <p class="text-xs uppercase tracking-[0.18em] text-base-content/55">daisyUI catalogue</p>
        <h2 class="mt-2 text-2xl font-semibold leading-tight">
          Every primitive available below the wrapper layer
        </h2>
        <p class="mt-2 max-w-3xl text-sm leading-relaxed text-base-content/65">
          Status badges show whether a primitive is already wrapped (use the wrapper),
          available unwrapped (use directly until reuse justifies wrapping), or listed for
          reference only. Each entry links to the daisyUI documentation.
        </p>
      </div>

      <div class="space-y-6">
        <article
          :for={category <- @catalogue}
          id={"design-daisyui-" <> DaisyCatalogue.slug(category.name)}
          class="rounded-2xl border border-base-300/70 bg-base-100/70 p-5 shadow-sm"
        >
          <header class="mb-4 flex flex-wrap items-baseline justify-between gap-3">
            <div>
              <h3 class="text-lg font-semibold text-base-content">{category.name}</h3>
              <p class="mt-1 text-sm text-base-content/65">{category.description}</p>
            </div>
            <p class="text-xs uppercase tracking-[0.16em] text-base-content/45">
              {length(category.components)} components
            </p>
          </header>
          <div class="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
            <.daisy_entry :for={component <- category.components} component={component} />
          </div>
        </article>
      </div>
    </section>
    """
  end

  attr :component, :map, required: true

  defp daisy_entry(assigns) do
    ~H"""
    <div
      data-daisy-entry={@component.id}
      data-status={@component.status}
      class="flex flex-col gap-3 rounded-xl border border-base-300/60 bg-base-100/70 p-4"
    >
      <div class="flex items-start justify-between gap-3">
        <div>
          <p class="text-sm font-semibold text-base-content">{@component.name}</p>
          <p class="mt-0.5 font-mono text-[0.7rem] text-base-content/55">{@component.classes}</p>
        </div>
        <.daisy_status_badge status={@component.status} />
      </div>

      <div class="flex min-h-[3.5rem] items-center justify-center rounded-lg border border-base-300/60 bg-base-200/40 px-3 py-3">
        <DaisyCatalogue.demo id={@component.id} />
      </div>

      <div class="flex flex-wrap items-center justify-between gap-2 text-xs">
        <a
          href={DaisyCatalogue.docs_url(@component)}
          class="link link-hover text-base-content/65"
          target="_blank"
          rel="noopener noreferrer"
        >
          daisyUI docs ↗
        </a>
        <a
          :if={@component.anchor}
          href={@component.anchor}
          class="link link-hover text-primary/80"
        >
          {@component.wrapper}
        </a>
      </div>
      <p :if={@component[:note]} class="text-xs text-base-content/55">
        {@component.note}
      </p>
    </div>
    """
  end

  attr :status, :atom, required: true

  defp daisy_status_badge(%{status: :wrapped} = assigns) do
    ~H"""
    <span class="badge badge-success badge-soft">Wrapped</span>
    """
  end

  defp daisy_status_badge(%{status: :partial} = assigns) do
    ~H"""
    <span class="badge badge-primary badge-soft">Partial</span>
    """
  end

  defp daisy_status_badge(%{status: :available} = assigns) do
    ~H"""
    <span class="badge badge-warning badge-soft">Available</span>
    """
  end

  defp daisy_status_badge(%{status: :reference} = assigns) do
    ~H"""
    <span class="badge badge-soft">Reference</span>
    """
  end
end

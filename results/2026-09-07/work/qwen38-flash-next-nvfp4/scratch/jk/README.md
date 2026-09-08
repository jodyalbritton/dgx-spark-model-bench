# JobyKit

An opinionated, agentic-first design-system kit for Phoenix + daisyUI apps.

JobyKit gives your AI coding agents a structured, machine-readable inventory
of every UI component your app exposes — with prop signatures, daisyUI basis,
rendered previews, and a stable contract — so design and prototype phases
don't accumulate a hodgepodge of UI markup that's hard to reason about.

## Why this exists

Most Phoenix apps end up with a sprawl of inline Tailwind classes, ad-hoc
component shapes, and undocumented variants. AI coding agents working on
those apps have to grep through HEEx to discover what's available and often
just write new markup from scratch — making the sprawl worse.

JobyKit pushes the codebase in the opposite direction. Your app declares a
**manifest** of its components, and JobyKit serves them at two surfaces:

* `/design` — a curated, kit-uniform page showing your **core wrappers**
  (one per daisyUI primitive), the daisyUI catalogue, the wrapper contract,
  and the build-order decision tree. Same shape across every JobyKit
  consumer.

* `/custom-designs` — your app's **composites and domain components**,
  separated from the kit's curated inventory so the kit page stays clean.

* `/design.json` — a **single combined JSON endpoint** that an agent can
  fetch to get every component, attr, slot, and source path without
  parsing rendered HEEx.

## Install

### Generate a new app from scratch

The project generator ships as its own package, `joby_kit_new`, the same
way `phx_new` is separate from `phoenix`. It has to run before a project
exists, so it installs as a Mix archive:

```sh
mix archive.install hex joby_kit_new
```

Then from anywhere:

```sh
mix joby_kit.new my_app   # wraps `mix phx.new` with the kit's HTML layer baked in
cd my_app
mix ecto.setup            # creates the dev DB and runs migrations
mix phx.server
```

Visit `http://localhost:4000/`. `/design`, `/custom-designs`, and
`/design.json` are wired automatically.

### Add to an existing Phoenix app

Add `joby_kit` to your `deps`:

```elixir
def deps do
  [
    {:joby_kit, "~> 0.1"}
  ]
end
```

Then run one of:

```sh
# Adds the manifest, previews, design pages, and patches AGENTS.md +
# assets/css/app.css + your layout's nav. Idempotent.
mix joby_kit.install

# Same as install, plus replaces the default HomeLive at /, removes
# PageController/PageHTML. For a kit-flavored greenfield start.
mix joby_kit.bootstrap
```

> JobyKit ships function components built on `phoenix_live_view ~> 1.0` and
> assumes daisyUI is installed in your Tailwind config (the default for
> Phoenix 1.7+ apps generated with `mix phx.new`). Heroicons via the
> `heroicons` Tailwind plugin is also expected.

After running `install` or `bootstrap`, restart `mix phx.server`, visit
`/design` and `/custom-designs`, and `curl /design.json` to see the
manifest.

The rest of this README walks through the same steps manually for projects
that prefer a hand-rolled wiring.

### 1. Declare your manifest

```elixir
defmodule MyAppWeb.DesignManifest do
  use JobyKit.Manifest

  alias MyAppWeb.{CoreComponents, DesignPreviews}

  category :core,
    label: "Core wrappers",
    description: "One wrapper per daisyUI primitive."

  category :composite,
    label: "Composites",
    description: "Multi-primitive patterns reused across domains."

  category :domain,
    label: "Domain composites",
    description: "Composites tied to a product area."

  component CoreComponents, :button,
    category: :core,
    daisy_basis: "btn",
    summary: "Standard text button.",
    preview: &DesignPreviews.button_preview/1

  component CoreComponents, :card,
    category: :core,
    daisy_basis: "card",
    summary: "Padded content surface.",
    preview: &DesignPreviews.card_preview/1

  # ...one component/3 call per host wrapper

  @doc """
  Tells JobyKit which daisyUI primitives are wrapped, so the catalogue
  rendering flips them to :wrapped and links to the matching signature card.
  """
  def daisy_overrides do
    %{
      button: %{wrapper: "<.button>", anchor: "#jobykit-component-myappweb-corecomponents-button"},
      card: %{wrapper: "<.card>", anchor: "#jobykit-component-myappweb-corecomponents-card"}
    }
  end
end
```

### 2. Write preview functions

```elixir
defmodule MyAppWeb.DesignPreviews do
  use Phoenix.Component
  # import your CoreComponents wrappers as needed

  def button_preview(assigns) do
    ~H"""
    <button class="btn btn-primary">Click me</button>
    """
  end

  # ...one *_preview/1 per registered component
end
```

### 3. Wire the routes

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :authenticated_json do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
    # plug your auth pipeline; the controller does not enforce auth
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/design", DesignSystemLive, :index
    live "/custom-designs", CustomDesignsLive, :index
  end

  scope "/" do
    pipe_through :authenticated_json

    get "/design.json", JobyKit.ManifestController, :show,
      private: %{joby_kit_manifest: MyAppWeb.DesignManifest}
  end
end
```

### 4. Wrap the page components

```elixir
defmodule MyAppWeb.DesignSystemLive do
  use MyAppWeb, :live_view

  def mount(_, _, socket), do: {:ok, assign(socket, page_title: "Design System")}
  def handle_event(_, _, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <JobyKit.PageComponent.page_component
        manifest={MyAppWeb.DesignManifest}
        custom_path={~p"/custom-designs"}
      />
    </Layouts.app>
    """
  end
end

defmodule MyAppWeb.CustomDesignsLive do
  use MyAppWeb, :live_view

  def mount(_, _, socket), do: {:ok, assign(socket, page_title: "Custom Designs")}
  def handle_event(_, _, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <JobyKit.PageComponent.custom_page_component
        manifest={MyAppWeb.DesignManifest}
        back_to={~p"/design"}
      />
    </Layouts.app>
    """
  end
end
```

That's it. Visit `/design` for the kit-curated catalogue; visit
`/custom-designs` for your app's composites; `curl /design.json` to fetch the
combined inventory for your AI agent.

## The contract

JobyKit ships a five-step **build order** every consumer's `/design` page
displays:

1. **Domain composite?** Use it. Lives in a domain-scoped component module
   in this app. Surfaces on the custom-designs page.
2. **Generic composite?** Use it. Multi-primitive pattern reused across
   domains in this app. Surfaces on the custom-designs page.
3. **Core wrapper?** Use it. One wrapper per daisyUI primitive, defined
   in `core_components`. Surfaces on the kit page.
4. **daisyUI primitive?** Wrap it as a core component first, then use the
   wrapper. The daisyUI catalogue at the bottom of `/design` lists every
   primitive.
5. **Build from tokens.** Tailwind + theme tokens only. Expose the result
   as a core wrapper or composite and register it in the manifest.

And a five-rule **wrapper contract** every host component must satisfy:

1. Declare every prop with `attr`.
2. Carry `data-component` on the root element.
3. Accept `:rest, :global`.
4. Internals compose tokens + daisyUI primitives only.
5. Register every component in the host manifest.

The agent surface (`/design.json`) is a single source of truth even when the
two pages render different subsets — kit core, generic composites, and
domain composites are all returned together with category labels.

## What ships

* **Runtime modules** — `JobyKit.Manifest`, `JobyKit.Contract`,
  `JobyKit.DaisyCatalogue`, `JobyKit.SignatureComponent`,
  `JobyKit.PageComponent`, `JobyKit.ManifestController`,
  `JobyKit.NavComponent`, and `JobyKit.CoreComponents` (kit-shipped
  wrappers: `<.button>`, `<.card>`, `<.icon>`, `<.input>`,
  `<.flash>`, `<.flash_group>`, `<.header>`, `<.list>`, `<.table>`).
* **Mix tasks** — `mix joby_kit.install` (existing app),
  `mix joby_kit.bootstrap` (greenfield over an existing phx.new),
  `mix joby_kit.gen.wrapper` (scaffold a contract-clean wrapper +
  manifest entry + preview), `mix joby_kit.lint` (verify the wrapper
  contract). These live in this package, so the version in your
  `mix.exs` is the one that runs.
  `mix joby_kit.new` (fresh app from scratch) ships separately as
  [joby_kit_new](https://github.com/jobycorp/joby_kit_new) — it must run
  before a project exists, and an archive carrying the in-project tasks
  would shadow every app's own dependency.
* **Patchers** — `JobyKit.AgentsMd` and `JobyKit.NavPatcher` keep
  AGENTS.md and the host's nav consistent with the kit's stance, both
  idempotent.

## License

MIT. See `LICENSE`.

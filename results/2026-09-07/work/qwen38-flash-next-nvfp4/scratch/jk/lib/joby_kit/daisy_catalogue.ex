defmodule JobyKit.DaisyCatalogue do
  # The daisyUI release this catalogue was verified against. Bump it in the
  # same commit that reconciles entries with a new daisy version.
  @daisy_version "5.7.16"

  @moduledoc """
  The canonical daisyUI primitive catalogue — every component daisy ships,
  organized by daisy's own categories.

  This is host-agnostic reference data. Each entry has a stable atom `:id`,
  the daisy class string, a default status (`:available` for normal
  primitives or `:reference` for ones that are listed for awareness only),
  and an optional note.

  ## daisyUI version

  The catalogue describes daisyUI #{@daisy_version} (see `daisy_version/0`).
  Entries introduced after 5.0 carry a `:since` key and say so in their
  note — a host pinned to an older daisy bundle will find those classes
  absent from its CSS. `assets/vendor/daisyui.js` is vendored per host,
  so check the host's own bundle before reaching for a `:since` entry.

  Hosts that have wrapped a primitive declare it via `daisy_overrides/0` on
  their manifest module:

      def daisy_overrides, do: %{
        button: %{wrapper: "<.button>", anchor: "#design-button"},
        badge:  %{wrapper: "<.badge>",  anchor: "#design-badge"}
      }

  The `merged/1` function applies those overrides to flip the matching
  entries to `:wrapped` and attach the wrapper label + anchor link.
  """

  use Phoenix.Component

  @categories [
    %{
      name: "Actions",
      description: "Buttons, dropdowns, modals, and other interactive triggers.",
      components: [
        %{id: :button, name: "Button", classes: "btn", default_status: :available},
        %{id: :dropdown, name: "Dropdown", classes: "dropdown", default_status: :available},
        %{
          id: :fab,
          name: "FAB / Speed Dial",
          docs_slug: "fab",
          classes: "fab",
          default_status: :reference,
          note: "Mobile floating action."
        },
        %{id: :modal, name: "Modal", classes: "modal", default_status: :available},
        %{id: :swap, name: "Swap", classes: "swap", default_status: :available},
        %{
          id: :theme_controller,
          name: "Theme Controller",
          classes: "theme-controller",
          default_status: :available
        }
      ]
    },
    %{
      name: "Data display",
      description: "Cards, badges, tables, lists, and read-only surfaces.",
      components: [
        %{
          id: :accordion,
          name: "Accordion",
          classes: "collapse + radio",
          default_status: :available,
          note: "Compose collapse with radio inputs for one-open behavior."
        },
        %{id: :avatar, name: "Avatar", classes: "avatar", default_status: :available},
        %{id: :badge, name: "Badge", classes: "badge", default_status: :available},
        %{id: :card, name: "Card", classes: "card", default_status: :available},
        %{id: :carousel, name: "Carousel", classes: "carousel", default_status: :reference},
        %{
          id: :chat_bubble,
          name: "Chat bubble",
          docs_slug: "chat",
          classes: "chat / chat-bubble",
          default_status: :available
        },
        %{id: :collapse, name: "Collapse", classes: "collapse", default_status: :available},
        %{id: :countdown, name: "Countdown", classes: "countdown", default_status: :reference},
        %{id: :diff, name: "Diff", classes: "diff", default_status: :reference},
        %{
          id: :hover_gallery,
          name: "Hover Gallery",
          classes: "hover-gallery",
          default_status: :reference,
          since: "5.1",
          note: "Requires daisyUI 5.1+."
        },
        %{id: :kbd, name: "Kbd", classes: "kbd", default_status: :available},
        %{id: :list, name: "List", classes: "list", default_status: :available},
        %{id: :stat, name: "Stat", classes: "stats / stat", default_status: :available},
        %{id: :status, name: "Status", classes: "status", default_status: :available},
        %{id: :table, name: "Table", classes: "table", default_status: :available},
        %{
          id: :text_rotate,
          name: "Text Rotate",
          classes: "text-rotate",
          default_status: :reference,
          since: "5.5",
          note: "Requires daisyUI 5.5+."
        },
        %{id: :timeline, name: "Timeline", classes: "timeline", default_status: :available}
      ]
    },
    %{
      name: "Navigation",
      description: "Wayfinding, tabs, breadcrumbs, and pagination.",
      components: [
        %{
          id: :breadcrumbs,
          name: "Breadcrumbs",
          classes: "breadcrumbs",
          default_status: :available
        },
        %{
          id: :dock,
          name: "Dock",
          classes: "dock",
          default_status: :reference,
          note: "Mobile-style bottom dock."
        },
        %{id: :link, name: "Link", classes: "link", default_status: :available},
        %{
          id: :mega_menu,
          name: "Mega Menu",
          docs_slug: "megamenu",
          classes: "megamenu",
          default_status: :reference,
          since: "5.6",
          note: "Requires daisyUI 5.6+."
        },
        %{id: :menu, name: "Menu", classes: "menu", default_status: :available},
        %{id: :navbar, name: "Navbar", classes: "navbar", default_status: :available},
        %{
          id: :pagination,
          name: "Pagination",
          classes: "join + buttons",
          default_status: :available,
          note: "Compose join with buttons for paged controls."
        },
        %{id: :steps, name: "Steps", classes: "steps", default_status: :available},
        %{id: :tab, name: "Tab", classes: "tabs / tab", default_status: :available}
      ]
    },
    %{
      name: "Feedback",
      description: "Alerts, loading, progress, and ephemeral notices.",
      components: [
        %{id: :alert, name: "Alert", classes: "alert", default_status: :available},
        %{id: :loading, name: "Loading", classes: "loading", default_status: :available},
        %{id: :progress, name: "Progress", classes: "progress", default_status: :available},
        %{
          id: :radial_progress,
          name: "Radial progress",
          classes: "radial-progress",
          default_status: :available
        },
        %{id: :skeleton, name: "Skeleton", classes: "skeleton", default_status: :available},
        %{id: :toast, name: "Toast", classes: "toast", default_status: :available},
        %{id: :tooltip, name: "Tooltip", classes: "tooltip", default_status: :available}
      ]
    },
    %{
      name: "Data input",
      description: "Form controls. Use a wrapped form input before reaching for raw classes.",
      components: [
        %{
          id: :calendar,
          name: "Calendar",
          classes: "calendar (cally / pikaday)",
          default_status: :reference
        },
        %{id: :checkbox, name: "Checkbox", classes: "checkbox", default_status: :available},
        %{id: :fieldset, name: "Fieldset", classes: "fieldset", default_status: :available},
        %{id: :file_input, name: "File Input", classes: "file-input", default_status: :available},
        %{id: :filter, name: "Filter", classes: "filter", default_status: :available},
        %{id: :label, name: "Label", classes: "label", default_status: :available},
        %{
          id: :otp,
          name: "OTP",
          classes: "otp",
          default_status: :available,
          since: "5.6",
          note: "One-time-password input. Requires daisyUI 5.6+."
        },
        %{id: :radio, name: "Radio", classes: "radio", default_status: :available},
        %{id: :range, name: "Range", classes: "range", default_status: :available},
        %{id: :rating, name: "Rating", classes: "rating", default_status: :reference},
        %{id: :select, name: "Select", classes: "select", default_status: :available},
        %{
          id: :text_input,
          name: "Text Input",
          docs_slug: "input",
          classes: "input",
          default_status: :available
        },
        %{id: :textarea, name: "Textarea", classes: "textarea", default_status: :available},
        %{id: :toggle, name: "Toggle", classes: "toggle", default_status: :available},
        %{id: :validator, name: "Validator", classes: "validator", default_status: :available}
      ]
    },
    %{
      name: "Layout",
      description: "Page-level chrome, dividers, sidebars, and grouping.",
      components: [
        %{id: :divider, name: "Divider", classes: "divider", default_status: :available},
        %{
          id: :aura,
          name: "Aura",
          classes: "aura",
          default_status: :reference,
          since: "5.6",
          note: "Decorative glow. Requires daisyUI 5.6+."
        },
        %{
          id: :drawer,
          name: "Drawer sidebar",
          docs_slug: "drawer",
          classes: "drawer",
          default_status: :reference,
          note: "Often replaced by custom layouts."
        },
        %{id: :footer, name: "Footer", classes: "footer", default_status: :reference},
        %{
          id: :hero,
          name: "Hero",
          classes: "hero",
          default_status: :reference,
          note: "Marketing-style; product surfaces typically use card."
        },
        %{
          id: :hover_3d,
          name: "Hover 3D",
          classes: "hover-3d",
          default_status: :reference,
          since: "5.5",
          note: "Decorative tilt. Requires daisyUI 5.5+."
        },
        %{id: :indicator, name: "Indicator", classes: "indicator", default_status: :available},
        %{
          id: :join,
          name: "Join",
          classes: "join",
          default_status: :available,
          note: "Group buttons or inputs for segmented controls."
        },
        %{
          id: :mask,
          name: "Mask",
          classes: "mask",
          default_status: :reference,
          note: "Decorative shape masks."
        },
        %{
          id: :stack,
          name: "Stack",
          classes: "stack",
          default_status: :reference,
          note: "Use Tailwind grid/flex instead."
        }
      ]
    },
    %{
      name: "Mockup",
      description: "Decorative containers; useful for product screenshots and demos.",
      components: [
        %{
          id: :browser_mockup,
          name: "Browser mockup",
          docs_slug: "mockup-browser",
          classes: "mockup-browser",
          default_status: :reference
        },
        %{
          id: :code_mockup,
          name: "Code mockup",
          docs_slug: "mockup-code",
          classes: "mockup-code",
          default_status: :reference
        },
        %{
          id: :phone_mockup,
          name: "Phone mockup",
          docs_slug: "mockup-phone",
          classes: "mockup-phone",
          default_status: :reference
        },
        %{
          id: :window_mockup,
          name: "Window mockup",
          docs_slug: "mockup-window",
          classes: "mockup-window",
          default_status: :reference
        }
      ]
    }
  ]

  @doc "Static catalogue with default statuses; no host-specific overrides applied."
  def categories, do: @categories

  @doc """
  Returns the catalogue with host overrides applied.

  Walks the manifest module's `daisy_overrides/0` map (a `%{id => %{wrapper, anchor}}`
  mapping) and flips matching entries from `default_status` to `:wrapped`,
  attaching the wrapper label and anchor for cross-linking.
  """
  def merged(manifest_module) do
    # Code.ensure_loaded? first: function_exported?/3 answers false for a
    # module that simply hasn't been loaded yet, which silently drops every
    # override and shows wrapped primitives as unwrapped.
    # The kit knows which primitives it wraps; the host adds any it wraps
    # itself. Host entries win on conflict, since an app that has built
    # its own wrapper for a primitive should link to that one.
    host_overrides =
      if Code.ensure_loaded?(manifest_module) and
           function_exported?(manifest_module, :daisy_overrides, 0),
         do: manifest_module.daisy_overrides(),
         else: %{}

    overrides = Map.merge(kit_overrides(), host_overrides)

    Enum.map(@categories, fn category ->
      Map.update!(category, :components, fn components ->
        Enum.map(components, &resolve(&1, overrides))
      end)
    end)
  end

  # Guarded because KitManifest is compiled after this module in some
  # orders, and because a host could call merged/1 very early.
  defp kit_overrides do
    if Code.ensure_loaded?(JobyKit.KitManifest) and
         function_exported?(JobyKit.KitManifest, :daisy_overrides, 0) do
      JobyKit.KitManifest.daisy_overrides()
    else
      %{}
    end
  end

  defp resolve(component, overrides) do
    base = Map.put(component, :status, component.default_status)

    case Map.get(overrides, component.id) do
      nil ->
        base
        |> Map.put(:wrapper, nil)
        |> Map.put(:anchor, nil)

      override ->
        base
        |> Map.put(:status, :wrapped)
        |> Map.put(:wrapper, Map.get(override, :wrapper))
        |> Map.put(:anchor, Map.get(override, :anchor))
    end
  end

  @doc """
  The daisyUI release this catalogue was verified against.

  Hosts vendor their own `assets/vendor/daisyui.js`, so this is the
  version the catalogue *describes*, not necessarily the one a given app
  ships. Compare the two before trusting a `:since` entry.
  """
  def daisy_version, do: @daisy_version

  @doc "Slug helper: turns a category or component name into a stable URL fragment."
  def slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  @doc """
  Returns the daisyUI documentation URL for a primitive.

  Pass a catalogue entry to honour its `:docs_slug`; passing a bare name
  derives the slug from the display name, which is right for most
  entries but 404s wherever our label differs from daisy's URL (e.g.
  "Chat bubble" → `/components/chat/`). Prefer the entry form.
  """
  def docs_url(%{} = component) do
    slug = Map.get(component, :docs_slug) || derive_docs_slug(component.name)
    "https://daisyui.com/components/" <> slug <> "/"
  end

  def docs_url(name) when is_binary(name) do
    "https://daisyui.com/components/" <> derive_docs_slug(name) <> "/"
  end

  defp derive_docs_slug(name) do
    name
    |> String.downcase()
    |> String.replace("/", " ")
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  @doc """
  Renders the small live-demo for a daisy primitive, dispatched on its `:id`.

  Used inside each catalogue card so consumers see a working example beside
  the class string.
  """
  attr :id, :atom, required: true

  def demo(%{id: :button} = assigns) do
    ~H"""
    <button type="button" class="btn btn-sm btn-primary">Action</button>
    """
  end

  def demo(%{id: :dropdown} = assigns) do
    ~H"""
    <div class="dropdown">
      <div tabindex="0" role="button" class="btn btn-sm">Open</div>
      <ul tabindex="0" class="dropdown-content menu z-10 w-32 rounded-box bg-base-100 p-2 shadow">
        <li><a>One</a></li>
        <li><a>Two</a></li>
      </ul>
    </div>
    """
  end

  def demo(%{id: :fab} = assigns) do
    ~H"""
    <button type="button" class="btn btn-circle btn-primary">+</button>
    """
  end

  def demo(%{id: :modal} = assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-200/60 px-3 py-2 text-xs text-base-content/60">
      <code>&lt;dialog class="modal"&gt;</code>
    </div>
    """
  end

  def demo(%{id: :swap} = assigns) do
    ~H"""
    <label class="swap swap-rotate">
      <input type="checkbox" />
      <span class="swap-on">☀</span>
      <span class="swap-off">☾</span>
    </label>
    """
  end

  def demo(%{id: :theme_controller} = assigns) do
    ~H"""
    <input type="checkbox" value="dark" class="toggle theme-controller" />
    """
  end

  def demo(%{id: :accordion} = assigns) do
    ~H"""
    <div class="collapse collapse-arrow w-full bg-base-100 text-xs">
      <input type="checkbox" />
      <div class="collapse-title min-h-0 py-1.5">Section</div>
    </div>
    """
  end

  def demo(%{id: :avatar} = assigns) do
    ~H"""
    <div class="avatar avatar-placeholder">
      <div class="size-9 rounded-full bg-neutral text-neutral-content">
        <span class="text-xs">JV</span>
      </div>
    </div>
    """
  end

  def demo(%{id: :badge} = assigns) do
    ~H"""
    <div class="flex gap-1.5">
      <span class="badge badge-primary">primary</span>
      <span class="badge badge-soft">soft</span>
    </div>
    """
  end

  def demo(%{id: :card} = assigns) do
    # `card-sm`, not v4's `card-compact` — daisyUI 5 replaced the single
    # compact modifier with the card-xs/sm/md/lg/xl scale.
    ~H"""
    <div class="card card-sm w-full bg-base-200/60 text-xs">
      <div class="card-body">
        <p class="card-title text-sm">Card title</p>
      </div>
    </div>
    """
  end

  def demo(%{id: :carousel} = assigns) do
    ~H"""
    <div class="carousel rounded-box w-full">
      <div class="carousel-item h-9 w-12 bg-primary/30"></div>
      <div class="carousel-item h-9 w-12 bg-info/30"></div>
      <div class="carousel-item h-9 w-12 bg-success/30"></div>
    </div>
    """
  end

  def demo(%{id: :chat_bubble} = assigns) do
    ~H"""
    <div class="chat chat-start">
      <div class="chat-bubble chat-bubble-primary text-xs">Hello</div>
    </div>
    """
  end

  def demo(%{id: :collapse} = assigns) do
    ~H"""
    <div class="collapse w-full bg-base-100 text-xs">
      <input type="checkbox" />
      <div class="collapse-title min-h-0 py-1.5">Click to expand</div>
    </div>
    """
  end

  def demo(%{id: :countdown} = assigns) do
    ~H"""
    <span class="countdown font-mono text-base">
      <span style="--value:12;"></span>:<span style="--value:34;"></span>
    </span>
    """
  end

  def demo(%{id: :diff} = assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-200/60 px-3 py-2 text-xs text-base-content/60">
      <code>diff before / after</code>
    </div>
    """
  end

  def demo(%{id: :kbd} = assigns) do
    ~H"""
    <div class="flex gap-1">
      <kbd class="kbd kbd-sm">⌘</kbd>
      <kbd class="kbd kbd-sm">K</kbd>
    </div>
    """
  end

  def demo(%{id: :list} = assigns) do
    ~H"""
    <ul class="list w-full bg-base-100 text-xs rounded-box">
      <li class="list-row px-3 py-1.5">Row one</li>
      <li class="list-row px-3 py-1.5">Row two</li>
    </ul>
    """
  end

  def demo(%{id: :stat} = assigns) do
    ~H"""
    <div class="stats bg-base-100 text-xs shadow">
      <div class="stat px-3 py-2">
        <p class="stat-title text-[0.65rem]">Cast</p>
        <p class="stat-value text-base">12</p>
      </div>
    </div>
    """
  end

  def demo(%{id: :status} = assigns) do
    ~H"""
    <div class="flex items-center gap-2 text-xs">
      <span class="status status-success" /> online
    </div>
    """
  end

  def demo(%{id: :table} = assigns) do
    ~H"""
    <table class="table table-xs w-full">
      <thead>
        <tr><th>Name</th><th>State</th></tr>
      </thead>
      <tbody>
        <tr><td>Maeve</td><td>active</td></tr>
      </tbody>
    </table>
    """
  end

  def demo(%{id: :timeline} = assigns) do
    ~H"""
    <ul class="timeline timeline-compact text-xs">
      <li>
        <div class="timeline-start">10:00</div>
        <div class="timeline-middle">
          <span class="size-1.5 rounded-full bg-primary" />
        </div>
        <div class="timeline-end">Event</div>
      </li>
    </ul>
    """
  end

  def demo(%{id: :breadcrumbs} = assigns) do
    ~H"""
    <div class="breadcrumbs text-xs">
      <ul><li>Home</li><li>Section</li><li>Page</li></ul>
    </div>
    """
  end

  def demo(%{id: :dock} = assigns) do
    ~H"""
    <div class="dock dock-xs static w-full">
      <button class="dock-active">A</button>
      <button>B</button>
      <button>C</button>
    </div>
    """
  end

  def demo(%{id: :link} = assigns) do
    ~H"""
    <a class="link link-primary text-xs">Open</a>
    """
  end

  def demo(%{id: :menu} = assigns) do
    ~H"""
    <ul class="menu menu-xs w-full bg-base-100 rounded-box">
      <li><a>Overview</a></li>
      <li><a>Settings</a></li>
    </ul>
    """
  end

  def demo(%{id: :navbar} = assigns) do
    ~H"""
    <div class="navbar min-h-0 rounded-box bg-base-100 px-2 py-1 text-xs">
      <span class="font-semibold">App</span>
    </div>
    """
  end

  def demo(%{id: :pagination} = assigns) do
    ~H"""
    <div class="join">
      <button class="btn btn-xs join-item">«</button>
      <button class="btn btn-xs join-item btn-active">1</button>
      <button class="btn btn-xs join-item">2</button>
      <button class="btn btn-xs join-item">»</button>
    </div>
    """
  end

  def demo(%{id: :steps} = assigns) do
    ~H"""
    <ul class="steps text-xs">
      <li class="step step-primary">A</li>
      <li class="step step-primary">B</li>
      <li class="step">C</li>
    </ul>
    """
  end

  def demo(%{id: :tab} = assigns) do
    ~H"""
    <div role="tablist" class="tabs tabs-box tabs-xs">
      <a role="tab" class="tab tab-active">One</a>
      <a role="tab" class="tab">Two</a>
    </div>
    """
  end

  def demo(%{id: :alert} = assigns) do
    ~H"""
    <div class="alert alert-info py-2 text-xs">
      <span>info notice</span>
    </div>
    """
  end

  def demo(%{id: :loading} = assigns) do
    ~H"""
    <div class="flex gap-2">
      <span class="loading loading-spinner loading-xs" />
      <span class="loading loading-dots loading-xs" />
    </div>
    """
  end

  def demo(%{id: :progress} = assigns) do
    ~H"""
    <progress class="progress progress-primary w-full" value="64" max="100" />
    """
  end

  def demo(%{id: :radial_progress} = assigns) do
    ~H"""
    <div
      class="radial-progress text-primary text-xs"
      style="--value:70; --size:2.5rem; --thickness:3px;"
    >
      70%
    </div>
    """
  end

  def demo(%{id: :skeleton} = assigns) do
    ~H"""
    <div class="flex w-full flex-col gap-1">
      <div class="skeleton h-2 w-full"></div>
      <div class="skeleton h-2 w-3/4"></div>
    </div>
    """
  end

  def demo(%{id: :toast} = assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-200/60 px-3 py-2 text-xs text-base-content/60">
      <code>&lt;div class="toast"&gt;</code>
    </div>
    """
  end

  def demo(%{id: :tooltip} = assigns) do
    ~H"""
    <div class="tooltip tooltip-open" data-tip="Hint">
      <button class="btn btn-xs">Hover</button>
    </div>
    """
  end

  def demo(%{id: :calendar} = assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-200/60 px-3 py-2 text-xs text-base-content/60">
      <code>cally / pikaday</code>
    </div>
    """
  end

  def demo(%{id: :checkbox} = assigns) do
    ~H"""
    <div class="flex items-center gap-2 text-xs">
      <input type="checkbox" class="checkbox checkbox-sm" checked /> ready
    </div>
    """
  end

  def demo(%{id: :fieldset} = assigns) do
    ~H"""
    <fieldset class="fieldset w-full text-xs">
      <legend class="fieldset-legend">Group</legend>
      <input type="text" class="input input-xs" placeholder="value" />
    </fieldset>
    """
  end

  def demo(%{id: :file_input} = assigns) do
    ~H"""
    <input type="file" class="file-input file-input-xs w-full" />
    """
  end

  def demo(%{id: :filter} = assigns) do
    ~H"""
    <form class="filter">
      <input class="btn btn-square btn-xs" type="reset" value="×" />
      <input class="btn btn-xs" type="radio" name="f" aria-label="A" />
      <input class="btn btn-xs" type="radio" name="f" aria-label="B" />
    </form>
    """
  end

  def demo(%{id: :label} = assigns) do
    # daisyUI 5 dropped v4's `form-control` / `label-text` pairing; the
    # label class itself now styles its text children.
    ~H"""
    <label class="label cursor-pointer text-xs">
      <input type="checkbox" class="checkbox checkbox-xs" checked />
      Field label
    </label>
    """
  end

  def demo(%{id: :radio} = assigns) do
    ~H"""
    <div class="flex items-center gap-2 text-xs">
      <input type="radio" name="r" class="radio radio-xs" checked />
      <input type="radio" name="r" class="radio radio-xs" />
    </div>
    """
  end

  def demo(%{id: :range} = assigns) do
    ~H"""
    <input type="range" min="0" max="100" value="40" class="range range-primary range-xs w-full" />
    """
  end

  def demo(%{id: :rating} = assigns) do
    ~H"""
    <div class="rating rating-xs">
      <input type="radio" name="rate" class="mask mask-star-2 bg-warning" />
      <input type="radio" name="rate" class="mask mask-star-2 bg-warning" checked />
      <input type="radio" name="rate" class="mask mask-star-2 bg-warning" />
    </div>
    """
  end

  def demo(%{id: :select} = assigns) do
    ~H"""
    <select class="select select-xs w-full">
      <option>one</option>
      <option>two</option>
    </select>
    """
  end

  def demo(%{id: :text_input} = assigns) do
    ~H"""
    <input type="text" class="input input-xs w-full" placeholder="text" />
    """
  end

  def demo(%{id: :textarea} = assigns) do
    ~H"""
    <textarea class="textarea textarea-xs w-full" rows="2" placeholder="textarea"></textarea>
    """
  end

  def demo(%{id: :toggle} = assigns) do
    ~H"""
    <input type="checkbox" class="toggle toggle-sm" checked />
    """
  end

  def demo(%{id: :validator} = assigns) do
    ~H"""
    <input type="email" class="input input-xs validator w-full" required placeholder="email" />
    """
  end

  def demo(%{id: :divider} = assigns) do
    ~H"""
    <div class="w-full">
      <div class="divider my-0 text-xs">or</div>
    </div>
    """
  end

  def demo(%{id: :drawer} = assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-200/60 px-3 py-2 text-xs text-base-content/60">
      <code>&lt;div class="drawer"&gt;</code>
    </div>
    """
  end

  def demo(%{id: :footer} = assigns) do
    ~H"""
    <footer class="footer footer-horizontal w-full bg-base-100 px-3 py-1 text-[0.65rem]">
      <p>© App</p>
    </footer>
    """
  end

  def demo(%{id: :hero} = assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-200/60 px-3 py-2 text-xs text-base-content/60">
      <code>&lt;section class="hero"&gt;</code>
    </div>
    """
  end

  def demo(%{id: :indicator} = assigns) do
    ~H"""
    <div class="indicator">
      <span class="indicator-item badge badge-xs badge-primary"></span>
      <button class="btn btn-xs">Inbox</button>
    </div>
    """
  end

  def demo(%{id: :join} = assigns) do
    ~H"""
    <div class="join">
      <button class="btn btn-xs join-item">A</button>
      <button class="btn btn-xs join-item btn-active">B</button>
      <button class="btn btn-xs join-item">C</button>
    </div>
    """
  end

  def demo(%{id: :mask} = assigns) do
    ~H"""
    <div class="mask mask-hexagon size-9 bg-primary"></div>
    """
  end

  def demo(%{id: :stack} = assigns) do
    ~H"""
    <div class="stack">
      <div class="size-9 rounded-box bg-primary/40"></div>
      <div class="size-9 rounded-box bg-info/40"></div>
      <div class="size-9 rounded-box bg-success/40"></div>
    </div>
    """
  end

  def demo(%{id: :browser_mockup} = assigns) do
    ~H"""
    <div class="mockup-browser w-full border border-base-300 bg-base-200/60 text-[0.6rem]">
      <div class="mockup-browser-toolbar"><div class="input text-[0.6rem]">/</div></div>
    </div>
    """
  end

  def demo(%{id: :code_mockup} = assigns) do
    ~H"""
    <div class="mockup-code w-full text-[0.6rem]">
      <pre data-prefix="$"><code>mix phx.server</code></pre>
    </div>
    """
  end

  def demo(%{id: :phone_mockup} = assigns) do
    ~H"""
    <div class="rounded-box border border-base-300 bg-base-200/60 px-3 py-2 text-xs text-base-content/60">
      <code>&lt;div class="mockup-phone"&gt;</code>
    </div>
    """
  end

  def demo(%{id: :window_mockup} = assigns) do
    ~H"""
    <div class="mockup-window w-full border border-base-300 bg-base-200/60 text-[0.6rem]">
      <div class="bg-base-100 px-2 py-1">window body</div>
    </div>
    """
  end

  # ------------------------------------------------------------------
  # Post-5.0 additions. These render as plain markup on a host whose
  # vendored daisy bundle predates the entry's :since — the classes
  # simply aren't in its CSS.

  def demo(%{id: :otp} = assigns) do
    ~H"""
    <div class="otp otp-sm">
      <input value="4" size="1" readonly />
      <input value="2" size="1" readonly />
      <input value="7" size="1" readonly />
      <input value="9" size="1" readonly />
    </div>
    """
  end

  def demo(%{id: :hover_gallery} = assigns) do
    ~H"""
    <div class="hover-gallery h-12 w-full overflow-hidden rounded">
      <div class="size-full bg-primary/30" />
      <div class="size-full bg-secondary/30" />
      <div class="size-full bg-accent/30" />
    </div>
    """
  end

  def demo(%{id: :hover_3d} = assigns) do
    ~H"""
    <div class="hover-3d size-12 rounded bg-base-300/70 text-[0.6rem]">
      <div class="flex size-full items-center justify-center">tilt</div>
    </div>
    """
  end

  def demo(%{id: :text_rotate} = assigns) do
    ~H"""
    <span class="text-rotate text-xs font-semibold">daisyUI</span>
    """
  end

  def demo(%{id: :aura} = assigns) do
    ~H"""
    <div class="aura aura-sm size-12 rounded bg-base-300/70" />
    """
  end

  def demo(%{id: :mega_menu} = assigns) do
    ~H"""
    <div class="megamenu megamenu-sm text-xs">
      <ul>
        <li><a>Products</a></li>
        <li><a>Docs</a></li>
      </ul>
    </div>
    """
  end

  def demo(assigns) do
    ~H"""
    <span class="text-[0.65rem] text-base-content/45">no demo</span>
    """
  end
end

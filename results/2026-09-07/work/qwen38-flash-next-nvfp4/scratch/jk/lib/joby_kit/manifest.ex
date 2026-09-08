defmodule JobyKit.Manifest do
  @moduledoc """
  Behaviour and DSL for declaring a JobyKit design-system manifest.

  A host module `use`s this behaviour and registers its component inventory
  with the `category/2` and `component/3` macros. At compile time, the
  callbacks `entries/0`, `by_category/0`, `categories/0`, `category_label/1`,
  `category_description/1`, and `fetch/2` are generated automatically.

  ## Example

      defmodule MyAppWeb.DesignManifest do
        use JobyKit.Manifest

        category :core,
          label: "Core wrappers",
          description: "One wrapper per daisyUI primitive."

        category :composite,
          label: "Generic composites",
          description: "Multi-primitive patterns reused across domains."

        component MyAppWeb.CoreComponents, :button,
          category: :core,
          daisy_basis: "btn",
          summary: "Text button family.",
          preview: &MyAppWeb.DesignPreviews.button/1

        component MyAppWeb.UIComponents, :listing_card,
          category: :composite,
          summary: "Navigable directory entry.",
          preview: &MyAppWeb.DesignPreviews.listing_card/1
      end

  ## Entry shape

  Each entry returned by `entries/0` is a map with these keys:

    * `:module` — the module the component is defined in
    * `:function` — the component function name
    * `:category` — `:core`, `:composite`, `:domain`, or any custom atom
    * `:label` — human-readable label
    * `:daisy_basis` — daisy class(es) the wrapper composes (or `nil`)
    * `:summary` — one-line description
    * `:anchor` — page anchor for cross-linking (or `nil`)
    * `:preview` — optional 1-arity function returning HEEX
    * `:attrs` — list of attr maps introspected from the component
    * `:slots` — list of slot maps introspected from the component
    * `:line` — source line of the component definition (or `nil`)
    * `:data_component` — the canonical "Module.function" string for
      the `data-component` attribute on the rendered element
    * `:source` — relative source path (or `nil`)
  """

  @type entry :: %{
          required(:module) => module(),
          required(:function) => atom(),
          required(:category) => atom(),
          required(:label) => String.t(),
          required(:daisy_basis) => String.t() | nil,
          required(:summary) => String.t() | nil,
          required(:anchor) => String.t() | nil,
          required(:preview) => (map() -> Phoenix.LiveView.Rendered.t()) | nil,
          required(:attrs) => [attr_meta()],
          required(:slots) => [slot_meta()],
          required(:line) => integer() | nil,
          required(:data_component) => String.t(),
          required(:source) => String.t() | nil
        }

  @type attr_meta :: %{
          required(:name) => String.t(),
          required(:type) => String.t(),
          required(:required) => boolean(),
          required(:default) => term() | nil,
          required(:values) => [String.t()] | nil,
          required(:doc) => String.t() | nil
        }

  @type slot_meta :: %{
          required(:name) => String.t(),
          required(:required) => boolean(),
          required(:doc) => String.t() | nil
        }

  @type category_spec :: {atom(), keyword()}

  @callback entries() :: [entry()]
  @callback by_category() :: [{atom(), [entry()]}]
  @callback categories() :: [atom()]
  @callback category_label(atom()) :: String.t()
  @callback category_description(atom()) :: String.t()
  @callback fetch(module(), atom()) :: entry() | nil

  @doc """
  Tells `JobyKit.DaisyCatalogue` which daisy primitives this app wraps.

  Optional. Declared as a callback so a misspelling (`daisy_override/0`)
  is a compile-time warning instead of a silent no-op that leaves every
  wrapped primitive showing as unwrapped.
  """
  @callback daisy_overrides() :: %{optional(atom()) => %{optional(atom()) => String.t()}}

  @optional_callbacks daisy_overrides: 0

  defmacro __using__(_opts) do
    quote do
      @behaviour JobyKit.Manifest
      import JobyKit.Manifest, only: [component: 3, category: 2]

      Module.register_attribute(__MODULE__, :joby_kit_components, accumulate: true)
      Module.register_attribute(__MODULE__, :joby_kit_categories, accumulate: true)

      @before_compile JobyKit.Manifest
    end
  end

  @doc """
  Register a category. Pass `:label` (human-readable) and `:description`
  (one-line) in `opts`.

      category :core,
        label: "Core wrappers",
        description: "One wrapper per daisyUI primitive."
  """
  defmacro category(name, opts) do
    quote bind_quoted: [name: name, opts: opts] do
      @joby_kit_categories {name, opts}
    end
  end

  @doc """
  Register a component.

  ## Options

    * `:category` — required atom matching one of the declared categories
    * `:label` — defaults to the function name capitalized
    * `:daisy_basis` — daisy class(es) the wrapper composes
    * `:summary` — one-line description
    * `:anchor` — page anchor (defaults to `nil`; the page derives one)
    * `:preview` — optional 1-arity function returning HEEX
  """
  defmacro component(module, function, opts) do
    quote bind_quoted: [module: module, function: function, opts: opts] do
      @joby_kit_components {module, function, opts}
    end
  end

  defmacro __before_compile__(env) do
    components = Module.get_attribute(env.module, :joby_kit_components) |> Enum.reverse()
    categories = Module.get_attribute(env.module, :joby_kit_categories) |> Enum.reverse()

    validate_categories!(env.module, components, categories)

    quote do
      @impl JobyKit.Manifest
      def entries, do: JobyKit.Manifest.enrich(unquote(Macro.escape(components)))

      @impl JobyKit.Manifest
      def categories, do: Enum.map(unquote(Macro.escape(categories)), &elem(&1, 0))

      @impl JobyKit.Manifest
      def category_label(category) do
        case List.keyfind(unquote(Macro.escape(categories)), category, 0) do
          {_, opts} -> Keyword.fetch!(opts, :label)
          nil -> raise ArgumentError, "unknown category: #{inspect(category)}"
        end
      end

      @impl JobyKit.Manifest
      def category_description(category) do
        case List.keyfind(unquote(Macro.escape(categories)), category, 0) do
          {_, opts} -> Keyword.get(opts, :description, "")
          nil -> raise ArgumentError, "unknown category: #{inspect(category)}"
        end
      end

      @impl JobyKit.Manifest
      def by_category do
        grouped = entries() |> Enum.group_by(& &1.category)

        Enum.map(categories(), fn category ->
          {category, Map.get(grouped, category, []) |> Enum.sort_by(& &1.label)}
        end)
      end

      @impl JobyKit.Manifest
      def fetch(module, function) do
        Enum.find(entries(), &(&1.module == module and &1.function == function))
      end
    end
  end

  @doc false
  # An entry registered under a category that was never declared is
  # dropped by `by_category/0`, which only walks declared categories — so
  # the component vanishes from /design and /custom-designs while still
  # appearing in entries() and /design.json. Silent invisibility is the
  # exact failure this kit exists to prevent, so it is a compile error.
  #
  # Anonymous preview functions are caught here too: they reach
  # `Macro.escape/1` in the generated `entries/0` and blow up with
  # "cannot escape #Function<...>", which says nothing about the
  # `component/3` line that caused it.
  def validate_categories!(module, components, categories) do
    declared = MapSet.new(categories, &elem(&1, 0))

    for {comp_module, function, opts} <- components do
      category = Keyword.fetch!(opts, :category)

      unless MapSet.member?(declared, category) do
        raise ArgumentError, """
        #{inspect(module)} registers #{inspect(comp_module)}.#{function} under         category #{inspect(category)}, which is not declared.

        Declared categories: #{declared |> Enum.sort() |> Enum.map_join(", ", &inspect/1)}

        Add a `category #{inspect(category)}, label: "...", description: "..."`         line, or correct the component's `category:`. Left as is, the         component would be invisible on /design and /custom-designs.
        """
      end

      case Keyword.get(opts, :preview) do
        nil ->
          :ok

        fun when is_function(fun, 1) ->
          unless Function.info(fun, :type) == {:type, :external} do
            raise ArgumentError, """
            #{inspect(module)} registers #{inspect(comp_module)}.#{function} with an             anonymous preview function.

            Previews are stored at compile time, so they have to be remote             captures: `preview: &MyAppWeb.DesignPreviews.thing_preview/1`, not             `preview: fn assigns -> ... end`.
            """
          end

        other ->
          raise ArgumentError, """
          #{inspect(module)} registers #{inspect(comp_module)}.#{function} with an           invalid `preview:` — expected a 1-arity function capture, got           #{inspect(other)}.
          """
      end
    end

    :ok
  end

  @doc """
  Enrich raw component registrations with introspected attrs/slots/source.

  Called at runtime by the generated `entries/0` callback. Applied to each
  `{module, function, opts}` registration in declaration order.
  """
  def enrich(component_registrations) do
    Enum.map(component_registrations, fn {module, function, opts} ->
      meta = component_meta(module, function)

      %{
        module: module,
        function: function,
        category: Keyword.fetch!(opts, :category),
        label: Keyword.get(opts, :label, default_label(function)),
        daisy_basis: Keyword.get(opts, :daisy_basis),
        summary: Keyword.get(opts, :summary),
        anchor: Keyword.get(opts, :anchor),
        preview: Keyword.get(opts, :preview),
        attrs: simplify_attrs(meta[:attrs] || []),
        slots: simplify_slots(meta[:slots] || []),
        line: meta[:line],
        data_component: "#{inspect(module)}.#{function}",
        source: source_path(module),
        forked_from_kit: forked_from_kit?(module, function)
      }
    end)
  end

  @doc """
  Whether this entry shadows a kit component with a host-owned copy.

  An entry registered under a name the kit also ships, but pointing at a
  module other than `JobyKit.CoreComponents`, is a fork: kit fixes to
  that component never reach this app. Surfaced on `/design` and in
  `/design.json` so "did that fix reach us?" is a lookup rather than an
  archaeology exercise.
  """
  @spec forked_from_kit?(module(), atom()) :: boolean()
  def forked_from_kit?(JobyKit.CoreComponents, _function), do: false

  def forked_from_kit?(_module, function) do
    Code.ensure_loaded?(JobyKit.CoreComponents) and
      function_exported?(JobyKit.CoreComponents, :__components__, 0) and
      Map.has_key?(JobyKit.CoreComponents.__components__(), function)
  end

  defp default_label(function) do
    function
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp component_meta(module, function) do
    if function_exported?(module, :__components__, 0) do
      Map.get(module.__components__(), function, %{})
    else
      %{}
    end
  end

  defp simplify_attrs(attrs) do
    attrs
    |> Enum.reject(&(&1.name in [:rest, :class]))
    |> Enum.map(fn attr ->
      %{
        name: to_string(attr.name),
        type: format_type(attr.type),
        required: attr.required,
        default: format_default(Keyword.get(attr.opts, :default)),
        values: Keyword.get(attr.opts, :values),
        doc: attr.doc
      }
    end)
  end

  defp simplify_slots(slots) do
    Enum.map(slots, fn slot ->
      %{
        name: to_string(slot.name),
        required: slot.required,
        doc: slot.doc
      }
    end)
  end

  defp format_type(type) when is_atom(type), do: to_string(type)
  defp format_type({:struct, mod}), do: "%#{inspect(mod)}{}"
  defp format_type(other), do: inspect(other)

  defp format_default(nil), do: nil
  defp format_default(value) when is_binary(value), do: value
  defp format_default(value) when is_atom(value) or is_number(value), do: to_string(value)
  defp format_default(value), do: inspect(value)

  defp source_path(module) do
    case module.module_info(:compile)[:source] do
      nil -> nil
      path -> path |> to_string() |> Path.relative_to_cwd()
    end
  end
end

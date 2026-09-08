defmodule Mix.Tasks.JobyKit.Gen.Wrapper do
  @shortdoc "Scaffold a JobyKit wrapper component, manifest entry, and preview"

  @moduledoc """
  Scaffolds a new wrapper component end-to-end:

    1. Inserts a function-component skeleton in the target module
       (`<App>Web.CoreComponents` or `<App>Web.CompositeComponents`).
       The skeleton already satisfies the wrapper contract:
       `data-component`, `attr :rest, :global`, declared slot.
    2. Inserts a `component/3` registration in `<App>Web.DesignManifest`
       (immediately before `def daisy_overrides`, falling back to the
       module's closing `end`).
    3. Inserts a `<name>_preview/1` function in
       `<App>Web.DesignPreviews`, adding an `alias` line for the host
       module if necessary.

  After the task runs, `mix joby_kit.lint` should report clean for the
  new component.

  ## Usage

      mix joby_kit.gen.wrapper modal --daisy modal
      mix joby_kit.gen.wrapper chat_panel --category composite

  ## Options

    * `--category` — `core` (default) or `composite`.
    * `--daisy` — daisyUI primitive id (see `JobyKit.DaisyCatalogue`).
      Only meaningful for `--category core`. Pre-populates the root
      element's class with the primitive's daisy class string.
    * `--manifest` — manifest module name. Defaults to
      `<App>Web.DesignManifest`.
    * `--web` — web module name. Defaults to `<App>Web` derived from
      `mix.exs`.

  ## Conventions

  Component names must be `snake_case`. The function name and the
  preview name (`<name>_preview`) must not already exist in the
  respective files; the task fails loudly rather than overwriting.

  ## Domain composites

  Domain composites (`category: :domain`) live in host-specific modules
  and aren't supported by the generator yet — register those by hand or
  use this task with `--category composite` and re-categorize the
  manifest entry afterward.
  """

  use Mix.Task

  @switches [
    category: :string,
    daisy: :string,
    manifest: :string,
    web: :string
  ]

  @impl Mix.Task
  def run(argv) do
    {opts, argv, _invalid} = OptionParser.parse(argv, switches: @switches)

    name = parse_name(argv)
    category = parse_category(Keyword.get(opts, :category, "core"))
    daisy = parse_daisy(opts[:daisy], category)

    app = Mix.Project.config()[:app] || Mix.raise("could not determine :app from mix.exs")
    web_module = opts[:web] || Macro.camelize(to_string(app)) <> "Web"
    web_path = Macro.underscore(web_module)

    target_module_short = target_module_short(category)
    target_module = web_module <> "." <> target_module_short
    target_path = "lib/#{web_path}/components/#{Macro.underscore(target_module_short)}.ex"

    manifest_module = opts[:manifest] || web_module <> ".DesignManifest"
    manifest_path = "lib/#{web_path}/design_manifest.ex"
    previews_path = "lib/#{web_path}/design_previews.ex"

    ensure_target_file(target_path, target_module, category)
    refuse_duplicate_function!(target_path, name)
    refuse_duplicate_manifest!(manifest_path, target_module_short, name)
    refuse_duplicate_preview!(previews_path, name)

    insert_component(target_path, target_module, name, category, daisy)
    insert_manifest_entry(manifest_path, target_module, name, category, daisy)
    insert_preview(previews_path, web_module, target_module_short, name, category)

    print_next_steps(target_module, name, category, daisy, manifest_module)
  end

  # --------------------------------------------------------------- inputs

  defp parse_name([name | _]) when is_binary(name) do
    if Regex.match?(~r/^[a-z][a-z0-9_]*$/, name) do
      name
    else
      Mix.raise(
        "component name must be snake_case (lowercase, digits, underscores). Got: #{inspect(name)}"
      )
    end
  end

  defp parse_name(_) do
    Mix.raise("component name is required. Usage: mix joby_kit.gen.wrapper <name>")
  end

  defp parse_category("core"), do: :core
  defp parse_category("composite"), do: :composite

  defp parse_category(other),
    do:
      Mix.raise(
        "unknown --category #{inspect(other)} (valid: core, composite). Domain composites are not yet supported by the generator."
      )

  defp parse_daisy(nil, _category), do: nil

  defp parse_daisy(_daisy, :composite),
    do:
      Mix.raise("--daisy is only meaningful with --category core. Drop the flag for composites.")

  defp parse_daisy(id, :core) do
    atom = String.to_atom(id)

    JobyKit.DaisyCatalogue.categories()
    |> Enum.flat_map(& &1.components)
    |> Enum.find(&(&1.id == atom))
    |> case do
      nil ->
        Mix.raise(
          "unknown --daisy #{inspect(id)}. See JobyKit.DaisyCatalogue.categories/0 for valid ids."
        )

      component ->
        component
    end
  end

  defp target_module_short(:core), do: "CoreComponents"
  defp target_module_short(:composite), do: "CompositeComponents"

  # --------------------------------------------------------- target module

  defp ensure_target_file(path, _module, :core) do
    unless File.exists?(path) do
      Mix.raise(
        "expected core_components at #{path}, but the file does not exist. Did you run `mix joby_kit.install`?"
      )
    end
  end

  defp ensure_target_file(path, module, :composite) do
    if File.exists?(path) do
      :ok
    else
      File.mkdir_p!(Path.dirname(path))
      web_module = module |> String.split(".") |> hd()

      # `use <App>Web, :html` rather than a bare `use Phoenix.Component`:
      # composites compose core wrappers and verified routes, and the
      # install template does the same. A bare Phoenix.Component scaffold
      # fails to compile the moment the new composite uses `<.icon>` or
      # `~p"/..."` — which the kit's own worked example does.
      File.write!(path, """
      defmodule #{module} do
        @moduledoc \"\"\"
        Generic composites for this app — multi-primitive patterns reused
        across domains. Surfaces on /custom-designs.
        \"\"\"

        use #{web_module}, :html

        alias JobyKit.CoreComponents
      end
      """)

      Mix.shell().info([:green, "* creating ", :reset, path])
    end
  end

  defp refuse_duplicate_function!(path, name) do
    if String.contains?(File.read!(path), "def #{name}(") do
      Mix.raise("function #{name}/1 already exists in #{path}. Pick a different name.")
    end
  end

  defp refuse_duplicate_manifest!(path, target_short, name) do
    source = File.read!(path)

    # Match either short alias form (`component(CoreComponents, :foo,`)
    # or fully qualified (`component(MyAppWeb.CoreComponents, :foo,`).
    if Regex.match?(~r/component[\(\s]+\S*#{target_short},\s*:#{name},/, source) do
      Mix.raise(
        "manifest entry for #{target_short}.#{name} already exists in #{path}. Pick a different name."
      )
    end
  end

  defp refuse_duplicate_preview!(path, name) do
    if String.contains?(File.read!(path), "def #{name}_preview(") do
      Mix.raise("preview #{name}_preview/1 already exists in #{path}. Pick a different name.")
    end
  end

  # ----------------------------------------------------- component insertion

  defp insert_component(path, target_module, name, category, daisy) do
    body = component_body(target_module, name, category, daisy)
    insert_before_final_end(path, body)
    Mix.shell().info([:green, "* updating ", :reset, "#{path} (added #{name}/1)"])
  end

  defp component_body(target_module, name, category, daisy) do
    description =
      case daisy do
        nil -> "TODO: describe the #{name} #{category_word(category)}."
        primitive -> "Wrapper around the daisyUI `#{primitive.classes}` primitive."
      end

    class_attr =
      case daisy do
        nil -> ""
        primitive -> ~s| class="#{primary_class(primitive.classes)}"|
      end

    """

      @doc \"\"\"
      #{description}
      \"\"\"
      attr :rest, :global
      slot :inner_block, required: true

      def #{name}(assigns) do
        ~H\"\"\"
        <div data-component="#{target_module}.#{name}"#{class_attr} {@rest}>
          {render_slot(@inner_block)}
        </div>
        \"\"\"
      end
    """
  end

  defp category_word(:core), do: "wrapper"
  defp category_word(:composite), do: "composite"

  # daisy classes can be compound ("collapse + radio", "chat / chat-bubble").
  # Use the first token; user can refine.
  defp primary_class(classes) do
    classes
    |> String.split(~r/[\/+]/, trim: true)
    |> hd()
    |> String.trim()
  end

  # ------------------------------------------------------ manifest insertion

  defp insert_manifest_entry(path, target_module, name, category, daisy) do
    entry = manifest_entry(target_module, name, category, daisy)
    insert_before_daisy_overrides_or_end(path, entry)
    Mix.shell().info([:green, "* updating ", :reset, "#{path} (registered :#{name})"])
  end

  defp manifest_entry(target_module, name, category, daisy) do
    daisy_line =
      case daisy do
        nil -> ""
        primitive -> ~s|    daisy_basis: "#{primitive.classes}",\n|
      end

    """

      component(#{target_module}, :#{name},
        category: :#{category},
    #{daisy_line |> String.trim_trailing("\n")}
        summary: "TODO: describe.",
        preview: &DesignPreviews.#{name}_preview/1
      )
    """
    |> collapse_blank_lines()
  end

  defp collapse_blank_lines(text) do
    Regex.replace(~r/\n\s*\n\s*\n/, text, "\n\n")
  end

  defp insert_before_daisy_overrides_or_end(path, content) do
    source = File.read!(path)

    case Regex.run(~r/\n(\s*@doc\s+"""\n.*?"""\n)?(\s*def daisy_overrides do)/s, source,
           return: :index
         ) do
      [{full_start, _}, _doc_match, _def_match] when full_start > 0 ->
        before = binary_part(source, 0, full_start)
        rest = binary_part(source, full_start, byte_size(source) - full_start)
        File.write!(path, String.trim_trailing(before, "\n") <> "\n" <> content <> rest)

      _ ->
        insert_before_final_end(path, content)
    end
  end

  # ------------------------------------------------------- preview insertion

  defp insert_preview(path, web_module, target_short, name, category) do
    if category == :composite, do: ensure_alias(path, web_module, target_short)
    body = preview_body(target_short, name, category)
    insert_before_final_end(path, body)
    Mix.shell().info([:green, "* updating ", :reset, "#{path} (added #{name}_preview/1)"])
  end

  # Core wrappers are imported into design_previews via `use <App>Web, :html`,
  # so the preview can use the `<.name>` form. Composites need an aliased
  # call site.
  defp preview_body("CoreComponents", name, :core) do
    """

      def #{name}_preview(assigns) do
        ~H\"\"\"
        <.#{name}>#{name}</.#{name}>
        \"\"\"
      end
    """
  end

  defp preview_body(target_short, name, _category) do
    """

      def #{name}_preview(assigns) do
        ~H\"\"\"
        <#{target_short}.#{name}>#{name}</#{target_short}.#{name}>
        \"\"\"
      end
    """
  end

  defp ensure_alias(path, web_module, target_short) do
    source = File.read!(path)
    alias_line = "alias #{web_module}.#{target_short}"
    group_re = ~r/alias\s+#{Regex.escape(web_module)}\.\{([^}]*)\}/

    cond do
      String.contains?(source, alias_line) ->
        :ok

      Regex.match?(
        ~r/alias\s+#{Regex.escape(web_module)}\.\{[^}]*\b#{target_short}\b[^}]*\}/,
        source
      ) ->
        :ok

      Regex.match?(group_re, source) ->
        new_source =
          Regex.replace(
            group_re,
            source,
            fn _full, members ->
              extended =
                members
                |> String.split(",")
                |> Enum.map(&String.trim/1)
                |> Enum.reject(&(&1 == ""))
                |> Kernel.++([target_short])
                |> Enum.uniq()
                |> Enum.sort()
                |> Enum.join(", ")

              "alias #{web_module}.{#{extended}}"
            end, global: false)

        File.write!(path, new_source)

      true ->
        # Insert after the first `use ...` line. For design_previews this is
        # `use <App>Web, :html`; for design_manifest it's
        # `use JobyKit.Manifest`. Either anchors a sensible alias position.
        case Regex.run(~r/use [^\n]*\n/, source, return: :index) do
          [{start, len}] ->
            before = binary_part(source, 0, start + len)
            after_ = binary_part(source, start + len, byte_size(source) - start - len)
            File.write!(path, before <> "\n  " <> alias_line <> "\n" <> after_)

          _ ->
            Mix.shell().error(
              "could not find a `use ...` line in #{path}; please add `#{alias_line}` manually."
            )
        end
    end
  end

  # ------------------------------------------------- generic file insertion

  defp insert_before_final_end(path, content) do
    source = File.read!(path)

    case Regex.run(~r/\A(.*\n)(end\s*\z)/s, source, capture: :all_but_first) do
      [body, trailer] ->
        File.write!(path, body <> String.trim_trailing(content, "\n") <> "\n" <> trailer)

      nil ->
        Mix.raise("could not find module-closing `end` in #{path}.")
    end
  end

  # ----------------------------------------------------------- next-steps

  defp print_next_steps(target_module, name, category, daisy, manifest_module) do
    Mix.shell().info("")
    Mix.shell().info([:cyan, "Scaffolded:", :reset])
    Mix.shell().info("  #{target_module}.#{name}/1   (category: :#{category})")
    if daisy, do: Mix.shell().info("  daisyUI basis: #{daisy.classes}")
    Mix.shell().info("  manifest: #{manifest_module}")
    Mix.shell().info("")
    Mix.shell().info([:cyan, "Next:", :reset])
    Mix.shell().info("  1. Fill in the @doc summary and the body of the wrapper.")
    Mix.shell().info("  2. Update the manifest summary: \"TODO: describe.\".")
    Mix.shell().info("  3. Flesh out the preview.")
    Mix.shell().info("  4. mix joby_kit.lint   # confirm contract holds")
  end
end

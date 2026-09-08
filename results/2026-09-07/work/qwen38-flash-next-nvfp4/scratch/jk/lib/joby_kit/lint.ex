defmodule JobyKit.Lint do
  @moduledoc """
  Lint engine for JobyKit-installed apps. Verifies wrapper-contract
  invariants by introspecting a manifest module and scanning the host's
  component source files.

  ## Rules

    * `:manifest_drift` (error) — a manifest entry points at a function
      that is not actually a Phoenix function component. Caught first
      because every other check depends on the entry being live.
    * `:missing_data_component` (error) — a registered wrapper does not
      carry `data-component="Module.function"` in its source.
    * `:missing_rest_global` (warning) — a registered wrapper does not
      declare `attr :rest, :global`, blocking pass-through of phx-* and
      aria-* attributes from callers.
    * `:unregistered_wrapper` (warning) — a function carries a
      `data-component="..."` attribute but is not registered in the
      manifest, making it invisible to `/design.json` and to agents.
    * `:raw_html_primitive` (warning) — a `.heex` template (or `~H`
      block in a `.ex`) contains a raw `<button>`, `<input>`,
      `<textarea>`, or `<select>` outside of a wrapper definition. The
      kit ships wrappers for all four; reaching past them drops the
      contract. Exempted per **enclosing `def`**: a function whose body
      carries `data-component=` is a wrapper, and raw primitives inside
      it are its own body. Commented-out markup is ignored. Per-line
      opt-out via `<%!-- jobykit:allow-raw-html --%>`.
    * `:forked_wrapper` (warning) — the app excludes a kit component
      from `import JobyKit.CoreComponents` and substitutes its own, so
      upstream fixes to that component never reach it.
    * `:duplicated_class_string` (warning) — the same long `class="..."`
      string appears three or more times, which the kit's own guidance
      names as the signal that markup wants lifting into a wrapper.
    * `:unmarked_component` (warning) — a public function component
      renders markup but carries no `data-component` at all, so
      `:unregistered_wrapper` (which keys off that attribute) cannot see
      it. The most common way to skip the contract entirely.
    * `:assign_new_default` (error) — `assign_new(assigns, :x, ...)` on an
      attr declared with a `default:`. The key is always present, so the
      fallback is dead code. This shipped once as the flash nil-id bug.

  Each violation is a map with `:rule`, `:severity`, `:message`,
  `:file`, `:line`, `:module`, `:function`. The engine is pure data —
  formatting and exit codes live in `Mix.Tasks.JobyKit.Lint`.
  """

  @type severity :: :error | :warning | :info

  @type violation :: %{
          rule: atom(),
          severity: severity(),
          message: String.t(),
          file: String.t() | nil,
          line: non_neg_integer() | nil,
          module: module() | nil,
          function: atom() | nil
        }

  @default_paths ["lib/**/*.ex", "lib/**/*.heex"]
  @data_component_re ~r/data-component=(?:"([^"]+)"|'([^']+)')/
  # Deliberately case-sensitive: HEEx reserves lowercase tags for HTML and
  # capitalised ones for remote components, so `<Input.autocomplete />` is a
  # component call, not a raw `<input>`. Matching case-insensitively flagged
  # any host using a component module named Input/Select/Button.
  @raw_html_primitive_re ~r/<(button|input|textarea|select)\b/
  @allow_raw_html_marker "jobykit:allow-raw-html"

  # Defined here rather than beside heex_bearing?/2 because module
  # attributes must exist before the first use, and the component scans
  # below reference it.
  @sigil_h_re ~r/~H["'\[\(\{<\/\|]/

  @doc """
  Run the lint engine. Returns a list of violations in deterministic
  order (drift first, then per-entry checks in manifest declaration
  order, then unregistered wrappers sorted by data-component string).

  ## Options

    * `:manifest` — required. The host's manifest module
      (`use JobyKit.Manifest`).
    * `:paths` — list of glob patterns to scan for the unregistered-
      wrapper rule. Defaults to `["lib/**/*.ex"]`. Patterns are
      resolved relative to `cwd`.
  """
  @spec run(keyword()) :: [violation()]
  def run(opts) do
    manifest = Keyword.fetch!(opts, :manifest)
    paths = Keyword.get(opts, :paths, @default_paths)

    Code.ensure_loaded!(manifest)
    entries = manifest.entries()

    {drift_violations, healthy_entries} = check_manifest_drift(entries)

    data_component_violations = Enum.flat_map(healthy_entries, &check_data_component/1)
    rest_global_violations = Enum.flat_map(healthy_entries, &check_rest_global/1)

    registered = MapSet.new(healthy_entries, & &1.data_component)
    unregistered_violations = scan_unregistered_wrappers(paths, registered)
    raw_html_violations = scan_raw_html_primitives(paths)
    unmarked_violations = scan_unmarked_components(paths, registered)
    forked_violations = scan_forked_wrappers(paths)
    duplicated_class_violations = scan_duplicated_class_strings(paths)
    assign_new_violations = scan_assign_new_defaults(paths)

    drift_violations ++
      data_component_violations ++
      rest_global_violations ++
      unregistered_violations ++
      unmarked_violations ++
      raw_html_violations ++
      forked_violations ++ duplicated_class_violations ++ assign_new_violations
  end

  # -------------------------------------------------------- manifest_drift

  defp check_manifest_drift(entries) do
    Enum.reduce(entries, {[], []}, fn entry, {drift, healthy} ->
      cond do
        not Code.ensure_loaded?(entry.module) ->
          {[drift_violation(entry, "module is not loadable") | drift], healthy}

        not function_exported?(entry.module, entry.function, 1) ->
          {[drift_violation(entry, "function/1 does not exist") | drift], healthy}

        not phoenix_component?(entry.module, entry.function) ->
          {[drift_violation(entry, "function is not a Phoenix function component") | drift],
           healthy}

        true ->
          {drift, [entry | healthy]}
      end
    end)
    |> then(fn {drift, healthy} -> {Enum.reverse(drift), Enum.reverse(healthy)} end)
  end

  defp drift_violation(entry, reason) do
    %{
      rule: :manifest_drift,
      severity: :error,
      message:
        "manifest entry #{entry.data_component} is broken: #{reason}. Update or remove the component/3 line.",
      file: entry.source,
      line: entry.line,
      module: entry.module,
      function: entry.function
    }
  end

  defp phoenix_component?(module, function) do
    function_exported?(module, :__components__, 0) and
      Map.has_key?(module.__components__(), function)
  end

  # -------------------------------------------------- missing_data_component

  defp check_data_component(entry) do
    case read_source(entry) do
      {:ok, raw} ->
        # Scoped to this component's own `def`. A docstring that mentions
        # the attribute does not satisfy the contract, and neither does a
        # *sibling* component's marker — checking the whole file let one
        # compliant wrapper vouch for every other function in it.
        source = raw |> blank_doc_heredocs() |> component_body(entry.function)

        if String.contains?(source, ~s|data-component="#{entry.data_component}"|) or
             String.contains?(source, ~s|data-component='#{entry.data_component}'|) or
             dynamic_data_component?(source) do
          []
        else
          [
            %{
              rule: :missing_data_component,
              severity: :error,
              message:
                ~s|wrapper #{entry.data_component} does not carry data-component="#{entry.data_component}" on its root element|,
              file: entry.source,
              line: entry.line,
              module: entry.module,
              function: entry.function
            }
          ]
        end

      :error ->
        []
    end
  end

  defp read_source(%{source: nil}), do: :error

  defp read_source(%{source: path}) do
    case File.read(path) do
      {:ok, contents} -> {:ok, contents}
      {:error, _} -> :error
    end
  end

  # ----------------------------------------------------- missing_rest_global

  defp check_rest_global(entry) do
    attrs = raw_attrs(entry.module, entry.function)

    if Enum.any?(attrs, &(&1.name == :rest and &1.type == :global)) do
      []
    else
      [
        %{
          rule: :missing_rest_global,
          severity: :warning,
          message:
            "wrapper #{entry.data_component} is missing `attr :rest, :global` — callers cannot pass id/class/aria-*/phx-* through",
          file: entry.source,
          line: entry.line,
          module: entry.module,
          function: entry.function
        }
      ]
    end
  end

  defp raw_attrs(module, function) do
    case Map.get(module.__components__(), function) do
      %{attrs: attrs} when is_list(attrs) -> attrs
      _ -> []
    end
  end

  # ---------------------------------------------------- unregistered_wrapper

  defp scan_unregistered_wrappers(patterns, registered) do
    patterns
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.flat_map(&scan_file_for_data_components/1)
    |> Enum.reject(fn %{data_component: dc} -> MapSet.member?(registered, dc) end)
    |> Enum.uniq_by(& &1.data_component)
    |> Enum.sort_by(& &1.data_component)
    |> Enum.map(&unregistered_violation/1)
  end

  defp scan_file_for_data_components(path) do
    case File.read(path) do
      {:ok, raw} ->
        # Documentation that *describes* the contract is not a wrapper
        # definition. The shipped composite_components.ex template spells
        # out `data-component="<App>Web.CompositeComponents.<name>"` in its
        # moduledoc, so every freshly installed host opened with a phantom
        # unregistered_wrapper warning for a component named `<name>`.
        contents = blank_doc_heredocs(raw)
        line_index = build_line_index(contents)

        Regex.scan(@data_component_re, contents, return: :index)
        |> Enum.map(fn match ->
          {start, _len} = match |> Enum.drop(1) |> Enum.find(&(&1 != {-1, 0}))
          dc = capture_value(contents, match)
          %{data_component: dc, file: path, line: line_for_offset(line_index, start)}
        end)
        |> Enum.reject(&(&1.data_component == nil))

      {:error, _} ->
        []
    end
  end

  defp capture_value(contents, [_full | captures]) do
    captures
    |> Enum.find(&(&1 != {-1, 0}))
    |> case do
      nil -> nil
      {start, len} -> binary_part(contents, start, len)
    end
  end

  defp build_line_index(contents) do
    contents
    |> String.split("\n")
    |> Enum.scan(0, fn line, acc -> acc + byte_size(line) + 1 end)
  end

  defp line_for_offset(line_index, offset) do
    Enum.find_index(line_index, &(&1 > offset)) |> Kernel.||(0) |> Kernel.+(1)
  end

  defp unregistered_violation(%{data_component: dc, file: file, line: line}) do
    %{
      rule: :unregistered_wrapper,
      severity: :warning,
      message:
        "#{dc} carries data-component but is not registered in the manifest — it is invisible to /design.json and to agents",
      file: file,
      line: line,
      module: nil,
      function: nil
    }
  end

  # Shared: blank out `@doc`/`@moduledoc` heredocs, preserving newlines so
  # line numbers stay accurate. Prose about the contract is not the
  # contract.
  @doc_heredoc_re ~r/@(?:module)?doc\s+(?:~S)?"""(?:.|\n)*?"""/

  defp blank_doc_heredocs(contents) do
    Regex.replace(@doc_heredoc_re, contents, fn match ->
      String.replace(match, ~r/[^\n]/, " ")
    end)
  end

  # ---------------------------------------------------------- forked_wrapper

  @kit_import_except_re ~r/import\s+JobyKit\.CoreComponents\s*,\s*except:\s*\[([^\]]*)\]/

  defp scan_forked_wrappers(patterns) do
    patterns
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.flat_map(&scan_file_for_forks/1)
    |> Enum.sort_by(&{&1.file, &1.line})
  end

  defp scan_file_for_forks(path) do
    case File.read(path) do
      {:ok, raw} ->
        contents = blank_doc_heredocs(raw)
        line_index = build_line_index(contents)

        @kit_import_except_re
        |> Regex.scan(contents, return: :index)
        |> Enum.flat_map(fn [{start, _}, {list_start, list_len}] ->
          binary_part(contents, list_start, list_len)
          |> then(&Regex.scan(~r/([a-z_][a-z_0-9]*):\s*\d+/, &1))
          |> Enum.map(fn [_, name] ->
            forked_violation(name, path, line_for_offset(line_index, start))
          end)
        end)

      {:error, _} ->
        []
    end
  end

  defp forked_violation(name, path, line) do
    %{
      rule: :forked_wrapper,
      severity: :warning,
      message:
        "`#{name}/1` is excluded from the JobyKit.CoreComponents import, so this app renders its own copy — " <>
          "kit fixes to #{name}/1 will not reach it. Re-check the CHANGELOG against your fork on every upgrade, " <>
          "or drop the fork if the upstream component now covers your case.",
      file: path,
      line: line,
      module: nil,
      function: String.to_atom(name)
    }
  end

  # -------------------------------------------------- duplicated_class_string

  @class_attr_re ~r/class="([^"{}]{25,})"/
  @duplicate_threshold 3

  # The kit's own CLAUDE.md names "the same class string on the same
  # semantic element on more than one page" as a symptom that the wrapper
  # layer was skipped — but nothing checked for it, so an app could paste
  # the same 60-character header string ten times and still lint clean.
  defp scan_duplicated_class_strings(patterns) do
    patterns
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.flat_map(&scan_file_for_class_strings/1)
    |> Enum.group_by(& &1.class)
    |> Enum.filter(fn {_class, uses} -> length(uses) >= @duplicate_threshold end)
    |> Enum.sort_by(fn {class, _} -> class end)
    |> Enum.map(fn {class, uses} -> duplicated_class_violation(class, uses) end)
  end

  defp scan_file_for_class_strings(path) do
    case File.read(path) do
      {:ok, raw} ->
        contents = raw |> blank_doc_heredocs() |> blank_comments()
        line_index = build_line_index(contents)

        @class_attr_re
        |> Regex.scan(contents, return: :index)
        |> Enum.map(fn [{start, _}, {cs, cl}] ->
          %{
            class: contents |> binary_part(cs, cl) |> String.trim(),
            file: path,
            line: line_for_offset(line_index, start)
          }
        end)

      {:error, _} ->
        []
    end
  end

  defp duplicated_class_violation(class, uses) do
    first = List.first(uses)
    where = uses |> Enum.map(&"#{&1.file}:#{&1.line}") |> Enum.uniq() |> Enum.take(4)

    %{
      rule: :duplicated_class_string,
      severity: :warning,
      message:
        "the same #{String.length(class)}-character class string appears #{length(uses)} times — " <>
          "lift it into a wrapper or composite and register it. Seen at: #{Enum.join(where, ", ")}" <>
          if(length(uses) > length(where), do: ", …", else: ""),
      file: first.file,
      line: first.line,
      module: nil,
      function: nil
    }
  end

  # A wrapper may build the attribute rather than hardcode it —
  # `data-component={@dc}` or `data-component={"\#{inspect(__MODULE__)}.thing"}`.
  # Treating that as missing was a false positive that told a compliant
  # wrapper it was broken.
  @dynamic_data_component_re ~r/data-component=\{/
  defp dynamic_data_component?(source), do: Regex.match?(@dynamic_data_component_re, source)

  # The slice of `source` belonging to `function`'s definition: from its
  # `def` line to the next top-level `def`, or end of file. Falls back to
  # the whole source when the definition can't be located (a generated or
  # macro-defined component), which keeps the check permissive rather
  # than reporting a false error.
  defp component_body(source, function) do
    lines = String.split(source, "\n")

    starts =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {line, _} -> Regex.match?(~r/^\s*defp?\s+[a-z_]/, line) end)
      |> Enum.map(fn {_, idx} -> idx end)

    # Every clause, not just the first. `input/1` has six — the
    # FormField clause only delegates, so slicing to the next `def`
    # looked at a body with no marker in it and reported the kit's own
    # most-used component as non-compliant.
    own =
      Enum.filter(starts, fn idx ->
        Regex.match?(
          ~r/^\s*defp?\s+#{Regex.escape(to_string(function))}\s*[\(\s]/,
          Enum.at(lines, idx)
        )
      end)

    case own do
      [] ->
        source

      clause_starts ->
        clause_starts
        |> Enum.map_join("\n", fn idx ->
          stop = Enum.find(starts, length(lines), &(&1 > idx))
          lines |> Enum.slice(idx..(stop - 1)//1) |> Enum.join("\n")
        end)
    end
  end

  # -------------------------------------------------- unmarked_component

  # `:unregistered_wrapper` only fires on functions that already carry
  # `data-component`, which makes it circular: a component is flagged for
  # being unregistered only once it has done half the registration. A
  # public function component with markup and no marker at all — the most
  # common way to skip the contract — was invisible to it.
  @component_def_re ~r/^\s{0,4}def\s+([a-z_][a-zA-Z0-9_]*)\s*\(\s*assigns/m

  defp scan_unmarked_components(patterns, registered) do
    patterns
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.flat_map(&scan_file_for_unmarked(&1, registered))
    |> Enum.sort_by(&{&1.file, &1.line})
  end

  defp scan_file_for_unmarked(path, registered) do
    with {:ok, raw} <- File.read(path),
         true <- heex_bearing?(path, raw) do
      contents = raw |> blank_doc_heredocs() |> blank_comments()
      lines = String.split(contents, "\n")
      line_index = build_line_index(contents)
      modules = module_positions(contents)
      wrapper_ranges = wrapper_line_ranges(path, raw)

      @component_def_re
      |> Regex.scan(contents, return: :index)
      |> Enum.flat_map(fn [_full, {name_start, name_len}] ->
        name = binary_part(contents, name_start, name_len)
        # Line is taken from the function name, not the match start: a
        # match anchored at column 0 lands exactly on a line boundary and
        # line_for_offset/2 attributes it to the line above.
        line = line_for_offset(line_index, name_start)
        module = enclosing_module(modules, name_start)

        cond do
          # Already carries a marker — :unregistered_wrapper's job.
          exempt?(wrapper_ranges, line) -> []
          # No module we can name, or already registered under it.
          module == nil -> []
          MapSet.member?(registered, "#{module}.#{name}") -> []
          # Not a component by convention (see component_by_convention?/2).
          not component_by_convention?(module, name) -> []
          # Only flag defs that actually render markup.
          not renders_markup?(lines, line) -> []
          true -> [unmarked_violation(module, name, path, line)]
        end
      end)
    else
      _ -> []
    end
  end

  # Three kinds of public `def x(assigns)` render markup without being
  # components, and every one of them is named by convention rather than
  # guessed at. Without these the rule fires on every LiveView and every
  # previews module in a clean generated app — eighteen findings on the
  # kit's own dev shell, which is how they were found.
  #
  #   * `render/1` is the LiveView/LiveComponent callback.
  #   * `*_preview/1` is the manifest's preview harness; the previews
  #     module documents the suffix as its naming rule.
  #   * `<App>Web.Layouts` holds page chrome, not registered components.
  defp component_by_convention?(module, name) do
    not (name == "render" or
           String.ends_with?(name, "_preview") or
           String.ends_with?(module, ".Layouts"))
  end

  # Look ahead a little way for a `~H` sigil belonging to this def.
  defp renders_markup?(lines, line) do
    lines
    |> Enum.slice((line - 1)..(line + 12)//1)
    |> Enum.any?(&Regex.match?(@sigil_h_re, &1))
  end

  # A file can hold several modules — the kit's own lint fixtures do — so
  # attribute each def to the last `defmodule` that opened before it
  # rather than to the first one in the file.
  defp module_positions(contents) do
    ~r/^defmodule\s+([A-Z][\w.]*)/m
    |> Regex.scan(contents, return: :index)
    |> Enum.map(fn [{start, _}, {name_start, name_len}] ->
      {start, binary_part(contents, name_start, name_len)}
    end)
  end

  defp enclosing_module(modules, offset) do
    modules
    |> Enum.take_while(fn {start, _} -> start < offset end)
    |> List.last()
    |> case do
      {_start, module} -> module
      nil -> nil
    end
  end

  defp unmarked_violation(module, name, path, line) do
    %{
      rule: :unmarked_component,
      severity: :warning,
      message:
        "#{module}.#{name} renders markup but carries no data-component and is not registered — " <>
          "it is invisible to /design.json and to agents. Add the marker and a manifest entry, " <>
          "or move it out of the component layer.",
      file: path,
      line: line,
      module: nil,
      function: String.to_atom(name)
    }
  end

  # --------------------------------------------------------- assign_new_default

  # `attr :x, default: nil` puts :x in assigns, so `assign_new(assigns, :x, ...)`
  # never fires and the default silently wins. That is exactly the bug that
  # shipped as the flash nil-id defect in 0.2.0: every toast rendered without
  # an id and the dismiss handler became JS.hide(to: "#").
  @assign_new_re ~r/assign_new\(\s*assigns\s*,\s*:([a-z_][a-zA-Z0-9_]*)/

  defp scan_assign_new_defaults(patterns) do
    patterns
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.flat_map(&scan_file_for_assign_new/1)
    |> Enum.sort_by(&{&1.file, &1.line})
  end

  defp scan_file_for_assign_new(path) do
    case File.read(path) do
      {:ok, raw} ->
        contents = raw |> blank_doc_heredocs() |> blank_comments()
        line_index = build_line_index(contents)

        @assign_new_re
        |> Regex.scan(contents, return: :index)
        |> Enum.flat_map(fn [{start, _}, {name_start, name_len}] ->
          name = binary_part(contents, name_start, name_len)

          if attr_has_default?(contents, name) do
            [assign_new_violation(name, path, line_for_offset(line_index, start))]
          else
            []
          end
        end)

      {:error, _} ->
        []
    end
  end

  defp attr_has_default?(contents, name) do
    Regex.match?(~r/attr\s+:#{Regex.escape(name)}\s*,[^\n]*\bdefault:/, contents)
  end

  defp assign_new_violation(name, path, line) do
    %{
      rule: :assign_new_default,
      severity: :error,
      message:
        "assign_new(assigns, :#{name}, ...) never runs — `attr :#{name}` declares a `default:`, " <>
          "so the key is always present in assigns and the fallback is dead code. " <>
          "Use `assigns.#{name} || fallback` instead.",
      file: path,
      line: line,
      module: nil,
      function: nil
    }
  end

  # ----------------------------------------------------- raw_html_primitive

  defp scan_raw_html_primitives(patterns) do
    patterns
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.uniq()
    |> Enum.flat_map(&scan_file_for_raw_primitives/1)
    |> Enum.sort_by(&{&1.file, &1.line})
  end

  defp scan_file_for_raw_primitives(path) do
    case File.read(path) do
      {:ok, contents} ->
        if heex_bearing?(path, contents) do
          find_raw_primitives_in(path, contents)
        else
          []
        end

      {:error, _} ->
        []
    end
  end

  # A file is HEEx-bearing if it's a .heex template or contains a `~H`
  # sigil. Pure .ex files without `~H` (mix tasks, GenServers, etc.)
  # have no templates to lint. The sigil regex requires a delimiter
  # character immediately after `~H` so a comment that *mentions* `~H`
  # in prose doesn't flip a file into scannable mode.
  defp heex_bearing?(path, contents) do
    Path.extname(path) == ".heex" or Regex.match?(@sigil_h_re, contents)
  end

  defp find_raw_primitives_in(path, contents) do
    # Marker lookups read the original text — the documented escape hatch
    # is itself a HEEx comment, so it must be checked before comments are
    # blanked out.
    lines = String.split(contents, "\n")

    # Docstrings routinely *describe* the rule ("never raw `<button>`") —
    # the kit's own composite template does exactly that. Prose is not
    # markup, so blank docs and comments before looking for tags.
    scannable =
      contents |> blank_doc_heredocs() |> blank_comments() |> String.split("\n")

    exempt = wrapper_line_ranges(path, contents)

    scannable
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, line_no} ->
      if exempt?(exempt, line_no) do
        []
      else
        original = Enum.at(lines, line_no - 1) || ""

        @raw_html_primitive_re
        |> Regex.scan(line, return: :index)
        |> Enum.flat_map(fn [{tag_offset, _}, {tag_start, tag_len}] ->
          tag = binary_part(line, tag_start, tag_len)

          cond do
            allows_raw_html?(original, lines, line_no) -> []
            in_string_literal?(line, tag_offset) -> []
            true -> [raw_html_violation(path, line_no, tag)]
          end
        end)
      end
    end)
  end

  # Blank out HEEx (`<%!-- --%>`) and HTML (`<!-- -->`) comments so
  # commented-out markup doesn't read as live markup, preserving newlines
  # so line numbers still line up with the original file.
  defp blank_comments(contents) do
    contents
    |> blank_regions(~r/<%!--.*?--%>/s)
    |> blank_regions(~r/<!--.*?-->/s)
  end

  defp blank_regions(contents, re) do
    Regex.replace(re, contents, fn match ->
      String.replace(match, ~r/[^\n]/, " ")
    end)
  end

  # Wrapper territory, scoped to the enclosing `def`.
  #
  # A `def` whose body carries `data-component=` is a wrapper definition,
  # and raw primitives inside it are the wrapper's own body — that's how
  # wrappers work. Everything else in the file still gets checked. The
  # old file-level exemption meant one small wrapper in a 500-line
  # LiveView silenced the rule for the entire render, and a stray
  # `data-component=` in a comment disabled it wholesale.
  #
  # `.heex` files have no defs; a template carrying `data-component=` is
  # treated as a wrapper template and exempted whole, as before.
  defp wrapper_line_ranges(path, contents) do
    lines = String.split(contents, "\n")

    cond do
      Path.extname(path) == ".heex" ->
        if String.contains?(blank_comments(contents), "data-component=") do
          :all
        else
          []
        end

      true ->
        starts =
          lines
          |> Enum.with_index(1)
          |> Enum.filter(fn {line, _} -> Regex.match?(~r/^\s*defp?\s+[a-z_]/, line) end)
          |> Enum.map(fn {_, line_no} -> line_no end)

        ends = Enum.drop(starts, 1) |> Enum.map(&(&1 - 1)) |> Kernel.++([length(lines)])

        Enum.zip(starts, ends)
        |> Enum.filter(fn {from, to} ->
          lines
          |> Enum.slice((from - 1)..(to - 1)//1)
          |> Enum.any?(&String.contains?(&1, "data-component="))
        end)
    end
  end

  defp exempt?(:all, _line_no), do: true

  defp exempt?(ranges, line_no),
    do: Enum.any?(ranges, fn {a, b} -> line_no >= a and line_no <= b end)

  defp allows_raw_html?(line, lines, line_no) do
    String.contains?(line, @allow_raw_html_marker) or
      case Enum.at(lines, line_no - 2) do
        nil -> false
        prev -> String.contains?(prev, @allow_raw_html_marker)
      end
  end

  # Heuristic: if the match is preceded by an odd number of unescaped
  # double-quotes on the same line, it's likely inside an Elixir string
  # literal (e.g. a docstring or an error message that mentions
  # `<button>`), not a real HEEx tag. Skip.
  defp in_string_literal?(line, match_offset) do
    line
    |> binary_part(0, match_offset)
    |> String.replace("\\\"", "")
    |> count_chars(?")
    |> rem(2)
    |> Kernel.==(1)
  end

  defp count_chars(string, char) do
    for <<c <- string>>, c == char, reduce: 0 do
      acc -> acc + 1
    end
  end

  defp raw_html_violation(path, line_no, tag) do
    suggestion =
      case String.downcase(tag) do
        "button" -> "use `<.button>` (or register a new wrapper for icon/ghost variants)"
        "input" -> "use `<.input>`"
        "textarea" -> "use `<.input type=\"textarea\">` (or register a new wrapper)"
        "select" -> "use `<.input type=\"select\">` (or register a new wrapper)"
        _ -> "lift this primitive into a registered wrapper"
      end

    %{
      rule: :raw_html_primitive,
      severity: :warning,
      message:
        "raw <#{tag}> outside a wrapper definition — #{suggestion}. " <>
          "Silence with `<%!-- #{@allow_raw_html_marker} --%>` on the same or " <>
          "preceding line. Inside a `~H` block that HEEx-comment form is the " <>
          "only one that works: a `#` line there is literal template text and " <>
          "renders into the page.",
      file: path,
      line: line_no,
      module: nil,
      function: nil
    }
  end
end

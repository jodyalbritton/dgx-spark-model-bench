defmodule Mix.Tasks.JobyKit.Lint do
  @shortdoc "Lint the host app's wrapper contract against the JobyKit manifest"

  @moduledoc """
  Verifies the JobyKit wrapper contract for this app.

  Checks every component registered in the host's `DesignManifest`:

    * Every entry points at a real Phoenix function component
      (`:manifest_drift`).
    * Every wrapper carries `data-component="Module.function"` on its
      root element (`:missing_data_component`).
    * Every wrapper declares `attr :rest, :global`
      (`:missing_rest_global`).

  Plus two sweeps across the host's source tree:

    * any function that carries `data-component=...` but is not
      registered in the manifest (`:unregistered_wrapper`) — i.e.
      wrappers invisible to `/design.json` and to agents.
    * any raw `<button>`/`<input>`/`<textarea>`/`<select>` in `.heex`
      or `~H` blocks outside a wrapper definition (`:raw_html_primitive`).
      Silence per-line with `<%!-- jobykit:allow-raw-html --%>` (heex)
      or `# jobykit:allow-raw-html` on the preceding `.ex` line.

  ## Usage

      mix joby_kit.lint
      mix joby_kit.lint --format json
      mix joby_kit.lint --manifest MyAppWeb.DesignManifest
      mix joby_kit.lint --paths "lib/**/components/**/*.ex"
      mix joby_kit.lint --strict      # warnings count as failures

  ## Options

    * `--manifest` — manifest module to lint. Defaults to
      `<App>Web.DesignManifest` derived from `mix.exs`.
    * `--paths` — glob pattern(s) to scan for unregistered wrappers
      and raw HTML primitives. Repeatable. Defaults to `lib/**/*.ex`
      and `lib/**/*.heex`.
    * `--format` — `text` (default) or `json`.
    * `--strict` — exit non-zero on warnings as well as errors.

  ## Exit codes

    * `0` — clean.
    * `1` — at least one error (or any violation under `--strict`).
  """

  use Mix.Task

  @requirements ["compile"]

  @switches [
    manifest: :string,
    paths: :keep,
    format: :string,
    strict: :boolean
  ]

  @impl Mix.Task
  def run(argv) do
    {opts, _argv, _invalid} = OptionParser.parse(argv, switches: @switches)

    manifest = resolve_manifest(opts[:manifest])
    paths = collect_paths(opts)
    format = Keyword.get(opts, :format, "text")
    strict? = Keyword.get(opts, :strict, false)

    violations = JobyKit.Lint.run(manifest: manifest, paths: paths)

    case format do
      "json" -> emit_json(manifest, violations)
      "text" -> emit_text(manifest, violations)
      other -> Mix.raise("unknown --format #{inspect(other)} (expected: text, json)")
    end

    if exit_nonzero?(violations, strict?) do
      exit({:shutdown, 1})
    else
      :ok
    end
  end

  # ------------------------------------------------------------ manifest

  defp resolve_manifest(nil) do
    app = Mix.Project.config()[:app] || Mix.raise("could not determine :app from mix.exs")
    web_module = Macro.camelize(to_string(app)) <> "Web"
    candidate = Module.concat([web_module, "DesignManifest"])

    case Code.ensure_loaded(candidate) do
      {:module, ^candidate} ->
        candidate

      _ ->
        Mix.raise("""
        could not auto-detect manifest module #{inspect(candidate)}.
        Pass one explicitly with --manifest <Module>.
        """)
    end
  end

  defp resolve_manifest(name) when is_binary(name) do
    module = Module.concat([name])

    case Code.ensure_loaded(module) do
      {:module, ^module} -> module
      _ -> Mix.raise("manifest module #{name} could not be loaded")
    end
  end

  defp collect_paths(opts) do
    case Keyword.get_values(opts, :paths) do
      [] -> ["lib/**/*.ex", "lib/**/*.heex"]
      list -> list
    end
  end

  # -------------------------------------------------------------- output

  defp emit_text(manifest, violations) do
    Mix.shell().info("JobyKit lint — #{inspect(manifest)}")
    Mix.shell().info("")

    if violations == [] do
      Mix.shell().info("  ✓ Clean. Wrapper contract holds across the manifest.")
    else
      Enum.each(violations, &print_violation/1)
      Mix.shell().info("")
      Mix.shell().info("Summary: #{summarize(violations)}.")
    end
  end

  defp print_violation(v) do
    severity = severity_label(v.severity)
    location = location_string(v)

    Mix.shell().info("  #{severity}  #{v.rule}")
    Mix.shell().info("    #{v.message}")
    if location, do: Mix.shell().info("    #{location}")
    Mix.shell().info("")
  end

  defp severity_label(:error), do: "ERROR"
  defp severity_label(:warning), do: " WARN"
  defp severity_label(:info), do: " INFO"

  defp location_string(%{file: nil}), do: nil
  defp location_string(%{file: file, line: nil}), do: file
  defp location_string(%{file: file, line: line}), do: "#{file}:#{line}"

  defp summarize(violations) do
    counts =
      violations
      |> Enum.frequencies_by(& &1.severity)
      |> Map.new()

    [
      pluralize(Map.get(counts, :error, 0), "error", "errors"),
      pluralize(Map.get(counts, :warning, 0), "warning", "warnings"),
      pluralize(Map.get(counts, :info, 0), "info", "infos")
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  defp pluralize(0, _singular, _plural), do: nil
  defp pluralize(1, singular, _plural), do: "1 #{singular}"
  defp pluralize(n, _singular, plural), do: "#{n} #{plural}"

  defp emit_json(manifest, violations) do
    payload = %{
      manifest: inspect(manifest),
      violations: Enum.map(violations, &serialize/1),
      summary: %{
        errors: Enum.count(violations, &(&1.severity == :error)),
        warnings: Enum.count(violations, &(&1.severity == :warning)),
        info: Enum.count(violations, &(&1.severity == :info))
      }
    }

    Mix.shell().info(Jason.encode!(payload, pretty: true))
  end

  defp serialize(v) do
    %{
      rule: v.rule,
      severity: v.severity,
      message: v.message,
      file: v.file,
      line: v.line,
      module: v.module && inspect(v.module),
      function: v.function && to_string(v.function)
    }
  end

  defp exit_nonzero?(violations, strict?) do
    Enum.any?(violations, fn v ->
      v.severity == :error or (strict? and v.severity == :warning)
    end)
  end
end

defmodule JobyKit.AppCss do
  @moduledoc false

  # Helpers for patching the host's `assets/css/app.css` during install.
  #
  # Tailwind v4 uses `@source` directives to discover class names. Class
  # names that live inside `deps/joby_kit/lib` won't be picked up unless
  # the host opts that path in, so kit components silently render
  # un-styled (e.g. `menu-horizontal` resolving to a vertical menu).
  #
  # The patch inserts a single `@source` line directly after the last
  # existing one. Idempotent and safe to re-run.
  #
  # The path is derived from `Mix.Project.deps_paths()` rather than
  # hardcoded to `../../deps/joby_kit/lib`. The hardcoded form was wrong
  # in two ways that both failed silently:
  #
  #   * Umbrella apps keep deps at the umbrella root, so the relative
  #     path from `apps/my_app/assets/css/` never resolved and Tailwind
  #     scanned nothing.
  #   * Switching an app between a hex dep and a path dep leaves the old
  #     `deps/joby_kit/` directory behind. The `@source` kept resolving —
  #     to a *stale copy of the previous version's source*. Observed
  #     live: Tailwind generated CSS from 0.2.1 while the app compiled
  #     against 0.2.3, so every class added in the newer kit was missing
  #     from the stylesheet and the new button tones rendered unstyled.
  #     No error anywhere; the only symptom was components looking wrong.

  @fallback_source_line ~s|@source "../../deps/joby_kit/lib";|

  @doc """
  Patches `path` (typically `assets/css/app.css`) so Tailwind scans the
  installed JobyKit dependency for class names.

  Returns one of `:patched | :unchanged | :missing` so the caller can
  log a useful summary. `:missing` is returned when the host has no
  `app.css` file at all (e.g. a non-Phoenix project).
  """
  def patch(path \\ "assets/css/app.css") do
    case File.read(path) do
      {:error, _} ->
        :missing

      {:ok, contents} ->
        line = source_line(path)

        if String.contains?(contents, line) do
          :unchanged
        else
          File.write!(path, insert_after_last_source(contents, line))
          :patched
        end
    end
  end

  @doc """
  The `@source` line for this project, relative to `css_path`'s directory.

  Falls back to the conventional `deps/joby_kit/lib` when the kit isn't a
  resolvable dependency (no Mix project, or the task running outside one).
  """
  def source_line(css_path \\ "assets/css/app.css") do
    case kit_lib_path() do
      nil ->
        @fallback_source_line

      lib_path ->
        relative =
          lib_path
          |> Path.relative_to(Path.expand(Path.dirname(css_path)))
          |> case do
            # relative_to/2 returns an absolute path when it can't build a
            # relative one; an absolute @source is valid and unambiguous.
            ^lib_path -> lib_path
            rel -> rel
          end

        ~s|@source "#{relative}";|
    end
  end

  defp kit_lib_path do
    case Mix.Project.deps_paths() do
      %{joby_kit: dep_path} -> dep_path |> Path.join("lib") |> Path.expand()
      _ -> nil
    end
  rescue
    # No surrounding Mix project (e.g. invoked from an archive).
    _ -> nil
  end

  defp insert_after_last_source(contents, line) do
    lines = String.split(contents, "\n")

    case last_source_index(lines) do
      nil -> prepend_source(contents, line)
      idx -> List.insert_at(lines, idx + 1, line) |> Enum.join("\n")
    end
  end

  defp last_source_index(lines) do
    lines
    |> Enum.with_index()
    |> Enum.filter(fn {line, _i} -> Regex.match?(~r/^\s*@source\b/, line) end)
    |> List.last()
    |> case do
      nil -> nil
      {_line, idx} -> idx
    end
  end

  defp prepend_source(contents, line) do
    line <> "\n" <> contents
  end
end

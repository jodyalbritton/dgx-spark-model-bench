defmodule JobyKit.AgentsMd do
  @moduledoc false

  # Helpers for patching the host's AGENTS.md file during install.
  #
  # Two transformations are applied (both idempotent, both safe to re-run):
  #
  #   * Append a `<!-- jobykit:start -->` … `<!-- jobykit:end -->` block
  #     describing how to use the kit.
  #   * Walk a list of rule-rewrites — Phoenix-default lines that are
  #     stale once the kit owns the corresponding components — and
  #     replace each with kit-friendly wording.
  #
  # Rule-rewrites are declared in `@rule_rewrites/0` below. Each entry
  # has a `:pattern`, `:replacement`, and `:reason` (the reason is for
  # human readers of this file, not the output). To add a rewrite for
  # another Phoenix-default rule the kit now owns, append a new map.

  @start_marker "<!-- jobykit:start -->"
  @end_marker "<!-- jobykit:end -->"

  @rule_rewrites [
    %{
      reason: "Phoenix's anti-daisy line directly contradicts the kit's wrapper-first stance.",
      pattern:
        ~r/^- \*\*Always\*\* manually write your own tailwind-based components instead of using daisyUI[^\n]*$/m,
      replacement:
        "- When a primitive UI need matches an existing core wrapper, use the wrapper instead of raw daisyUI or hand-rolled markup. JobyKit's goal is reuse and discoverability of existing app components, not generic daisyUI aesthetics. Page-level Tailwind for layout, motion, and visual hierarchy is encouraged; see \"Composition vs. creation\" below."
    },
    %{
      reason:
        "Phoenix's <.input> rule points at the host's core_components; the kit ships <.input> from JobyKit.CoreComponents.",
      pattern:
        ~r/^- \*\*Always\*\* use the imported `<\.input>` component for form inputs from `core_components\.ex`[^\n]*$/m,
      replacement:
        "- **Always** use the imported `<.input>` from `JobyKit.CoreComponents` (registered in `design_manifest.ex` and surfaced on `/design`). Using it saves steps and prevents form-error mistakes."
    },
    %{
      reason:
        "Phoenix's class-override rule for <.input> is wrong for the kit's <.input>, which treats class as additive.",
      pattern:
        ~r/^- If you override the default input classes \(`<\.input class=[^\n]*\n[^\n]*custom classes must fully style the input[^\n]*$/m,
      replacement:
        "- The kit's `<.input>` treats `class` as additive on top of the daisyUI defaults — pass utilities (margin, max-width, etc.) and the wrapper's identity classes (`input` / `select` / `textarea`) still apply."
    },
    %{
      reason:
        "Phoenix's <.icon> rule references the host's core_components; the kit ships <.icon>.",
      pattern:
        ~r/^- Out of the box, `core_components\.ex` imports an `<\.icon[^\n]*\n?[^\n]*Heroicons[^\n]*$/m,
      replacement:
        "- For icons, use `<.icon name=\"hero-x-mark\" />` from `JobyKit.CoreComponents`. **Never** use `Heroicons` modules or similar — the kit's `<.icon>` component is the canonical entry point."
    }
  ]

  @doc """
  Patches `path` (typically `AGENTS.md`) so that it (a) carries a
  JobyKit guidelines block and (b) doesn't contain Phoenix-default
  rules that the kit has now superseded.

  Creates the file if it does not exist. Returns one of
  `:created | :patched | :unchanged` so the calling mix task can print
  the right summary line.

  Pass `section: "...string..."` to override the appended block (used
  by tests).
  """
  def patch(path, opts \\ []) do
    section = Keyword.get_lazy(opts, :section, &default_section/0)

    {existing, file_existed?} =
      case File.read(path) do
        {:ok, contents} -> {contents, true}
        {:error, _} -> {"", false}
      end

    {rewritten, rewrite_count} = apply_rule_rewrites(existing)
    {with_block, appended?} = ensure_block(rewritten, section)

    cond do
      not file_existed? ->
        File.write!(path, with_block)
        :created

      rewrite_count > 0 or appended? ->
        File.write!(path, with_block)
        :patched

      true ->
        :unchanged
    end
  end

  @doc "Returns the canonical JobyKit AGENTS.md section."
  def default_section do
    Application.app_dir(:joby_kit, ["priv", "templates", "joby_kit.install", "AGENTS.md.section"])
    |> File.read!()
  end

  @doc """
  Returns the rule-rewrite list. Exposed for tests; not part of the
  stable API.
  """
  def rule_rewrites, do: @rule_rewrites

  defp apply_rule_rewrites(contents) do
    Enum.reduce(@rule_rewrites, {contents, 0}, fn rule, {acc, count} ->
      if Regex.match?(rule.pattern, acc) do
        replacement = String.trim_trailing(rule.replacement, "\n")
        updated = Regex.replace(rule.pattern, acc, replacement, global: false)
        {updated, count + 1}
      else
        {acc, count}
      end
    end)
  end

  # Requiring *both* markers meant a file that kept the start marker but
  # lost the end one got a second block appended — and then, with both
  # markers now present, was considered done forever, leaving the
  # duplicate permanently. Treat a lone start marker as "already has a
  # block, just a damaged one" and leave it alone rather than compound it.
  defp ensure_block(contents, section) do
    cond do
      String.contains?(contents, @start_marker) and String.contains?(contents, @end_marker) ->
        {contents, false}

      # Start marker without its end: the block is present but was
      # truncated by hand. Appending another leaves two start markers,
      # and from then on both markers are present so it looks done —
      # the duplicate becomes permanent. Leave the damaged block alone.
      String.contains?(contents, @start_marker) ->
        {contents, false}

      true ->
        separator = if String.ends_with?(contents, "\n") or contents == "", do: "", else: "\n"
        trailing = if String.ends_with?(section, "\n"), do: "", else: "\n"
        {contents <> separator <> section <> trailing, true}
    end
  end
end

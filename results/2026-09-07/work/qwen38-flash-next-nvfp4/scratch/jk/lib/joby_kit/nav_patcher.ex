defmodule JobyKit.NavPatcher do
  @moduledoc false

  # Patches the host's `lib/<app>_web/components/layouts/app.html.heex`
  # to add nav links pointing at `/design` and `/custom-designs`.
  #
  # Strategy is similar to `phx.gen.auth`: find the first `</ul>` that
  # follows a `<nav>` or `<header>` opening tag and inject `<li>` items
  # right before it. Items are wrapped in
  # `<%!-- jobykit:nav-start --%>` / `<%!-- jobykit:nav-end --%>`
  # comments so subsequent runs detect and skip the insertion.
  #
  # Returns one of:
  #
  #   * `:patched`        — inserted the block.
  #   * `:unchanged`      — markers already present (idempotent re-run).
  #   * `:no_nav_found`   — no `<nav>`/`<header>` + `</ul>` pair in the
  #                         file. Caller should print a manual-add note.
  #   * `:missing`        — file doesn't exist (e.g. host customized
  #                         layouts in a different shape). Caller decides.

  @start_marker "<%!-- jobykit:nav-start --%>"
  @end_marker "<%!-- jobykit:nav-end --%>"

  @kit_links [
    {"Design", "/design"},
    {"Custom Designs", "/custom-designs"}
  ]

  @doc """
  Patches `path` to inject the kit's nav links before the first `</ul>`
  inside a `<nav>` or `<header>`. Idempotent.

  Pass `:links` (a list of `{label, href}` tuples) to override the
  default kit links.
  """
  def patch(path, opts \\ []) do
    links = Keyword.get(opts, :links, @kit_links)

    case File.read(path) do
      {:error, _} ->
        :missing

      {:ok, contents} ->
        cond do
          String.contains?(contents, @start_marker) ->
            :unchanged

          true ->
            case locate_insertion_point(contents) do
              nil ->
                :no_nav_found

              {before_text, after_text, indent} ->
                new_contents = before_text <> render_block(links, indent) <> after_text
                File.write!(path, new_contents)
                :patched
            end
        end
    end
  end

  @doc false
  def kit_links, do: @kit_links

  @doc false
  def start_marker, do: @start_marker

  @doc false
  def end_marker, do: @end_marker

  # Locate the first `</ul>` that comes after a `<nav>` or `<header>`
  # opening tag. Returns `{before, after, indent}` where `indent` is
  # the run of whitespace that precedes the `</ul>` (used for matching
  # the host's existing indentation).
  defp locate_insertion_point(contents) do
    with [{nav_start, _}] <- Regex.run(~r/<(?:nav|header)\b/, contents, return: :index),
         remainder <- nav_element(contents, nav_start),
         {ul_offset, _len} <- :binary.match(remainder, "</ul>") do
      ul_pos = nav_start + ul_offset
      indent = leading_indent(contents, ul_pos)

      {
        binary_part(contents, 0, ul_pos),
        binary_part(contents, ul_pos, byte_size(contents) - ul_pos),
        indent
      }
    else
      _ -> nil
    end
  end

  # Everything from the nav/header open tag to its matching close.
  #
  # Previously the `</ul>` search ran to end-of-file, so a header with no
  # list of its own would happily adopt the first `</ul>` anywhere later
  # in the document — a footer link list, a sidebar — and the patch still
  # reported `:patched`. Bounding the search means a nav we can't place
  # links inside returns `:no_nav_found`, which the install task already
  # handles by printing manual instructions. Failing loudly beats writing
  # into the wrong element.
  defp nav_element(contents, nav_start) do
    rest = binary_part(contents, nav_start, byte_size(contents) - nav_start)

    close =
      case Regex.run(~r/<(nav|header)\b/, rest, capture: :all_but_first) do
        [tag] -> "</#{tag}>"
        _ -> nil
      end

    case close && :binary.match(rest, close) do
      {close_offset, len} -> binary_part(rest, 0, close_offset + len)
      _ -> rest
    end
  end

  # Walk backward from `pos` until a non-space/tab char or a newline,
  # returning the whitespace run that begins the `</ul>` line.
  defp leading_indent(contents, pos) do
    {indent, _} =
      Enum.reduce_while((pos - 1)..0//-1, {"", false}, fn i, {acc, _} ->
        case binary_part(contents, i, 1) do
          " " -> {:cont, {" " <> acc, false}}
          "\t" -> {:cont, {"\t" <> acc, false}}
          "\n" -> {:halt, {acc, true}}
          _ -> {:halt, {"", true}}
        end
      end)

    indent
  end

  defp render_block(links, indent) do
    items =
      Enum.map(links, fn {label, href} ->
        """
        #{indent}<li>
        #{indent}  <.link navigate={~p"#{href}"}>#{label}</.link>
        #{indent}</li>\
        """
      end)
      |> Enum.join("\n")

    "#{indent}#{@start_marker}\n#{items}\n#{indent}#{@end_marker}\n#{indent}"
  end
end

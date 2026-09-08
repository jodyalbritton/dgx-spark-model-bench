defmodule Mix.Tasks.JobyKit.Bootstrap do
  @shortdoc "Bootstrap an existing phx.new project as a JobyKit demo"

  @moduledoc """
  Bootstraps an existing `mix phx.new` project (run inside it) as a
  JobyKit demo. Run this when you already have a Phoenix app and want
  to convert it into a kit-flavored greenfield demo.

  For a fresh app from scratch, use `mix joby_kit.new` from the
  separate `joby_kit_new` archive (which wraps
  `mix phx.new --no-html` and ships the kit's HTML layer from minute
  one).

  Composes `mix joby_kit.install` (manifest, previews, and the two design
  LiveViews) with four additional steps appropriate for a blank greenfield
  project:

    1. Generate a clean `HomeLive` welcome page that composes the
       host's existing `<Layouts.app>`, so it reuses the project's nav,
       flash group, and chrome.
    2. Overwrite the install-shipped DesignSystemLive and
       CustomDesignsLive with greenfield variants that compose
       `<Layouts.app>` rather than rendering their own chrome.
    3. Rewire `router.ex` so:
         live "/", HomeLive, :index
         live "/design", DesignSystemLive, :index
         live "/custom-designs", CustomDesignsLive, :index
       …and the JSON manifest at `/design.json`.
    4. Optionally delete the now-unused `PageController` and
       `PageHTML` modules (skip with `--keep-page-controller`).

  This task is destructive — it edits `router.ex`, overwrites generated
  LiveViews, and may delete files. Use `mix joby_kit.install` instead if
  you have an existing project with meaningful state at `/`.

  ## Usage

      mix joby_kit.bootstrap
      mix joby_kit.bootstrap --force                  # overwrite all generated files
      mix joby_kit.bootstrap --keep-page-controller   # leave PageController in place
      mix joby_kit.bootstrap --web MyAppWeb           # specify web module name

  After this task completes:

      mix phx.server

  …and visit `http://localhost:4000/` for the Home page.
  """

  use Mix.Task

  @switches [force: :boolean, web: :string, keep_page_controller: :boolean]

  @greenfield_targets [
    {"home_live.ex", "live/home_live.ex"},
    {"design_system_live.ex", "live/design_system_live.ex"},
    {"custom_designs_live.ex", "live/custom_designs_live.ex"}
  ]

  @impl Mix.Task
  def run(args) do
    {opts, _argv, _invalid} = OptionParser.parse(args, switches: @switches)

    install_args =
      [] |> append_flag("--force", opts[:force]) |> append_flag("--web", opts[:web])

    # Call the module directly (not Mix.Task.run/2) so re-runs in the
    # same Mix lifecycle (e.g. from tests that exercise both tasks)
    # don't get short-circuited by Mix's run-once semantics.
    Mix.Tasks.JobyKit.Install.run(install_args)

    app = Keyword.fetch!(Mix.Project.config(), :app)
    web_module = web_module_name(opts[:web], app)
    web_path = Macro.underscore(web_module)
    app_camel = Macro.camelize(to_string(app))

    assigns = [
      app: app,
      app_camel: app_camel,
      web_module: web_module,
      web_path: web_path,
      web_module_anchor: String.replace(web_path, "/", "")
    ]

    overwrite_greenfield_pages(web_path, assigns)
    rewire_router(web_module, web_path)
    delete_page_controller(web_path, opts[:keep_page_controller])
    print_summary(web_module)

    :ok
  end

  defp append_flag(args, _flag, nil), do: args
  defp append_flag(args, _flag, false), do: args
  defp append_flag(args, flag, true), do: args ++ [flag]
  defp append_flag(args, flag, value) when is_binary(value), do: args ++ [flag, value]

  defp web_module_name(nil, app), do: "#{Macro.camelize(to_string(app))}Web"
  defp web_module_name(override, _app), do: override

  defp overwrite_greenfield_pages(web_path, assigns) do
    File.mkdir_p!("lib/#{web_path}/live")

    Enum.each(@greenfield_targets, fn {template, dest_relative} ->
      source = greenfield_template_path(template)
      dest = "lib/#{web_path}/#{dest_relative}"
      Mix.Generator.copy_template(source, dest, assigns, force: true)
    end)
  end

  defp greenfield_template_path(name) do
    Application.app_dir(:joby_kit, ["priv", "templates", "joby_kit.bootstrap", name])
  end

  defp rewire_router(web_module, web_path) do
    router = "lib/#{web_path}/router.ex"

    case File.read(router) do
      {:ok, body} ->
        body
        |> replace_home_route(web_module)
        |> ensure_kit_live_routes()
        |> ensure_json_route(web_module)
        |> write_router(router)

      {:error, _} ->
        Mix.shell().error("* could not read #{router}; routes were not auto-injected")
        :ok
    end
  end

  defp replace_home_route(contents, _web_module) do
    if Regex.match?(~r{\n\s*live\s+"/"\s*,\s*HomeLive}, contents) do
      contents
    else
      # Drop any pre-existing /design or /custom-designs live routes the
      # user may have added themselves (e.g. from a prior
      # `mix joby_kit.install` run); we re-insert the canonical block
      # below so they don't duplicate.
      contents = strip_existing_kit_live_routes(contents)

      case Regex.run(~r{(\s*)get\s+"/"\s*,\s+PageController\s*,\s+:home[^\n]*}, contents) do
        [match, indent] ->
          Mix.shell().info(
            "* update router (replace home route with /, /design, /custom-designs LiveViews)"
          )

          replacement =
            [
              ~s|live "/", HomeLive, :index|,
              ~s|live "/design", DesignSystemLive, :index|,
              ~s|live "/custom-designs", CustomDesignsLive, :index|
            ]
            |> Enum.map(&"#{indent}#{&1}")
            |> Enum.join("")

          String.replace(contents, match, replacement, global: false)

        _ ->
          Mix.shell().info(
            "* skip router (could not find default home route to replace; add the three live routes manually)"
          )

          contents
      end
    end
  end

  defp strip_existing_kit_live_routes(contents) do
    contents
    |> String.replace(~r{\n\s*live\s+"/design"\s*,\s+DesignSystemLive[^\n]*}, "")
    |> String.replace(~r{\n\s*live\s+"/custom-designs"\s*,\s+CustomDesignsLive[^\n]*}, "")
  end

  defp ensure_kit_live_routes(contents) do
    needed = [
      ~s|live "/", HomeLive, :index|,
      ~s|live "/design", DesignSystemLive, :index|,
      ~s|live "/custom-designs", CustomDesignsLive, :index|
    ]

    missing = Enum.reject(needed, &String.contains?(contents, &1))

    if missing == [] do
      contents
    else
      Mix.shell().info("* note router is missing one or more kit live routes; add manually:")
      Enum.each(missing, &Mix.shell().info("    #{&1}"))
      contents
    end
  end

  defp ensure_json_route(contents, web_module) do
    if String.contains?(contents, "JobyKit.ManifestController") do
      contents
    else
      Mix.shell().info("* update router (add /design.json route)")

      block = """

        scope "/" do
          pipe_through :api

          get "/design.json", JobyKit.ManifestController, :show,
            private: %{joby_kit_manifest: #{web_module}.DesignManifest}
        end
      """

      String.replace(contents, ~r{\nend\s*\z}, block <> "\nend\n", global: false)
    end
  end

  defp write_router(contents, path), do: File.write!(path, contents)

  defp delete_page_controller(_web_path, true) do
    Mix.shell().info("* skip PageController (kept by --keep-page-controller)")
  end

  defp delete_page_controller(web_path, _keep) do
    candidates = [
      "lib/#{web_path}/controllers/page_controller.ex",
      "lib/#{web_path}/controllers/page_html.ex",
      "lib/#{web_path}/controllers/page_html"
    ]

    Enum.each(candidates, fn path ->
      cond do
        File.dir?(path) ->
          File.rm_rf!(path)
          Mix.shell().info("* remove #{path}/")

        File.regular?(path) ->
          File.rm!(path)
          Mix.shell().info("* remove #{path}")

        true ->
          :ok
      end
    end)
  end

  defp print_summary(web_module) do
    Mix.shell().info("""

    JobyKit greenfield bootstrap complete.

    Routes wired:
      live "/", #{web_module}.HomeLive, :index
      live "/design", #{web_module}.DesignSystemLive, :index
      live "/custom-designs", #{web_module}.CustomDesignsLive, :index
      get  "/design.json", JobyKit.ManifestController, :show

    Start the server and visit http://localhost:4000/

        mix phx.server

    ── For the AI agent picking up this app ──────────────────────────

    CLAUDE.md (project root, auto-loaded by Claude Code) inlines the
    wrapper-contract diagnostics. AGENTS.md has the full build order.

    Symptoms you skipped step 1:

      • `<button class="…">` / `<input>` / `<textarea>` in `.heex` when
        `<.button>` / `<.input>` already exists.
      • A private function component styled as if it were a primitive.
      • A new component without `data-component`, `attr :rest, :global`,
        or a `DesignManifest` entry.

    Run `mix joby_kit.lint` before claiming done — it catches all three.
    """)
  end
end

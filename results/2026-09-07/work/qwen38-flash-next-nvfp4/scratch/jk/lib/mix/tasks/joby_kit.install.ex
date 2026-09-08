defmodule Mix.Tasks.JobyKit.Install do
  @shortdoc "Install JobyKit into an existing Phoenix application"

  @moduledoc """
  Installs JobyKit into an existing Phoenix project.

  Generates five files under `lib/<your_app>_web/`:

    * `design_manifest.ex` — `use JobyKit.Manifest`, with every shipped
      core wrapper pre-registered and a `daisy_overrides/0` callback.
    * `design_previews.ex` — preview functions for the registered
      components (one per component, suffixed `_preview`).
    * `components/composite_components.ex` — the worked `empty_state`
      composite, as a precedent for extending the kit.
    * `live/design_system_live.ex` — the kit-curated `/design` page.
    * `live/custom_designs_live.ex` — the host-owned `/custom-designs`
      page for composites and domain components.

  It also patches, idempotently: `AGENTS.md` and `CLAUDE.md` (the
  wrapper-contract guidance), `assets/css/app.css` (a Tailwind
  `@source` so kit classes are generated), and your layout's nav.

  Existing files are not overwritten unless you pass `--force`. Routes
  are not auto-injected; the task prints the lines you need to add to
  `router.ex` at the end.

  ## Usage

      mix joby_kit.install
      mix joby_kit.install --force            # overwrite existing files
      mix joby_kit.install --web MyAppWeb     # specify web module name

  ## Next steps

  After running this task, follow the printed instructions to:

    1. Add the two `live` routes and the JSON `get` route to your
       `router.ex`.
    2. Restart the dev server.
    3. Visit `/design` and `/custom-designs`.

  See the `mix joby_kit.bootstrap` task for a more aggressive variant
  aimed at fresh `mix phx.new` projects (replaces the default Phoenix
  landing page). For a from-scratch app, see `mix joby_kit.new`, which
  ships as the separate `joby_kit_new` archive.
  """

  use Mix.Task

  @switches [force: :boolean, web: :string]

  @impl Mix.Task
  def run(args) do
    {opts, _argv, _invalid} = OptionParser.parse(args, switches: @switches)

    # Tolerate missing project context (e.g. when invoked from a Mix
    # archive after `mix archive.install`). When there's no `:app`, the
    # caller must pass `--web` so we can derive the web module name.
    app = Keyword.get(Mix.Project.config(), :app)
    web_module = web_module_name(opts[:web], app)
    web_path = Macro.underscore(web_module)
    web_module_anchor = String.replace(web_path, "/", "")

    assigns = [
      app: app,
      web_module: web_module,
      web_path: web_path,
      web_module_anchor: web_module_anchor
    ]

    targets = [
      {"design_manifest.ex", "lib/#{web_path}/design_manifest.ex"},
      {"design_previews.ex", "lib/#{web_path}/design_previews.ex"},
      {"composite_components.ex", "lib/#{web_path}/components/composite_components.ex"},
      {"design_system_live.ex", "lib/#{web_path}/live/design_system_live.ex"},
      {"custom_designs_live.ex", "lib/#{web_path}/live/custom_designs_live.ex"}
    ]

    File.mkdir_p!("lib/#{web_path}/live")

    force? = opts[:force] == true

    Enum.each(targets, fn {template, dest} ->
      template_path = template_path(template)
      copy_or_skip(template_path, dest, assigns, force?)
    end)

    patch_agents_md()
    patch_claude_md()
    patch_app_css()
    patch_layout_nav(web_path)
    print_next_steps(web_module)
    :ok
  end

  defp patch_layout_nav(web_path) do
    # Phoenix 1.8 puts the layout markup either in app.html.heex (the
    # standard) or in the Layouts module's function component. Try both.
    candidates = [
      "lib/#{web_path}/components/layouts/app.html.heex",
      "lib/#{web_path}/components/layouts.ex"
    ]

    Enum.reduce_while(candidates, :no_match, fn path, _acc ->
      case JobyKit.NavPatcher.patch(path) do
        :patched ->
          Mix.shell().info(
            "* update #{path} (added /design and /custom-designs links to the nav)"
          )

          {:halt, :patched}

        :unchanged ->
          {:halt, :unchanged}

        :no_nav_found ->
          {:cont, :no_nav}

        :missing ->
          {:cont, :missing}
      end
    end)
    |> case do
      :patched -> :ok
      :unchanged -> :ok
      _other -> print_nav_manual_fallback(web_path)
    end
  end

  defp print_nav_manual_fallback(web_path) do
    Mix.shell().info("""
    * skipped layout nav patch (no <nav>/<header> + <ul> found in
      lib/#{web_path}/components/layouts/app.html.heex or layouts.ex).

      Add these manually to your nav so /design and /custom-designs are
      reachable:

          <li><.link navigate={~p"/design"}>Design</.link></li>
          <li><.link navigate={~p"/custom-designs"}>Custom Designs</.link></li>
    """)
  end

  defp patch_agents_md(path \\ "AGENTS.md") do
    case JobyKit.AgentsMd.patch(path) do
      :created ->
        Mix.shell().info("* create #{path}")

      :patched ->
        Mix.shell().info(
          "* update #{path} (added JobyKit guidelines; replaced daisyUI conflict line if present)"
        )

      :unchanged ->
        :ok
    end
  end

  defp patch_claude_md(path \\ "CLAUDE.md") do
    case JobyKit.ClaudeMd.patch(path) do
      :created ->
        Mix.shell().info(
          "* create #{path} (auto-loaded by Claude Code; inlines the wrapper-contract diagnostics)"
        )

      :patched ->
        Mix.shell().info("* update #{path} (added JobyKit wrapper-contract block)")

      :unchanged ->
        :ok
    end
  end

  defp patch_app_css(path \\ "assets/css/app.css") do
    case JobyKit.AppCss.patch(path) do
      :patched ->
        Mix.shell().info(
          "* update #{path} (added @source for deps/joby_kit/lib so Tailwind scans kit components)"
        )

      :unchanged ->
        :ok

      :missing ->
        :ok
    end
  end

  defp web_module_name(nil, nil) do
    Mix.raise("""
    Could not determine the web module name.

    `mix joby_kit.install` was invoked outside a Mix project (or in a
    project without an `:app` configured). Re-run with --web:

        mix joby_kit.install --web MyAppWeb
    """)
  end

  defp web_module_name(nil, app) do
    "#{Macro.camelize(to_string(app))}Web"
  end

  defp web_module_name(override, _app) when is_binary(override), do: override

  defp template_path(name) do
    Application.app_dir(:joby_kit, ["priv", "templates", "joby_kit.install", name])
  end

  defp copy_or_skip(source, dest, assigns, force?) do
    if File.exists?(dest) and not force? do
      Mix.shell().info("* skip #{dest} (already exists; use --force to overwrite)")
    else
      Mix.Generator.copy_template(source, dest, assigns, force: true)
    end
  end

  defp print_next_steps(web_module) do
    Mix.shell().info("""

    JobyKit files generated.

    Add these routes to your router (lib/#{Macro.underscore(web_module)}/router.ex):

        scope "/", #{web_module} do
          pipe_through :browser

          live "/design", DesignSystemLive, :index
          live "/custom-designs", CustomDesignsLive, :index
        end

        scope "/" do
          # The JSON endpoint needs a JSON-accepting pipeline. Use the
          # default `:api` pipeline that ships with `mix phx.new`, or
          # roll your own that fetches sessions/auth if you want to
          # gate the manifest behind a logged-in user.
          pipe_through :api

          get "/design.json", JobyKit.ManifestController, :show,
            private: %{joby_kit_manifest: #{web_module}.DesignManifest}
        end

    Then restart `mix phx.server`, visit /design and /custom-designs, and
    extend lib/#{Macro.underscore(web_module)}/design_manifest.ex with
    your own component registrations.

    Note on core components: the manifest registers `JobyKit.CoreComponents`
    (button, card, icon, input, flash). Your host's `<.button>` etc. still
    resolve through `#{web_module}.CoreComponents` until you wire the kit
    module in. To make `<.button>` etc. resolve to the kit version, edit
    lib/#{Macro.underscore(web_module)}.ex's `html_helpers` to:

        import JobyKit.CoreComponents
        # remove or thin out: import #{web_module}.CoreComponents

    Run `mix joby_kit.lint` to verify the contract holds end-to-end.

    Tip: run `curl http://localhost:PORT/design.json | jq` to see the
    machine-readable manifest your AI agents can consume.

    ── For the AI agent picking up this app ──────────────────────────

    CLAUDE.md (project root, auto-loaded by Claude Code) inlines the
    wrapper-contract diagnostics. AGENTS.md has the full build order.

    Symptoms you skipped step 1:

      • `<button class="…">` / `<input>` / `<textarea>` in `.heex` when
        `<.button>` / `<.input>` already exists.
      • A private function component styled as if it were a primitive.
      • A new component without `data-component`, `attr :rest, :global`,
        or a `DesignManifest` entry.

    Run `mix joby_kit.lint` to catch all three.
    """)
  end
end

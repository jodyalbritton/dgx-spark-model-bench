defmodule JobyKit.MixProject do
  use Mix.Project

  @version "0.3.3"
  @source_url "https://github.com/jobycorp/joby_kit"

  def project do
    [
      app: :joby_kit,
      version: @version,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # A floor, not a target. Set below the current 90.9% so a genuine
      # regression trips it without every small refactor doing so.
      test_coverage: [threshold: 85],
      description: description(),
      package: package(),
      docs: docs(),
      name: "JobyKit",
      source_url: @source_url
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_html, "~> 4.1"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    An opinionated, agentic-first design-system kit for Phoenix + daisyUI.
    Ships a component manifest, a /design page, a /design.json endpoint for
    AI agents, contract-clean core wrappers, a wrapper-contract linter, and
    mix tasks for installing into existing apps or generating new ones.
    """
  end

  defp package do
    [
      maintainers: ["Jody Albritton"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: ~w(lib priv/templates .formatter.exs mix.exs README.md LICENSE CHANGELOG.md
           MIGRATING-0.3.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "MIGRATING-0.3.md"],
      source_url: @source_url,
      source_ref: "v#{@version}",
      # These are referenced by name in the README/CHANGELOG prose but are
      # deliberately `@moduledoc false` (internal patchers) or hidden
      # upstream. Render them as plain code instead of trying to link them.
      skip_code_autolink_to: [
        "JobyKit.AgentsMd",
        "JobyKit.ClaudeMd",
        "JobyKit.NavPatcher",
        "JobyKit.AppCss",
        "Phoenix.Component.__components__/0"
      ]
    ]
  end
end

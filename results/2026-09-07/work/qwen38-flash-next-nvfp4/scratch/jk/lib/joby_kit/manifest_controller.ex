defmodule JobyKit.ManifestController do
  @moduledoc """
  Serves the host's design manifest as JSON for agent consumption.

  Hosts wire this up by passing their manifest module via route
  `:private`:

      scope "/" do
        pipe_through :authenticated_json
        get "/design.json", JobyKit.ManifestController, :show,
          private: %{joby_kit_manifest: MyAppWeb.DesignManifest}
      end

  The controller does not enforce auth on its own — that's the host's
  pipeline's responsibility. Pair it with a JSON-accepting authenticated
  pipeline (or a public pipeline if the manifest is OK to expose).
  """

  use Phoenix.Controller, formats: [:json]

  alias JobyKit.Contract

  def show(conn, _params) do
    case fetch_manifest(conn) do
      {:ok, manifest} ->
        Phoenix.Controller.json(conn, payload(manifest))

      :error ->
        conn
        |> put_status(:internal_server_error)
        |> Phoenix.Controller.json(%{
          error: "missing manifest",
          hint:
            "Pass the manifest module via route private, e.g. private: %{joby_kit_manifest: MyAppWeb.DesignManifest}"
        })
    end
  end

  # Any atom used to pass this guard, so a typo'd module name
  # (`DesignManifst`) sailed through and then raised
  # UndefinedFunctionError deep inside payload/1 — surfacing as a generic
  # HTML 500 rather than the JSON error written for exactly this case.
  defp fetch_manifest(conn) do
    with module when is_atom(module) and not is_nil(module) <- conn.private[:joby_kit_manifest],
         {:module, ^module} <- Code.ensure_loaded(module),
         true <- function_exported?(module, :entries, 0) do
      {:ok, module}
    else
      _ -> :error
    end
  end

  defp payload(manifest) do
    %{
      generated_at: DateTime.utc_now(),
      contract: %{
        build_order: Enum.map(Contract.build_order(), & &1.title),
        rules: Enum.map(Contract.rules(), & &1.title),
        taxonomy:
          Enum.map(Contract.taxonomy(), fn layer ->
            %{layer: layer.layer, title: layer.title, body: layer.body}
          end)
      },
      categories:
        Enum.map(manifest.categories(), fn category ->
          %{
            id: category,
            label: manifest.category_label(category),
            description: manifest.category_description(category)
          }
        end),
      components: Enum.map(all_entries(manifest), &serialize_entry/1)
    }
  end

  # The kit's entries plus the host's. Agents read this endpoint as the
  # single source of truth, so it has to cover both surfaces — and since
  # the kit now registers its own components, a host that still lists
  # them (every install before 0.3.2 did) would otherwise produce
  # duplicates. Kit entries win; host copies of the same component are
  # dropped.
  defp all_entries(manifest) do
    kit = JobyKit.KitManifest.entries()
    kit_keys = MapSet.new(kit, & &1.data_component)

    host = Enum.reject(manifest.entries(), &MapSet.member?(kit_keys, &1.data_component))

    kit ++ host
  end

  defp serialize_entry(entry) do
    %{
      module: inspect(entry.module),
      function: entry.function,
      label: entry.label,
      category: entry.category,
      daisy_basis: entry.daisy_basis,
      summary: entry.summary,
      anchor: entry.anchor,
      data_component: entry.data_component,
      source: entry.source,
      line: entry.line,
      # True when this app substitutes its own copy of a component the kit
      # also ships — i.e. upstream fixes to it do not reach this app.
      forked_from_kit: entry.forked_from_kit,
      attrs: entry.attrs,
      slots: entry.slots
    }
  end
end

defmodule Benchapp.Signups do
  @moduledoc """
  In-memory signups + live counters shared by every HomeLive session.

  Signups and per-signup email validation state live in an ETS table
  (`:benchapp_signups`), so all connected users see the same list. The
  table survives code reloads (created once per node in `ensure_table/0`).
  """

  import Ecto.Changeset

  alias Benchapp.Signups.Signup

  @table :benchapp_signups
  @max_signups 10
  @max_activities 10

  defmodule Signup do
    @moduledoc false
    use Ecto.Schema

    embedded_schema do
      field :email, :string
      field :at, :integer
    end

    def changeset(signup, attrs) do
      signup
      |> Ecto.Changeset.cast(attrs, [:email])
      |> Ecto.Changeset.validate_required([:email])
      |> Ecto.Changeset.validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    end
  end

  # -- Signup API -------------------------------------------------------

  @doc "Returns the signup changeset for form rendering."
  def change_signup(attrs \\ %{}) do
    Signup.changeset(%Signup{}, attrs)
  end

  @doc """
  Creates a signup from attrs. Returns `{:ok, signup}` or
  `{:error, changeset}`.
  """
  def create_signup(attrs) do
    changeset = Signup.changeset(%Signup{at: System.system_time(:millisecond)}, attrs)

    with {:ok, %Signup{} = signup} <- apply_action(changeset, :insert) do
      email = String.downcase(signup.email)

      if registered?(email) do
        {:error, %{changeset | errors: [email: {"Already signed up.", []}]}}
      else
        ensure_table()
        id = "signup-#{System.unique_integer([:positive])}"
        :ets.insert(@table, {id, email, signup.at})
        {:ok, %{signup | id: id, email: email}}
      end
    end
  end

  @doc "Recent signups, newest first, capped at #{@max_signups}."
  def recent_signups do
    ensure_table()

    @table
    |> :ets.tab2list()
    |> Enum.flat_map(fn
      {id, email, at} when is_integer(at) -> [%{id: id, email: email, at: at}]
      _ -> []
    end)
    |> Enum.sort_by(& &1.at, :desc)
    |> Enum.take(@max_signups)
  end

  def registered?(email) when is_binary(email) do
    ensure_table()
    :ets.member(@table, email)
  end

  def registered?(_), do: false

  def signup_count do
    ensure_table()

    @table
    |> :ets.tab2list()
    |> Enum.count(fn {_id, email, at} -> is_integer(at) and is_binary(email) end)
  end

  # -- Activity feed ----------------------------------------------------

  @doc "Adds an activity entry. Trimmed to the last #{@max_activities}."
  def add_activity(kind, label) do
    ensure_table()

    entry = %{
      id: "activity-#{System.unique_integer([:positive])}",
      kind: kind,
      label: label,
      at: System.system_time(:millisecond)
    }

    :ets.insert(@table, {entry.id, entry})

    activities()
    |> Enum.drop(-@max_activities)
    |> Enum.each(fn e -> :ets.delete(@table, e.id) end)

    entry
  end

  @doc "Activity entries, newest first, capped at #{@max_activities}."
  def activities do
    ensure_table()

    @table
    |> :ets.tab2list()
    |> Enum.filter(fn
      {_id, %{kind: _}} -> true
      _ -> false
    end)
    |> Enum.map(fn {_id, entry} -> entry end)
    |> Enum.sort_by(& &1.at, :desc)
  end

  # -- Counters ---------------------------------------------------------

  def increment_ticks do
    ensure_table()
    :ets.update_counter(@table, :ticks, {2, 1}, {:ticks, 0, 0})
  end

  def tick_count do
    ensure_table()

    case :ets.lookup(@table, :ticks) do
      [{:ticks, count, _ts}] -> count
      [] -> 0
    end
  end

  def reset! do
    if :ets.whereis(@table) != :undefined do
      :ets.delete_all_objects(@table)
    end
  end

  # -- Internals --------------------------------------------------------

  defp ensure_table do
    if :ets.whereis(@table) == :undefined do
      try do
        :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
      rescue
        ArgumentError -> :ok
      end
    end

    :ok
  end
end

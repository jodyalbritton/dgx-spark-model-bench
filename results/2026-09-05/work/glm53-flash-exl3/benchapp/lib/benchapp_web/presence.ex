defmodule BenchappWeb.Presence do
  @moduledoc """
  In-memory launch-day state shared across LiveView processes: the
  countdown ticker, newsletter signups, and the activity feed.

  A single GenServer holds the state; each connected HomeLive process
  receives `:tick` messages every 5 seconds and calls `tick/0`, which
  advances the shared clock once per interval regardless of how many
  viewers are attached.
  """

  use GenServer

  @max_activities 10

  # ---------------------------------------------------------------- client

  defp server do
    Application.get_env(:benchapp, :presence_server, __MODULE__)
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  @doc "Current countdown value, tick count, and activity entries (newest first)."
  def tick do
    GenServer.call(server(), :tick)
  end

  @doc "Adds a signup. `{:error, :invalid}` for malformed addresses, `{:error, :taken}` for duplicates."
  def add_signup(email) do
    GenServer.call(server(), {:add_signup, email})
  end

  @doc "Recent signup emails, most recent last."
  def recent_signups do
    GenServer.call(server(), :recent_signups)
  end

  # ---------------------------------------------------------------- server

  @impl true
  def init(:ok) do
    {:ok, %{countdown: 100, ticks: 0, signups: MapSet.new(), signup_order: [], activities: []}}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    countdown = if state.countdown <= 1, do: 100, else: state.countdown - 1
    ticks = state.ticks + 1

    state = %{
      state
      | countdown: countdown,
        ticks: ticks,
        activities: push_activity("Countdown ticked to #{countdown}", state.activities)
    }

    {:reply, {countdown, ticks, state.activities}, state}
  end

  def handle_call({:add_signup, email}, _from, state) do
    email = String.trim(email || "")

    cond do
      not valid_email?(email) ->
        {:reply, {:error, :invalid}, state}

      MapSet.member?(state.signups, String.downcase(email)) ->
        {:reply, {:error, :taken}, state}

      true ->
        state = %{
          state
          | signups: MapSet.put(state.signups, String.downcase(email)),
            signup_order: state.signup_order ++ [email],
            activities: push_activity("#{email} joined the launch list", state.activities)
        }

        {:reply, {:ok, email}, state}
    end
  end

  def handle_call(:recent_signups, _from, state) do
    {:reply, state.signup_order, state}
  end

  # --------------------------------------------------------------- helpers

  defp push_activity(entry, activities) do
    Enum.take([entry | activities], @max_activities)
  end

  defp valid_email?(email) do
    Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email)
  end
end

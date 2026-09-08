defmodule Benchapp.Launch do
  @moduledoc """
  Launch-page state: the beta countdown's starting value and the
  newsletter signup rules.

  Signups are held in the LiveView that collected them, so "already
  subscribed" is checked against the `taken` list the caller passes in
  — no database, no process to supervise.
  """

  alias Benchapp.Launch.Signup

  @countdown_start 100

  @doc "The value the beta countdown starts from."
  def countdown_start, do: @countdown_start

  @doc "A blank changeset for the signup form."
  def signup_changeset(attrs \\ %{}), do: Signup.changeset(attrs)

  @doc """
  Validates an address against `taken` and returns `{:ok, signup}` or
  `{:error, changeset}`.
  """
  def register(attrs, taken) do
    changeset =
      Signup.changeset(attrs)
      |> Ecto.Changeset.validate_exclusion(:email, taken, message: "is already on the list")

    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  @doc "The first validation message on `changeset`, for `#signup-error`."
  def error_message(changeset) do
    case Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
           Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
             opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
           end)
         end) do
      %{email: [message | _]} -> message
      _ -> "could not be saved"
    end
  end
end

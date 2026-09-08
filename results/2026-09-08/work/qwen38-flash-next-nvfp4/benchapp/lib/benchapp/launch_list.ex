defmodule Benchapp.LaunchList do
  @moduledoc """
  The pilot-attendee list for a Tidepool launch window.

  Deliberately in-memory: the landing page keeps the list in its own
  LiveView assigns, so this module is pure functions — normalise, validate,
  and reject duplicates. No Ecto schema, no Repo, no database.

  Validation runs through `Ecto.Changeset` so the page has one set of
  messages to render, and the same rules hold whether they arrive from a
  submit or from live change validation.
  """

  @email_format ~r/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/

  @typedoc "An address as it is stored on the list."
  @type email :: String.t()

  @doc """
  Canonical form of an address: trimmed, lower-cased.

  Duplicates are decided on this value, so `Ada@Lab.org ` and
  `ada@lab.org` are the same signup.
  """
  @spec normalize(String.t() | nil) :: String.t()
  def normalize(email) when is_binary(email), do: email |> String.trim() |> String.downcase()
  def normalize(_), do: ""

  @doc """
  Changeset over `%{"email" => address}` — trims, requires, and format-checks.

  Errors are the messages the page shows verbatim, so `signup-error` reads
  the same whether the address was malformed or already on the list.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(params) when is_map(params) do
    {%{}, %{email: :string}}
    |> Ecto.Changeset.cast(params, [:email])
    |> Ecto.Changeset.update_change(:email, &normalize/1)
    |> Ecto.Changeset.validate_required(:email, message: "Enter an email address.")
    |> Ecto.Changeset.validate_format(:email, @email_format,
      message: "That doesn't look like an email address."
    )
    |> Ecto.Changeset.validate_length(:email, max: 160, message: "That address is too long.")
  end

  @doc """
  Validates one address against the list already signed up.

  Returns `{:ok, normalized}` when the address is well-formed and absent,
  `{:error, message}` otherwise.
  """
  @spec check_signup(String.t() | nil, [email()]) :: {:ok, email()} | {:error, String.t()}
  def check_signup(email, signed_up) when is_list(signed_up) do
    changeset = changeset(%{"email" => email})

    cond do
      not changeset.valid? ->
        {:error, first_message(changeset)}

      Enum.member?(signed_up, changeset.changes.email) ->
        {:error, "That address is already on this launch list."}

      true ->
        {:ok, changeset.changes.email}
    end
  end

  @doc """
  Whether an address is well-formed, ignoring the list.

  Live validation uses this so a half-typed address reads as unfinished
  rather than wrong.
  """
  @spec valid_email?(String.t() | nil) :: boolean()
  def valid_email?(email) do
    changeset(%{"email" => email}).valid?
  end

  # The first error's own message, interpolations filled in — the page shows
  # it verbatim in `#signup-error`.
  defp first_message(%{errors: [{_field, {message, opts}} | _]}) do
    Enum.reduce(opts, message, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp first_message(_changeset), do: "That address could not be saved."
end

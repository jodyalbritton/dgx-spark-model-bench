defmodule Benchapp.Crew do
  @moduledoc """
  Crew-manifest bookkeeping for the Lodestar launch page.

  Deliberately database-free: the demo manifest lives in the LiveView's own
  state, and this module holds the parts worth testing on their own — the
  email changeset and the "reject the second copy" rule. Everything here is
  pure, so the LiveView keeps the state and this keeps the policy.
  """

  defmodule Signup do
    @moduledoc """
    An embedded (never persisted) signup record.
    """
    use Ecto.Schema

    import Ecto.Changeset

    @email_format ~r/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/

    embedded_schema do
      field :email, :string
    end

    def changeset(%Signup{} = signup, attrs) do
      signup
      |> cast(attrs, [:email])
      |> update_change(:email, &Benchapp.Crew.normalize/1)
      |> validate_required([:email], message: "is required")
      |> validate_length(:email, max: 254)
      |> validate_format(:email, @email_format, message: "is not a deliverable address")
    end
  end

  @typedoc "A manifest entry as the page renders it."
  @type entry :: %{
          id: String.t(),
          email: String.t(),
          at: Time.t(),
          seq: pos_integer()
        }

  @doc "A changeset for the signup form, driven by `to_form/1` in the LiveView."
  def change_signup(attrs \\ %{}) do
    Signup.changeset(%Signup{}, attrs)
  end

  @doc """
  Adds `email` to `entries`, which must already be newest-first.

  Returns `{:ok, entry, entries}` when the address is well-formed and
  absent, `{:error, reason}` otherwise — `:invalid` for a malformed
  address, `:duplicate` for one already on the manifest.
  """
  @spec subscribe([entry()], String.t() | nil) ::
          {:ok, entry(), [entry()]} | {:error, :invalid | :duplicate}
  def subscribe(entries, email) when is_binary(email) do
    changeset = change_signup(%{"email" => email})
    candidate = Ecto.Changeset.get_change(changeset, :email)

    cond do
      not changeset.valid? ->
        {:error, :invalid}

      Enum.any?(entries, &(&1.email == candidate)) ->
        {:error, :duplicate}

      true ->
        entry = %{
          id: "signup-#{System.unique_integer([:positive, :monotonic])}",
          email: candidate,
          at: Time.utc_now(),
          seq: length(entries) + 1
        }

        {:ok, entry, [entry | entries]}
    end
  end

  def subscribe(_entries, _email), do: {:error, :invalid}

  @doc """
  A single readable line for `#signup-error`.

  Changeset messages are fragments — "is not a deliverable address" — so
  they get a subject here. Returns `nil` for a valid changeset, which lets
  callers treat "no message" as "valid" without re-running the validation.
  """
  def error_message(changeset) do
    messages =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, _opts} -> msg end)
      |> Map.values()
      |> List.flatten()

    case messages do
      [] -> nil
      [first | _] -> "That email address #{first}."
    end
  end

  @doc "Trims and lowercases an address, the one way the manifest compares them."
  def normalize(email) when is_binary(email) do
    email |> String.trim() |> String.downcase()
  end
end

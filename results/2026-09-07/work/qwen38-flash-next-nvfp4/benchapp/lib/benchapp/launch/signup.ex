defmodule Benchapp.Launch.Signup do
  @moduledoc """
  An embedded signup record: the newsletter address the landing page
  collects, with its validation rules.

  Deliberately `embedded_schema` — signups live in LiveView state for
  the life of the session, so there is nothing to persist and no table
  to migrate.
  """
  use Ecto.Schema

  embedded_schema do
    field :email, :string
  end

  @email_format ~r/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/

  def changeset(attrs) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(attrs, [:email])
    |> Ecto.Changeset.update_change(:email, fn email ->
      email |> String.trim() |> String.downcase()
    end)
    |> Ecto.Changeset.validate_required(:email, message: "is required")
    |> Ecto.Changeset.validate_format(:email, @email_format,
      message: "is not a valid email address"
    )
  end
end

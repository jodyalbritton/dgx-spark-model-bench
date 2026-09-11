defmodule Benchapp.Repo do
  use Ecto.Repo,
    otp_app: :benchapp,
    adapter: Ecto.Adapters.Postgres
end

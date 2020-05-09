defmodule Seance.Repo do
  use Ecto.Repo,
    otp_app: :seance,
    adapter: Ecto.Adapters.Postgres
end

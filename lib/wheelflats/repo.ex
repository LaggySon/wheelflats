defmodule Wheelflats.Repo do
  use Ecto.Repo,
    otp_app: :wheelflats,
    adapter: Ecto.Adapters.Postgres
end

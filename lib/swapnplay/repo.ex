defmodule Swapnplay.Repo do
  use Ecto.Repo,
    otp_app: :swapnplay,
    adapter: Ecto.Adapters.Postgres
end

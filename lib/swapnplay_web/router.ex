defmodule SwapnplayWeb.Router do
  use SwapnplayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SwapnplayWeb do
    pipe_through :api
  end
end

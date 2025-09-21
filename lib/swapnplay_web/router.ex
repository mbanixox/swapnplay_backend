defmodule SwapnplayWeb.Router do
  use SwapnplayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", SwapnplayWeb.Api do
    pipe_through :api

    # Game routes
    resources "/games", GamesController, only: [:index, :show] do
      get "/screenshots", GamesController, :screenshots
    end

    # Genre routes
    get "/genres", GenresController, :index
    get "/genres/:genre_query", GenresController, :show

  end
end

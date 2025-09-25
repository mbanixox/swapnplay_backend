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

  # Cache management routes
  scope "/api/cache", SwapnplayWeb.Api do
    pipe_through :api

    get "/stats", CacheController, :stats
    post "/warmup", CacheController, :warm_cache
    delete "/games/:id", CacheController, :invalidate_game
    delete "/genres", CacheController, :invalidate_genre
    delete "/genres/:genre_query", CacheController, :invalidate_genre
    delete "/clear", CacheController, :clear_all
  end
end

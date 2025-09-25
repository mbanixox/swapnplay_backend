defmodule SwapnplayWeb.Api.CacheController do
  use SwapnplayWeb, :controller

  alias Swapnplay.{Games, CacheService}

  # GET /api/cache/stats
  def stats(conn, _params) do
    stats = Games.get_cache_stats()
    json(conn, stats)
  end

  # DELETE /api/cache/games/:id
  def invalidate_game(conn, %{"id" => game_id}) do
    Games.invalidate_game_cache(game_id)
    json(conn, %{message: "Invalidated cache for game ID: #{game_id}"})
  end

  # DELETE /api/cache/genres
  # DELETE /api/cache/genres/:genre_query
  def invalidate_genre(conn, params) do
    genre_query = Map.get(params, "genre_query")
    Games.invalidate_genres_cache(genre_query)

    message =
      if genre_query do
        "Invalidated cache for genre: #{genre_query}"
      else
        "All genres cache cleared"
      end

    json(conn, %{message: message})
  end

  # POST /api/cache/warmup
  def warm_cache(conn, _params) do
    CacheService.warm_up_cache()
    json(conn, %{message: "Cache warm-up initiated"})
  end

  # DELETE /api/cache/clear
  def clear_all(conn, _params) do
    CacheService.clear_cache(:games_cache)
    CacheService.clear_cache(:genres_cache)
    json(conn, %{message: "All caches cleared"})
  end
end

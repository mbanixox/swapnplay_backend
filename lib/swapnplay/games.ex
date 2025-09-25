defmodule Swapnplay.Games do
  @moduledoc """
  Context for game-related operations using RAWG API
  """

  alias Swapnplay.{RawgClient, CacheService}

  def fetch_genres do
    CacheService.fetch_with_cache(
      :genres_cache,
      "all_genres",
      :genres,
      fn ->
        case RawgClient.get("/genres") do
          {:ok, response} ->
            filtered_response =
              response
              |> Map.delete("next")
              |> Map.delete("previous")

            {:ok, filtered_response}

          {:error, reason} ->
            {:error, reason}
        end
      end
    )
  end

  def fetch_games(options \\ []) do
    search_query = Keyword.get(options, :search)
    genre_query = Keyword.get(options, :genres)
    platforms = Keyword.get(options, :platforms, RawgClient.default_platforms())
    page = Keyword.get(options, :page, 1)
    page_size = Keyword.get(options, :page_size, 20)

    params = [
      platforms: platforms,
      page: page,
      page_size: page_size
    ]

    params = if search_query, do: Keyword.put(params, :search, search_query), else: params
    params = if genre_query, do: Keyword.put(params, :genres, genre_query), else: params

    # Generate a cache key based on the parameters
    cache_key = CacheService.cache_key("games", params)

    cache_type =
      cond do
        search_query -> :games_search
        genre_query -> :games_by_genre
        true -> :games_list
      end

    CacheService.fetch_with_cache(
      :games_cache,
      cache_key,
      cache_type,
      fn ->
        case RawgClient.get("/games", params) do
          {:ok, response} ->
            filtered_response =
              response
              |> Map.delete("next")
              |> Map.delete("previous")

            {:ok, filtered_response}

          {:error, reason} ->
            {:error, reason}
        end
      end
    )
  end

  def fetch_genre_details(genre_query) do
    cache_key = "genre_details:#{genre_query}"

    CacheService.fetch_with_cache(
      :genres_cache,
      cache_key,
      :genre_details,
      fn -> RawgClient.get("/genres/#{genre_query}") end
    )
  end

  def fetch_game_details(game_id) do
    cache_key = "game_details:#{game_id}"

    CacheService.fetch_with_cache(
      :games_cache,
      cache_key,
      :game_details,
      fn -> RawgClient.get("/games/#{game_id}") end
    )
  end

  def fetch_game_screenshots(game_id) do
    cache_key = "game_screenshots:#{game_id}"

    CacheService.fetch_with_cache(
      :games_cache,
      cache_key,
      :game_screenshots,
      fn ->
        case RawgClient.get("/games/#{game_id}/screenshots") do
          {:ok, response} ->
            filtered_response =
              response
              |> Map.delete("next")
              |> Map.delete("previous")

            {:ok, filtered_response}

          {:error, reason} ->
            {:error, reason}
        end
      end
    )
  end

  # Cache management functions

  def invalidate_game_cache(game_id) do
    patterns = [
      "game_details:#{game_id}",
      "game_screenshots:#{game_id}"
    ]

    Enum.each(patterns, &CacheService.invalidate_cache(:games_cache, &1))
  end

  def invalidate_genres_cache(genre_query \\ nil) do
    if genre_query do
      CacheService.invalidate_cache(:genres_cache, "genre_details:#{genre_query}")
    else
      CacheService.clear_cache(:genres_cache)
    end
  end

  def get_cache_stats do
    %{
      games_cache: CacheService.get_cache_stats(:games_cache),
      genres_cache: CacheService.get_cache_stats(:genres_cache)
    }
  end
end

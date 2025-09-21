defmodule Swapnplay.Games do
  @moduledoc """
  Context for game-related operations using RAWG API
  """

  alias Swapnplay.RawgClient

  def fetch_genres do
    case RawgClient.get("/genres") do
      {:ok, response} ->
        filtered_response =
          response
          |> Map.delete("next")
          |> Map.delete("previous")
        {:ok, filtered_response}
      {:error, reason} -> {:error, reason}
    end
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

    case RawgClient.get("/games", params) do
      {:ok, response} ->
        filtered_response =
          response
          |> Map.delete("next")
          |> Map.delete("previous")
        {:ok, filtered_response}
      {:error, reason} -> {:error, reason}
    end
  end

  def fetch_genre_details(genre_query) do
    RawgClient.get("/genres/#{genre_query}")
  end

  def fetch_game_details(game_id) do
    RawgClient.get("/games/#{game_id}")
  end

  def fetch_game_screenshots(game_id) do
    case RawgClient.get("/games/#{game_id}/screenshots") do
      {:ok, response} ->
        filtered_response =
          response
          |> Map.delete("next")
          |> Map.delete("previous")
        {:ok, filtered_response}
      {:error, reason} -> {:error, reason}
    end
  end
end

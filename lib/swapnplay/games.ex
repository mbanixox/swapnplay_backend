defmodule Swapnplay.Games do
  @moduledoc """
  Context for game-related operations using RAWG API
  """

  alias Swapnplay.RawgClient

  def fetch_genres do
    RawgClient.get("/genres")
  end

  def fetch_games(options \\ []) do
    search_query = Keyword.get(options, :search)
    platforms = Keyword.get(options, :platforms, RawgClient.default_platforms())
    page = Keyword.get(options, :page, 1)
    page_size = Keyword.get(options, :page_size, 20)

    params = [
      platforms: platforms,
      page: page,
      page_size: page_size,
    ]

    params = if search_query, do: Keyword.put(params, :search, search_query), else: params

    RawgClient.get("/games", params)
  end

  def fetch_games_by_genre(genre_query, options \\ []) do
    platforms = Keyword.get(options, :platforms, RawgClient.default_platforms())
    page = Keyword.get(options, :page, 1)
    page_size = Keyword.get(options, :page_size, 20)

    params = [
      platforms: platforms,
      genre: genre_query,
      page: page,
      page_size: page_size,
    ]

    RawgClient.get("/games", params)
  end

  def fetch_genre_details(genre_query) do
    RawgClient.get("/genres/#{genre_query}")
  end

  def fetch_game_details(game_id) do
    RawgClient.get("/games/#{game_id}")
  end

  def fetch_game_screenshots(game_id) do
    RawgClient.get("/games/#{game_id}/screenshots")
  end

end

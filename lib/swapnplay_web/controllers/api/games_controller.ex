defmodule SwapnplayWeb.Api.GamesController do
  use SwapnplayWeb, :controller
  require Logger

  alias Swapnplay.Games

  def index(conn, params) do
    search = Map.get(params, "search")
    genres = Map.get(params, "genres")
    page = get_page(params)
    page_size = get_page_size(params)

    case Games.fetch_games(search: search, genres: genres, page: page, page_size: page_size) do
      {:ok, games} ->
        json(conn, games)

      {:error, reason} ->
        Logger.error("Failed to fetch games: #{reason}")

        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "Failed to fetch games", details: reason})
    end
  end

  def show(conn, %{"id" => id}) do
    case Games.fetch_game_details(id) do
      {:ok, games} ->
        json(conn, games)

      {:error, reason} ->
        Logger.error("Failed to fetch game details for ID #{id}: #{reason}")

        conn
        |> put_status(:not_found)
        |> json(%{error: "Failed to fetch game details", details: reason})
    end
  end

  def screenshots(conn, %{"games_id" => id}) do
    case Games.fetch_game_screenshots(id) do
      {:ok, screenshots} ->
        json(conn, screenshots)

      {:error, reason} ->
        Logger.error("Failed to fetch screenshots for game ID #{id}: #{reason}")

        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "Failed to fetch screenshots", details: reason})
    end
  end

  # Helper functions for pagination
  defp get_page(params) do
    params
    |> Map.get("page", "1")
    |> String.to_integer()
  rescue
    ArgumentError -> 1
  end

  defp get_page_size(params) do
    params
    |> Map.get("page_size", "20")
    |> String.to_integer()
    # Limit maximum page size to 100 to prevent abuse
    |> min(100)
    # Ensure minimum page size is 1
    |> max(1)
  rescue
    ArgumentError -> 20
  end
end

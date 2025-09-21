defmodule SwapnplayWeb.Api.GenresController do
  use SwapnplayWeb, :controller
  require Logger

  alias Swapnplay.Games

  def index(conn, _params) do
    case Games.fetch_genres() do
      {:ok, genres} ->
        json(conn, genres)

      {:error, reason} ->
        Logger.error("Failed to fetch genres: #{reason}")

        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "Failed to fetch genres", details: reason})
    end
  end

  def show(conn, %{"genre_query" => genre_query}) do
    case Games.fetch_genre_details(genre_query) do
      {:ok, genre} ->
        json(conn, genre)

      {:error, reason} ->
        Logger.error("Failed to fetch genre details for ID #{genre_query}: #{reason}")

        conn
        |> put_status(:not_found)
        |> json(%{error: "Genre not found", details: reason})
    end
  end
end

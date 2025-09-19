defmodule Swapnplay.RawgClient do
  @moduledoc """
  A client module for interacting with the RAWG Video Games Database API.
  """

  # Platform IDs
  @platform_ids "187,18,186,1,7" # PS5, PS4, Xbox Series X, Xbox One, Nintendo Switch

  def new do
    Req.new(
      base_url: "https://api.rawg.io/api/",
      params: [key: api_key()],
      retry: :transient,
      retry_delay: fn attempt -> 200 * attempt end,
      max_retries: 3
    )
  end

  def get(endpoint, params \\ %{}) do
    new()
    |> Req.get(url: endpoint, params: params)
    |> handle_response()
  end

  defp handle_response({:ok, %{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %{status: status, body: body}}) do
    error_message = get_in(body, ["error"]) || "HTTP Error #{status}"
    {:error, error_message}
  end

  defp handle_response({:error, %{reason: reason}}) do
    {:error, "Connection error: #{reason}"}
  end

  defp handle_response({:error, exception}) do
    {:error, "Request failed: #{Exception.message(exception)}"}
  end

  defp api_key do
    Application.get_env(:swapnplay, :rawg_api_key) ||
      raise "RAWG_API_KEY configuration is not set"
  end

  def default_platforms, do: @platform_ids

end

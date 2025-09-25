defmodule Swapnplay.CacheService do
  @moduledoc """
  Centralized cache service for RAWG API data with smart TTL strategies
  """

  require Logger

  # Cache TTL configurations
  @cache_ttls %{
    # Genre data - rarely changing data
    genres: :timer.hours(24 * 7),
    genre_details: :timer.hours(24 * 7),

    # Game data
    games_list: :timer.hours(24),
    games_by_genre: :timer.hours(24),

    # Search results - can change frequently
    games_search: :timer.minutes(60),

    # Game details
    game_details: :timer.hours(24 * 3),
    game_screenshots: :timer.hours(24 * 3)
  }

  @doc """
  Fetch data with caching.
  Will return cached data if available, otherwise fetch and cache.
  """
  def fetch_with_cache(cache_name, key, type, fetch_func) do
    case Cachex.get(cache_name, key) do
      {:ok, nil} ->
        # Cache miss - fetch data from API
        Logger.debug("Cache miss for #{type}: #{key}. Fetching from API...")
        fetch_and_cache(cache_name, key, type, fetch_func)

      {:ok, data} ->
        # Cache hit
        Logger.debug("Cache hit for #{type}: #{key}")
        {:ok, data}

      {:error, reason} ->
        # Cache error - log and fetch data from API
        Logger.error("Cache error for #{type}: #{key}. Reason: #{reason}")
        fetch_and_cache(cache_name, key, type, fetch_func)
    end
  end

  @doc """
  Fetch data and cache it with appropriate TTL
  """
  def fetch_and_cache(cache_name, key, type, fetch_func) do
    case fetch_func.() do
      {:ok, data} = result ->
        ttl = Map.get(@cache_ttls, type, :timer.minutes(30))

        case Cachex.put(cache_name, key, data, ttl: ttl) do
          {:ok, true} ->
            Logger.debug("Cached #{type}: #{key} with TTL #{ttl} ms")
            result

          {:error, reason} ->
            Logger.error("Failed to cache #{type}: #{key}. Reason: #{reason}")
            result
        end

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Invalidate cache for a specific key or pattern
  """
  def invalidate_cache(cache_name, key_or_pattern) do
    case Cachex.del(cache_name, key_or_pattern) do
      {:ok, count} ->
        Logger.debug(
          "Invalidated #{count} entries in cache #{cache_name} for key/pattern: #{key_or_pattern}"
        )

        {:ok, count}

      {:error, reason} ->
        Logger.error(
          "Failed to invalidate cache #{cache_name} for key/pattern: #{key_or_pattern}. Reason: #{reason}"
        )

        {:error, reason}
    end
  end

  @doc """
  Clear entire cache
  """
  def clear_cache(cache_name) do
    case Cachex.clear(cache_name) do
      {:ok, count} ->
        Logger.debug("Cleared entire cache #{cache_name}. Removed #{count} entries.")
        {:ok, count}

      {:error, reason} ->
        Logger.error("Failed to clear cache #{cache_name}. Reason: #{reason}")
        {:error, reason}
    end
  end

  @doc """
  Get cache statistics for monitoring
  """
  def get_cache_stats(cache_name) do
    case Cachex.stats(cache_name) do
      {:ok, stats} -> stats
      {:error, _reason} -> %{}
    end
  end

  @doc """
  Warm up cache
  """
  def warm_up_cache do
    Task.start(fn ->
      Logger.info("Starting cache warm-up...")

      # Warm up genres - it is accessed frequently
      case Swapnplay.RawgClient.get("/genres") do
        {:ok, genres} ->
          Cachex.put(:genres_cache, "all_genres", genres, ttl: @cache_ttls.genres)
          Logger.info("Warmed up genres cache")

        {:error, reason} ->
          Logger.warning("Failed to warm up genres cache. Reason: #{reason}")
      end

      Logger.info("Cache warm-up completed.")
    end)
  end

  # Helper function to generate cache keys
  def cache_key(base, params \\ %{})
  def cache_key(base, params) when params == %{}, do: base

  def cache_key(base, params) do
    param_string =
      params
      |> Enum.sort()
      |> Enum.map(fn {k, v} -> "#{k}:#{v}" end)
      |> Enum.join("|")

    "#{base}:#{param_string}"
  end
end

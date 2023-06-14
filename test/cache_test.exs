defmodule LogflareLogger.BatchCacheTest do
  @moduledoc false
  use ExUnit.Case
  alias LogflareLogger.BatchCache

  @backend_config %{
    api_client: LogflareApiClient.new(%{url: "http://localhost:4000", api_key: ""}),
    source_id: "source-id",
    batch_max_size: 10
  }

  test "cache puts events, gets events and resets batch" do
    ev1 = %{metadata: %{}, message: "log1"}
    ev2 = %{metadata: %{}, message: "log2"}
    ev3 = %{metadata: %{}, message: "log3"}

    assert BatchCache.put(ev1, @backend_config) === {:ok, :insert_successful}
    assert BatchCache.put(ev2, @backend_config) === {:ok, :insert_successful}

    BatchCache.clear()

    assert BatchCache.put(ev3, @backend_config) === {:ok, :insert_successful}
  end
end

defmodule Mix.Tasks.LogflareLogger.VerifyConfig do
  alias LogflareLogger.CLI
  use Mix.Task

  @app :logflare_logger_backend
  @default_api_url "https://api.logflare.app"

  @impl Mix.Task
  def run(_args \\ []) do
    IO.puts("You are verifying config for the #{Mix.env()} environment")
    {:ok, _} = Application.ensure_all_started(:logflare_logger_backend)

    api_key = get_env(:api_key) || System.get_env("LOGFLARE_API_KEY")
    source_id = get_env(:source_id) || System.get_env("LOGFLARE_SOURCE_ID")
    url = get_env(:url) || System.get_env("LOGFLARE_URL") || @default_api_url

    CLI.throw_on_missing_api_key!(api_key)
    CLI.throw_on_missing_source!(source_id)
    CLI.throw_on_missing_url!(url)

    client = LogflareApiClient.new(%{api_key: api_key, url: url})

    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601() |> Kernel.<>("Z")

    result =
      LogflareApiClient.post_logs(
        client,
        [
          %{
            "message" => "LogflareLogger has been properly setup",
            "metadata" => %{},
            "level" => "info",
            "timestamp" => timestamp
          }
        ],
        source_id
      )

    case result do
      {:ok, %{status: status}} when status in 200..299 ->
        IO.puts("Logflare API endpoint responded ok, check your dashboard!")

      {:ok, %{status: status, body: body}} ->
        IO.puts("HTTP request to Logflare API endpoint returned an HTTP status code #{status}.")
        IO.puts("Response body is: #{body}")

      {:error, tesla_env} ->
        IO.puts("Unknown Error")
        IO.inspect(tesla_env)
    end
  end

  def get_env(key) do
    Application.get_env(@app, key)
  end
end

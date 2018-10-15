defmodule Neuron do
  alias Neuron.{Response, Connection, Config, Fragment}

  @moduledoc """
  Neuron is a GraphQL client for elixir.

  ## Usage

  ```elixir
  iex> Neuron.Config.set(url: "https://example.com/graph")
  iex> Neuron.Config.set(headers: [hackney: [basic_auth: {"username", "password"}]])

  iex> Neuron.query(\"""
      {
        films {
          title
        }
      }
      \""")

  # Response will be:
  {:ok, %Neuron.Response{body: %{"data" => {"films" => [%{"title" => "A New Hope"}]}}%, status_code: 200, headers: []}}

  # You can also run mutations
  iex> Neuron.mutation("YourMutation()")

  """

  @doc """
  runs a query request to your graphql endpoint.

  ## Example

  ```elixir
  Neuron.query(\"""
    {
      films {
        title
      }
    }
  \""")
  ```

  You can also overwrite parameters set on `Neuron.Config` by passing them as options.

  ## Example

  ```elixir
  Neuron.query(
    \"""
    {
      films {
        title
      }
    }
    \""",
    url: "https://api.super.com/graph"
  )
  ```
  """

  @spec query(query_string :: String.t(), variables :: Map.t(), options :: keyword()) ::
          Neuron.Response.t()
  def query(query_string, variables \\ %{}, options \\ []) do
    query_string
    |> Fragment.insert_into_query()
    |> build_body(:query)
    |> insert_variables(variables)
    |> Poison.encode!()
    |> run(options)
  end

  @doc """
  runs a mutation request to your graphql endpoint

  ## Example

  ```elixir
  Neuron.mutation("YourMutation()")
  ```

  You can also overwrite parameters set on `Neuron.Config` by passing them as options.

  ## Example

  ```elixir
  Neuron.mutation("YourMutation()", url: "https://api.super.com/graph")
  ```
  """

  @spec mutation(query_string :: String.t(), variables :: Map.t(), options :: keyword()) ::
          Neuron.Response.t()
  def mutation(mutation_string, variables \\ %{}, options \\ []) do
    mutation_string
    |> Fragment.insert_into_query()
    |> build_body(:mutation)
    |> insert_variables(variables)
    |> Poison.encode!()
    |> run(options)
  end

  defp run(body, options) do
    body
    |> run_query(options)
    |> Response.handle()
  end

  defp run_query(body, options) do
    url = url(options)
    headers = build_headers(options)
    IO.inspect(body)
    Connection.post(url, body, headers)
  end

  defp build_body(query_string, operation_name) do
    %{
      operationName: operation_name,
      query: "#{operation_name} #{query_string}"
    }
  end

  defp insert_variables(body, variables) do
    Map.put(body, :variables, variables)
  end

  defp url(options) do
    Keyword.get(options, :url) || Config.get(:url)
  end

  defp build_headers(options) do
    Keyword.merge(["Content-Type": "application/json"], headers(options))
  end

  defp headers(options) do
    Keyword.get(options, :headers, Config.get(:headers) || [])
  end
end

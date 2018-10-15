defmodule NeuronTest do
  use ExUnit.Case

  alias Neuron.Connection

  import Mock

  setup do
    url = "www.example.com/graph"
    json_headers = ["Content-Type": "application/json"]
    Neuron.Config.set(nil)
    Neuron.Config.set(url: url)
    %{url: url, json_headers: json_headers}
  end

  describe "query/1" do
    test "calls the connection with correct url and query string", %{
      url: url,
      json_headers: json_headers
    } do
      with_mock Connection,
        post: fn _url, _body, _headers ->
          {:ok, %{body: ~s/{"data": {"users": []}}/, status_code: 200, headers: []}}
        end do
        Neuron.query("{ users { name } }")

        assert called(
                 Connection.post(
                   url,
                   "{\"variables\":{},\"query\":\"query { users { name } }\",\"operationName\":\"query\"}",
                   json_headers
                 )
               )
      end
    end
  end

  describe "query/2" do
    test "it takes all configs as arguments", %{json_headers: json_headers} do
      url = "www.example.com/another/graph"
      headers = ["X-test-header": 'my_header']

      with_mock Connection,
        post: fn _url, _body, _headers ->
          {:ok, %{body: ~s/{"data": {"users": []}}/, status_code: 200, headers: []}}
        end do
        Neuron.query("{ users { name } }", %{}, url: url, headers: headers)

        assert called(
                 Connection.post(
                   url,
                   "{\"variables\":{},\"query\":\"query { users { name } }\",\"operationName\":\"query\"}",
                   Keyword.merge(json_headers, headers)
                 )
               )
      end
    end
  end

  describe "mutation/1" do
    test "calls the connection with correct url and query string", %{
      url: url,
      json_headers: json_headers
    } do
      with_mock Connection,
        post: fn _url, _body, _headers ->
          {:ok,
           %{body: ~s/{"data": {"addUser": {"name": "unai"}}}/, status_code: 200, headers: []}}
        end do
        Neuron.mutation(~s/{ addUser(name: "unai") }/)

        assert called(
                 Connection.post(
                   url,
                   "{\"variables\":{},\"query\":\"mutation { addUser(name: \\\"unai\\\") }\",\"operationName\":\"mutation\"}",
                   json_headers
                 )
               )
      end
    end
  end

  describe "mutation/2" do
    test "it takes all configs as arguments", %{json_headers: json_headers} do
      url = "www.example.com/another/graph"
      headers = ["X-test-header": 'my_header']

      with_mock Connection,
        post: fn _url, _body, _headers ->
          {:ok, %{body: ~s/{"data": {"users": []}}/, status_code: 200, headers: []}}
        end do
        Neuron.mutation(~s/{ addUser(name: "unai") }/, %{}, url: url, headers: headers)

        assert called(
                 Connection.post(
                   url,
                   "{\"variables\":{},\"query\":\"mutation { addUser(name: \\\"unai\\\") }\",\"operationName\":\"mutation\"}",
                   Keyword.merge(json_headers, headers)
                 )
               )
      end
    end
  end
end

defmodule ConsulKv.Client do
  @moduledoc """
  The client for Consul KV store.

  There are several configuration options for the client:

    - consul_recv_timeout (default: 5000)
      the timeout for receive response from the server side

    - consul_connect_timeout (default: 5000)
      the timeout for connect consul server

    - consul_kv_address
      the address of consul KV store
  """

  use Tesla

  adapter Tesla.Adapter.Hackney,
    recv_timeout: Application.get_env(:consul_kv, :consul_recv_timeout, 5000),
    connect_timeout: Application.get_env(:consul_kv, :consul_connect_timeout, 5000)

  plug Tesla.Middleware.BaseUrl, Application.fetch_env!(:consul_kv, :consul_kv_address)
  plug Tesla.Middleware.JSON

  @doc """
  This interface updates the value of the specified key. If no key exists at the given path,
  the key will be created.

  The key should be a string, and value could be a string or any types which could be encode
  to json. The query parameters could be `Keyword`:

    - dc (default: "")
      Specifies the datacenter.

    - flags (default: 0)
      Specifies an unsigned value between 0 and (2^64)-1.

    - cas (default: 0)
      Specifies to use a `Check-And-Set` operation. If the index is 0, Consul will only put
      the key if it does not already exist. If the index is non-zero, the key is only set if
      the index matches the `ModifyIndex` of that key.

    - acquire (default: "")
      Supply a session ID to use in a lock acquisition operation. This is useful as it allows
      leader election to be built on top of Consul.

    - release (default: "")
      Supply a session ID to use in a release operation.

    - ns (default: "")
      Specifies the namespace to query.
  """
  @spec put_kv(String.t(), any(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def put_kv(key, value, query_params \\ []) do
    key
    |> put(value, query: query_params)
    |> case do
      {:ok, %{status: 200}} -> {:ok, true}
      {:ok, other_status} -> {:error, other_status}
      other -> other
    end
  end

  @doc """
  Return the specified key. If no key exists at the given path, a 404 is returned instead of
  a 200 response.

  The key should be a string, the query parameters could be `Keyword`:

    - dc (default: "")
      Specifies the datacenter.

    - recurse (default: false)
      Specifies to delete all keys which have the specified prefix.
      Without this, only a key with an extract match will be deleted.

    - raw (default: false)
      Specifies the response is just the raw value of the key, without any encoding or metadata.

    - keys (default: false)
      Specifies to return only keys (no values or metadata).

    - separator (default: "")
      Specifies the string to use as a separator for recursive key lookups.

    - ns (default: "")
      Specifies the namespace to query.
  """
  @spec get_kv(String.t(), Keyword.t()) :: {:ok, [ConsulKv.t()]} | {:error, any()}
  def get_kv(key, query_params \\ []) do
    key
    |> get(query: query_params)
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, parse_get_kv_body(body)}
      {:ok, %{status: 404}} -> {:error, :not_found}
      {:ok, other_status} -> {:error, other_status}
      other -> other
    end
  end

  @doc false
  defp parse_get_kv_body(body) do
    Enum.map(body, &parse_body/1)
  end

  @doc false
  defp parse_body(item) when is_map(item) do
    %ConsulKv{
      key: Map.get(item, "Key"),
      flags: Map.get(item, "Flags"),
      value: decode_value(Map.get(item, "Value")),
      lock_index: Map.get(item, "LockIndex"),
      session: Map.get(item, "Session"),
      create_index: Map.get(item, "CreateIndex"),
      modify_index: Map.get(item, "ModifyIndex")
    }
  end

  defp parse_body(item), do: item

  @doc false
  defp decode_value(nil), do: nil
  defp decode_value(value), do: Base.decode64!(value)

  @doc """
  Delete a single key or all keys sharing a prefix.

  The key should be a string, the query parameters could be `Keyword`:

    - dc (default: "")
      Specifies the datacenter.

    - recurse (default: false)
      Specifies to delete all keys which have the specified prefix.
      Without this, only a key with an extract match will be deleted.

    - cas (default: 0)
      Specifies to use a Check-And-Set operation

    - ns (default: "")
      Specifies the namespace to query.
  """
  @spec delete_kv(String.t(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def delete_kv(key, query_params \\ []) do
    key
    |> delete(query: query_params)
    |> case do
      {:ok, %{status: 200}} -> {:ok, true}
      {:ok, other_status} -> {:error, other_status}
      other -> other
    end
  end
end

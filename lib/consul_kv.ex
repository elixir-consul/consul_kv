defmodule ConsulKv do
  @moduledoc """
  Elixir SDK for Consul KV store.
  """

  @type path :: String.t()
  @type key :: String.t()
  @type value :: any
  @type flags :: non_neg_integer
  @type index :: non_neg_integer
  @type session :: String.t()
  @type options :: keyword

  @type t :: %__MODULE__{
          key: key,
          value: value,
          flags: flags,
          lock_index: index,
          create_index: index,
          modify_index: index,
          session: session
        }

  defstruct key: "",
            value: "",
            flags: 0,
            lock_index: 0,
            create_index: 0,
            modify_index: 0,
            session: ""

  @doc """
  Put kv pair.
  """
  @spec put(String.t(), any(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def put(key, value, options \\ []), do: ConsulKv.Client.put_kv(key, value, options)

  @doc """
  Put kv pair use Check-And-Set operation.
  """
  @spec cas_put(t(), any(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def cas_put(%__MODULE__{key: key, modify_index: modify_index}, new_value, options \\ []) do
    new_options = Keyword.merge(options, cas: modify_index)
    put(key, new_value, new_options)
  end

  @doc """
  Delete kv pair by given key.
  """
  @spec delete(String.t(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def delete(key, options \\ []), do: ConsulKv.Client.delete_kv(key, options)

  @doc """
  Delete kv pair by given key use Check-And-Set operation.
  """
  @spec cas_delete(t(), Keyword.t()) :: {:ok, true} | {:error, any}
  def cas_delete(%__MODULE__{key: key, modify_index: modify_index}, options \\ []) do
    new_options = Keyword.merge(options, cas: modify_index)
    delete(key, new_options)
  end

  @doc """
  Delete kv pair by given key recursively.
  """
  def recurse_delete(key, options \\ []) do
    new_options = Keyword.merge(options, recurse: true)
    delete(key, new_options)
  end

  @doc """
  Get kv pair by given key.
  """
  @spec get(String.t(), Keyword.t()) :: {:ok, [ConsulKv.t()]} | {:error, any()}
  def get(key, options \\ []), do: ConsulKv.Client.get_kv(key, options)

  @doc """
  Get kv pair by given key.
  """
  @spec single_get(String.t(), Keyword.t()) :: {:ok, ConsulKv.t()} | {:error, any()}
  def single_get(key, options \\ []) do
    new_options = Keyword.merge(options, recurse: false)

    case get(key, new_options) do
      {:ok, [kv]} -> {:ok, kv}
      {:ok, [_ | _]} -> {:error, "key has multi values"}
      {:error, _} = error -> error
    end
  end

  @doc """
  Get kv pair by given key recursively.
  """
  @spec recurse_get(String.t(), Keyword.t()) :: {:ok, [ConsulKv.t()]} | {:error, any()}
  def recurse_get(key, options \\ []) do
    new_options = Keyword.merge(options, recurse: true)
    get(key, new_options)
  end
end

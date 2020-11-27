defmodule ConsulKv do
  @moduledoc """
  Documentation for `ConsulKv`.
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

  """
  @spec put(String.t(), any(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def put(key, value, options \\ []), do: ConsulKv.Client.put_kv(key, value, options)

  @doc """

  """
  @spec cas_put(t(), any(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def cas_put(%__MODULE__{key: key, modify_index: modify_index}, new_value, options \\ []) do
    new_options = Keyword.merge(options, cas: modify_index)
    put(key, new_value, new_options)
  end

  @doc """

  """
  @spec delete(String.t(), Keyword.t()) :: {:ok, true} | {:error, any()}
  def delete(key, options \\ []), do: ConsulKv.Client.delete_kv(key, options)

  @doc """

  """
  @spec cas_delete(t(), Keyword.t()) :: {:ok, true} | {:error, any}
  def cas_delete(%__MODULE__{key: key, modify_index: modify_index}, options \\ []) do
    new_options = Keyword.merge(options, cas: modify_index)
    delete(key, new_options)
  end

  @doc """

  """
  @spec get(String.t(), Keyword.t()) :: {:ok, [ConsulKv.t()]} | {:error, any()}
  def get(key, options \\ []), do: ConsulKv.Client.get(key, options)

  @doc """

  """
  @spec single_get(String.t(), Keyword.t()) :: {:ok, ConsulKv.t()} | {:error, any()}
  def single_get(key, options \\ []) do
    new_options = Keyword.merge(options, recurse: false)

    case get(key, new_options) do
      {:ok, [kv]} -> {:ok, kv}
      {:error, _} = error -> error
    end
  end

  @doc """

  """
  @spec recurse_get(String.t(), Keyword.t()) :: {:ok, [ConsulKv.t()]} | {:error, any()}
  def recurse_get(key, options \\ []) do
    new_options = Keyword.merge(options, recurse: true)
    get(key, new_options)
  end
end
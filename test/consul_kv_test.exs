defmodule ConsulKvTest do
  use ExUnit.Case

  alias ConsulKv.Client

  @prefix "consul-kv-test/"

  test "put kv with acquire and release" do
    key = @prefix <> "acquire-test/master-node"

    Client.put_kv(key, "master-node-is-a", acquire: "adf4238a-882b-9ddc-4a9d-5b6758e4159a")
    |> IO.inspect()

    Client.get_kv(key) |> IO.inspect()

    Client.put_kv(key, "master-node-is-b", acquire: "adf4238a-882b-9ddc-4a9d-5b6758e4159b")
    |> IO.inspect()

    Client.get_kv(key) |> IO.inspect()
  end
end

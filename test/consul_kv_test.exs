defmodule ConsulKvTest do
  use ExUnit.Case

  @prefix "consul-kv-test-#{:erlang.system_info(:otp_release)}-#{System.version()}/"

  setup do
    assert {:ok, true} == ConsulKv.recurse_delete(@prefix)
    assert {:error, :not_found} == ConsulKv.recurse_get(@prefix)
    :ok
  end

  test "put and single get" do
    key = @prefix <> "single-put"
    assert {:ok, true} = ConsulKv.put(key, "single-value")
    assert {:ok, [%{key: ^key, value: "single-value"}]} = ConsulKv.get(key)
  end

  test "put then recurse_get, single_get and get keys" do
    key = @prefix <> "multi-put"

    key1 = @prefix <> "multi-put/k1"
    key2 = @prefix <> "multi-put/k2"
    key3 = @prefix <> "multi-put/k3"

    assert {:ok, true} = ConsulKv.put(key1, "v1")
    assert {:ok, true} = ConsulKv.put(key2, "v2")
    assert {:ok, true} = ConsulKv.put(key3, "v3")

    assert {:ok,
            [
              %{key: ^key1, value: "v1"},
              %{key: ^key2, value: "v2"},
              %{key: ^key3, value: "v3"}
            ]} = ConsulKv.recurse_get(key)

    assert {:error, "key has multi values"} == ConsulKv.single_get(key)
    assert {:ok, %{key: ^key1, value: "v1"}} = ConsulKv.single_get(key1)

    assert {:ok, ["#{@prefix}multi-put/k1", "#{@prefix}multi-put/k2", "#{@prefix}multi-put/k3"]} ==
             ConsulKv.get_keys(@prefix)

    assert {:ok, ["#{@prefix}multi-put/k1", "#{@prefix}multi-put/k2", "#{@prefix}multi-put/k3"]} ==
             ConsulKv.get_keys(key)
  end

  test "cas put" do
    key = @prefix <> "cas-put"

    # first put
    assert {:ok, true} == ConsulKv.put(key, "v1")
    {:ok, kv1} = ConsulKv.single_get(key)

    # second put
    assert {:ok, true} == ConsulKv.put(key, "v2")
    {:ok, kv2} = ConsulKv.single_get(key)

    # use old modify_index to cas put, failed
    assert {:ok, true} = ConsulKv.cas_put(kv1, "v1-1")
    assert {:ok, %{key: ^key, value: "v2"} = kv2_2} = ConsulKv.single_get(key)
    assert kv2_2 == kv2

    # use new modify_index to cas put, success
    assert {:ok, true} = ConsulKv.cas_put(kv2, "v2-2")
    assert {:ok, %{key: ^key, value: "v2-2"}} = ConsulKv.single_get(key)
  end

  test "cas delete" do
    key = @prefix <> "cas-delete"

    # first put
    assert {:ok, true} == ConsulKv.put(key, "v1")
    {:ok, kv1} = ConsulKv.single_get(key)

    # second put
    assert {:ok, true} == ConsulKv.put(key, "v2")
    {:ok, kv2} = ConsulKv.single_get(key)

    # cas delete, failed
    assert {:ok, true} == ConsulKv.cas_delete(kv1)
    assert {:ok, %ConsulKv{}} = ConsulKv.single_get(key)

    # cas delete, success
    assert {:ok, true} == ConsulKv.cas_delete(kv2)
    assert {:error, :not_found} = ConsulKv.single_get(key)
  end
end

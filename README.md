# ConsulKv

[![GitHub actions Status](https://github.com/elixir-consul/consul_kv/workflows/CI/badge.svg)](https://github.com/elixir-consul/consul_kv/actions)
[![Hex.pm Version](https://img.shields.io/hexpm/v/consul_kv.svg?style=flat-square)](https://hex.pm/packages/consul_kv)

Elixir SDK for [Consul KV store](https://www.consul.io/api/kv.html).

## Installation

The package could be installed as:

```elixir
def deps do
  [
    {:consul_kv, "~> 0.1.0"}
  ]
end
```

## Configuration

There are several configuration options for the client:

  - consul_recv_timeout (default: 5000)

    the timeout for receive response from the server side

  - consul_connect_timeout (default: 5000)

    the timeout for connect consul server

  - consul_kv_address (required)

    the address of consul KV store, for example: `"https://demo.consul.io/v1/kv"`

## Usage

### 1. setup correct configuration

### 2. put kv pair

```elixir
iex(1)> ConsulKv.put("consul-kv/k1", "v1")
{:ok, true}
```

### 3. get value

```elixir
iex(2)> ConsulKv.get("consul-kv/k1")
{:ok,
 [
   %ConsulKv{
     create_index: 45687,
     flags: 0,
     key: "consul-kv/k1",
     lock_index: 0,
     modify_index: 45687,
     session: nil,
     value: "v1"
   }
 ]}
```

or use single get

```elixir
iex(3)> ConsulKv.single_get("consul-kv/k1")
{:ok,
 %ConsulKv{
   create_index: 45687,
   flags: 0,
   key: "consul-kv/k1",
   lock_index: 0,
   modify_index: 45687,
   session: nil,
   value: "v1"
 }}
```

if you want put more than one keys share a prefix, like:

```elixir
iex(4)> ConsulKv.put("consul-kv/k2", "v2")
{:ok, true}
```

you can also use recurse get to fetch all kvs which sharing one prefix:

```elixir
iex(5)> ConsulKv.recurse_get("consul-kv")
{:ok,
 [
   %ConsulKv{
     create_index: 45687,
     flags: 0,
     key: "consul-kv/k1",
     lock_index: 0,
     modify_index: 45687,
     session: nil,
     value: "v1"
   },
   %ConsulKv{
     create_index: 45871,
     flags: 0,
     key: "consul-kv/k2",
     lock_index: 0,
     modify_index: 45871,
     session: nil,
     value: "v2"
   }
 ]}
```

get keys by a prefix

``` elixir
iex(6)> ConsulKv.get_keys("consul-kv")
{:ok, ["consul-kv/k1", "consul-kv/k2"]}
```


### 4. delete

delete one kv:

```elixir
iex(7)> ConsulKv.recurse_delete("consul-kv")
{:ok, true}
```

More information, you can check the function document. And more usage example, please check the unit test cases.

## Contributions

Any contributions are welcomed, documentation especially.

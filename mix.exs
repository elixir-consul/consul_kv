defmodule ConsulKv.MixProject do
  use Mix.Project

  def project do
    [
      app: :consul_kv,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_options: [warnings_as_errors: true],
      package: [
        name: "consul_kv",
        maintainers: ["redink"],
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/elixir-consul/consul_kv"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.16"},
      {:jason, ">= 1.0.0"},
      {:ex_doc, "~> 0.23", only: [:dev, :test]}
    ]
  end
end

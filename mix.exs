defmodule X3m.Rabbit.MixProject do
  use Mix.Project

  def project do
    [
      app: :x3m_rabbit,
      version: "0.1.2",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/x3m-ex/rabbit",
      description: """
      Wrapper for RabbitMQ
      """,
      package: _package(),
      deps: _deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp _deps do
    [
      {:amqp, "~> 1.2"},

      # documentation
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp _package do
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["Milan Burmaja"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/x3m-ex/rabbit"}
    ]
  end
end

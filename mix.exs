defmodule X3m.Rabbit.MixProject do
  use Mix.Project

  def project do
    [
      app: :x3m_rabbit,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
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
      {:amqp, "~> 1.1"}
    ]
  end
end

defmodule ExGherkin.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_gherkin,
      version: "0.1.0",
      elixir: "~> 1.9",
      config_path: "config/config.exs",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mix_test_watch, :ex_unit_notifier]
    ]
  end

  defp deps do
    [
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end

defmodule ExGherkin.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :ex_gherkin,
      version: "0.1.0",
      elixir: "~> 1.9",
      config_path: "config/config.exs",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [
      extra_applications: [:logger] ++ extra(Mix.env())
    ]
  end

  def extra(:test), do: [:ex_unit_notifier, :mix_test_watch]
  def extra(_), do: []
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jiffy, "~> 1.0"},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false}
    ]
  end
end

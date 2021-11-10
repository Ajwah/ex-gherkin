defmodule ExGherkin.MixProject do
  @moduledoc false
  use Mix.Project

  @vsn "0.1.2"
  @github "https://github.com/Ajwah/ex-gherkin"
  @name "MyExGherkin"

  def project do
    [
      app: :my_ex_gherkin,
      version: @vsn,
      description: "Parse Gherkin Syntax",
      package: %{
        licenses: ["Apache-2.0"],
        source_url: @github,
        links: %{"GitHub" => @github}
      },
      docs: [
        main: @name,
        extras: ["README.md"]
      ],
      aliases: [docs: &build_docs/1],
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
  defp elixirc_paths(_), do: ["lib", "test/support"]

  defp deps do
    [
      {:jiffy, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false}
    ]
  end

  defp build_docs(_) do
    Mix.Task.run("compile")
    ex_doc = Path.join(Mix.path_for(:escripts), "ex_doc")

    unless File.exists?(ex_doc) do
      raise "cannot build docs because escript for ex_doc is not installed"
    end

    args = [@name, @vsn, Mix.Project.compile_path()]
    opts = ~w[--main #{@name} --source-ref v#{@vsn} --source-url #{@github}]
    System.cmd(ex_doc, args ++ opts)
    Mix.shell().info("Docs built successfully")
  end
end

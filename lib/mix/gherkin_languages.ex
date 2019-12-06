defmodule Mix.Tasks.GherkinLanguages do
  @moduledoc """
  Parse json
  """
  use Mix.Task
  alias Gherkin.Scanner.LanguageSupport
  @shortdoc "Converts `gherkin-languages.json` to pallatable format"
  def run(["--no-save"]) do
    LanguageSupport.parse()
    |> IO.inspect(limit: :infinity)
  end

  def run(_) do
    LanguageSupport.unload()
  end
end

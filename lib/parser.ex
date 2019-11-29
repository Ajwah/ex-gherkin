defmodule Gherkin.Parser do
  @moduledoc false

  def run(tokens) when is_list(tokens) do
    tokens
    |> :parser.parse()
  end
end

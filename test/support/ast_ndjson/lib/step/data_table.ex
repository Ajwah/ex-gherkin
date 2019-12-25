defmodule ExGherkin.AstNdjson.Step.DataTable do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L139-L143
    location
    rows
  """
  @derive Jason.Encoder
  alias ExGherkin.AstNdjson.Location

  defstruct location: Location.new(),
            rows: []

  def new(rows, location = %Location{}) do
    struct(__MODULE__, %{
      location: location,
      rows: rows
    })
  end
end

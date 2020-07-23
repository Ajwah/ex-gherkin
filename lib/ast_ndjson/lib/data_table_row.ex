defmodule ExGherkin.AstNdjson.DataTable.Row do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L72-L77

    location
    cells
    id
  """

  @derive Jason.Encoder

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct location: Location.new(),
            cells: [],
            id: "0"

  def new(cells, location, id \\ "0")

  def new(cells, location = %Location{}, id) do
    struct(__MODULE__, %{
      location: location,
      cells: Util.normalize(cells),
      id: id
    })
  end
end

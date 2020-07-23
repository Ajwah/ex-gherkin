defmodule ExGherkin.AstNdjson.DataTable.Body do
  @moduledoc false

  @derive Jason.Encoder

  alias ExGherkin.AstNdjson.Location

  defstruct location: Location.new(),
            cells: [],
            id: "0"

  def new(location, cells, id \\ 0) do
    struct(__MODULE__, %{
      location: location,
      cells: cells,
      id: id
    })
  end
end

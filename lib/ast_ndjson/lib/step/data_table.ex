defmodule ExGherkin.AstNdjson.Step.DataTable do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L139-L143
    location
    rows
  """
  @derive Jason.Encoder
  alias ExGherkin.AstNdjson.Location
  alias ExGherkin.AstNdjson.DataTable.Row.Cell, as: RowCell

  defstruct location: Location.new(),
            rows: []

  def new(rows, location = %Location{}) do
    struct(__MODULE__, %{
      location: location,
      rows: rows
    })
  end

  def to_map(nil, _), do: false
  def to_map(%__MODULE__{} = m, examples) do
    [header | values] = m.rows
    header = header.cells |> Enum.map(&(&1.value))
    values
    |> Enum.map(fn row ->
      rows = row.cells
        |> Enum.map(fn %RowCell{} = cell ->
          if cell.parsed_sentence do
            cell.parsed_sentence.vars
            |> Enum.reduce(cell.parsed_sentence.template, fn
              var, template -> example = Map.fetch!(examples, var)
                String.replace(template, "%", "#{example}", global: false)
            end)
          else
            cell.value
          end
        end)

      header
      |> Enum.zip(rows)
      |> Enum.into(%{})
    end)
  end
end

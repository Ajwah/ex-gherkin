defmodule ExGherkin.AstNdjson.Examples do
  @moduledoc """
  Based on https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L182-L191

    name
    description
    location
    keyword
    table_header
    table_body
    tags


  """

  @derive {Jason.Encoder, except: [:token, :parsed_sentence]}

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct name: "",
            description: "",
            location: Location.new(),
            keyword: "",
            tableHeader: %{},
            tableBody: %{},
            tags: [],
            id: "",
            parsed_sentence: %{}

  def new(name, description, keyword, tags, location = %Location{}, data_table_rows, id \\ "0") do
    {header_section, body_section} = split_data_table_rows(data_table_rows)

    struct(__MODULE__, %{
      name: Util.normalize(name),
      description: Util.normalize(description),
      keyword: Util.normalize(keyword),
      location: location,
      tags: Util.normalize(tags),
      tableHeader: Util.normalize(header_section),
      tableBody: Util.normalize(body_section),
      id: id,
      parsed_sentence: Util.parse_sentence(name)
    })
  end

  def split_data_table_rows([]), do: {nil, nil}
  def split_data_table_rows([header]), do: {header, nil}
  def split_data_table_rows([header | body]), do: {header, body}

  def table_to_tagged_map(nil), do: false

  def table_to_tagged_map(%__MODULE__{} = m) do
    header = m.tableHeader.cells |> Enum.map(& &1.value)

    map =
      m.tableBody
      |> Enum.map(fn row ->
        header
        |> Enum.zip(row.cells |> Enum.map(& &1.value))
        |> Enum.into(%{})
      end)

    {m.tags, map}
  end
end

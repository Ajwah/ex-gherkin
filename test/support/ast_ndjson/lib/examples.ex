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

  @derive Jason.Encoder

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
            tags: []

  def new(name, description, keyword, tags, location = %Location{}, data_table_rows) do
    {header_section, body_section} = split_data_table_rows(data_table_rows)

    struct(__MODULE__, %{
      name: Util.normalize(name),
      description: Util.normalize(description),
      keyword: Util.normalize(keyword),
      location: location,
      tags: Util.normalize(tags),
      tableHeader: Util.normalize(header_section),
      tableBody: Util.normalize(body_section)
    })
  end

  def split_data_table_rows([]), do: {nil, nil}
  def split_data_table_rows([header]), do: {header, nil}
  def split_data_table_rows([header | body]), do: {header, body}
end

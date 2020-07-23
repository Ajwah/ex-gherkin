defmodule ExGherkin.AstNdjson.Step do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L117-L124

    text
    keyword
    location
    id
    data_table
    doc_string
  """

  @derive {Jason.Encoder, except: [:token, :parsed_sentence]}

  alias ExGherkin.AstNdjson.{
    DocString,
    Location,
    Util
  }

  alias __MODULE__.DataTable

  defstruct text: "",
            keyword: "",
            location: Location.new(),
            id: "0",
            dataTable: nil,
            docString: nil,
            token: nil,
            parsed_sentence: %{}

  def new(text, keyword, location = %Location{}, token, id \\ "0") do
    struct(__MODULE__, %{
      text: Util.normalize(text),
      keyword: Util.normalize(keyword),
      location: location,
      id: id,
      token: token,
      parsed_sentence: Util.parse_sentence(text),
    })
  end

  def arg(m = %__MODULE__{}, :none), do: m
  def arg(m = %__MODULE__{}, doc_string = %DocString{}), do: %{m | docString: doc_string}

  def arg(m = %__MODULE__{}, data_table_rows = []),
    do: %{m | dataTable: DataTable.new(data_table_rows, Location.new())}

  def arg(m = %__MODULE__{}, data_table_rows = [data_table_row | _]) do
    %{m | dataTable: DataTable.new(data_table_rows, data_table_row.location)}
  end
end

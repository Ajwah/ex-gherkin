defmodule ExGherkin.AstNdjson.DataTable.Row.Cell do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L95-L99

    location
    value
  """

  @derive {Jason.Encoder, except: [:token, :parsed_sentence]}

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct location: Location.new(),
            value: "",
            parsed_sentence: %{}

  def new(value, location = %Location{}) do
    struct(__MODULE__, %{
      location: location,
      value: Util.normalize(value),
      parsed_sentence: Util.parse_sentence(value)
    })
  end
end

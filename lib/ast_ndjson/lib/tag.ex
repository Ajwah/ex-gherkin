defmodule ExGherkin.AstNdjson.Tag do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L59-L64

    location
    name
    id
  """

  @derive {Jason.Encoder, except: [:parsed_sentence]}

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct location: Location.new(),
            name: "",
            id: "0",
            parsed_sentence: %{}

  def new(name, location = %Location{}, id \\ "0") do
    struct(__MODULE__, %{
      location: location,
      name: Util.normalize(name),
      id: id,
      parsed_sentence: Util.parse_sentence(name),
    })
  end
end

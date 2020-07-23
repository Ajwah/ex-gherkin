defmodule ExGherkin.AstNdjson.Comment do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L27-L31

    location
    text
  """

  @derive Jason.Encoder

  alias ExGherkin.AstNdjson.Location

  defstruct location: Location.new(),
            text: ""

  def new(text, location = %Location{}) do
    struct(__MODULE__, %{
      location: Location.column(location, 1),
      text: String.duplicate(" ", location.column - 1) <> "#" <> text
    })
  end
end

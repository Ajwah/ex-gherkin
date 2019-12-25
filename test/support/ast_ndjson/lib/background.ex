defmodule ExGherkin.AstNdjson.Background do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L148-L154

    name
    description
    location
    keyword
    steps
  """

  @derive Jason.Encoder

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct name: "",
            description: "",
            keyword: "",
            location: Location.new(),
            steps: []

  def new(name, description, keyword, location = %Location{}, steps) do
    %{
      background:
        struct(__MODULE__, %{
          name: Util.normalize(name),
          description: Util.normalize(description),
          keyword: Util.normalize(keyword),
          location: location,
          steps: Util.normalize(steps)
        })
    }
  end
end

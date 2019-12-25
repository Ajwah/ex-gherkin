defmodule ExGherkin.AstNdjson.Scenario do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L162-L172

    name
    description
    location
    keyword
    id
    tags
    steps
    examples
  """

  @derive Jason.Encoder

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct name: "",
            description: "",
            location: Location.new(),
            keyword: %{},
            id: "",
            tags: [],
            steps: [],
            examples: []

  def new(name, description, keyword, location = %Location{}, tags, steps, examples, id \\ "0") do
    %{
      scenario:
        struct(__MODULE__, %{
          name: Util.normalize(name),
          description: Util.normalize(description),
          keyword: Util.normalize(keyword),
          location: location,
          tags: Util.normalize(tags),
          steps: Util.normalize(steps),
          examples: Util.normalize(examples),
          id: id
        })
    }
  end
end

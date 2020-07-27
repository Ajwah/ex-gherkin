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

  @derive {Jason.Encoder, except: [:token, :parsed_sentence]}

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
            examples: [],
            token: nil,
            parsed_sentence: %{}

  def new(
        name,
        description,
        keyword,
        location = %Location{},
        tags,
        steps,
        examples,
        token,
        id \\ "0"
      ) do
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
          id: id,
          token: token,
          parsed_sentence: Util.parse_sentence(name)
        })
    }
  end
end

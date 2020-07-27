defmodule ExGherkin.AstNdjson.Rule do
  @moduledoc """
  Based on https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L239-L245
    location
    keyword
    name
    description
    children
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
            children: [],
            token: nil,
            id: "",
            parsed_sentence: %{}

  def new(name, description, keyword, location = %Location{}, token, id \\ "0") do
    %{
      rule:
        struct(__MODULE__, %{
          name: Util.normalize(name),
          description: Util.normalize(description),
          keyword: Util.normalize(keyword),
          location: location,
          token: token,
          id: id,
          parsed_sentence: Util.parse_sentence(name)
        })
    }
  end

  def add_child(%{rule: m = %__MODULE__{}}, :empty), do: %{rule: m}
  def add_child(%{rule: m = %__MODULE__{}}, []), do: %{rule: m}
  def add_child(%{rule: m = %__MODULE__{}}, nil), do: %{rule: m}

  def add_child(%{rule: m = %__MODULE__{}}, child),
    do: %{rule: %{m | children: m.children ++ child}}

  def normalize(%{rule: m = %__MODULE__{}}),
    do: %{rule: %{m | children: Util.normalize(m.children)}}
end

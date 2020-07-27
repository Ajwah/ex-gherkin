defmodule ExGherkin.AstNdjson.Feature do
  @moduledoc """
  Based on https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L182-L191
    name
    description
    language
    location
    keyword
    tags
    children
  """

  @derive {Jason.Encoder, except: [:token, :parsed_sentence]}

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct name: "",
            description: "",
            language: "",
            location: Location.new(),
            keyword: "",
            tags: [],
            children: [],
            token: nil,
            parsed_sentence: %{}

  def new(name, description, keyword, language, tags, location = %Location{}, token) do
    struct(__MODULE__, %{
      name: Util.normalize(name),
      description: Util.normalize(description),
      keyword: Util.normalize(keyword),
      language: Util.normalize(language),
      tags: Util.normalize(tags),
      location: location,
      token: token,
      parsed_sentence: Util.parse_sentence(name)
    })
  end

  def add_child(m = %__MODULE__{}, :empty), do: m
  def add_child(m = %__MODULE__{}, []), do: m
  def add_child(m = %__MODULE__{}, nil), do: m
  def add_child(m = %__MODULE__{}, child), do: %{m | children: m.children ++ child}

  def normalize(m = %__MODULE__{}), do: %{m | children: Util.normalize(m.children)}
end

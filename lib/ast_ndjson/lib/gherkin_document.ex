defmodule ExGherkin.AstNdjson.GherkinDocument do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L246-L253

    comments
    feature
  """

  @derive Jason.Encoder

  defstruct comments: [],
            feature: %{},
            uri: ""

  alias ExGherkin.AstNdjson.{
    Util
  }

  def new(uri, feature, comments) do
    struct(__MODULE__, %{
      uri: uri,
      feature: Util.normalize(feature),
      comments: Util.normalize(comments)
    })
  end
end

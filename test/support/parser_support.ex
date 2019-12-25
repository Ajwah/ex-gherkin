defmodule ParserSupport do
  @moduledoc false
  alias ExGherkin.AstNdjson
  alias ExGherkin.AstNdjson.GherkinDocument

  def to_ast_standard({comments, feature}, uri) do
    # |> IO.inspect(label: :comments)
    comments = AstNdjson.run(comments)
    # |> IO.inspect(label: :feature)
    feature = AstNdjson.run(feature)

    %{
      gherkinDocument: GherkinDocument.new(uri, feature, comments)
    }
  end
end

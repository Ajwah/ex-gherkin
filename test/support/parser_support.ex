defmodule ParserSupport do
  @moduledoc false
  alias ExGherkin.AstNdjson
  alias ExGherkin.AstNdjson.GherkinDocument

  def to_ast_standard({comments, feature}, uri) do
    # comments |> IO.inspect(label: :comments)
    # feature |> IO.inspect(label: :feature)
    comments = AstNdjson.run(comments)
    feature = AstNdjson.run(feature)

    %{
      gherkinDocument: GherkinDocument.new(uri, feature, comments)
    }
  end
end

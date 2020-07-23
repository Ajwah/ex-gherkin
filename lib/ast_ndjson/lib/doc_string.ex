defmodule ExGherkin.AstNdjson.DocString do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L131-L137
    location
    content
    delimiter
    media_type
  """

  @derive Jason.Encoder

  alias ExGherkin.AstNdjson.{
    Location,
    Util
  }

  defstruct location: Location.new(),
            content: "",
            mediaType: "",
            delimiter: ""

  def new(content, media_type, delimiter, location = %Location{}) do
    struct(__MODULE__, %{
      location: location,
      content: Util.normalize(content),
      mediaType: Util.normalize(media_type),
      delimiter: Util.normalize(delimiter)
    })
  end
end

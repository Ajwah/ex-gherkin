defmodule ExGherkin do
  @moduledoc """
  Library to parse Gherkin files.
  Kindly consult README for more details
  """

  defstruct [
    :feature_file,
    :content,
    opts: %{}
  ]

  alias __MODULE__.{
    Parser,
    Scanner,
    Utils
  }

  alias __MODULE__.Parser.SyntaxError, as: ParserSyntaxError

  defdelegate tokenize(arg), to: Scanner
  defdelegate parse(arg), to: Parser, as: :run

  def prepare(path: path) do
    struct(__MODULE__, %{
      feature_file: path,
      content: File.stream!(path)
    })
  end

  def prepare(content) do
    struct(__MODULE__, %{
      feature_file: :none,
      content: String.split(content, "\n", trim: true)
    })
  end

  def run(details = %__MODULE__{}) do
    details.content
    |> tokenize
    |> Enum.to_list()
    |> Utils.introspect(:tokenizer)
    |> parse
    |> Utils.introspect(:parser)
    |> case do
      {:error, error} -> ParserSyntaxError.raise({details.feature_file, error})
      {:ok, other} -> other
    end
  end
end

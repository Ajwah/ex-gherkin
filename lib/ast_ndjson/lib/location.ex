defmodule ExGherkin.AstNdjson.Location do
  @moduledoc """
  Based on: https://github.com/cucumber/cucumber/blob/f15a9ec416a54da806f9f6aad9c393b9a753cbf0/gherkin/ruby/lib/gherkin/ast_builder.rb#L46-L50

    line
    column
  """

  @derive Jason.Encoder

  defstruct line: 0,
            column: 0

  def new(:none), do: new({:none, :none})

  def new({line, column}) do
    struct(__MODULE__, %{
      line: line,
      column: column
    })
  end

  def new, do: new({0, 0})
  def column(m = %__MODULE__{}, c), do: %{m | column: c}
end

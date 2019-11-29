defmodule Gherkin.Scanner.Token do
  @moduledoc """
  A token combines following three identifiers:
    * Label
    * Starting Coordinate
    * Text
  """

  import Record
  alias Gherkin.Scanner.Location
  import Location

  defrecord(:token, label: :feature, cord: location(line: 1, column: 1), text: "")

  @type t() :: record(:token, label: atom, cord: Coordinate.t, text: String.t)

  def feature(line, column, text) do
    token(label: :feature, cord: location(line: line, column: column), text: text)
  end

  def rule(line, column, text) do
    token(label: :rule, cord: location(line: line, column: column), text: text)
  end

  def scenario(line, column, text) do
    token(label: :scenario, cord: location(line: line, column: column), text: text)
  end

  def given(line, column, text) do
    token(label: :given, cord: location(line: line, column: column), text: text)
  end

  def _when(line, column, text) do
    token(label: :when, cord: location(line: line, column: column), text: text)
  end

  def then(line, column, text) do
    token(label: :then, cord: location(line: line, column: column), text: text)
  end

  def but(line, column, text) do
    token(label: :but, cord: location(line: line, column: column), text: text)
  end

  def _and(line, column, text) do
    token(label: :and, cord: location(line: line, column: column), text: text)
  end

  def background(line, column, text) do
    token(label: :background, cord: location(line: line, column: column), text: text)
  end

  def scenario_outline(line, column, text) do
    token(label: :scenario_outline, cord: location(line: line, column: column), text: text)
  end

  def scenarios(line, column, text) do
    token(label: :scenarios, cord: location(line: line, column: column), text: text)
  end

  def doc_string(line, column, text) do
    token(label: :doc_string, cord: location(line: line, column: column), text: text)
  end

  def data_table(line, column, text) do
    token(label: :data_table, cord: location(line: line, column: column), text: text)
  end

  def tag(line, column, text) do
    token(label: :tag, cord: location(line: line, column: column), text: text)
  end

  def comment(line, column, text) do
    token(label: :comment, cord: location(line: line, column: column), text: text)
  end

  def content(line, column, text) do
    token(label: :string, cord: location(line: line, column: column), text: text)
  end

  def empty(line, column) do
    token(label: :empty, cord: location(line: line, column: column), text: "")
  end
end

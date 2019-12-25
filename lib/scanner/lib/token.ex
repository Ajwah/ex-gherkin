defmodule ExGherkin.Scanner.Token do
  @moduledoc """
  A token combines following three identifiers:
    * Label
    * Starting Coordinate
    * Text
  """

  alias ExGherkin.Scanner.Location
  import Location
  import Record

  defrecord(:token,
    label: :feature,
    label_text: "Feature:",
    cord: location(line: 1, column: 1),
    text: "Some Text"
  )

  @type t() ::
          record(:token,
            label: atom,
            label_text: String.t(),
            cord: Coordinate.t(),
            text: String.t()
          )

  def strip_record_name({:token, label, label_text, cord, text}),
    do: {label, label_text, cord, text}

  def column(t = {:token, _, _, _, _}), do: location(token(t, :cord), :column)

  def feature(line, column, label_text, text) do
    token(
      label: :feature,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: String.trim_leading(text)
    )
  end

  def rule(line, column, label_text, text) do
    token(
      label: :rule,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: String.trim_leading(text)
    )
  end

  def scenario(line, column, label_text, text) do
    token(
      label: :scenario,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: String.trim_leading(text)
    )
  end

  def given(line, column, label_text, text) do
    token(
      label: :given,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def _when(line, column, label_text, text) do
    token(
      label: :when,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def then(line, column, label_text, text) do
    token(
      label: :then,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def but(line, column, label_text, text) do
    token(
      label: :but,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def _and(line, column, label_text, text) do
    token(
      label: :and,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def background(line, column, label_text, text) do
    token(
      label: :background,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def scenario_outline(line, column, label_text, text) do
    token(
      label: :scenario_outline,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: String.trim_leading(text)
    )
  end

  def scenarios(line, column, label_text, text) do
    token(
      label: :scenarios,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def doc_string(line, column, label_text, text) do
    token(
      label: :doc_string,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def data_table(line, column, label_text, text) do
    token(
      label: :data_table,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def tag(line, column, label_text, text) do
    token(
      label: :tag,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def language(line, column, label_text, text) do
    token(
      label: :language,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def comment(line, column, label_text, text) do
    token(
      label: :comment,
      label_text: label_text,
      cord: location(line: line, column: column),
      text: text
    )
  end

  def content(line, column, text) do
    token(
      label: :content,
      label_text: "",
      cord: location(line: line, column: column),
      text: text
    )
  end

  def empty(line, column) do
    token(label: :empty, label_text: "", cord: location(line: line, column: column), text: "")
  end
end

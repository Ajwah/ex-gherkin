defmodule Gherkin.Scanner.Context do
  @moduledoc false
  defstruct doc_string: false, stack: [], language: "en", original_line: ""

  def new, do: %__MODULE__{}
  def reset(%__MODULE__{}, :doc_string), do: new()

  def new(doc_string) do
    struct(
      __MODULE__,
      doc_string: doc_string
    )
  end

  def doc_string(c = %__MODULE__{}, trim_length, past_delimiter),
    do: %{c | doc_string: {trim_length, past_delimiter}}

  def push(c = %__MODULE__{}, token),
    do: %{c | stack: [token | c.stack]}

  def pop(c = %__MODULE__{stack: []}),
    do: c

  def pop(c = %__MODULE__{stack: [_ | tl]}),
    do: %{c | stack: tl}

  def peek(%__MODULE__{stack: []}),
    do: :empty

  def peek(%__MODULE__{stack: [hd | _]}),
    do: hd

  def language(c = %__MODULE__{}, language), do: %{c | language: language}
  def original_line(c = %__MODULE__{}, original_line), do: %{c | original_line: original_line}
end

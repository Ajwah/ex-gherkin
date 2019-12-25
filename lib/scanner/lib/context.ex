defmodule ExGherkin.Scanner.Context do
  @moduledoc false
  defstruct doc_string: false, stack: [], language: "en", original_line: "", stepline: false

  def new, do: %__MODULE__{}
  def reset(m = %__MODULE__{}, :doc_string), do: %{m | doc_string: false}
  def reset(m = %__MODULE__{}, :stepline), do: %{m | stepline: false}

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
  def stepline(c = %__MODULE__{}), do: %{c | stepline: true}
end

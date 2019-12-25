defmodule ExGherkin.Scanner.SyntaxError do
  @moduledoc false
  defexception [:message, :line_number, :violation_code]

  @impl true
  def exception({msg, line_number, column_number, violation_code}) do
    struct(__MODULE__, %{
      message: msg,
      line_number: line_number,
      column_number: column_number,
      violation_code: violation_code
    })
  end

  def raise(msg, line_number, column_number, violation_code) do
    raise __MODULE__, {msg, line_number, column_number, violation_code}
  end
end

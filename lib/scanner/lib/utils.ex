defmodule Gherkin.Scanner.Utils do
  @moduledoc false

  def trim_line(line, %_{doc_string: false}) do
    {line, column_count} = trim_leading_white_spaces(line, 1)
    {String.trim_trailing(line), column_count}
  end

  def trim_line(line, %_{doc_string: {1, _}}), do: {String.trim_trailing(line, "\n"), 1}

  def trim_line(line, %_{doc_string: {trim_length, _}}) do
    trimmed_line =
      if String.length(line) >= trim_length do
        <<leading_chars::binary-size(trim_length), rest::binary>> = line

        if String.trim(leading_chars) == "" do
          rest
        else
          String.trim_leading(line)
        end
      else
        String.trim_leading(line)
      end
      |> String.trim_trailing("\n")

    {trimmed_line, trim_length}
  end

  defp trim_leading_white_spaces(<<" ", rest::binary>>, column_count) do
    trim_leading_white_spaces(rest, column_count + 1)
  end

  defp trim_leading_white_spaces(<<"\n", rest::binary>>, column_count) do
    trim_leading_white_spaces(rest, column_count + 1)
  end

  defp trim_leading_white_spaces(line, column_count) do
    {line, column_count}
  end
end

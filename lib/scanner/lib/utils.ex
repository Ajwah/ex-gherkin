defmodule Gherkin.Scanner.Utils do
  @moduledoc false

  def trim_line(line, %{doc_string: false}) do
    {line, column_count} = trim_leading_white_spaces(line, 1)
    {String.trim_trailing(line), column_count}
  end

  def trim_line(line, %{doc_string: {1, _}}), do: {String.trim_trailing(line, "\n"), 1}

  def trim_line(line, %{doc_string: {trim_length, _}}) do
    trim_length = trim_length - 1

    trimmed_line =
      line
      |> trim_fixed_number_leading_white_spaces(trim_length)
      |> case do
        {trimmed_line, :wrongly_indented_line_within_doc_string} ->
          IO.warn("Wrongly indented line within `DocString`: #{line}")
          trimmed_line

        {trimmed_line, _} ->
          trimmed_line
      end
      |> String.trim_trailing("\n")

    {trimmed_line, trim_length + 1}
  end

  defp trim_leading_white_spaces(<<" ", rest::binary>>, column_count) do
    trim_leading_white_spaces(rest, column_count + 1)
  end

  defp trim_leading_white_spaces(<<"\n", rest::binary>>, column_count) do
    trim_leading_white_spaces(rest, column_count)
  end

  defp trim_leading_white_spaces(line, column_count) do
    {line, column_count}
  end

  defp trim_fixed_number_leading_white_spaces(remainder, 0) do
    {remainder, 0}
  end

  defp trim_fixed_number_leading_white_spaces(<<" ", rest::binary>>, remaining_char_count) do
    trim_fixed_number_leading_white_spaces(rest, remaining_char_count - 1)
  end

  defp trim_fixed_number_leading_white_spaces(<<"\n">>, remaining_char_count) do
    remaining_char_count =
      if remaining_char_count == 0 do
        0
      else
        :wrongly_indented_line_within_doc_string
      end

    {"", remaining_char_count}
  end

  defp trim_fixed_number_leading_white_spaces(remainder, _) do
    {remainder, :wrongly_indented_line_within_doc_string}
  end
end

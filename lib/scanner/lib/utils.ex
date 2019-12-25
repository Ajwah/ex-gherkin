defmodule ExGherkin.Scanner.Utils do
  @moduledoc false

  def data_table_pipe_splitter(line, offset_count \\ 0)

  def data_table_pipe_splitter(line, offset_count) when is_integer(offset_count) do
    data_table_pipe_splitter(line, {true, false, offset_count, offset_count, "", []})
  end

  def data_table_pipe_splitter("", {_, _, prev_count, _, cell, cells}) do
    if cell == "" do
      cells ++ [{prev_count + 1, cell}]
    else
      cells ++ [{prev_count, cell}]
    end
  end

  def data_table_pipe_splitter(
        <<"|", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {true, false, count + 1, count + 1, "", cells ++ [{prev_count + 1, cell}]}
      )
    else
      data_table_pipe_splitter(
        rest,
        {true, false, count + 1, count + 1, "", cells ++ [{prev_count, cell}]}
      )
    end
  end

  def data_table_pipe_splitter(
        <<"\\\\", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {false, false, prev_count + 1, count + 2, cell <> "\\", cells}
      )
    else
      data_table_pipe_splitter(rest, {false, false, prev_count, count + 2, cell <> "\\", cells})
    end
  end

  def data_table_pipe_splitter(
        <<"\\|", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {false, false, prev_count + 1, count + 2, cell <> "|", cells}
      )
    else
      data_table_pipe_splitter(rest, {false, false, prev_count, count + 2, cell <> "|", cells})
    end
  end

  def data_table_pipe_splitter(
        <<"\\n", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {false, false, prev_count + 1, count + 2, cell <> "\n", cells}
      )
    else
      data_table_pipe_splitter(rest, {false, false, prev_count, count + 2, cell <> "\n", cells})
    end
  end

  def data_table_pipe_splitter(
        <<"\\", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {false, false, prev_count + 1, count + 2, cell <> "\\", cells}
      )
    else
      data_table_pipe_splitter(rest, {false, false, prev_count, count + 2, cell <> "\\", cells})
    end
  end

  def data_table_pipe_splitter(
        <<"\n", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {false, false, prev_count + 1, count + 2, cell <> "\n", cells}
      )
    else
      data_table_pipe_splitter(rest, {false, false, prev_count, count + 2, cell <> "\n", cells})
    end
  end

  def data_table_pipe_splitter(
        <<"\t", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {leading_spaces_to_skip?, false, prev_count, count, cell, cells}
      )
    else
      data_table_pipe_splitter(
        rest,
        {leading_spaces_to_skip?, false, prev_count, count, cell, cells}
      )
    end
  end

  def data_table_pipe_splitter(
        <<160::utf8, rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {leading_spaces_to_skip?, false, prev_count + 2, count + 2, cell, cells}
      )
    else
      data_table_pipe_splitter(
        rest,
        {leading_spaces_to_skip?, false, prev_count, count + 2, cell, cells}
      )
    end
  end

  def data_table_pipe_splitter(
        <<" ", rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {leading_spaces_to_skip?, true, prev_count + 1, count + 1, cell, cells}
      )
    else
      data_table_pipe_splitter(
        rest,
        {leading_spaces_to_skip?, false, prev_count, count + 1, cell <> " ", cells}
      )
    end
  end

  def data_table_pipe_splitter(
        <<char::utf8, rest::binary>>,
        {leading_spaces_to_skip?, _, prev_count, count, cell, cells}
      ) do
    if leading_spaces_to_skip? do
      data_table_pipe_splitter(
        rest,
        {false, false, prev_count + 1, count + 1, cell <> <<char::utf8>>, cells}
      )
    else
      data_table_pipe_splitter(
        rest,
        {false, false, prev_count, count + 1, cell <> <<char::utf8>>, cells}
      )
    end
  end

  def count_spaces_before(<<" ", rest::binary>>, count) do
    count_spaces_before(rest, count + 1)
  end

  def count_spaces_before(trimmed_trailing, count) do
    {count, trimmed_trailing}
  end

  def pad_leading(line, 0), do: line

  def pad_leading(line, amount_spaces) do
    pad_leading(" " <> line, amount_spaces - 1)
  end

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

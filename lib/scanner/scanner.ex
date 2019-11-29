defmodule Gherkin.Scanner do
  @moduledoc false
  defmodule Context do
    @moduledoc false
    defstruct [
      doc_string: {:fully_trim, :no_delim_yet}
    ]

    def new, do: %__MODULE__{}
    def reset(%__MODULE__{}, :doc_string), do: new()

    def new(doc_string) do
      struct(
        __MODULE__,
        doc_string: doc_string
      )
    end

    def doc_string(c = %__MODULE__{}, trim_length, past_delimiter), do: %{c | doc_string: {trim_length, past_delimiter}}
  end
  import Record
  alias __MODULE__.{
    Token,
  }
  import Token, only: [token: 0, token: 1]

  alias Gherkin.Scanner.SyntaxError

  def tokenize(path: path) do
    path
    |> File.stream!()
    |> tokenize
  end

  def tokenize(content) do
    content
    |> Stream.with_index(1)
    |> Stream.transform(Context.new, fn {line, index}, context = %Context{} ->
      sanity_check(context.doc_string)
      {trim_length, _} = context.doc_string
      {trimmed_line, column_count} = trim_line(line, trim_length)

      trimmed_line
      |> map_to_token(index, column_count, context)
      |> case do
        {tokenized = {:token, :doc_string, _, _}, _, updated_context} -> {[tokenized], updated_context}
        {tokenized, trimmed_line, updated_context} ->
          {_, past_delimiter} = updated_context.doc_string
          if past_delimiter == :no_delim_yet do
            {[tokenized], updated_context}
          else
            {[handle_plain_text(trimmed_line, index, column_count)], updated_context}
          end
      end
    end)
  end

  defp sanity_check({:fully_trim, :no_delim_yet}), do: :ok
  defp sanity_check({_, :no_delim_yet}), do: raise("Developer Error")
  defp sanity_check({:fully_trim, _}), do: raise("Developer Error")
  defp sanity_check(_), do: :ok

  def trim_line(line, :fully_trim) do
    {line, column_count} = trim_leading_white_spaces(line, 1)
    {String.trim_trailing(line), column_count}
  end

  def trim_line(line, 1), do: {String.trim_trailing(line, "\n"), 1}
  def trim_line(line, trim_length) do
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

  def map_to_token(trimmed_line = <<"Feature:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.feature(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Rule:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.rule(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Example:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.scenario(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Scenario:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.scenario(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Given", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.given(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"When", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token._when(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Then", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.then(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"But", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.but(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"And", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token._and(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Background:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.background(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Scenario Outline:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.scenario_outline(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Scenario Template:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.scenario_outline(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Examples:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.scenarios(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"Scenarios:", " ", rest::binary>>, index, column, context = %Context{}) do
    {Token.scenarios(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = current_delimiter = "\"\"\"", index, column, context) do
    handle_doc_string(trimmed_line, current_delimiter, :plain, index, column, context)
  end

  def map_to_token(trimmed_line = <<"\"\"\"", rest::binary>>, index, column, context) do
    handle_doc_string(trimmed_line, "\"\"\"", String.to_atom(rest), index, column, context)
  end

  def map_to_token(trimmed_line = current_delimiter = "```", index, column, context) do
    handle_doc_string(trimmed_line, current_delimiter, :plain, index, column, context)
  end

  def map_to_token(trimmed_line = <<"```", rest::binary>>, index, column, context) do
    handle_doc_string(trimmed_line, "```", String.to_atom(rest), index, column, context)
  end

  def map_to_token(trimmed_line = <<"|", rest::binary>>, index, column, context = %Context{}) do
    {Token.data_table(index, column, String.split(rest, "|", trim: true) |> Enum.map(&String.trim/1)), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"@", rest::binary>>, index, column, context = %Context{}) do
    {Token.tag(index, column, String.split(rest, "@", trim: true) |> Enum.map(&String.trim/1)), trimmed_line, context}
  end

  def map_to_token(trimmed_line = <<"#", rest::binary>>, index, column, context = %Context{}) do
    {Token.comment(index, column, rest), trimmed_line, context}
  end

  def map_to_token(trimmed_line = text, index, column, context = %Context{}) do
    {handle_plain_text(text, index, column), trimmed_line, context}
  end

  defp handle_doc_string(trimmed_line, current_delimiter, type, index, column, context = %Context{}) do
    {trim_length, past_delimiter} = context.doc_string
    indentation_buffer_length = column

    if trim_length == :fully_trim do
      c = Context.doc_string(context, indentation_buffer_length, current_delimiter)
      {Token.doc_string(index, column, {current_delimiter, type}), trimmed_line, c}
    else
        {current_delimiter == past_delimiter, type == :plain}
        |> case do
          {true, true} -> {Token.doc_string(index, column, {current_delimiter, type}), trimmed_line, Context.reset(context, :doc_string)}
          {false, _} -> {Token.content(index, column, trimmed_line), trimmed_line, context}
          {true, false} -> SyntaxError.raise(
             "Docstring to be ended with an untyped delimiter. Kindly remove the type `#{
               type
             }` from `#{trimmed_line}` or use an alternate Docstring delimiter",
             index,
             column,
             :ending_docstring_delim_typed
           )
       end
     end
  end

  defp handle_plain_text("", index, column) do
    Token.empty(index, column)
  end

  defp handle_plain_text(text, index, column) do
    Token.content(index, column, text)
  end
end

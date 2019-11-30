defmodule Gherkin.Scanner do
  @moduledoc false
  defmodule Context do
    @moduledoc false
    defstruct doc_string: false

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
  end

  alias __MODULE__.{
    SyntaxError,
    Token
  }

  import Gherkin.Scanner.Utils

  def tokenize(path: path) do
    path
    |> File.stream!()
    |> tokenize
  end

  def tokenize(content) do
    content
    |> Stream.with_index(1)
    |> Stream.transform(Context.new(), fn {line, index}, context = %Context{} ->
      {trimmed_line, column_count} = trim_line(line, context)

      {tokenized, updated_context} = map_to_token(trimmed_line, index, column_count, context)

      {[Token.strip_record_name(tokenized)], updated_context}
    end)
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

  def map_to_token(trimmed_line, index, column, context = %Context{doc_string: {offset, _}}) do
    {handle_plain_text(trimmed_line, index, column - offset + 1), context}
  end

  def map_to_token(
        <<"Feature:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.feature(index, column, "Feature:", rest), context}
  end

  def map_to_token(
        <<"Rule:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.rule(index, column, "Rule:", rest), context}
  end

  def map_to_token(
        <<"Example:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.scenario(index, column, "Example:", rest), context}
  end

  def map_to_token(
        <<"Scenario:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.scenario(index, column, "Scenario:", rest), context}
  end

  def map_to_token(
        <<"Given", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.given(index, column, "Given", rest), context}
  end

  def map_to_token(
        <<"When", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token._when(index, column, "When", rest), context}
  end

  def map_to_token(
        <<"Then", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.then(index, column, "Then", rest), context}
  end

  def map_to_token(
        <<"But", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.but(index, column, "But", rest), context}
  end

  def map_to_token(
        <<"And", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token._and(index, column, "And", rest), context}
  end

  def map_to_token(
        <<"Background:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.background(index, column, "Background:", rest), context}
  end

  def map_to_token(
        <<"Scenario Outline:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.scenario_outline(index, column, "Scenario Outline:", rest), context}
  end

  def map_to_token(
        <<"Scenario Template:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.scenario_outline(index, column, "Scenario Template:", rest), context}
  end

  def map_to_token(
        <<"Examples:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.scenarios(index, column, "Examples:", rest), context}
  end

  def map_to_token(
        <<"Scenarios:", " ", rest::binary>>,
        index,
        column,
        context = %Context{}
      ) do
    {Token.scenarios(index, column, "Scenarios:", rest), context}
  end

  def map_to_token(<<"|", rest::binary>>, index, column, context = %Context{}) do
    {Token.data_table(
       index,
       column,
       "|",
       rest |> String.split("|", trim: true) |> Enum.map(&String.trim/1)
     ), context}
  end

  def map_to_token(<<"@", rest::binary>>, index, column, context = %Context{}) do
    {Token.tag(
       index,
       column,
       "@",
       rest |> String.split("@", trim: true) |> Enum.map(&String.trim/1)
     ), context}
  end

  def map_to_token(<<"#", rest::binary>>, index, column, context = %Context{}) do
    {Token.comment(index, column, "#", rest), context}
  end

  def map_to_token(text, index, column, context = %Context{}) do
    {handle_plain_text(text, index, column), context}
  end

  defp handle_doc_string(
         _,
         current_delimiter,
         type,
         index,
         column,
         context = %Context{doc_string: false}
       ) do
    c = Context.doc_string(context, column, current_delimiter)
    {Token.doc_string(index, column, current_delimiter, {current_delimiter, type}), c}
  end

  defp handle_doc_string(
         trimmed_line,
         current_delimiter,
         type,
         index,
         column,
         context = %Context{doc_string: {_, past_delimiter}}
       ) do
    {current_delimiter == past_delimiter, type == :plain}
    |> case do
      {true, true} ->
        {Token.doc_string(index, column, current_delimiter, {current_delimiter, type}),
         Context.reset(context, :doc_string)}

      {false, _} ->
        {Token.content(index, column, trimmed_line), context}

      {true, false} ->
        SyntaxError.raise(
          "Docstring to be ended with an untyped delimiter. Kindly remove the type `#{type}` from `#{
            trimmed_line
          }` or use an alternate Docstring delimiter",
          index,
          column,
          :ending_docstring_delim_typed
        )
    end
  end

  defp handle_plain_text("", index, column) do
    Token.empty(index, column)
  end

  defp handle_plain_text(text, index, column) do
    Token.content(index, column, text)
  end
end

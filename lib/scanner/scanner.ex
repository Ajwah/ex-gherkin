defmodule Gherkin.Scanner do
  @moduledoc false
  alias __MODULE__.{
    Context,
    SyntaxError,
    Token,
    Utils
  }

  def tokenize(path: path) do
    path
    |> File.stream!()
    |> tokenize
  end

  def tokenize(content), do: tokenize(content, Context.new())

  def tokenize(content, context = %Context{}) do
    content
    |> Stream.with_index(1)
    |> Stream.transform(context, fn {line, index}, context = %Context{} ->
      {trimmed_line, column_count} = Utils.trim_line(line, context)

      {tokenized, updated_context} =
        map_to_token(
          context.language,
          trimmed_line,
          index,
          column_count,
          Context.original_line(context, line)
        )

      {[Token.strip_record_name(tokenized)], updated_context}
    end)
  end

  def map_to_token(_, trimmed_line = current_delimiter = "\"\"\"", index, column, context) do
    handle_doc_string(trimmed_line, current_delimiter, :plain, index, column, context)
  end

  def map_to_token(_, trimmed_line = <<"\"\"\"", rest::binary>>, index, column, context) do
    handle_doc_string(trimmed_line, "\"\"\"", String.to_atom(rest), index, column, context)
  end

  def map_to_token(_, trimmed_line = current_delimiter = "```", index, column, context) do
    handle_doc_string(trimmed_line, current_delimiter, :plain, index, column, context)
  end

  def map_to_token(_, trimmed_line = <<"```", rest::binary>>, index, column, context) do
    handle_doc_string(trimmed_line, "```", String.to_atom(rest), index, column, context)
  end

  def map_to_token(_, trimmed_line, index, _, context = %Context{doc_string: {_, _}}) do
    if trimmed_line == "\\\"\\\"\\\"" do
      {handle_plain_text("\"\"\"", index, 1), context}
    else
      {handle_plain_text(trimmed_line, index, 1), context}
    end
  end

  @languages Gherkin.Scanner.LanguageSupport.all()
  # @languages []

  Enum.each(@languages, fn {language,
                            %{
                              feature: feature_phrasals,
                              rule: rule_phrasals,
                              background: background_phrasals,
                              scenario_outline: scenario_outline_phrasals,
                              example: example_phrasals,
                              given: given_phrasals,
                              when: when_phrasals,
                              then: then_phrasals,
                              but: but_phrasals,
                              and: and_phrasals,
                              examples: examples_phrasals,
                              direction: language_direction,
                              homonyms: homonym_phrasals
                            }} ->
    Enum.each(homonym_phrasals, fn {phrasal, next_in_sequence_lookup} ->
      {%{default: default_homonym}, next_in_sequence_lookup} =
        Map.split(next_in_sequence_lookup, [:default])

      def map_to_token(
            unquote(language),
            <<unquote(phrasal), rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        {:token, prev_keyword, _, _, _} = Context.peek(context)

        unquote(Macro.escape(next_in_sequence_lookup))
        |> Map.get(prev_keyword, unquote(default_homonym))
        |> case do
          :given ->
            handle_given(
              unquote(language_direction),
              unquote(phrasal),
              rest,
              index,
              column,
              context
            )

          :when ->
            handle_when(
              unquote(language_direction),
              unquote(phrasal),
              rest,
              index,
              column,
              context
            )

          :then ->
            handle_then(
              unquote(language_direction),
              unquote(phrasal),
              rest,
              index,
              column,
              context
            )

          :and ->
            handle_and(
              unquote(language_direction),
              unquote(phrasal),
              rest,
              index,
              column,
              context
            )

          :but ->
            handle_but(
              unquote(language_direction),
              unquote(phrasal),
              rest,
              index,
              column,
              context
            )
        end
      end
    end)

    Enum.each(feature_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), ":", rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        _language_direction = unquote(language_direction)
        token = Token.feature(index, column, unquote(phrasal), rest)
        {token, context |> Context.reset(:stepline) |> Context.push(token)}
      end
    end)

    Enum.each(rule_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), ":", rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        _language_direction = unquote(language_direction)
        token = Token.rule(index, column, unquote(phrasal), rest)
        {token, context |> Context.reset(:stepline) |> Context.push(token)}
      end
    end)

    Enum.each(example_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), ":", rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        _language_direction = unquote(language_direction)
        token = Token.scenario(index, column, unquote(phrasal), rest)
        {token, context |> Context.stepline() |> Context.push(token)}
      end
    end)

    Enum.each(given_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        handle_given(unquote(language_direction), unquote(phrasal), rest, index, column, context)
      end
    end)

    Enum.each(when_phrasals, fn phrasal ->
      # IO.puts(":when, #{language}, #{phrasal}")
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        handle_when(unquote(language_direction), unquote(phrasal), rest, index, column, context)
      end
    end)

    Enum.each(then_phrasals, fn phrasal ->
      # IO.puts(":then, #{language}, #{phrasal}")
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        handle_then(unquote(language_direction), unquote(phrasal), rest, index, column, context)
      end
    end)

    Enum.each(but_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        handle_but(unquote(language_direction), unquote(phrasal), rest, index, column, context)
      end
    end)

    Enum.each(and_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        handle_and(unquote(language_direction), unquote(phrasal), rest, index, column, context)
      end
    end)

    Enum.each(background_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), ":", rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        _language_direction = unquote(language_direction)
        token = Token.background(index, column, unquote(phrasal), String.trim_leading(rest))
        {token, context |> Context.stepline() |> Context.push(token)}
      end
    end)

    Enum.each(scenario_outline_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), ":", rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        _language_direction = unquote(language_direction)
        token = Token.scenario_outline(index, column, unquote(phrasal), rest)
        {token, context |> Context.reset(:stepline) |> Context.push(token)}
      end
    end)

    Enum.each(examples_phrasals, fn phrasal ->
      def map_to_token(
            unquote(language),
            <<unquote(phrasal), ":", rest::binary>>,
            index,
            column,
            context = %Context{}
          ) do
        _language_direction = unquote(language_direction)
        token = Token.scenarios(index, column, unquote(phrasal), String.trim_leading(rest))
        {token, Context.push(context, token)}
      end
    end)
  end)

  def map_to_token(_, <<"|", rest::binary>>, index, column, context = %Context{}) do
    text =
      rest
      |> String.trim_trailing("|")
      |> Utils.data_table_pipe_splitter(column)
      |> Enum.map(fn {offset_count, e} ->
        {offset_count, String.trim(e)}
      end)

    {Token.data_table(
       index,
       column,
       "|",
       text
     ), context}
  end

  def map_to_token(_, <<"@", rest::binary>>, index, column, context = %Context{}) do
    {_, text} =
      rest
      |> String.split("@")
      |> Enum.reduce({column, []}, fn tag, {left_offset, tags} ->
        {left_offset, trimmed_leading} = Utils.count_spaces_before(tag, left_offset)

        {left_offset + String.length(trimmed_leading) + 1,
         tags ++ [{left_offset, "@" <> String.trim_trailing(trimmed_leading)}]}
      end)

    {Token.tag(
       index,
       column,
       "@",
       text
     ), context}
  end

  def map_to_token(_, <<"# language:", rest::binary>>, index, column, context = %Context{}) do
    language = String.trim(rest)
    {Token.language(index, column, "#", language), Context.language(context, language)}
  end

  def map_to_token(_, <<"#language:", rest::binary>>, index, column, context = %Context{}) do
    language = String.trim(rest)
    {Token.language(index, column, "#", language), Context.language(context, language)}
  end

  def map_to_token(language, <<"#", rest::binary>>, index, column, context = %Context{}) do
    language_test = String.split(rest, "language")

    if length(language_test) == 2 do
      [_, language_part] = language_test
      language_test = String.split(language_part, ":")

      if length(language_test) == 2 do
        [_, language_part] = language_test

        map_to_token(
          language,
          "# language:" <> String.trim(language_part),
          index,
          column,
          context
        )
      else
        handle_comment(index, column, context)
      end
    else
      handle_comment(index, column, context)
    end
  end

  def map_to_token(_, text, index, column, context = %Context{}) do
    {text, column} =
      context
      |> Context.peek()
      |> case do
        token = {:token, :feature, _, _, _} ->
          new_column = Token.column(token)

          if column < new_column do
            {text, new_column}
          else
            {Utils.pad_leading(text, column - new_column), new_column}
          end

        {:token, :scenario, _, _, _} ->
          {Utils.pad_leading(text, column - 1), 1}

        {:token, :rule, _, _, _} ->
          {Utils.pad_leading(text, column - 1), 1}

        {:token, :background, _, _, _} ->
          {Utils.pad_leading(text, column - 1), 1}

        _ ->
          {text, column}
      end

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
        {column, _} = Utils.count_spaces_before(context.original_line, 1)

        {Token.doc_string(index, column, current_delimiter, {current_delimiter, type}),
         Context.reset(context, :doc_string)}

      {false, _} ->
        {Token.content(index, 1, trimmed_line), context}

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

  defp handle_comment(index, column, context) do
    line_with_white_spaces_at_end_preserved =
      context.original_line
      |> String.trim_leading()
      |> String.trim_leading("#")
      |> String.trim_trailing("\n")

    {Token.comment(index, column, "#", line_with_white_spaces_at_end_preserved), context}
  end

  def handle_given(_language_direction, phrasal, rest, index, column, context) do
    token = Token.given(index, column, phrasal, rest)
    {token, context |> Context.stepline() |> Context.push(token)}
  end

  def handle_when(_language_direction, phrasal, rest, index, column, context) do
    token = Token._when(index, column, phrasal, rest)
    {token, context |> Context.stepline() |> Context.push(token)}
  end

  def handle_then(_language_direction, phrasal, rest, index, column, context) do
    token = Token.then(index, column, phrasal, rest)
    {token, context |> Context.stepline() |> Context.push(token)}
  end

  def handle_and(_language_direction, phrasal, rest, index, column, context) do
    if context.stepline do
      token = Token._and(index, column, phrasal, rest)
      {token, Context.push(context, token)}
    else
      {handle_plain_text(String.trim_trailing(context.original_line, "\n"), index, 1), context}
    end
  end

  def handle_but(_language_direction, phrasal, rest, index, column, context) do
    if context.stepline do
      token = Token.but(index, column, phrasal, rest)
      {token, Context.push(context, token)}
    else
      {handle_plain_text(String.trim_leading(context.original_line), index, column), context}
    end
  end

  defp handle_plain_text("", index, _) do
    Token.empty(index, 1)
  end

  defp handle_plain_text(text, index, column) do
    Token.content(index, column, text)
  end
end

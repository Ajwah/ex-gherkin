defmodule ExGherkin.Parser do
  @moduledoc false
  alias ExGherkin.Utils

  def run(tokens) when is_list(tokens) do
    {comment_tokens, main_tokens} =
      tokens
      |> Enum.filter(fn token ->
        elem(token, 0) != :empty
      end)
      |> Enum.split_with(fn token ->
        elem(token, 0) == :comment
      end)

    main_tokens
    |> prepare
    |> Utils.introspect(:prepare)
    |> case do
      error = {:error, _} ->
        error

      [] ->
        validate_comments_not_preceding_language_token(
          {normalize_comments(comment_tokens), :empty}
        )

      main_tokens ->
        main_tokens
        |> :parser.parse()
        |> case do
          {:ok, result} ->
            validate_comments_not_preceding_language_token(
              {normalize_comments(comment_tokens), result}
            )

          error ->
            error
        end
    end
  end

  def prepare(tokens) do
    tokens
    |> Enum.reverse()
    |> Enum.reduce_while({:none, []}, fn full_token = {token, _, _, _},
                                         {full_prev_token, tokens} ->
      token
      |> case do
        :comment -> raise "Unexpected Token: #{token}"
        :tag -> tag_it(full_token, {full_prev_token, tokens})
        _ -> {:ok, {full_token, [full_token | tokens]}}
      end
      |> case do
        {:ok, prepared} -> {:cont, prepared}
        error -> {:halt, {:error, error}}
      end
    end)
    |> elem(1)
  end

  defp tag_it(current_token = {:tag, _, _, _}, {:none, _}) do
    invalid_tagging_error(current_token, :tagged_eof)
  end

  defp tag_it(
         full_tag_token = {:tag, label, location, content},
         {full_prev_token = {prev_token, _, _, _}, tokens}
       ) do
    prev_token
    |> case do
      :given ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      :when ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      :then ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      :and ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      :but ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      :content ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      :language ->
        invalid_tagging_error(full_tag_token, :tagged_language_token)

      :doc_string ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      :data_table ->
        invalid_tagging_error(full_prev_token, :untaggable_token)

      _ ->
        {:ok,
         {full_prev_token,
          [{String.to_atom("#{prev_token}_tag"), label, location, content} | tokens]}}
    end
  end

  defp invalid_tagging_error(full_prev_token, error_code),
    do: {:error, {full_prev_token, :outside_yrl_parser, error_code}}

  defp validate_comments_not_preceding_language_token(result = {_, :empty}), do: {:ok, result}

  defp validate_comments_not_preceding_language_token(
         result = {{:comments, _, {:constituents, []}}, _}
       ),
       do: {:ok, result}

  defp validate_comments_not_preceding_language_token(
         result =
           {{:comments, _,
             {
               :constituents,
               [
                 first_comment =
                   {:comment, {:meta, {{:location, {{:line, first_comment_line}, _}}, _}, _}, _}
                 | _
               ]
             }},
            {:feature,
             {:meta,
              {_, _, {:language, {:meta, {{:location, {{:line, language_line}, _}}, _}, _}, _}},
              _}, _}}
       ) do
    if first_comment_line < language_line do
      {:error, {first_comment, :outside_yrl_parser, :commented_language_token}}
    else
      {:ok, result}
    end
  end

  defp validate_comments_not_preceding_language_token(result), do: {:ok, result}

  defp normalize_comments(comments) do
    {
      :comments,
      {:meta, {:none, :none}, {:type, :multiples}},
      {:constituents, Enum.map(comments, &normalize_comment/1)}
    }
  end

  defp normalize_comment({:comment, token_label, {:location, line, column}, comment_text}) do
    {:comment,
     {
       :meta,
       {
         {
           :location,
           {
             {:line, line},
             {:column, column}
           }
         },
         {
           :token_label,
           token_label
         }
       },
       {
         :type,
         :singular
       }
     }, comment_text}
  end
end

defmodule ExGherkin.Parser.SyntaxError do
  @moduledoc false
  defexception [:message, :token, :label, :line, :column, :content, :error_code, :feature_file]

  alias __MODULE__.Message

  def new(
        all_details = %{
          message: _,
          token: _,
          label: _,
          line: _,
          column: _,
          content: _,
          error_code: _,
          feature_file: _
        }
      ) do
    struct(__MODULE__, all_details)
  end

  @impl true
  def exception(
        {feature_file,
         {{token,
           {:meta, {{:location, {{:line, line}, {:column, column}}}, {:token_label, token_label}},
            {:type, _}}, contents}, _, error_code}}
      ) do
    message_details = %{
      token: token,
      label: token_label,
      line: line,
      column: column,
      content: contents,
      error_code: error_code,
      feature_file: feature_file
    }

    message = Message.compose(message_details)

    message_details
    |> Map.put(:message, message)
    |> new
  end

  @impl true
  def exception({feature_file, {full_token = {_, _, _, _}, _, error_code}}) do
    message_details = %{
      token: token(full_token),
      label: label(full_token),
      line: line(full_token),
      column: column(full_token),
      content: content(full_token),
      error_code: error_code,
      feature_file: feature_file
    }

    message = Message.compose(message_details)

    message_details
    |> Map.put(:message, message)
    |> new
  end

  @impl true
  def exception({feature_file, {_, _, details}}) do
    message_details =
      details
      |> to_parser_details
      |> incorporate_error_code
      |> Map.put(:feature_file, feature_file)

    message = Message.compose(message_details)

    message_details
    |> Map.put(:message, message)
    |> new
  end

  def raise(details = {_, _}) do
    raise __MODULE__, details
  end

  defp line({_, _, {:location, line, _}, _}), do: line
  defp column({_, _, {:location, _, column}, _}), do: column
  defp label({_, label, _, _}), do: label
  defp content({_, _, _, content}), do: content
  defp token({token, _, _, _}), do: token

  defp to_parser_details([
         'syntax error before: ',
         [
           [
             123,
             [
               token,
               44,
               [60, 60, token_label, 62, 62],
               44,
               [123, ['location', 44, line, 44, column], 125],
               44,
               [60, 60, content, 62, 62]
             ],
             125
           ]
         ]
       ]) do
    {line, ""} = Integer.parse(to_string(line))
    {column, ""} = Integer.parse(to_string(column))

    %{
      token: token |> to_string |> String.to_atom(),
      label: to_string(token_label) |> String.trim("\""),
      line: line,
      column: column,
      content: to_string(content) |> String.trim("\"")
    }
  end

  defp to_parser_details(details) do
    %{
      token: :"?",
      label: "?",
      line: "?",
      column: "?",
      content: to_string(details)
    }
  end

  defp incorporate_error_code(details = %{token: :language}),
    do: details |> Map.put(:error_code, :unparsable_language_token)

  defp incorporate_error_code(details = %{token: :feature}),
    do: details |> Map.put(:error_code, :multiple_feature_tokens)

  defp incorporate_error_code(details = %{token: :"?"}),
    do: details |> Map.put(:error_code, :unrefined_error)
end

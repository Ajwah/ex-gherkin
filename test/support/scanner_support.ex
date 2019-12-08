defmodule ScannerSupport do
  @moduledoc false
  alias Gherkin.Scanner.Utils

  def to_feature_tokens_format(tokens) do
    {contents, _, _} =
      tokens
      |> Enum.reduce({[], false, :none}, fn _token = {label, label_text, location, text},
                                            {contents, docstring_ctx?, previous} ->
        # indent tag
        #
        # IO.inspect(token, label: :token)
        {formatted, previous} =
          if label in [:content, :empty] && docstring_ctx? do
            {format(:other, label_text, text), :other}
          else
            cond do
              previous in [:other, :content] && label == :empty ->
                {format(:other, label_text, text), :other}

              true ->
                {format(label, label_text, text), label}
            end
          end

        docstring_ctx? =
          if label == :doc_string do
            !docstring_ctx?
          else
            docstring_ctx?
          end

        formatted_location =
          if label == :comment do
            format_location({:location, elem(location, 1), 1})
          else
            format_location(location)
          end

        formatted_regex =
          if label == :comment do
            "/#{Utils.pad_leading("#" <> text, elem(location, 2) - 1)}/"
          else
            format_regex(text)
          end

        result = [formatted_location <> formatted <> formatted_regex | contents]

        {
          result,
          docstring_ctx?,
          previous
        }
      end)

    ["EOF\n" | contents]
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp format_location({:location, line, column}) do
    "(#{line}:#{column})"
  end

  defp format_regex({_, :plain}), do: "//"
  defp format_regex({_, type}), do: "/#{type}/"

  defp format_regex(cells) when is_list(cells) do
    formatted_cells =
      cells
      |> Enum.reduce([], fn {left_offset_count, content}, cells ->
        cells ++ ["#{left_offset_count}:#{content}"]
      end)

    "//" <> Enum.join(formatted_cells, ",")
  end

  defp format_regex(text), do: "/#{text}/"

  defp format(:feature, label_text, _), do: "FeatureLine:#{label_text}"
  defp format(:rule, label_text, _), do: "RuleLine:#{label_text}"
  defp format(:background, label_text, _), do: "BackgroundLine:#{label_text}"
  defp format(:scenarios, label_text, _), do: "ExamplesLine:#{label_text}"

  defp format(:scenario, label_text, _), do: "ScenarioLine:#{label_text}"
  defp format(:scenario_outline, label_text, _), do: "ScenarioLine:#{label_text}"

  defp format(:given, label_text, _), do: "StepLine:#{label_text}"
  defp format(:when, label_text, _), do: "StepLine:#{label_text}"
  defp format(:and, label_text, _), do: "StepLine:#{label_text}"
  defp format(:then, label_text, _), do: "StepLine:#{label_text}"
  defp format(:but, label_text, _), do: "StepLine:#{label_text}"

  defp format(:doc_string, delimiter, _), do: "DocStringSeparator:#{delimiter}"
  defp format(:data_table, _, _), do: "TableRow:"

  defp format(:content, _, _), do: "Other:"
  defp format(:other, _, _), do: "Other:"
  defp format(:tag, _, _), do: "TagLine:"
  defp format(:comment, _, _), do: "Comment:"
  defp format(:language, _, _), do: "Language:"
  defp format(:empty, _, _), do: "Empty:"

  def data_cell_metrics(cell_content) do
    {left_offset, trimmed_leading} = Utils.count_spaces_before(cell_content, 0)
    content = String.trim_trailing(trimmed_leading)
    {left_offset, String.length(cell_content), content}
  end
end

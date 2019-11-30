defmodule ScannerSupport do
  @moduledoc false

  def to_feature_tokens_format(tokens) do
    {contents, _} =
      tokens
      |> Enum.reduce({[], false}, fn {label, label_text, location, text},
                                     {contents, docstring_ctx?} ->
        formatted =
          if label in [:content, :empty] && docstring_ctx? do
            format(:other, label_text, text)
          else
            format(label, label_text, text)
          end

        docstring_ctx? =
          if label == :doc_string do
            !docstring_ctx?
          else
            docstring_ctx?
          end

        {[format_location(location) <> formatted <> format_regex(text) | contents],
         docstring_ctx?}
      end)

    ["EOF\n" | contents]
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp format_location({:location, line, row}) do
    "(#{line}:#{row})"
  end

  defp format_regex({_, :plain}), do: "//"
  defp format_regex({_, type}), do: "/#{type}/"
  defp format_regex(text), do: "/#{text}/"

  defp format(:feature, _, _), do: "FeatureLine:Feature"
  defp format(:empty, _, _), do: "Empty:"
  defp format(:scenario, _, _), do: "ScenarioLine:Scenario"
  defp format(:given, _, _), do: "StepLine:Given "
  defp format(:doc_string, delimiter, _), do: "DocStringSeparator:#{delimiter}"
  defp format(:and, _, _), do: "StepLine:And "
  defp format(:other, _, _), do: "Other:"
  defp format(:content, _, _), do: "Other:"
end

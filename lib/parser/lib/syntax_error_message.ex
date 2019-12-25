defmodule ExGherkin.Parser.SyntaxError.Message do
  @moduledoc false
  @domain "https://gherkin.com"
  @taggable_keywords [:feature, :scenario_outline, :scenario, :scenarios]
                     |> Enum.map(&to_string/1)
                     |> Enum.join(", ")
  alias ExGherkin.Utils

  def compose(details = %{error_code: error_code = :untaggable_token}) do
    format_message(%{
      details: details,
      message: "#{format_token(details)} Untaggable",
      original_line: original_line(details, ":"),
      clarrification:
        "This token cannot be tagged. Only tokens that can be tagged are: #{@taggable_keywords}",
      cta: "Kindly remove all such invalid occurrences.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def compose(details = %{error_code: error_code = :multiple_feature_tokens}) do
    format_message(%{
      details: details,
      message: "Multiple `Feature`-tokens Not Allowed",
      original_line: original_feature_line(details, ":"),
      clarrification: "Only one `Feature`-token allowed.",
      cta: "Kindly remove all multiple occurrences.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def compose(details = %{error_code: error_code = :missing_feature_token}) do
    format_message(%{
      details: details,
      message: "Missing `Feature`-token",
      original_line: false,
      clarrification: "Exactly one `Feature`-token required.",
      cta: "Kindly introduce one `Feature`-token.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def compose(details = %{error_code: error_code = :multiple_language_tokens}) do
    format_message(%{
      details: details,
      message: "Multiple `Language`-tokens Not Allowed",
      original_line: original_line(details, ":"),
      clarrification: "Only one `Language`-token allowed.",
      cta: "Kindly remove all multiple occurrences.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def compose(details = %{error_code: error_code = :unparsable_language_token}) do
    format_message(%{
      details: details,
      message: "Incorrect Placement `Language`-token",
      original_line: original_line(details, ":"),
      clarrification: "`Language`-token to appear at the top before the `Feature`-token",
      cta: "Kindly move the token to its designated place.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def compose(details = %{error_code: error_code = :commented_language_token}) do
    format_message(%{
      details: details,
      message: "Commented `Language`-token",
      original_line: original_line(details),
      clarrification: "`Language`-token not to be preceded upon, including comments",
      cta:
        "Kindly remove any comments preceding the point of contention to ensure top level prominence.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def compose(details = %{error_code: error_code = :tagged_language_token}) do
    format_message(%{
      details: details,
      message: "Tagged `Language`-token",
      original_line: original_tag_line(details),
      clarrification: "`Language`-token not to be preceded upon, including tags",
      cta:
        "Kindly remove any tags preceding the point of contention to ensure top level prominence.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def compose(details = %{error_code: error_code = :tagged_eof}) do
    format_message(%{
      details: details,
      message: "Unexpected `Tag`-token appearing at EOF",
      original_line: original_tag_line(details),
      clarrification: "Tokens that can be tagged are: #{@taggable_keywords}",
      cta:
        "Kindly, either remove the `Tag`-token or either introduce a taggable token as may apply.",
      error_code: error_code,
      feature_file: details.feature_file
    })
  end

  def format_message(%{
        details: details,
        message: message,
        original_line: original_line,
        clarrification: clarrification,
        cta: cta,
        error_code: error_code,
        feature_file: feature_file
      }) do
    """
    #{message}
    Kindly take note of the problematic occurrence with following details:
      Feature File: #{format_source(feature_file)}
      Line: #{details.line}
      Column: #{details.column}
      Content: #{original_line}

    #{clarrification}
    #{cta}

    For more information, kindly consult: #{@domain}/errors/#{error_code}
    """
    |> Utils.introspect(:format_message)
  end

  defp original_line(details = %{token: :feature}, delimiter),
    do: original_feature_line(details, delimiter)

  defp original_line(details = %{token: :data_table}, delimiter),
    do: original_data_table_line(details, delimiter)

  defp original_line(details = %{token: :doc_string}, delimiter),
    do: original_doc_string_line(details, delimiter)

  defp original_line(details, delimiter) do
    "#{details.label} #{details.token}#{delimiter}#{details.content}"
  end

  defp original_line(details) do
    "#{details.label}#{details.content}"
  end

  defp original_feature_line(details, delimiter) do
    "#{details.label}#{delimiter} #{details.content}"
  end

  defp original_data_table_line(details, _) do
    [{_, content}] = details.content
    "#{details.label} #{content} #{details.label}"
  end

  defp original_doc_string_line(details, _) do
    details.content
    |> case do
      {content, :plain} -> content
      {content, language} -> "#{content}#{language}"
    end
  end

  defp original_tag_line(details) do
    {line, _} =
      details.content
      |> Enum.reduce({"", 0}, fn {position, tag}, {line, current_length} ->
        line = line <> String.duplicate(" ", position - current_length - 1) <> tag
        {line, String.length(line)}
      end)

    line
  end

  defp format_source(:none), do: "inline"
  defp format_source(file), do: file
  defp format_token(%{token: :doc_string}), do: "DocString"
  defp format_token(%{token: :data_table}), do: "Data Table"

  defp format_token(%{token: token}) do
    token
    |> to_string
    |> String.capitalize()
    |> String.pad_leading(1, "`")
    |> String.pad_trailing(1, "`-token")
  end
end

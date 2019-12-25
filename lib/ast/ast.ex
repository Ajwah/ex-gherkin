defmodule ExGherkin.Ast do
  @moduledoc false
  def r(:empty), do: :empty
  def r(s), do: s |> traverse("", &print/4)

  def traverse({token, {:meta, meta, {:type, :singular}}, value}, acc, fun) do
    value
    |> case do
      {_, {:meta, _, {:type, :multiples}}, _} -> fun.(token, meta, value, acc)
      _ -> fun.(token, meta, {:singular, value}, acc)
    end
  end

  def traverse(
        {token, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
        acc,
        fun
      ) do
    Enum.reduce(constituents, acc, fn
      e = {_, {:meta, _, {:type, _}}, _}, a -> traverse(e, fun.(token, meta, e, a), fun)
      e, a -> fun.(token, meta, e, a)
    end)
  end

  def print(:feature, {location, token_label, language}, constituent, acc) do
    """
    ********************************************************************

    Token: Feature
    Line: #{location(location).line}
    Column: #{location(location).column}
    TokenLabel: #{token_label(token_label)}
    Language: #{language(language)}
    Constituent:
    #{traverse(constituent, acc, &print/4)}

    ********************************************************************
    """
  end

  def print(token, {location, token_label}, sth, acc) do
    {tag, result} =
      sth
      |> case do
        {:singular, value} ->
          {"Value: ", value}

        {column, value} ->
          {String.pad_leading("Value: ", column), value}

        constituent = {_, {:meta, _, {:type, _}}, _} ->
          {"Constituent: ", traverse(constituent, acc, &print/4)}

        [] ->
          {"Value: ", "Empty"}
      end

    """
    #{format_token(token, location)}
    #{format_line(location)}
    #{format_column(location)}
    #{format_token_label(token_label, location)}
    #{format_txt(tag, result, location)}
    """
  end

  defp format_token(token, location), do: format_line("Token: #{token}", location)
  defp format_line(location), do: format_line("Line: #{location(location).line}", location)
  defp format_column(location), do: format_line("Column: #{location(location).column}", location)

  defp format_token_label(token_label, location),
    do: format_line("TokenLabel: #{token_label(token_label)}", location)

  defp format_txt(tag, result, location), do: format_line("#{tag}#{result}", location)

  defp format_line(str, location) do
    location
    |> location
    |> Map.get(:column)
    |> case do
      :na -> str
      column -> String.pad_leading(str, column)
    end
  end

  defp location({:location, {{:line, line}, {:column, column}}}) do
    %{line: line, column: column}
  end

  defp location(:none) do
    %{line: :na, column: :na}
  end

  defp language({:language, _, language}) do
    language
  end

  defp token_label({:token_label, label}), do: label
  defp token_label(:none), do: :na
end

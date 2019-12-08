defmodule Mix.Tasks.GherkinLanguages do
  @moduledoc """
  Parse json
  """
  use Mix.Task

  @gherkin_languages_source Application.get_env(:ex_gherkin, :file).source
  @gherkin_languages_resource Application.get_env(:ex_gherkin, :file).resource
  @homonyms Application.get_env(:ex_gherkin, :homonyms)

  alias Gherkin.Scanner.LanguageSupport
  @shortdoc "Converts `gherkin-languages.json` to pallatable format"
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [debug: :boolean, source: :string, resource: :string, homonyms: :string, languages: :string])

    source = opts[:source] || @gherkin_languages_source
    resource = opts[:resource] || @gherkin_languages_resource
    homonyms = trim(opts[:homonyms]) || @homonyms
    languages = trim(opts[:languages], :fully) || :all
    debug? = opts[:debug] || false

    IO.puts(message(debug?, source, resource, homonyms, languages))

    if debug? do
      LanguageSupport.parse(source, homonyms, languages)
      |> IO.inspect(limit: :infinity)
    else
      LanguageSupport.unload(source, resource, homonyms, languages)
    end
  end

  defp message(true, source, _, homonyms, languages) do
    """
    ******************* Parsing ********************

    Source: '#{source}'

    Homonyms:
    #{bullet_list(homonyms)}

    #{format_languages(languages)}

    ************************************************
    """
  end

  defp message(false, source, resource, homonyms, languages) do
    """
    ************ Parsing and Persisting ************

    Source: '#{source}'
    Resource: '#{resource}'

    Homonyms:
    #{bullet_list(homonyms)}

    #{format_languages(languages)}

    ************************************************
    """
  end

  defp trim(nil, :fully), do: nil
  defp trim(input, :fully) when is_binary(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end

  defp trim(nil), do: nil
  defp trim(input) when is_binary(input) do
    input
    |> String.split(",", trim: true)
  end

  defp bullet_list(ls) do
    ls
    |> Enum.map(&("   * '#{&1}'"))
    |> Enum.join("\n")
  end

  defp format_languages(:all), do: "Languages: All"
  defp format_languages(languages) do
    """
    Languages:
    #{bullet_list(languages)}
    """
  end
end

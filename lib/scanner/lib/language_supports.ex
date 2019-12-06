defmodule Gherkin.Scanner.LanguageSupport do
  @gherkin_languages "gherkin-languages"
  @gherkin_languages_source "#{@gherkin_languages}.json"
  @gherkin_languages_resource "#{@gherkin_languages}.terms"
  @homonyms ["Агар ", "* ", "अनी ", "Tha ", "Þá ", "Ða ", "Þa "]
  @moduledoc_homonyms @homonyms |> Enum.map(&("      * '#{&1}'")) |> Enum.join("\n")

  @moduledoc """
  The main purpose of this module is to facilitate full international
  language support by normalizing each entry under
  '#{@gherkin_languages_source}' to the following format:

  ```elixir
  %{
    # Top Level Gherkin Keywords
    feature: ["Feature", "Business Need", "Ability"],
    rule: ["Rule"],
    background: ["Background"],
    scenario_outline: ["Scenario Outline", "Scenario Template"],
    example: ["Example", "Scenario"],
    examples: ["Examples", "Scenarios"],

    # Step Level Gherkin Keywords
    given: ["Given "],
    when: ["When "],
    then: ["Then "],
    and: ["And "],
    but: ["But "],

    # Meta
    name: "English",
    native: "English",
    direction: :ltr,
    homonyms: %{
      "* " => %{
        given: :when,
        when: :then
        then: :and,
        and: :and,
        but: :but,
        default: :given,
      }
    },
  }
  ```

  and persisting the same as '#{@gherkin_languages_resource}'.

  The `# Meta` section comprises of the keys `:name` and `:native` which
  are part and parcel of the #{@gherkin_languages_source} standard. The
  other keys are newly introduced:

    * `:direction` is to designate if it pertains a `:ltr`(Left to Right)
    or `:rtl` (Right to Left) language. This can be derived thanks to
    the contents under `:native`.

    * `:homonyms` represent the various keywords that are the same
    accross languages, such as "* " to mean any of the Step Level Gherkin
    Keywords or within a language, such as `"Tha "` for old English to
    mean `When` and `Then`. Currently the `homonyms` existent are:
  #{@moduledoc_homonyms}

    Each homonym has a sequence of keywords that it can logically revolve
    to. For the above sample presented, this would mean that the
    following feature:

      ```cucumber
      Feature: Some Feature
          Scenario: Some Scenario
            * A
            * B
            * C
            * D
      ```

    could be interpreted as:
      ```cucumber
      Feature: Some Feature
          Scenario: Some Scenario
            Given A
            When B
            Then C
            And D
      ```
  """
  def gherkin_languages_source, do: @gherkin_languages_source
  def gherkin_languages_resource, do: @gherkin_languages_resource

  @doc """
  Convenience function that provides the contents under the resource:
  '#{@gherkin_languages_resource}'
  """
  def all, do: load()

  @doc """
  Saves parsed content to: '#{@gherkin_languages_resource}' in `binary`
  format.
  """
  def unload do
    content = parse() |> :erlang.term_to_binary()
    File.write!(@gherkin_languages_resource, content)
  end

  @doc """
  Loads: '#{@gherkin_languages_resource}' as Erlang compatible `terms`.
  """
  def load do
    @gherkin_languages_resource
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  @doc """
  Parses the content of '#{@gherkin_languages_source}' into the desired
  format.
  """
  def parse do
    @gherkin_languages_source
    |> File.read!()
    |> :jiffy.decode([:return_maps, :copy_strings])
    |> Enum.reduce(%{}, fn {language, translations}, a ->
      {%{homonyms: homonyms}, remainder} =
        Enum.reduce(translations, %{}, fn
          {"name", val}, a -> Map.put(a, :name, val)
          {"native", val}, a -> Map.put(a, :native, val)
          {key, vals}, a -> normalized_key = handle_key(key)
            {homonyms, remainder} = vals
              |> Enum.uniq
              |> seperate_out_homonyms(@homonyms)

            a
            |> Map.put(normalized_key, remainder)
            |> put_in([Access.key(:homonyms, %{}), normalized_key], homonyms)
        end)
        |> Map.put(:direction, :ltr)
        |> Map.split([:homonyms])

      normalized_homonyms =
        homonyms
        |> Enum.reduce(%{}, fn
          {_, :none}, a -> a
          {keyword, homonyms_for_keyword}, a -> Enum.reduce(homonyms_for_keyword, a, fn homonym, a ->
              put_in(a, [Access.key(homonym, %{}), keyword], next_keyword(keyword, homonym, homonyms))
            end)
        end)
        |> Enum.reduce(%{}, fn {homonym, keywords_sequence}, a ->
          default_homonym = cond do
            keywords_sequence[:given] -> :given
            keywords_sequence[:when] -> :when
            keywords_sequence[:then] -> :then
            keywords_sequence[:and]  -> :and
            keywords_sequence[:but]  -> :but
            true -> raise "Developer Error. Keywords Sequence Has No Members"
          end

          put_in(a, [Access.key(homonym, keywords_sequence), :default], default_homonym)
        end)

      normalized_translations = Map.put(remainder, :homonyms, normalized_homonyms)
      Map.put(a, language, normalized_translations)
    end)
  end

  defp seperate_out_homonyms(words, homonyms) do
    words
    |> Enum.split_with(fn e -> e in homonyms end)
    |> case do
      {[], ^words} -> {:none, words}
      paritioned_result -> paritioned_result
    end
  end

  defp next_keyword(:given, homonym, homonyms) do
    cond do
      homonym in (homonyms[:when] || []) -> :when
      homonym in (homonyms[:then] || []) -> :then
      homonym in (homonyms[:and] || []) -> :and
      true -> :given
    end
  end

  defp next_keyword(:when, homonym, homonyms) do
    cond do
      homonym in (homonyms[:then] || []) -> :then
      homonym in (homonyms[:and] || []) -> :and
      true -> :given
    end
  end

  defp next_keyword(:then, homonym, homonyms) do
    cond do
      homonym in (homonyms[:and] || []) -> :and
      true -> :given
    end
  end

  defp next_keyword(:and, homonym, homonyms) do
    cond do
      homonym in (homonyms[:and] || []) -> :and
      true -> :given
    end
  end

  defp next_keyword(:but, homonym, homonyms) do
    cond do
      homonym in (homonyms[:but] || []) -> :but
      homonym in (homonyms[:and] || []) -> :and
      true -> :given
    end
  end

  defp handle_key("scenarioOutline"), do: :scenario_outline
  defp handle_key("scenario"), do: :example
  defp handle_key(key), do: String.to_atom(key)
end

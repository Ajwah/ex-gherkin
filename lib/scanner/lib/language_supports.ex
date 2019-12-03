defmodule Gherkin.Scanner.LanguageSupport do
  @gherkin_languages "gherkin-languages"
  @gherkin_languages_source "#{@gherkin_languages}.json"
  @gherkin_languages_resource "#{@gherkin_languages}.terms"

  @moduledoc """
  Normalizes each entry under '#{@gherkin_languages_source}' to
  following template:
  %{
    feature: [],
    rule: [],
    background: [],
    scenario_outline: [],
    example: [],
    given: [],
    when: [],
    then: [],
    but: [],
    and: [],
    examples: [],
    direction: :ltr,
    name: "",
    native: "",
  }
  and persists the same as '#{@gherkin_languages_resource}'
  """
  def gherkin_languages_source, do: @gherkin_languages_source
  def gherkin_languages_resource, do: @gherkin_languages_resource

  def parse do
    @gherkin_languages_source
    |> File.read!()
    |> :jiffy.decode([:return_maps, :copy_strings])
    |> Enum.reduce(%{}, fn {language, translations}, a ->
      normalized_translations =
        Enum.reduce(translations, %{}, fn {key, val}, a ->
          Map.put(a, handle_key(key), val)
        end)
        |> Map.put(:direction, :ltr)

      Map.put(a, language, normalized_translations)
    end)
  end

  def unload do
    content = parse() |> :erlang.term_to_binary()
    File.write!(@gherkin_languages_resource, content)
  end

  def load do
    @gherkin_languages_resource
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  defp handle_key("scenarioOutline"), do: :scenario_outline
  defp handle_key("scenario"), do: :example
  defp handle_key(key), do: String.to_atom(key)

  def all, do: load()
end

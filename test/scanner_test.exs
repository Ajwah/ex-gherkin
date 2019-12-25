defmodule ScannerTest do
  @moduledoc false
  use ExUnit.Case
  alias ExGherkin.Scanner

  alias ExGherkin.Scanner.{
    Context,
    SyntaxError
  }

  @keywords [
    {"Feature:", :feature},
    {"Rule:", :rule},
    {"Example:", :scenario},
    {"Scenario:", :scenario},
    {"Given ", :given},
    {"When ", :when},
    {"Then ", :then},
    {"But ", :but},
    {"And ", :and},
    {"Background:", :background},
    {"Scenario Outline:", :scenario_outline},
    {"Scenario Template:", :scenario_outline},
    {"Examples:", :scenarios},
    {"Scenarios:", :scenarios}
  ]

  def tokenize(contents) do
    contents
    |> Scanner.tokenize()
    |> Enum.to_list()
  end

  def tokenize(contents, context) do
    contents
    |> Scanner.tokenize!(context)
    |> Enum.to_list()
  end

  defp tokenize_from_path(path) do
    [path: path]
    |> ExGherkin.prepare()
    |> Map.get(:content)
    |> tokenize()
    |> ScannerSupport.to_feature_tokens_format()
  end

  describe "#tokenize(list) Recognizes Primitives:" do
    @some_text "This is some text"
    @keywords
    |> Enum.each(fn {textual_syntax, keyword} ->
      test "Gherkin Keyword: `#{textual_syntax}`" do
        ctx =
          if unquote(keyword) in [:and, :but] do
            Context.new() |> Context.stepline()
          else
            Context.new()
          end

        assert [
                 {unquote(keyword), String.trim(unquote(textual_syntax), ":"), {:location, 1, 1},
                  unquote(@some_text)}
               ] ==
                 tokenize(["#{String.trim(unquote(textual_syntax))} #{@some_text}"], ctx)
      end
    end)

    test "Recognizes Comment: `#`" do
      assert [{:comment, "#", {:location, 1, 1}, " This is some comment"}] ==
               tokenize(["# This is some comment"])
    end

    test "Recognizes Tag: `@`" do
      assert [{:tag, "@", {:location, 1, 1}, [{1, "@some_tag"}]}] == tokenize(["@some_tag"])
    end

    test "Recognizes Table: `|`" do
      assert [
               {:data_table, "|", {:location, 1, 1}, [{3, "A"}, {7, "B"}, {11, "C"}]}
             ] ==
               tokenize(["| A | B | C |"])
    end

    test "Recognizes Docstring: `\"\"\"`" do
      delim = "\"\"\""

      assert [{:doc_string, "\"\"\"", {:location, 1, 1}, {delim, :plain}}] ==
               tokenize([delim])
    end

    test "Recognizes Docstring with annotated type: `\"\"\"ruby`" do
      delim = "\"\"\""

      assert [{:doc_string, "\"\"\"", {:location, 1, 1}, {delim, :ruby}}] ==
               tokenize(["#{delim}ruby"])
    end
  end

  describe "#tokenize(list) docstring" do
    test "incorrectly indented" do
      delim = "\"\"\""

      content =
        """
        Scenario: Some Scenario
           #{delim}
                 1
                 2
                 3
        #{delim}
        """
        |> String.split("\n", trim: true)

      expected = [
        {:scenario, "Scenario", {:location, 1, 1}, "Some Scenario"},
        {:doc_string, "\"\"\"", {:location, 2, 4}, {delim, :plain}},
        {:content, "", {:location, 3, 1}, "      1"},
        {:content, "", {:location, 4, 1}, "      2"},
        {:content, "", {:location, 5, 1}, "      3"},
        {:doc_string, "\"\"\"", {:location, 6, 1}, {delim, :plain}}
      ]

      assert expected == tokenize(content)
    end
  end

  describe "#tokenize(path: _) works for all Good Feature Files" do
    __DIR__
    |> Path.join("support/testdata/good/*.feature")
    |> Path.wildcard()
    |> Enum.each(fn path ->
      file =
        path
        |> String.split()
        |> List.last()

      test "#{file}" do
        expected = File.read!("#{unquote(path)}.tokens")
        result = tokenize_from_path(unquote(path))

        if expected != result do
          IO.inspect(unquote(path), label: :failed, syntax_colors: [string: :red])
        end

        assert expected == result
      end
    end)
  end

  describe "#tokenize(list) ignores Gherkin Keywords within Docstring" do
    @some_text "This is some text"
    @keywords
    |> Enum.each(fn {textual_syntax, keyword} ->
      test "Gherkin Keyword: `#{textual_syntax}`" do
        gherkin_keyword_content = "#{unquote(textual_syntax)} #{@some_text}"

        docstring_lines =
          """
          This is a Docstring

          All content in here is regarded as normal text
          Regardless as to Gherkin Keywords being indented:
                #{gherkin_keyword_content}

          or not
          #{gherkin_keyword_content}
          """
          |> String.split("\n")
          |> Enum.map(&(&1 <> "\n"))
          |> Kernel.++(["\"\"\""])

        ["\"\"\"" | docstring_lines]
        |> tokenize
        |> Enum.each(fn {actual_keyword, actual_textual_syntax, _, _} ->
          assert actual_keyword != unquote(keyword)
          assert actual_textual_syntax != unquote(textual_syntax)
          assert actual_keyword in [:doc_string, :content, :empty]
        end)
      end
    end)
  end

  describe "#tokenize(list) does not allow ending Docstring with a typed delim" do
    test "Starting without typed delim but ending with typed delim" do
      assert_raise SyntaxError, fn ->
        tokenize(["\"\"\"", "a\n", "\"\"\"ruby"])
      end
    end

    test "Starting and ending with typed delim" do
      assert_raise SyntaxError, fn ->
        tokenize(["\"\"\"ruby", "a\n", "\"\"\"ruby"])
      end

      assert_raise SyntaxError, fn ->
        tokenize(["\"\"\"ruby", "a\n", "\"\"\"ruby", "\"\"\""])
      end
    end
  end

  describe "#tokenize handles i18n" do
    __DIR__
    |> Path.join("support/testdata/i18n/*.feature")
    |> Path.wildcard()
    |> Enum.each(fn path ->
      file =
        path
        |> String.split()
        |> List.last()

      test "#{file}" do
        expected = File.read!("#{unquote(path)}.tokens")
        result = tokenize_from_path(unquote(path))

        if expected != result do
          IO.inspect(unquote(path), label: :failed, syntax_colors: [string: :red])
        end

        assert expected == result
      end
    end)
  end

  describe "#tokenize handles full feature files" do
    __DIR__
    |> Path.join("support/testdata/full_features/*.feature")
    |> Path.wildcard()
    |> Enum.each(fn path ->
      file =
        path
        |> String.split()
        |> List.last()

      test "#{file}" do
        expected = File.read!("#{unquote(path)}.tokens")
        result = tokenize_from_path(unquote(path))

        if expected != result do
          IO.inspect(unquote(path), label: :failed, syntax_colors: [string: :red])
        end

        assert expected == result
      end
    end)
  end
end

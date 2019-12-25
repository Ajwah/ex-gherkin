defmodule ParserTest do
  @moduledoc false
  use ExUnit.Case

  alias ExGherkin.{
    Parser.SyntaxError
  }

  # defmacro assert_specific_raise(exception, error_code, function) do
  #   quote do
  #     unquote(function).() |> IO.inspect
  #   end
  # end

  defmacro assert_specific_raise(exception, error_code, function) do
    quote do
      try do
        unquote(function).()
      rescue
        raised_error in [unquote(exception)] ->
          assert raised_error.error_code == unquote(error_code)

        error ->
          raise error
      else
        _ -> flunk("Expected exception #{inspect(unquote(exception))} but nothing was raised")
      end
    end
  end

  defp remove_null_vals(json_str) do
    ~r/,\s*"[^"]+":null|"[^"]+":null,?/
    |> Regex.replace(json_str, "")
  end

  # defp remove_null_vals(json_str) do
  #   System.cmd("jq", [
  #     "-n",
  #     "'#{json_str}| with_entries( select( .value != null ) )'"
  #   ])
  # end

  def parse(path: path) do
    [path: path]
    |> ExGherkin.prepare()
    |> ExGherkin.run()
    |> ParserSupport.to_ast_standard(path)
    |> Jason.encode!()
    # |> IO.inspect(label: :json_str)
    |> remove_null_vals
    |> Jason.decode!()
  end

  def parse(feature) do
    feature
    |> ExGherkin.prepare()
    |> ExGherkin.run()
    |> ParserSupport.to_ast_standard("")
    |> Jason.encode!()
    # |> IO.inspect(label: :json_str)
    |> remove_null_vals
    |> Jason.decode!()
  end

  describe "#run handles syntax errors gracefully\n      " do
    test "There can be only one feature" do
      assert_specific_raise(SyntaxError, :multiple_feature_tokens, fn ->
        """
        Feature: Some feature
        Feature: Other feature
        """
        |> parse
      end)
    end

    test "There can be only one language-token" do
      assert_specific_raise(SyntaxError, :multiple_language_tokens, fn ->
        """
        #language: fr
        #language: en
        Feature: Some feature
        """
        |> parse
      end)
    end

    test "language-token to appear at top" do
      assert_specific_raise(SyntaxError, :unparsable_language_token, fn ->
        """
        Feature: Some feature
        #language: fr
        """
        |> parse
      end)
    end

    test "language-token not to be tagged" do
      assert_specific_raise(SyntaxError, :tagged_language_token, fn ->
        """
        @some_meaningless_tag
        #language: en
        Feature: Some feature
        """
        |> parse
      end)
    end

    test "language-token not to be commented" do
      assert_specific_raise(SyntaxError, :commented_language_token, fn ->
        """
        # some useless comment
        #language:en
        Feature: Explicit language specification
        """
        |> parse
      end)
    end

    test "Required presence `Feature`-token" do
      assert_specific_raise(SyntaxError, :missing_feature_token, fn ->
        """
        #language:en
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:given`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:given` shall not be tagged
          Scenario:
            @invalid_tag
            Given a step that is attempted to be tagged
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:when`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:when` shall not be tagged
          Scenario:
            @invalid_tag
            When a step that is attempted to be tagged
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:then`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:then` shall not be tagged
          Scenario:
            @invalid_tag
            Then a step that is attempted to be tagged
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:and`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:and` shall not be tagged
          Scenario:
            @invalid_tag
            And a step that is attempted to be tagged
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:but`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:but` shall not be tagged
          Scenario:
            @invalid_tag
            But a step that is attempted to be tagged
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:content`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:content` shall not be tagged
          @invalid_tag
          This is some description upon which a tag is attempted to be applied
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:doc_string`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:doc_string` shall not be tagged
          Scenario:
            Given a doc_string with a tag
            @invalid_tag
            ```
            some doc_string upon which a tag is attempted to be applied
            ```
        """
        |> parse
      end)
    end

    test "Untaggable Token: `:data_table`" do
      assert_specific_raise(SyntaxError, :untaggable_token, fn ->
        """
        Feature: `:data_table` shall not be tagged
          Scenario:
            Given a data_table with a tag
            @invalid_tag
            | x |
            | y |
        """
        |> parse
      end)
    end

    test "Unexpected EOF when tagging" do
      assert_specific_raise(SyntaxError, :tagged_eof, fn ->
        """
        Feature: @tag appearing at bottom
          Scenario:
            Given a data_table with a tag
            | x |
            | y |
            @tag
        """
        |> parse
      end)
    end
  end

  describe "#run works for all Good Feature Files" do
    __DIR__
    |> Path.join("support/testdata/full_features/*.feature")
    |> Path.wildcard()
    |> Enum.each(fn path ->
      file =
        path
        |> String.split()
        |> List.last()

      test "#{file}" do
        expected =
          "#{unquote(path)}.ast.ndjson"
          |> File.read!()
          |> String.replace(~r/"id":"(\d*)"/, "\"id\":\"0\"")
          |> Jason.decode!()

        result =
          [path: unquote(path)]
          |> parse()

        assert expected == result
      end
    end)
  end

  describe "#run parses tokens from scanner" do
    test "blah" do
      """
      @a
      Feature: Some Feature Heading
        This constitutes a description of the feature at hand.
        It spans multiple lines.

        It also has empty lines


        @b @c
        Scenario Outline:
          Given <x>
          Given 1
          Given 2
          Given 3
          Given 4

          When <x>
          When 1
          When 2
          When 3
          When 4

          And <x>
          And 1
          And 2
          And 3
          And 4

          Then <x>
          Then 1
          Then 2
          Then 3
          Then 4

          But <x>
          But 1
          But 2
          But 3
          But 4

          @f
          Examples: A
            | x |
            | x1 |
            | y1 |

          @ff
          Examples: B
            | x |
            | x2 |
            | y2 |

          @fff
          Examples: C
            | x |
            | x3 |
            | y3 |

          @examples_tag1
          # Examples without a DataTable
          Examples:

          @ffff
          Examples: D
            | x |
            | x4 |
            | y4 |

        @d @e
        Scenario Outline:
          Given <m>

          @f
          Examples: E
            | m |
            | n |
      """
      |> parse()
    end
  end
end

defmodule ExGherkin.Utils do
  @moduledoc false
  @debug Application.get_env(:ex_gherkin, :debug, %{})

  def introspect(content, sth = :format_message) do
    if @debug[sth] do
      IO.puts(:stderr, content)
      content
    else
      content
    end
  end

  def introspect(content, sth) do
    if @debug[sth] do
      content
      |> IO.inspect(
        pretty: true,
        limit: :infinity,
        width: 120,
        binaries: :as_strings,
        printable_limit: :infinity,
        label: sth
      )
    else
      content
    end
  end
end

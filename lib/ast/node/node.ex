defmodule ExGherkin.Ast.Node do
  @moduledoc """

  Two types of tokens:
    SingleValueToken: {token, meta, value}
    MultipleValueToken: {token, meta, constituents}
                                        -> {:constituents, []}

  meta:
    {:meta, {location, token_label, language}, type}
    {:meta, {location, token_label}, type}
    {:meta, {:none, :none}, type}

  location: {
      :location, { {:line, 11}, {:column, 1} }
    }

  token_label: {:token_label, "#"}

  language: SingleValueToken
  """

  # def process({token, {:meta, {location, token_label, language}, type}, {:constituents, constituents}})
end

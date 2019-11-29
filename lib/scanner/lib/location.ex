defmodule Gherkin.Scanner.Location do
  @moduledoc """
  Keeps track of token position within file
  """
  import Record
  defrecord(:location, line: 1, column: 1)

  @type t() :: record(:location, line: integer(), column: integer())
end

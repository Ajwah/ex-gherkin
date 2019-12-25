defmodule ExGherkin.AstNdjson.Util do
  @moduledoc false

  def normalize(""), do: nil
  def normalize([]), do: nil
  def normalize(a), do: a
end

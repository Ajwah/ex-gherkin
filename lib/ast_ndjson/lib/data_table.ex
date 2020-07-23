defmodule ExGherkin.AstNdjson.DataTable do
  @moduledoc false

  @derive Jason.Encoder

  defstruct header: %{},
            body: %{}

  def new(header, body) do
    struct(__MODULE__, %{
      header: header,
      body: body
    })
  end
end

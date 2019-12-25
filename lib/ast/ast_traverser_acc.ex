defmodule ExGherkin.AstTraverser.Acc do
  @moduledoc false
  import Record

  defrecord :storage, ctx: [], global: :empty, local: :empty

  @type t() :: record(:storage, ctx: any, global: any, local: any)

  def new, do: storage(ctx: [], global: %{}, local: %{})
  def initial_value(acc = storage(), local_acc), do: set_local(acc, local_acc)

  def initial_value(acc = storage(), local_acc, new_ctx),
    do:
      storage(
        ctx: [new_ctx | storage(acc, :ctx)],
        global: storage(acc, :global),
        local: local_acc
      )

  def local(rec = storage()), do: storage(rec, :local)
  def global(rec = storage()), do: storage(rec, :global)
  def ctx(rec = storage()), do: storage(rec, :ctx)

  def set_local(rec = storage(), new_local), do: storage(rec, local: new_local)
  def set_global(rec = storage(), new_global), do: storage(rec, global: new_global)

  def set_ctx(rec = storage(), new_ctx), do: storage(rec, ctx: new_ctx)
  def push_ctx(rec = storage(), new_ctx), do: storage(rec, ctx: [new_ctx | storage(rec, :ctx)])

  def pop_ctx(rec = storage()) do
    new_ctx =
      rec
      |> storage(:ctx)
      |> case do
        [] -> []
        [_ | tl] -> tl
      end

    storage(rec, ctx: new_ctx)
  end

  def peek_ctx(rec = storage()) do
    rec
    |> storage(:ctx)
    |> case do
      [] -> :none
      [hd | _] -> hd
    end
  end
end

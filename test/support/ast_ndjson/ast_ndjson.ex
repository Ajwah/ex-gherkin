defmodule ExGherkin.AstNdjson do
  @moduledoc false
  defmodule Reducer do
    use ExGherkin.AstTraverser.ReducerTemplate

    alias ExGherkin.AstNdjson.{
      Background,
      Comment,
      DataTable,
      DocString,
      Examples,
      Feature,
      Location,
      Rule,
      Scenario,
      Step,
      Tag
    }

    alias DataTable.Row, as: DataTableRow
    alias DataTableRow.Cell, as: DataTableRowCell

    def feature_constituents_reconcile(
          {title, ctx, tags, description, background, scenario_blocks, rule_blocks},
          acc = Acc.storage()
        ) do
      {
        raw_location,
        keyword,
        {
          _,
          _,
          language
        }
      } = ctx

      global_acc =
        title
        |> Feature.new(description, keyword, language, tags, Location.new(raw_location))
        |> Feature.add_child(background)
        |> Feature.add_child(scenario_blocks)
        |> Feature.add_child(rule_blocks)
        |> Feature.normalize()

      Acc.set_global(acc, global_acc)
    end

    def background_constituents_reconcile(
          {title, ctx, description, steps},
          acc = Acc.storage()
        ) do
      {raw_location, keyword} = ctx

      local_acc =
        title
        |> Background.new(description, keyword, Location.new(raw_location), steps)

      Acc.set_local(acc, [local_acc])
    end

    def rule_constituents_reconcile(
          {title, ctx, description, background, scenario_blocks},
          acc = Acc.storage()
        ) do
      {raw_location, keyword} = ctx

      local_acc =
        title
        |> Rule.new(description, keyword, Location.new(raw_location))
        |> Rule.add_child(background)
        |> Rule.add_child(scenario_blocks)
        |> Rule.normalize()

      Acc.set_local(acc, [local_acc | Acc.local(acc)])
    end

    def step_constituents_reconcile({ctx, text, step_arg}, acc = Acc.storage()) do
      {raw_location, keyword} = ctx

      local_acc =
        text
        |> Step.new(keyword, Location.new(raw_location))
        |> Step.arg(step_arg)

      Acc.set_local(acc, [local_acc | Acc.local(acc)])
    end

    def scenario_blocks_initial_value, do: []

    def scenario_blocks_reconcile(acc = Acc.storage()),
      do: Acc.set_local(acc, Enum.reverse(Acc.local(acc)))

    def scenario_reconcile(acc = Acc.storage(), _scenario_blocks_so_far) do
      scenario_block = Acc.local(acc)
      Acc.set_local(acc, scenario_block)
    end

    def scenario_outline_reconcile(acc = Acc.storage(), scenario_blocks_so_far),
      do: scenario_reconcile(acc, scenario_blocks_so_far)

    def scenario_constituents_reconcile(
          {title, ctx, tags, description, steps, examples},
          acc = Acc.storage()
        ) do
      {raw_location, keyword} = ctx

      local_acc =
        title
        |> Scenario.new(description, keyword, Location.new(raw_location), tags, steps, examples)

      Acc.set_local(acc, [local_acc | Acc.local(acc)])
    end

    def examples_blocks_initial_value, do: []

    def examples_blocks_reconcile(acc = Acc.storage()),
      do: Acc.set_local(acc, Enum.reverse(Acc.local(acc)))

    def examples_constituents_ctx(acc = Acc.storage()),
      do: Acc.set_local(acc, acc |> Acc.peek_ctx() |> elem(1))

    def examples_constituents_reconcile(
          {title, ctx, tags, description, data_table},
          acc = Acc.storage()
        ) do
      {raw_location, keyword} = ctx

      local_acc =
        title
        |> Examples.new(description, keyword, tags, Location.new(raw_location), data_table)

      Acc.set_local(acc, [local_acc | Acc.local(acc)])
    end

    def steps_initial_value, do: []
    def steps_reconcile(acc = Acc.storage()), do: Acc.set_local(acc, Enum.reverse(Acc.local(acc)))

    def step_constituents_ctx(acc = Acc.storage()),
      do: Acc.set_local(acc, acc |> Acc.peek_ctx() |> elem(1))

    def title_apply({_token, _meta, value}, acc = Acc.storage()), do: Acc.set_local(acc, value)
    def title_reconcile(acc = Acc.storage()), do: acc

    def step_text_apply({_token, _meta, value}, acc = Acc.storage()),
      do: Acc.set_local(acc, value)

    def step_text_reconcile(acc = Acc.storage()), do: acc

    def rule_blocks_initial_value, do: []

    def rule_blocks_reconcile(acc = Acc.storage()),
      do: Acc.set_local(acc, Enum.reverse(Acc.local(acc)))

    def data_table_initial_value, do: []

    def data_table_reconcile(acc = Acc.storage()) do
      acc
      |> Acc.local()
      |> case do
        {data_table, []} -> Acc.set_local(acc, Enum.reverse(data_table))
        [] -> acc
      end
    end

    def data_table_cells_initial_value(data_table_acc) when is_list(data_table_acc),
      do: {data_table_acc, []}

    def data_table_cells_initial_value(acc = {_, _}), do: acc

    def data_table_cells_initial_value(data_table_acc = Acc.storage()),
      do: Acc.local(data_table_acc)

    def data_table_cells_apply({_token, ctx, value}, acc = Acc.storage()) do
      {data_table_acc, data_table_cells} = Acc.local(acc)
      {raw_location, _} = ctx

      Acc.set_local(
        acc,
        {data_table_acc,
         [DataTableRowCell.new(value, Location.new(raw_location)) | data_table_cells]}
      )
    end

    def data_table_cells_reconcile(acc = Acc.storage()) do
      {data_table_acc, data_table_cells} = Acc.local(acc)
      {:data_table_row, row_meta} = Acc.peek_ctx(acc)
      {raw_location, _} = row_meta

      new_row =
        data_table_cells
        |> Enum.reverse()
        |> DataTableRow.new(Location.new(raw_location))

      Acc.set_local(acc, {
        [new_row | data_table_acc],
        []
      })
    end

    def description_block_initial_value, do: :none

    def description_block_apply(
          {_token, {{line, column}, _token_label}, description_text},
          acc = Acc.storage()
        ) do
      acc
      |> Acc.local()
      |> case do
        :none ->
          Acc.set_local(acc, {String.duplicate(" ", column - 1) <> description_text, line})

        {line_so_far, prev_line} ->
          empty_new_lines = prev_line..(line - 1) |> Enum.reduce("", fn _, a -> a <> "\n" end)

          Acc.set_local(
            acc,
            {line_so_far <>
               empty_new_lines <> String.duplicate(" ", column - 1) <> description_text, line}
          )
      end
    end

    def description_block_initial_reconcile(acc = Acc.storage()) do
      description =
        acc
        |> Acc.local()
        |> case do
          :none -> ""
          {line_so_far, _} -> line_so_far
        end

      Acc.set_local(acc, description)
    end

    def tags_initial_value, do: []

    def tags_apply({_token, meta, tag_value}, acc = Acc.storage()) do
      {raw_location, _} = meta
      tag = Tag.new(tag_value, Location.new(raw_location))
      Acc.set_local(acc, [tag | Acc.local(acc)])
    end

    def tags_initial_reconcile(acc = Acc.storage()),
      do: Acc.set_local(acc, Enum.reverse(Acc.local(acc)))

    def doc_string_delimiter_tag_apply({_token, _meta, :plain}, acc = Acc.storage()),
      do: Acc.set_local(acc, nil)

    def doc_string_delimiter_tag_apply({_token, _meta, value}, acc = Acc.storage()),
      do: Acc.set_local(acc, value)

    def doc_string_delimiter_tag_reconcile(acc = Acc.storage()), do: acc

    def doc_string_constituents_ctx(acc = Acc.storage()),
      do: Acc.set_local(acc, acc |> Acc.peek_ctx() |> elem(1))

    def doc_string_constituents_reconcile({ctx, content_type, content}, acc = Acc.storage()) do
      {raw_location, delimiter} = ctx

      local_acc =
        content
        |> DocString.new(content_type, delimiter, Location.new(raw_location))

      Acc.set_local(acc, local_acc)
    end

    def doc_string_contents_initial_value, do: :initial_value

    def doc_string_contents_initial_reconcile(acc = Acc.storage()) do
      contents =
        acc
        |> Acc.local()
        |> case do
          :none -> ""
          {line_so_far, _} -> line_so_far
        end

      Acc.set_local(acc, contents)
    end

    def doc_string_contents_apply(
          {_token, {{line, _}, _token_label}, content},
          acc = Acc.storage()
        ) do
      acc
      |> Acc.local()
      |> case do
        :initial_value ->
          Acc.set_local(acc, {content, line})

        {line_so_far, prev_line} ->
          empty_new_lines = prev_line..(line - 1) |> Enum.reduce("", fn _, a -> a <> "\n" end)
          Acc.set_local(acc, {line_so_far <> empty_new_lines <> content, line})
      end
    end

    def comments_initial_value, do: []

    def comments_initial_reconcile(acc = Acc.storage()),
      do: Acc.set_local(acc, Enum.reverse(Acc.local(acc)))

    def comments_apply({_token, ctx, value}, acc = Acc.storage()) do
      {raw_location, _} = ctx

      local_acc = Comment.new(value, Location.new(raw_location))

      Acc.set_local(acc, [local_acc | Acc.local(acc)])
    end
  end

  use ExGherkin.AstTraverser, Reducer
end

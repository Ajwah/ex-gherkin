defmodule ExGherkin.AstTraverser do
  @moduledoc false
  defmacro __using__(reducer) do
    quote location: :keep do
      alias ExGherkin.AstTraverser.Acc
      require Acc
      @reducer unquote(reducer).all()
      @step_constituents_initial_value []
      @background_constituents_initial_value :empty

      def run(full_token), do: run(full_token, Acc.new())

      def run(full_token = {:feature, _, _}, acc = Acc.storage()),
        do: feature_constituents(full_token, acc) |> Acc.global()

      def run(full_token = {:comments, _, _}, acc = Acc.storage()),
        do: comments(full_token, acc) |> Acc.local()

      def feature_constituents(
            {:feature, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        [
          tags = {:tags, _, _},
          title = {:title, _, _},
          description_block = {:description_block, _, _},
          background = {:background, _, _},
          scenario_blocks = {:scenario_blocks, _, _},
          rule_blocks = {:rule_blocks, _, _}
        ] = constituents

        feature_constituents_so_far = Acc.local(acc)

        ctx = meta(meta)
        acc = acc_title = title(title, Acc.push_ctx(acc, {:feature, ctx}))
        acc = acc_tags = tags(tags, acc)
        acc = acc_description_block = description_block(description_block, acc)

        acc =
          acc_background =
          background_constituents(
            background,
            Acc.set_local(acc, @background_constituents_initial_value)
          )

        acc = acc_scenario_blocks = scenario_blocks(scenario_blocks, acc)
        acc = acc_rule_blocks = rule_blocks(rule_blocks, acc)

        {Acc.local(acc_title), ctx, Acc.local(acc_tags), Acc.local(acc_description_block),
         Acc.local(acc_background), Acc.local(acc_scenario_blocks), Acc.local(acc_rule_blocks)}
        |> @reducer.feature_constituents.reconcile.(
          Acc.set_local(acc, feature_constituents_so_far)
        )
      end

      def background_constituents(
            {:background, {:meta, meta, {:type, :multiples}}, {:constituents, []}},
            acc = Acc.storage()
          ),
          do: acc

      def background_constituents(
            {:background, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        [
          title = {:title, _, _},
          description_block = {:description_block, _, _},
          steps = {:steps, _, _}
        ] = constituents

        background_constituents_so_far = Acc.local(acc)

        ctx = meta(meta)
        acc = acc_title = title(title, Acc.push_ctx(acc, {:background, ctx}))
        acc = acc_description_block = description_block(description_block, acc)
        acc = acc_steps = steps(steps, Acc.set_local(acc, @step_constituents_initial_value))

        {Acc.local(acc_title), ctx, Acc.local(acc_description_block), Acc.local(acc_steps)}
        |> @reducer.background_constituents.reconcile.(
          Acc.set_local(acc, background_constituents_so_far)
        )
        |> Acc.pop_ctx()
      end

      def scenario_constituents(
            [
              tags = {:tags, _, _},
              title = {:title, _, _},
              description_block = {:description_block, _, _},
              steps = {:steps, _, _},
              examples_blocks = {:examples_blocks, _, _}
            ],
            acc = Acc.storage()
          ) do
        scenario_constituents_so_far = Acc.local(acc)

        {_, ctx} = Acc.peek_ctx(acc)

        acc = acc_title = title(title, acc)
        acc = acc_tags = tags(tags, acc)
        acc = acc_description_block = description_block(description_block, acc)
        acc = acc_steps = steps(steps, Acc.set_local(acc, @step_constituents_initial_value))
        acc = acc_examples_blocks = examples_blocks(examples_blocks, acc)

        {Acc.local(acc_title), ctx, Acc.local(acc_tags), Acc.local(acc_description_block),
         Acc.local(acc_steps), Acc.local(acc_examples_blocks)}
        |> @reducer.scenario_constituents.reconcile.(
          Acc.set_local(acc, scenario_constituents_so_far)
        )
      end

      def rule_constituents(
            [
              title = {:title, _, _},
              description_block = {:description_block, _, _},
              background = {:background, _, _},
              scenario_blocks = {:scenario_blocks, _, _}
            ],
            acc = Acc.storage()
          ) do
        rule_constituents_so_far = Acc.local(acc)

        {:rule_blocks, ctx} = Acc.peek_ctx(acc)

        acc = acc_title = title(title, acc)
        acc = acc_description_block = description_block(description_block, acc)

        acc =
          acc_background =
          background_constituents(
            background,
            Acc.set_local(acc, @background_constituents_initial_value)
          )

        acc = acc_scenario_blocks = scenario_blocks(scenario_blocks, acc)

        {Acc.local(acc_title), ctx, Acc.local(acc_description_block), Acc.local(acc_background),
         Acc.local(acc_scenario_blocks)}
        |> @reducer.rule_constituents.reconcile.(Acc.set_local(acc, rule_constituents_so_far))
      end

      def examples_constituents(
            {:examples, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        [
          tags = {:tags, _, _},
          # title = {:title, _, _},
          description_block = {:description_block, _, _},
          data_table = {:data_table, _, _}
        ] = constituents

        examples_constituents_so_far = Acc.local(acc)

        acc =
          acc_ctx =
          @reducer.examples_constituents.ctx.(Acc.push_ctx(acc, {:examples, meta(meta)}))

        # acc = acc_title = title(title, acc)
        acc = acc_tags = tags(tags, acc)
        acc = acc_description_block = description_block(description_block, acc)
        acc = acc_data_table = data_table(data_table, acc)

        {"", Acc.local(acc_ctx), Acc.local(acc_tags), Acc.local(acc_description_block),
         Acc.local(acc_data_table)}
        |> @reducer.examples_constituents.reconcile.(
          Acc.set_local(acc, examples_constituents_so_far)
        )
        |> Acc.pop_ctx()
      end

      def step_constituents(
            {step_token, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        [
          step_text = {:text, _, _},
          {:arg, {:meta, {:none, :none}, {:type, :singular}}, step_arg}
        ] = constituents

        step_constituents_constituents_so_far = Acc.local(acc)

        acc =
          acc_ctx = @reducer.step_constituents.ctx.(Acc.push_ctx(acc, {step_token, meta(meta)}))

        acc = acc_step_text = step_text(step_text, acc)

        {acc, acc_step_arg} =
          if step_arg == :none do
            {acc, :none}
          else
            r = step_arg(step_arg, acc)
            {r, Acc.local(r)}
          end

        {Acc.local(acc_ctx), Acc.local(acc_step_text), acc_step_arg}
        |> @reducer.step_constituents.reconcile.(
          Acc.set_local(acc, step_constituents_constituents_so_far)
        )
        |> Acc.pop_ctx()
      end

      def doc_string_constituents(
            {:doc_string, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        [
          delimiter_tag = {:delim, _, _},
          contents = {:contents, {:meta, {:none, :none}, {:type, :multiples}}, {:constituents, _}}
        ] = constituents

        acc =
          acc_ctx =
          @reducer.doc_string_constituents.ctx.(Acc.push_ctx(acc, {:doc_string, meta(meta)}))

        acc = acc_delimiter_tag = delimiter_tag(delimiter_tag, acc)

        acc = acc_doc_string_contents = doc_string_contents(contents, acc)

        {Acc.local(acc_ctx), Acc.local(acc_delimiter_tag), Acc.local(acc_doc_string_contents)}
        |> @reducer.doc_string_constituents.reconcile.(acc)
        |> Acc.pop_ctx()
      end

      def comments(full_token = {:comments, _, _}, acc = Acc.storage()),
        do: text_node(full_token, acc, @reducer.comments)

      def tags(full_token = {:tags, _, _}, acc = Acc.storage()),
        do: text_node(full_token, acc, @reducer.tags)

      def description_block(full_token = {:description_block, _, _}, acc = Acc.storage()),
        do: text_node(full_token, acc, @reducer.description_block)

      def doc_string_contents(full_token = {:contents, _, _}, acc = Acc.storage()),
        do: text_node(full_token, acc, @reducer.doc_string_contents)

      def steps(full_token = {:steps, _, _}, acc = Acc.storage()),
        do: node(full_token, acc, @reducer.steps, &step_constituents/2)

      def scenario_blocks(full_token = {:scenario_blocks, _, _}, acc = Acc.storage()),
        do: node(full_token, acc, @reducer.scenario_blocks, &handle_scenario/2)

      def examples_blocks(full_token = {:examples_blocks, _, _}, acc = Acc.storage()),
        do: node(full_token, acc, @reducer.examples_blocks, &examples_constituents/2)

      def data_table(full_token = {:data_table, _, _}, acc = Acc.storage()),
        do: node(full_token, acc, @reducer.data_table, &data_table_cells/2)

      def rule_blocks(full_token = {:rule_blocks, _, _}, acc = Acc.storage()),
        do: node(full_token, acc, @reducer.rule_blocks, &rule_blocks_helper/2)

      def step_arg(doc_string = {:doc_string, _, _}, acc),
        do: doc_string_constituents(doc_string, acc)

      def step_arg(data_table = {:data_table, _, _}, acc),
        do: data_table(data_table, acc)

      def handle_scenario(
            {:scenario, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        scenario_blocks_so_far = Acc.local(acc)

        constituents
        |> scenario_constituents(Acc.push_ctx(acc, {:scenario, meta(meta)}))
        |> @reducer.scenario.reconcile.(scenario_blocks_so_far)
        |> Acc.pop_ctx()
      end

      def handle_scenario(
            {:scenario_outline, {:meta, meta, {:type, :multiples}},
             {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        scenario_blocks_so_far = Acc.local(acc)

        constituents
        |> scenario_constituents(Acc.push_ctx(acc, {:scenario_outline, meta(meta)}))
        |> @reducer.scenario_outline.reconcile.(scenario_blocks_so_far)
        |> Acc.pop_ctx()
      end

      def data_table_cells(
            {:data_table_row, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        meta = meta(meta)

        constituents
        |> Enum.reduce(
          Acc.initial_value(
            acc,
            @reducer.data_table_cells.initial_value.(Acc.local(acc)),
            {:data_table_row, meta}
          ),
          fn full_token, acc ->
            :data_table_cell
            |> component(meta(full_token), text_value(full_token))
            |> @reducer.data_table_cells.apply.(acc)
          end
        )
        |> @reducer.data_table_cells.reconcile.()
      end

      def rule_blocks_helper(
            {:rule, {:meta, meta, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage()
          ) do
        constituents
        |> rule_constituents(Acc.push_ctx(acc, {:rule_blocks, meta(meta)}))
        |> Acc.pop_ctx()
      end

      def delimiter_tag(
            {:delim, {:meta, {:none, :none}, {:type, :singular}}, delimiter_tag},
            acc = Acc.storage()
          ) do
        :delimiter_tag
        |> component(:none, delimiter_tag)
        |> @reducer.doc_string_delimiter_tag.apply.(acc)
        |> @reducer.doc_string_delimiter_tag.reconcile.()
      end

      def step_text(
            {:text, {:meta, {:none, :none}, {:type, :singular}}, step_text},
            acc = Acc.storage()
          ) do
        :step_text
        |> component(:none, step_text)
        |> @reducer.step_text.apply.(acc)
        |> @reducer.step_text.reconcile.()
      end

      def title(
            {:title, {:meta, {:none, :none}, {:type, :singular}}, title},
            acc = Acc.storage()
          ) do
        :title
        |> component(:none, title)
        |> @reducer.title.apply.(acc)
        |> @reducer.title.reconcile.()
      end

      @spec node(any, Acc.t(), map, function) :: Acc.t()
      def node(
            {_token, {:meta, {:none, :none}, {:type, :multiples}}, {:constituents, constituents}},
            acc = Acc.storage(),
            specific_reducers,
            helper
          )
          when is_function(helper) do
        constituents
        |> Enum.reduce(Acc.initial_value(acc, specific_reducers.initial_value.()), fn full_token,
                                                                                      acc ->
          if is_function(helper, 2) do
            helper.(full_token, acc)
          else
            helper.(full_token, acc, specific_reducers)
          end
        end)
        |> specific_reducers.reconcile.()
      end

      def text_node(full_token = {_, _, _}, acc = Acc.storage(), specific_reducers),
        do: node(full_token, acc, specific_reducers, &text_node_helper/3)

      def text_node_helper(full_token, acc, specific_reducers),
        do: specific_reducers.apply.(component(full_token), acc)

      def component(token, meta, value), do: {token, meta, value}
      def component(full_token), do: {token(full_token), meta(full_token), text_value(full_token)}

      def meta({location, token_label}) do
        {raw_location(location), token_label(token_label)}
      end

      def meta({_, {:meta, relevant_meta, {:type, _}}, _}), do: meta(relevant_meta)

      def meta({location, token_label, language}) do
        {language_location, language_token_label} = meta(language)

        {raw_location(location), token_label(token_label),
         {language_location, language_token_label, text_value!(language)}}
      end

      def raw_location(:none), do: :none
      def raw_location({:location, {{:line, line}, {:column, column}}}), do: {line, column}

      def raw_location({_, {:meta, {location = {:location, {_, _}}, _}, _}, _}),
        do: raw_location(location)

      def raw_location({_, {:meta, {:none, :none}, _}, _}), do: raw_location(:none)

      def raw_location!(:none) do
        raise "No location to retrieve"
        {0, 0}
      end

      def raw_location!(full_token), do: raw_location(full_token)
      def token_label(:none), do: :none
      def token_label({:token_label, token_label}), do: token_label

      def token({token, {:meta, _, _}, _}), do: token
      def value({_, {:meta, _, _}, value}), do: value
      def text_value({_, {:meta, _, _}, value}) when is_binary(value), do: value
      def text_value!({_, {:meta, _, _}, value}) when is_binary(value), do: value
      def text_value!({_, {:meta, _, _}, value}) when is_atom(value), do: to_string(value)
    end
  end
end

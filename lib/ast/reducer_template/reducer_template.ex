defmodule ExGherkin.AstTraverser.ReducerTemplate do
  @moduledoc false
  defmodule Behaviour do
    @moduledoc false

    alias ExGherkin.AstTraverser.Acc

    @callback feature_constituents_reconcile(
                {title :: any, ctx :: any, tags :: any, description_block :: any,
                 background :: any, scenario_blocks :: any, rule_blocks :: any},
                Acc.t()
              ) :: Acc.t()

    @callback background_constituents_reconcile(
                {title :: any, ctx :: any, description_block :: any, steps :: any},
                Acc.t()
              ) :: Acc.t()

    @callback scenario_constituents_reconcile(
                {title :: any, ctx :: any, tags :: any, description_block :: any, steps :: any,
                 examples_blocks :: any},
                Acc.t()
              ) :: Acc.t()

    @callback rule_constituents_reconcile(
                {title :: any, ctx :: any, description_block :: any, background :: any,
                 scenario_blocks :: any},
                Acc.t()
              ) :: Acc.t()

    @callback examples_constituents_reconcile(
                {title :: any, ctx :: any, tags :: any, description_block :: any,
                 data_table :: any},
                Acc.t()
              ) :: Acc.t()

    @callback step_constituents_reconcile(
                {ctx :: any, step_text :: any, step_arg :: any},
                Acc.t()
              ) :: Acc.t()
    @callback doc_string_constituents_reconcile(
                {ctx :: any, delimiter_tag :: any, doc_string_contents :: any},
                Acc.t()
              ) :: Acc.t()

    @callback examples_constituents_ctx(Acc.t()) :: Acc.t()
    @callback step_constituents_ctx(Acc.t()) :: Acc.t()
    @callback doc_string_constituents_ctx(Acc.t()) :: Acc.t()

    @callback scenario_reconcile(Acc.t(), any) :: Acc.t()
    @callback scenario_outline_reconcile(Acc.t(), any) :: Acc.t()
    @callback title_apply({token :: any, meta :: any, value :: any}, Acc.t()) :: Acc.t()
    @callback title_reconcile(Acc.t()) :: Acc.t()
    @callback step_text_apply({token :: any, meta :: any, value :: any}, Acc.t()) :: Acc.t()
    @callback step_text_reconcile(Acc.t()) :: Acc.t()
    @callback doc_string_delimiter_tag_apply({token :: any, meta :: any, value :: any}, Acc.t()) ::
                Acc.t()
    @callback doc_string_delimiter_tag_reconcile(Acc.t()) :: Acc.t()
    @callback steps_initial_value :: any
    @callback steps_reconcile(Acc.t()) :: Acc.t()
    @callback rule_blocks_initial_value :: any
    @callback rule_blocks_reconcile(Acc.t()) :: Acc.t()
    @callback scenario_blocks_initial_value :: any
    @callback scenario_blocks_reconcile(Acc.t()) :: Acc.t()
    @callback examples_blocks_initial_value :: any
    @callback examples_blocks_reconcile(Acc.t()) :: Acc.t()
    @callback data_table_initial_value :: any
    @callback data_table_reconcile(Acc.t()) :: Acc.t()
    @callback data_table_cells_apply({token :: any, meta :: any, value :: any}, Acc.t()) ::
                Acc.t()
    @callback data_table_cells_initial_value(any) :: any
    @callback data_table_cells_reconcile(Acc.t()) :: Acc.t()
    @callback tags_apply({token :: any, meta :: any, value :: any}, Acc.t()) :: Acc.t()
    @callback comments_apply({token :: any, meta :: any, value :: any}, Acc.t()) :: Acc.t()
    @callback description_block_apply({token :: any, meta :: any, value :: any}, Acc.t()) ::
                Acc.t()
    @callback doc_string_contents_apply({token :: any, meta :: any, value :: any}, Acc.t()) ::
                Acc.t()

    @callback tags_initial_value :: any
    @callback comments_initial_value :: any
    @callback description_block_initial_value :: any
    @callback doc_string_contents_initial_value :: any

    @callback tags_initial_reconcile(Acc.t()) :: Acc.t()
    @callback comments_initial_reconcile(Acc.t()) :: Acc.t()
    @callback description_block_initial_reconcile(Acc.t()) :: Acc.t()
    @callback doc_string_contents_initial_reconcile(Acc.t()) :: Acc.t()
  end

  defmacro __using__(_opts) do
    quote do
      alias ExGherkin.AstTraverser.Acc
      require Acc

      alias ExGherkin.AstTraverser.Reducer.Behaviour
      @behaviour Behaviour

      def feature_constituents_reconcile(
            {_title, _ctx, _tags, _description_block, _background, _scenario_blocks,
             _rule_blocks},
            acc = Acc.storage()
          ),
          do: acc

      def background_constituents_reconcile(
            {_title, _ctx, _description_block, _steps},
            acc = Acc.storage()
          ),
          do: acc

      def scenario_constituents_reconcile(
            {_title, _ctx, _tags, _description_block, _steps, _examples_blocks},
            acc = Acc.storage()
          ),
          do: acc

      def rule_constituents_reconcile(
            {_title, _ctx, _description_block, _background, _scenario_blocks},
            acc = Acc.storage()
          ),
          do: acc

      def examples_constituents_reconcile(
            {_ctx, _tags, _description_block, _data_table},
            acc = Acc.storage()
          ),
          do: acc

      def step_constituents_reconcile({_ctx, _step_text, _step_arg}, acc = Acc.storage()), do: acc

      def doc_string_constituents_reconcile(
            {_ctx, _delimiter_tag, _doc_string_contents},
            acc = Acc.storage()
          ),
          do: acc

      def scenario_reconcile(acc = Acc.storage(), _), do: acc
      def scenario_outline_reconcile(acc = Acc.storage(), _), do: acc

      def examples_constituents_ctx(acc = Acc.storage()), do: acc
      def step_constituents_ctx(acc = Acc.storage()), do: acc
      def doc_string_constituents_ctx(acc = Acc.storage()), do: acc

      def title_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc
      def title_reconcile(acc = Acc.storage()), do: acc
      def step_text_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc
      def step_text_reconcile(acc = Acc.storage()), do: acc
      def doc_string_delimiter_tag_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc
      def doc_string_delimiter_tag_reconcile(acc = Acc.storage()), do: acc

      def steps_initial_value, do: :initial_value_to_be_set
      def steps_reconcile(acc = Acc.storage()), do: acc

      def rule_blocks_initial_value, do: :initial_value_to_be_set
      def rule_blocks_reconcile(acc = Acc.storage()), do: acc

      def scenario_blocks_initial_value, do: :initial_value_to_be_set
      def scenario_blocks_reconcile(acc = Acc.storage()), do: acc

      def examples_blocks_initial_value, do: :initial_value_to_be_set
      def examples_blocks_reconcile(acc = Acc.storage()), do: acc

      def data_table_initial_value, do: :initial_value_to_be_set
      def data_table_reconcile(acc = Acc.storage()), do: acc

      def data_table_cells_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc
      def data_table_cells_initial_value(_), do: :initial_value_to_be_set
      def data_table_cells_reconcile(acc = Acc.storage()), do: acc

      def tags_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc
      def comments_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc
      def description_block_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc
      def doc_string_contents_apply({_token, _meta, _value}, acc = Acc.storage()), do: acc

      def tags_initial_value, do: :initial_value_to_be_set
      def comments_initial_value, do: :initial_value_to_be_set
      def description_block_initial_value, do: :initial_value_to_be_set
      def doc_string_contents_initial_value, do: :initial_value_to_be_set

      def tags_initial_reconcile(acc = Acc.storage()), do: acc
      def comments_initial_reconcile(acc = Acc.storage()), do: acc
      def description_block_initial_reconcile(acc = Acc.storage()), do: acc
      def doc_string_contents_initial_reconcile(acc = Acc.storage()), do: acc

      def all do
        %{
          feature_constituents: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.feature_constituents_reconcile/2
          },
          background_constituents: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.background_constituents_reconcile/2
          },
          scenario_constituents: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.scenario_constituents_reconcile/2
          },
          rule_constituents: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.rule_constituents_reconcile/2
          },
          examples_constituents: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.examples_constituents_reconcile/2,
            ctx: &__MODULE__.examples_constituents_ctx/1
          },
          step_constituents: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.step_constituents_reconcile/2,
            ctx: &__MODULE__.step_constituents_ctx/1
          },
          doc_string_constituents: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.doc_string_constituents_reconcile/2,
            ctx: &__MODULE__.doc_string_constituents_ctx/1
          },
          scenario: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.scenario_reconcile/2
          },
          scenario_outline: %{
            initial_value: false,
            apply: false,
            reconcile: &__MODULE__.scenario_outline_reconcile/2
          },
          title: %{
            initial_value: false,
            apply: &__MODULE__.title_apply/2,
            reconcile: &__MODULE__.title_reconcile/1
          },
          step_text: %{
            initial_value: false,
            apply: &__MODULE__.step_text_apply/2,
            reconcile: &__MODULE__.step_text_reconcile/1
          },
          doc_string_delimiter_tag: %{
            initial_value: false,
            apply: &__MODULE__.doc_string_delimiter_tag_apply/2,
            reconcile: &__MODULE__.doc_string_delimiter_tag_reconcile/1
          },
          steps: %{
            initial_value: &__MODULE__.steps_initial_value/0,
            apply: false,
            reconcile: &__MODULE__.steps_reconcile/1
          },
          rule_blocks: %{
            initial_value: &__MODULE__.rule_blocks_initial_value/0,
            apply: false,
            reconcile: &__MODULE__.rule_blocks_reconcile/1
          },
          scenario_blocks: %{
            initial_value: &__MODULE__.scenario_blocks_initial_value/0,
            apply: false,
            reconcile: &__MODULE__.scenario_blocks_reconcile/1
          },
          examples_blocks: %{
            initial_value: &__MODULE__.examples_blocks_initial_value/0,
            apply: false,
            reconcile: &__MODULE__.examples_blocks_reconcile/1
          },
          data_table: %{
            initial_value: &__MODULE__.data_table_initial_value/0,
            apply: false,
            reconcile: &__MODULE__.data_table_reconcile/1
          },
          data_table_cells: %{
            initial_value: &__MODULE__.data_table_cells_initial_value/1,
            apply: &__MODULE__.data_table_cells_apply/2,
            reconcile: &__MODULE__.data_table_cells_reconcile/1
          },
          tags: %{
            initial_value: &__MODULE__.tags_initial_value/0,
            apply: &__MODULE__.tags_apply/2,
            reconcile: &__MODULE__.tags_initial_reconcile/1
          },
          comments: %{
            initial_value: &__MODULE__.comments_initial_value/0,
            apply: &__MODULE__.comments_apply/2,
            reconcile: &__MODULE__.comments_initial_reconcile/1
          },
          description_block: %{
            initial_value: &__MODULE__.description_block_initial_value/0,
            apply: &__MODULE__.description_block_apply/2,
            reconcile: &__MODULE__.description_block_initial_reconcile/1
          },
          doc_string_contents: %{
            initial_value: &__MODULE__.doc_string_contents_initial_value/0,
            apply: &__MODULE__.doc_string_contents_apply/2,
            reconcile: &__MODULE__.doc_string_contents_initial_reconcile/1
          }
        }
      end

      defoverridable Behaviour
    end
  end
end

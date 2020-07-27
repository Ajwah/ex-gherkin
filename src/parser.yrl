Terminals
    language

    feature
    background
    scenario_outline
    rule
    scenario
    scenarios

    given
    'when'
    then
    but
    and
    doc_string
    data_table

    feature_tag
    background_tag
    scenario_outline_tag
    rule_tag
    scenario_tag
    scenarios_tag

    content
    .

Nonterminals
    i18n
    grammar
    invalids
    tagged_feature_block
    feature_block

    rule_blocks
    rule_block

    background_block

    tagged_scenario_block
    scenario_blocks
    scenario_block
    scenario_outline_block

    tagged_examples_blocks
    tagged_examples_block
    examples_block

    step_blocks
    step_block
    givens
    whens
    thens
    buts
    ands

    step_arg
    datatable_rows
    docstring
    contents

    feature_tags
    background_tags
    scenario_outline_tags
    rule_tags
    scenario_tags
    scenarios_tags
    .

Rootsymbol grammar.

% Endsymbol '$end'.
% Expect 3.

Left 100 given.
Right 200 givens.
Left 100 then.
Right 200 thens.
Left 100 and.
Right 200 ands.
Left 100 but.
Right 200 buts.
Left 100 'when'.
Right 200 whens.

% All Syntax Error Related
grammar -> invalids : [].

% invalids -> tag i18n : return_error('$1', 'tagged_language_token').
invalids -> language i18n : return_error('$2', 'multiple_language_tokens').
invalids -> background_tags : return_error('$1', 'tagged_background').
invalids -> rule_tags : return_error('$1', 'tagged_rule').
invalids -> i18n : return_error('$1', 'missing_feature_token').

% All Valid Related

% FEATURE
grammar -> i18n tagged_feature_block : set_language('$2', '$1').
grammar -> tagged_feature_block : '$1'.

tagged_feature_block -> feature_tags feature_block : set_tags_block('$2', '$1').
tagged_feature_block -> feature_block : '$1'.

% `feature_block` has 5 arguments in which the first argument is mandatory.
% We can thus look at this as a 4-bit filling space, yielding a total of 16
% possibilities. These can be accounted for as follows:

    % First one fixed, 4 additional elements and 0 missing
        feature_block -> feature contents background_block scenario_blocks rule_blocks : feature_block('$1', '$2', '$3', '$4', '$5').

    % First one fixed, 3 additional elements and 1 missing
        feature_block -> feature contents background_block scenario_blocks : feature_block('$1', '$2', '$3', '$4', []).
        feature_block -> feature contents background_block rule_blocks : feature_block('$1', '$2', '$3', [], '$4').
        feature_block -> feature contents scenario_blocks rule_blocks : feature_block('$1', '$2', [], '$3', '$4').
        feature_block -> feature background_block scenario_blocks rule_blocks : feature_block('$1', [], '$2', '$3', '$4').

    % First one fixed, 2 additional elements and 2 missing
        % 2 missing with one of them fixed at last position
        feature_block -> feature contents scenario_blocks : feature_block('$1', '$2', [], '$3', []).
        feature_block -> feature background_block scenario_blocks : feature_block('$1', [], '$2', '$3', []).
        feature_block -> feature contents background_block : feature_block('$1', '$2', '$3', [], []).

        % 2 missing with one of them fixed at second last position
        feature_block -> feature background_block rule_blocks : feature_block('$1', [], '$2', [], '$3').
        feature_block -> feature contents rule_blocks : feature_block('$1', '$2', [], [], '$3').

        % 2 missing with one of them fixed at third position
        feature_block -> feature scenario_blocks rule_blocks : feature_block('$1', [], [], '$2', '$3').

    % First one fixed, 1 additional element and 3 missing
        feature_block -> feature contents : feature_block('$1', '$2', [], [], []).
        feature_block -> feature background_block : feature_block('$1', [], '$2', [], []).
        feature_block -> feature scenario_blocks : feature_block('$1', [], [], '$2', []).
        feature_block -> feature rule_blocks : feature_block('$1', [], [], [], '$2').

    % First one fixed, 0 additional elements and 4 missing
        feature_block -> feature : feature_block('$1', [], [], [], []).

% LANGUAGE
i18n -> language : '$1'.

% RULE
rule_blocks -> rule_block rule_blocks : ['$1' | '$2'].
rule_blocks -> rule_block : ['$1'].

rule_block -> rule contents background_block scenario_blocks : rule_block('$1', '$2', '$3', '$4').
rule_block -> rule contents background_block : rule_block('$1', '$2', '$3', []).
rule_block -> rule contents : rule_block('$1', '$2', [], []).
rule_block -> rule : rule_block('$1', [], [], []).

rule_block -> rule background_block scenario_blocks : rule_block('$1', [], '$2', '$3').
rule_block -> rule contents scenario_blocks : rule_block('$1', '$2', [], '$3').
rule_block -> rule scenario_blocks : rule_block('$1', [], [], '$2').
rule_block -> rule background_block : rule_block('$1', [], '$2', []).

% BACKGROUND
background_block -> background contents step_blocks : background_block('$1', '$2', '$3').
background_block -> background step_blocks : background_block('$1', [], '$2').
background_block -> background contents : background_block('$1', '$2', []).
background_block -> background : background_block('$1', [], []).

% SCENARIO
scenario_blocks -> tagged_scenario_block scenario_blocks : ['$1' | '$2'].
scenario_blocks -> tagged_scenario_block : ['$1'].

tagged_scenario_block -> scenario_tags scenario_block : set_tags_block('$2', '$1').
tagged_scenario_block -> scenario_block : '$1'.
tagged_scenario_block -> scenario_outline_tags scenario_outline_block : set_tags_block('$2', '$1').
tagged_scenario_block -> scenario_outline_block : '$1'.

scenario_block -> scenario contents step_blocks tagged_examples_blocks : scenario_block('$1', '$2', '$3', '$4').
scenario_block -> scenario contents step_blocks : scenario_block('$1', '$2', '$3', []).
scenario_block -> scenario contents tagged_examples_blocks : scenario_block('$1', '$2', [], '$3').
scenario_block -> scenario step_blocks tagged_examples_blocks : scenario_block('$1', [], '$2', '$3').
scenario_block -> scenario contents : scenario_block('$1', '$2', [], []).
scenario_block -> scenario step_blocks : scenario_block('$1', [], '$2', []).
scenario_block -> scenario tagged_examples_blocks : scenario_block('$1', [], [], '$2').
scenario_block -> scenario : scenario_block('$1', [], [], []).

scenario_outline_block -> scenario_outline contents step_blocks tagged_examples_blocks : scenario_block('$1', '$2', '$3', '$4').
scenario_outline_block -> scenario_outline contents step_blocks : scenario_block('$1', '$2', '$3', []).
scenario_outline_block -> scenario_outline contents tagged_examples_blocks : scenario_block('$1', '$2', [], '$3').
scenario_outline_block -> scenario_outline step_blocks tagged_examples_blocks : scenario_block('$1', [], '$2', '$3').
scenario_outline_block -> scenario_outline contents : scenario_block('$1', '$2', [], []).
scenario_outline_block -> scenario_outline step_blocks : scenario_block('$1', [], '$2', []).
scenario_outline_block -> scenario_outline tagged_examples_blocks : scenario_block('$1', [], [], '$2').
scenario_outline_block -> scenario_outline : scenario_block('$1', [], [], []).

% EXAMPLES
tagged_examples_blocks -> tagged_examples_block tagged_examples_blocks : ['$1' | '$2'].
tagged_examples_blocks -> tagged_examples_block : ['$1'].

tagged_examples_block -> scenarios_tags examples_block : set_tags_block('$2', '$1').
tagged_examples_block -> examples_block : '$1'.

examples_block -> scenarios contents datatable_rows: examples_block('$1', '$2', '$3').
examples_block -> scenarios contents : examples_block('$1', '$2', []).
examples_block -> scenarios datatable_rows : examples_block('$1', [], '$2').
examples_block -> scenarios : examples_block('$1', [], []).

% STEP
step_blocks -> step_block step_blocks : '$1' ++ '$2'.
step_blocks -> step_block : '$1'.
step_block -> givens : '$1'.
step_block -> whens : '$1'.
step_block -> thens : '$1'.
step_block -> ands : '$1'.
step_block -> buts : '$1'.

givens -> given content : return_error('$2', 'plain_content_within_step_block').
whens -> 'when' content : return_error('$2', 'plain_content_within_step_block').
thens -> then content : return_error('$2', 'plain_content_within_step_block').
ands -> and content : return_error('$2', 'plain_content_within_step_block').
buts -> but content : return_error('$2', 'plain_content_within_step_block').

givens -> given givens : [step_component('$1') | '$2'].
givens -> given step_arg : [step_component('$1', '$2')].
givens -> given : [step_component('$1')].

whens -> 'when' whens : [step_component('$1') | '$2'].
whens -> 'when' step_arg : [step_component('$1', '$2')].
whens -> 'when' : [step_component('$1')].

thens -> then thens : [step_component('$1') | '$2'].
thens -> then step_arg : [step_component('$1', '$2')].
thens -> then : [step_component('$1')].

ands -> 'and' ands : [step_component('$1') | '$2'].
ands -> 'and' step_arg : [step_component('$1', '$2')].
ands -> 'and' : [step_component('$1')].

buts -> but buts : [step_component('$1') | '$2'].
buts -> but step_arg : [step_component('$1', '$2')].
buts -> but : [step_component('$1')].

step_arg -> docstring : '$1'.
step_arg -> datatable_rows : data_table_block('$1').

% DOCSTRING
docstring -> doc_string doc_string : doc_string_component('$1', []).
docstring -> doc_string contents doc_string : doc_string_component('$1', '$2').

% DATATABLE
% datatable -> datatable_rows : data_table_block('$1').
datatable_rows -> data_table datatable_rows : [data_table_component('$1') | '$2'].
datatable_rows -> data_table : [data_table_component('$1')].

% CONTENT
contents -> content contents : ['$1'|'$2'].
contents -> content : ['$1'].

% TAG
feature_tags -> feature_tag feature_tags : [tag_component('$1') | '$2'].
feature_tags -> feature_tag : [tag_component('$1')].
background_tags -> background_tag background_tags : [tag_component('$1') | '$2'].
background_tags -> background_tag : [tag_component('$1')].
scenario_outline_tags -> scenario_outline_tag scenario_outline_tags : [tag_component('$1') | '$2'].
scenario_outline_tags -> scenario_outline_tag : [tag_component('$1')].
rule_tags -> rule_tag rule_tags : [tag_component('$1') | '$2'].
rule_tags -> rule_tag : [tag_component('$1')].
scenario_tags -> scenario_tag scenario_tags : [tag_component('$1') | '$2'].
scenario_tags -> scenario_tag : [tag_component('$1')].
scenarios_tags -> scenarios_tag scenarios_tags : [tag_component('$1') | '$2'].
scenarios_tags -> scenarios_tag : [tag_component('$1')].

Erlang code.

-compile([{hipe, [{regalloc, linear_scan}]}]).

% LANGUAGE
set_language({'feature', {'meta', {Location, TokenLabel, _}, Type}, Constituents}, Language) ->
    {'feature', {'meta', {Location, TokenLabel, language(Language)}, Type}, Constituents}.

% FEATURE
feature_block(Feature, Contents, BackgroundBlock, ScenarioBlocks, RuleBlocks) ->
    Constituents = [
        tags_component([]),
        title_component(Feature),
        description_block(Contents),
        background_block(BackgroundBlock),
        scenario_blocks(ScenarioBlocks),
        rule_blocks(RuleBlocks)
    ],
    component(token(Feature), meta(Feature, 'default_language'), Constituents).

% BACKGROUND
background_block([]) ->
    Meta = {meta, {none, none}, {type, multiples}},
    normalize('background', Meta, constituents([]));
background_block(B) -> B.

background_block(Background, Contents, Steps) ->
    Constituents = [
        title_component(Background),
        description_block(Contents),
        step_block(Steps)
    ],
    component(token(Background), meta(Background), Constituents).

% RULE
rule_blocks(RuleBlocks) -> multiple_component('rule_blocks', RuleBlocks).
rule_block(Rule, Contents, BackgroundBlock, ScenarioBlocks) ->
    Constituents = [
        title_component(Rule),
        description_block(Contents),
        background_block(BackgroundBlock),
        scenario_blocks(ScenarioBlocks)
    ],
    component(token(Rule), meta(Rule), Constituents).

% SCENARIO
scenario_blocks(ScenarioBlocks) -> multiple_component('scenario_blocks', ScenarioBlocks).
scenario_block(Scenario, Contents, Steps, ExamplesBlocks) ->
    Constituents = [
        tags_component([]),
        title_component(Scenario),
        description_block(Contents),
        step_block(Steps),
        examples_blocks(ExamplesBlocks)
    ],
    component(token(Scenario), meta(Scenario), Constituents).

% STEP
step_block(Steps) -> multiple_component(steps, Steps).
step_component(FullToken) ->
    Constituents = [
        text_component(FullToken),
        step_arg_component()
    ],
    component(token(FullToken), meta(FullToken), Constituents).
step_component(FullToken, StepArg) ->
    Constituents = [
        text_component(FullToken),
        step_arg_component(StepArg)
    ],
    component(token(FullToken), meta(FullToken), Constituents).
step_arg_component(StepArg) -> singular_component('arg', StepArg).
step_arg_component() -> singular_component('arg', 'none').

% EXAMPLES
examples_blocks(ExamplesBlocks) -> multiple_component('examples_blocks', ExamplesBlocks).
examples_block(Examples, Contents, TableData) ->
    Constituents = [
        tags_component([]),
        title_component(Examples),
        description_block(Contents),
        data_table_block(TableData)
    ],
    component('examples', meta(Examples), Constituents).

% DATATABLE
data_table_block(DataTableBlock) -> multiple_component(data_table, DataTableBlock).
data_table_component(Token = {_, _, _, Row}) ->
    Meta = meta(Token),
    Cells = lists:map(fun({Column, Value}) ->
        component('data_table_cell', set_column(Meta, Column), Value)
    end, Row),
    component('data_table_row', Meta, Cells).

% TAG
set_tags_block(FullToken, Tags) -> replace_tags_component(FullToken, tags_component(Tags)).
tag_component(Token = {_, _, _, TagName}) ->
    Meta = erlang:append_element(meta(Token), {type, singular}),
    normalize(token(Token), Meta, TagName).
tags_component(Tags) ->
    IndividualizedTags = lists:foldl(fun({Tag, Meta, TagsOnLine}, Acc) ->
        Acc ++ lists:map(fun({ColumnNumber, TagName}) -> {Tag, set_column(Meta, ColumnNumber), TagName} end, TagsOnLine)
    end, [], Tags),
    multiple_component('tags', IndividualizedTags).

% DOCSTRING
doc_string_component(FullToken, Contents) ->
    Constituents = [
        delim_component(FullToken),
        doc_string_content_component(Contents)
    ],
    component(token(FullToken), meta(FullToken), Constituents).
doc_string_content_component(Descriptions) -> to_block_component('contents', Descriptions, [], fun doc_string_content_line_component/1).
doc_string_content_line_component(Content = {_, _, _, _}) ->
    component(token(Content), meta(Content), value(Content)).
delim_component({_, _, _, {_, Delim}}) -> singular_component('delim', Delim).

% GENERAL COMPONENTS
to_block_component(Label, Contents, Acc, ComponentFunc) when is_list(Contents) and is_list(Acc) ->
    case Contents of
        [] -> multiple_component(Label, lists:reverse(Acc));
        [Hd | Tl] -> to_block_component(Label, Tl, [ComponentFunc(Hd) | Acc], ComponentFunc)
    end.

description_block(Descriptions) -> description_block(Descriptions, []).
description_block(Descriptions, Acc) -> to_block_component('description_block', Descriptions, Acc, fun description_component/1).
description_component(Content = {_, _, _, _}) -> component('description', meta(Content), value(Content)).

title_component({_, _, _, Title}) -> singular_component('title', Title).
text_component({_, _, _, ActualContent}) -> singular_component('text', ActualContent).

% COMPONENT
constituents(Constituents) -> {'constituents', Constituents}.
component(Label, {meta, Meta}, Constituents) when is_list(Constituents) ->
    UpdatedMeta = {meta, Meta, {type, multiples}},
    normalize(Label, UpdatedMeta, constituents(Constituents));
component(Label, {meta, Meta}, Constituent) ->
    UpdatedMeta = {meta, Meta, {type, singular}},
    normalize(Label, UpdatedMeta, Constituent);
component(Label, Meta, Constituents) -> normalize(Label, Meta, Constituents).
normalize(Label, Meta, Constituents) -> {Label, Meta, Constituents}.

singular_component(Label, Constituent) -> component(Label, singular_meta(), Constituent).
multiple_component(Label, Constituents) -> component(Label, multiple_meta(), constituents(Constituents)).

meta(FullToken = {_, _, _, _}) -> {'meta', {location(FullToken), token_label(FullToken)}}.
meta(FullToken = {_, _, _, _}, Language) -> {'meta', {location(FullToken), token_label(FullToken), language(Language)}}.
singular_meta() -> {'meta', {none, none}, {type, singular}}.
multiple_meta() -> {'meta', {none, none}, {type, multiples}}.

% HELPERS
token({Token, _, _, _}) -> Token.
token_label({_, TokenLabel, _, _}) -> {'token_label', TokenLabel}.
line({_, _, {location, Line, _}, _}) -> {'line', Line}.
column({_, _, {location, _, Column}, _}) -> {'column', Column}.
set_column({'meta', {{location, {Line, _}}, TokenLabel}, Typing}, ColumnNumber) -> {'meta', {{location, {Line, {'column', ColumnNumber}}}, TokenLabel}, Typing};
set_column({'meta', {{location, {Line, _}}, TokenLabel}}, ColumnNumber) -> {'meta', {{location, {Line, {'column', ColumnNumber}}}, TokenLabel}}.

location(FullToken = {_, _, {location, _, _}, _}) -> {location, {line(FullToken), column(FullToken)}}.
language(Language) ->
    case Language of
        FullToken = {_, _, _, LanguageSymbol} -> component(token(FullToken), meta(FullToken), LanguageSymbol);
        'default_language' -> singular_component('language', 'en')
    end.

value({_, _, _, ActualContent}) -> ActualContent.
replace_tags_component({Label, Meta, {'constituents', [_tags_component_to_replace | Constituents]}}, Constituent) ->
    component(Label, Meta, constituents([Constituent | Constituents]));
replace_tags_component({Label, Meta, [_tags_component_to_replace | Constituents]}, Constituent) ->
    component(Label, Meta, constituents([Constituent | Constituents])).

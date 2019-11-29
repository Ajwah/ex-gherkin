Terminals feature rule example scenario given 'when' then but and background scenario_outline scenarios '"""' '|' '@' '#' string.
Nonterminals contents docstring block blocks.
Rootsymbol blocks.

blocks -> block blocks : ['$1'|'$2'].
blocks -> block : ['$1'].
block -> feature contents : title_with_contents('$1', '$2').
block -> feature : title_with_contents('$1', []).
contents -> string contents : ['$1'|'$2'].
contents -> string : ['$1'].
docstring -> '"""' '"""' : {'$1', []}.
docstring -> '"""' contents '"""' : {'$1', '$2'}.

Erlang code.

title_with_contents({Token, Line, Title}, Contents) -> {Token, Line, [{'title', Title}, {'contents', Contents}]}.
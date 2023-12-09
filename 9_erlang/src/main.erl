-module(main).

-export([start/0, get_diffs/1, line_to_nums/1, find_next/1]).

start() ->
    {ok, BinaryData} = file:read_file('inputs/input'),
    StringData = binary_to_list(BinaryData),
    Lines = string:split(StringData, "\n", all),
    NonEmptyLines = lists:filter(fun(Line) -> Line /= "" end, Lines),
    Series = lists:map(fun line_to_nums/1, NonEmptyLines),
    AllNext = lists:map(fun find_next/1, Series),
    SumNext = lists:foldl(fun(X, Acc) -> X + Acc end, 0, AllNext),
    io:format('First part: ~p~n', [SumNext]),
    AllPrev = lists:map(fun find_prev/1, Series),
    SumPrev = lists:foldl(fun(X, Acc) -> X + Acc end, 0, AllPrev),
    io:format('Second part: ~p~n', [SumPrev]).

to_int(Str) ->
    {Int, _ } = string:to_integer(Str),
    Int.

line_to_nums(Line) ->
    Nums = string:split(Line, " ", all),
    lists:map(fun to_int/1, Nums).

get_diffs([First, Second | Tail]) ->
    Diff = Second - First,
    [Diff | get_diffs([Second | Tail])];
get_diffs([_]) -> [].


find_next(List) ->
    Diffs = get_diffs(List),
    AllZeroes = lists:all(fun(X) -> X == 0 end, Diffs),
    Last = lists:last(List),
    if
        AllZeroes -> Last;
        true ->
            NextDiff = find_next(Diffs),
            Last + NextDiff
    end.

find_prev(List) ->
    Diffs = get_diffs(List),
    AllZeroes = lists:all(fun(X) -> X == 0 end, Diffs),
    [First | _] = List,
    if
        AllZeroes -> First;
        true ->
            PrevDiff = find_prev(Diffs),
            First - PrevDiff
    end.


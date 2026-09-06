#!/usr/bin/env escript
%! -noshell

main(_) ->
    Path = "_build/dev/lib/benchapp/ebin/Elixir.Benchapp.Signups.beam",
    {ok, {_Mod, Chunks}} = beam_lib:chunks(Path, [abstract_code]),
    {abstract_code, {_, Ac}} = lists:keyfind(abstract_code, 1, Chunks),
    io:put_chars(erl_pp:forms(Ac)),
    halt(0).

#!/usr/bin/env escript
%! -noshell

main(_) ->
    Path = "_build/dev/lib/benchapp/ebin/Elixir.Benchapp.Signups.beam",
    {ok, {_Mod, Chunks}} = beam_lib:chunks(Path, [debug_info]),
    {debug_info, {_, _, {elixir_v1, Meta, _Dbg}}}= lists:keyfind(debug_info, 1, Chunks),
    Defs = proplists:get_value(definitions, Meta),
    io:put_chars(io_lib:format("~p~n", [Defs])),
    halt(0).

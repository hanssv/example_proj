%%% @author Thomas Arts
%%% @copyright (C) 2014, Quviq AB
%%% @doc Naive implementation of queue for QuickCheck course
%%%
%%% @end
%%% Created : 16 Jan 2014 by Thomas Arts <thomas.arts@quviq.com>

-module(myqueue).
-include_lib("eqc/include/eqc.hrl").

-export([new/0, cons/2, head/1, last/1]).

new() ->
  <<>>.

cons(X, Q) ->
  <<Q/binary, X:16>>.

head(Q) ->
  <<X:16, _/binary>> = Q,
  X.

last(Q) ->
  S = size(Q)*8 -16,
  <<_:S, X:16>> = Q,
  X.



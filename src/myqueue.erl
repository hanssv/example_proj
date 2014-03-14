%%% @author Thomas Arts
%%% @copyright (C) 2014, Quviq AB
%%% @doc Naive implementation of queue for QuickCheck course
%%%
%%% @end
%%% Created : 16 Jan 2014 by Thomas Arts <thomas.arts@quviq.com>

-module(myqueue).
-include_lib("eqc/include/eqc.hrl").

-export([new/0, cons/2, head/1, last/1]).
-export([to_list/1, is_empty/1, get/1]).

new() ->
  [].

is_empty(Q) ->
  Q == [].

cons(X, Q) ->
  [ X | Q ].

get(Q) ->
  head(Q).

head(Q) ->
  hd(Q).

last(Q) ->
  lists:last(Q).

to_list(Q) ->
  Q.

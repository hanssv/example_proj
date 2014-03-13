-module(myqueue_eqc).
-include_lib("eqc/include/eqc.hrl").
-compile(export_all).

-define(Q, queue).

queue() ->
    ?SIZED(Size,well_defined(queue(Size))).

queue(Size) ->
    ?LAZY(
    oneof([{call,queue,new,[]}]
          ++ [{call,queue,cons,[int(),queue(Size-1)]} || Size>0 ]
          %% ++ [{call,queue,tail,[queue(Size-1)]} || Size>0]
         )).

%% defined(E) ->
%%    case catch {ok,eval(E)} of
%%         {ok,_} -> true;
%%         {'EXIT',_} -> false
%%    end.

%% well_defined(G) ->
%%   ?SUCHTHAT(X,G,defined(X)).

prop_itsthere() ->
   ?FORALL(I,int(),
           I == queue:last(queue:cons(I, queue:new()))).

prop_get_cons() ->
    ?FORALL({I,Q}, {int(),queue()},
            queue:get(queue:cons(I,eval(Q))) == I).

model(Q) -> queue:to_list(Q).

prop_cons1() ->
   ?FORALL({I,Q},{int(),queue()},
           model(queue:cons(I,eval(Q))) == [I] ++ model(eval(Q))).

prop_cons2() ->
   ?FORALL({I,Q},{int(),queue()},
           model(queue:cons(I,eval(Q))) == [I|model(eval(Q))]).

prop_head() ->
    ?FORALL(Q,queue(),
            begin
                QVal = eval(Q),
                queue:is_empty(QVal) orelse
                         queue:head(QVal) == hd(model(QVal))
            end).

prop_last() ->
    ?FORALL(Q,queue(),
            aggregate(command_names(Q),
            begin
                QVal = eval(Q),
                queue:is_empty(QVal) orelse
                         queue:last(QVal) == lists:last(model(QVal))
            end)).

command_names({call,_Mod,Fun,Args}) ->
    [Fun] ++ command_names(Args);
command_names([A|As]) when is_list(As) ->
    command_names(A) ++ command_names(As);
command_names(_) ->
    [].

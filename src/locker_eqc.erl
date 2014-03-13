%%% File    : locker_eqc.erl
%%% Author  :  <John Hughes@JTABLET2007>
%%% Description :
%%% Created : 10 Dec 2008 by  <John Hughes@JTABLET2007>

-module(locker_eqc).

-include_lib("eqc/include/eqc.hrl").
-include_lib("eqc/include/eqc_fsm.hrl").

-compile(export_all).

-record(state_data,{current,saved}).

%% Specification of states and state transitions.

unlocked(S) ->
    [{unlocked,{call,locker,read,[elements(keys(S))]}},
     {locked,  {call,locker,lock,[]}}].

locked(S) ->
    [{locked,  {call,locker,read,[elements(keys(S))]}},
     {unlocked,{call,locker,commit,[]}},
     {unlocked,{call,locker,abort,[]}},
     {locked,  {call,locker,write,[key(),value()]}}].

keys(S) ->
    [K || {K,_V} <- S#state_data.current].

key() ->
    elements([a,b,c,d]).

value() ->
    int().

precondition(_,_,S,{call,_,read,[Key]}) ->
    lists:keymember(Key,1,S#state_data.current);
precondition(_,_,_,_) ->
    true.

initial_state() ->
    unlocked.

initial_state_data() ->
    #state_data{current=[],saved=[]}.

next_state_data(_,_,S,_,{call,_,write,[Key,Value]}) ->
    S#state_data{current=[{Key,Value}|S#state_data.current]};
next_state_data(unlocked,locked,S,_,_) ->
    S#state_data{saved=S#state_data.current};
next_state_data(_,_,S,_,{call,_,abort,_}) ->
    S#state_data{current=S#state_data.saved};
next_state_data(_,_,S,_,{call,_,_,_}) ->
    S.

postcondition(_,_,S,{call,_,read,[Key]},R) ->
    R == proplists:get_value(Key,S#state_data.current);
postcondition(_,_,_,_,R) ->
    R == ok.

prop_locker() ->
    ?FORALL(Cmds,eqc_fsm:commands(?MODULE),
            begin
                locker:start(),
                {H,S,Res} = eqc_fsm:run_commands(?MODULE,Cmds),
                locker:stop(),
                aggregate(zip(state_names(H),command_names(Cmds)),
                  pretty_commands(?MODULE, Cmds, {H, S, Res},
                                  Res == ok))
            end).


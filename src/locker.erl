-module(locker).

-compile(export_all).

start() ->
    gen_fsm:start({local,locker},?MODULE,[],[]).

init([]) ->
    {ok,unlocked,[]}.

unlocked(lock,S) ->
    {next_state,locked,S}.

unlocked({read,Key},Caller,S) ->
    gen_fsm:reply(Caller,proplists:get_value(Key,S)),
    {next_state,unlocked,S}.

locked({write,Key,Value},S) ->
    {next_state,locked,[{Key,Value}|lists:keydelete(Key,1,S)]};
locked(abort,S) ->
    {next_state,unlocked,S};
locked(commit,S) ->
    {next_state,unlocked,S}.

locked({read,Key},Client,S) ->
    gen_fsm:reply(Client,proplists:get_value(Key,S)),
    {next_state,locked,S}.

handle_sync_event(stop,_,_,_) ->
    {stop,normal,ok,[]}.

terminate(_,_,_) ->
    ok.

lock() ->
    gen_fsm:send_event(locker,lock).

write(Key,Val) ->
    gen_fsm:send_event(locker,{write,Key,Val}).

read(Key) ->
    gen_fsm:sync_send_event(locker,{read,Key}).

abort() ->
    gen_fsm:send_event(locker,abort).

commit() ->
    gen_fsm:send_event(locker,commit).

stop() ->
    gen_fsm:sync_send_all_state_event(locker,stop).

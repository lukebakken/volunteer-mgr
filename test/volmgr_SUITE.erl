-module(volmgr_SUITE).

-include("volunteer_mgr.hrl").

-include_lib("common_test/include/ct.hrl").

-export([all/0,
         init_per_suite/1,
         end_per_suite/1,
         create_and_retrieve_person_by_id/1,
         retrieve_all_people/1,
         create_and_retrieve_tag_by_id/1,
         retrieve_all_tags/1
        ]).

all() -> [
          create_and_retrieve_person_by_id,
          retrieve_all_people,
          create_and_retrieve_tag_by_id,
          retrieve_all_tags
         ].

init_per_suite(Config) ->
    ok = mnesia:start(),
    ok = volmgr_db:init_tables(),
    {ok, _Apps} = application:ensure_all_started(volunteer_mgr),
    Config.

end_per_suite(Config) ->
    Config.

create_and_retrieve_person_by_id(_) ->
    First = <<"Bob">>,
    Last = <<"Abooey">>,
    Phone = {345, 555, 1212},
    Email = <<"bob@abooey.com">>,
    Notes = [<<"Note 1">>, <<"Note 2">>],
    ok = volmgr_db:create_person(First, Last, Phone, Email, Notes),
    notfound = volmgr_db:retrieve_person(<<"does-not-exist">>),
    Id = <<"Abooey-Bob">>,
    #person{id=Id, first=First, last=Last,
            phone=Phone, email=Email, notes=Notes} = volmgr_db:retrieve_person(Id).

retrieve_all_people(_) ->
    First = <<"Frank">>,
    Last = <<"Barker">>,
    Phone = {456, 555, 1212},
    Email = <<"frankg@gmail.com">>,
    ok = volmgr_db:create_person(First, Last, Phone, Email, []),
    WantId = <<"Barker-Frank">>,
    Want = #person{id=WantId, active=true,
                   first=First, last=Last,
                   phone=Phone, email=Email},
    Got = volmgr_db:retrieve_people(),
    Pred = fun(Item) ->
               Item =:= Want
           end,
    true = lists:any(Pred, Got).

create_and_retrieve_tag_by_id(_) ->
    Tag = foo,
    ok = volmgr_db:create_tag(Tag),
    notfound = volmgr_db:retrieve_tag('unknown-tag-should-not-be-saved'),
    {Tag, true} = volmgr_db:retrieve_tag(Tag).

retrieve_all_tags(_) ->
    Tags = [foo, bar, baz, bat, frazzle],
    Want = [{T, true} || T <- Tags],
    ok = volmgr_db:create_tags(Tags),
    Got = volmgr_db:retrieve_tags(),
    true = lists:sort(Want) =:= lists:sort(Got).

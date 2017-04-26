-module(volmgr_cb_people).

-export([init/2]).

-spec init(cowboy_req:req(), term()) -> {ok, cowboy_req:req(), term()}.
init(Req, State) ->
    Method = cowboy_req:method(Req),
    HasBody = cowboy_req:has_body(Req),
    Reply = process_request(Method, HasBody, Req),
    {ok, Reply, State}.

-spec process_request(binary(), boolean(), cowboy_req:req()) -> cowboy_req:req().
process_request(<<"GET">>, _, Req) ->
    render_form_with_existing_tags(Req);
process_request(<<"POST">>, true, Req) ->
    {ok, PostVals, Req1} = cowboy_req:body_qs(Req),
    F = cb_util:get_post_value(<<"first_name">>, PostVals),
    L = cb_util:get_post_value(<<"last_name">>, PostVals),
    P = cb_util:get_phone(PostVals),
    E = cb_util:get_post_value(<<"email">>, PostVals),
    N = cb_util:get_post_value(<<"notes">>, PostVals),
    Tags = [binary_to_atom(T, latin1) || {<<"tags">>, T} <- PostVals],
    ok = volmgr_db_people:create(F, L, P, E, [N], Tags),
    render_form_with_existing_tags(Req1);
process_request(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing Body">>, Req);
process_request(_, _, Req) ->
    cowboy_req:reply(405, Req).

-spec render_form_with_existing_tags(cowboy_req:req()) -> cowboy_req:req().
render_form_with_existing_tags(Req) ->
    Tags = volmgr_db_tags:retrieve(),
    Data = [{tags, [T || {T, _} <- Tags]}],
    {ok, ResponseBody} = volunteer_mgr_templates_people:render(Data),
    cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], ResponseBody, Req).
-module(volmgr_cb_tag_create).

-export([init/2,
        allowed_methods/2,
        content_types_provided/2,
        content_types_accepted/2,
        to_html/2,
        html_create_tag/2]).

-spec init(Req, Opts) -> {cowboy_rest, Req, Opts} when Req::cowboy_req:req(), Opts::any().
init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

-spec allowed_methods(Req, State) -> {list(binary()), Req, State}
	when Req::cowboy_req:req(), State::any().
allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>], Req, State}.

-spec content_types_provided(Req, State) ->
    {[{binary() | {binary(), binary(), '*' | [{binary(), binary()}]}, atom()}], Req, State} | {stop, Req, State}
	when Req::cowboy_req:req(), State::any().
content_types_provided(Req, State) ->
    {[
		{<<"text/html">>, to_html} %%,
		%% TODO {<<"application/json">>, to_json}
	], Req, State}.

-spec content_types_accepted(Req, State) ->
    {[{binary() | {binary(), binary(), '*' | [{binary(), binary()}]}, atom()}], Req, State} | {stop, Req, State}
	when Req::cowboy_req:req(), State::any().
content_types_accepted(Req, State) ->
    {[{{<<"application">>, <<"x-www-form-urlencoded">>, []}, html_create_tag}], Req, State}.

-spec to_html(Req, State) -> {iolist(), Req, State} | {stop, Req, State}
	when Req::cowboy_req:req(), State::any().
to_html(Req, State) ->
    Body = html_render_existing_tags(),
    {Body, Req, State}.

-spec html_create_tag(Req, State) -> {true, Req, State} | {stop, Req, State}
	when Req::cowboy_req:req(), State::any().
html_create_tag(Req, State) ->
    {ok, PostVals, Req1} = cowboy_req:read_urlencoded_body(Req),
    Tag = cb_util:get_post_value(<<"new_tag">>, PostVals),
    ok = volmgr_db_tags:create(Tag),
    Req2 = cowboy_req:set_resp_body(html_render_existing_tags(), Req1),
    {true, Req2, State}.

-spec html_render_existing_tags() -> iolist().
html_render_existing_tags() ->
    Tags = volmgr_db_tags:retrieve(),
    Data = [{tags, [T || {T, _} <- Tags]}],
    {ok, Body} = volmgr_cb_tag_create_dtl:render(Data),
    Body.

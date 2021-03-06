-type db_phone() :: {integer(), integer(), integer()}.
-type db_tag() :: binary().

-record(volmgr_people,
        {id :: binary(),
         active :: boolean(),
         first :: binary(),
         last :: binary(),
         phone :: db_phone(),
         email :: binary(),
         notes :: list(binary())
        }).

-record(volmgr_people_tags,
        {volmgr_tags_id :: db_tag(),
         volmgr_people_id :: binary()
        }).

-record(volmgr_tags, {id :: db_tag(), active :: boolean()}).

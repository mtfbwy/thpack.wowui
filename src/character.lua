T.ask("PLAYER_LOGIN").answer("character", function()
    local name, server = UnitName("player");
    return {
        guid = UnitGUID("player"),
        name = name,
        race = UnitRace("player"),
        class = string.lower(select(2, UnitClass("player"))),
        server = server,
    };
end);

T.ask("VARIABLES_LOADED").answer("character", function()
    return {
        guid = UnitGUID("player"),
        name = UnitName("player"),
        race = UnitRace("player"),
        class = string.lower(select(2, UnitClass("player")))
    };
end);

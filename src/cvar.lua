(function()

    SetCVar("screenshotQuality", 10);

    RegisterCVar("profanityFilter", 0);
    SetCVar("profanityFilter", 0);

    -- "0" is enabling name colored by class in chat frame
    SetCVar("chatClassColorOverride", 0);

    SetCVar("alwaysShowActionBars", 1);

    RegisterCVar("targetNearestDistance", 50);
    SetCVar("targetNearestDistance", 50);
    RegisterCVar("targetNearestDistanceRadius", 50);
    SetCVar("targetNearestDistanceRadius", 50);

    RegisterCVar("CombatLogRangeCreature", 50);
    SetCVar("CombatLogRangeCreature", 50);
    RegisterCVar("CombatLogRangeHostilePlayers", 50);
    SetCVar("CombatLogRangeHostilePlayers", 50);

    SetCVar("scriptErrors", 1);

    RegisterCVar("taintLog", 1);
    SetCVar("taintLog", 1);
end)();

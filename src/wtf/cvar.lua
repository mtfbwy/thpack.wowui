(function()

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

    SetCVar("lootUnderMouse", 0);
    SetCVar("autoLootDefault", 1);
    SetCVar("autoLootRate", 0);
    SetCVar("autoOpenLootHistory", 0);

    SetCVar("screenshotQuality", 10);

    SetCVar("scriptErrors", 1);

    RegisterCVar("taintLog", 1);
    SetCVar("taintLog", 1);
end)();

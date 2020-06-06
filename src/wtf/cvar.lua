(function()

    -- disable box world
    SetCVar("overrideArchive", 0);

    -- chat
    SetCVar("chatClassColorOverride", 0); -- "0": enabling class-colored name
    RegisterCVar("profanityFilter", 0);
    SetCVar("profanityFilter", 0);

    -- action bar
    SetCVar("alwaysShowActionBars", 1);

    -- tab select
    RegisterCVar("targetNearestDistance", 50);
    SetCVar("targetNearestDistance", 50);
    RegisterCVar("targetNearestDistanceRadius", 50);
    SetCVar("targetNearestDistanceRadius", 50);

    -- combat log
    RegisterCVar("CombatLogRangeCreature", 50);
    SetCVar("CombatLogRangeCreature", 50);
    RegisterCVar("CombatLogRangeHostilePlayers", 50);
    SetCVar("CombatLogRangeHostilePlayers", 50);

    -- loot
    SetCVar("lootUnderMouse", 0);
    SetCVar("autoLootDefault", 1);
    SetCVar("autoLootRate", 0);
    SetCVar("autoOpenLootHistory", 0);

    -- screenshot
    SetCVar("screenshotQuality", 10);

    -- develop
    SetCVar("scriptErrors", 1);

    RegisterCVar("taintLog", 1);
    SetCVar("taintLog", 1);
end)();

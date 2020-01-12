A = A or {};

A.castCube = (function()
    local cube = {};

    local function onCastStart(srcGuid, spellIdOrName)
        local spellInfo = { GetSpellInfo(spellIdOrName) };
        cube[srcGuid] = {
            srcGuid = srcGuid,
            spellName = spellName,
            spellIcon = spellInfo[3],
            castStartTime = GetTime(),
        };
    end

    local function onCastEnd(srcGuid, reason)
        local entry = cube[srcGuid];
        if (entry) then
            -- for those who holds the reference
            entry.castEndTime = GetTime();
            entry.castEndReason = reason;
        end
        cube[srcGuid] = nil;
    end

    local f = CreateFrame("Frame", nil, nil, nil);
    f:SetScript("OnEvent", function(self, event, ...)
        local eventInfo = { CombatLogGetCurrentEventInfo() };
        local eventName = eventInfo[2];
        local srcGuid = eventInfo[4];
        if (eventName == "SPELL_CAST_START") then
            -- XXX will it hear item spell?
            local spellName = eventInfo[13];
            onCastStart(srcGuid, spellName);
        elseif (eventName == "SPELL_CAST_SUCCESS") then
            onCastEnd(srcGuid, "SUCCEEDED");
        elseif (eventName == "SPELL_CAST_FAILED") then
            onCastEnd(srcGuid, "FAILED");
        elseif (eventName == "SPELL_INTERRUPT") then
            onCastEnd(srcGuid, "INTERRUPTED");
        elseif (eventName == "SPELL_AURA_APPLIED") then
        elseif (eventName == "SPELL_AURA_REMOVED") then
        end
    end);

    return {
        start = function()
            f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        end,
        add = function(unitGuid, spellIdOrName)
            onCastStart(srcGuid, spellName);
        end,
        get = function(unitGuid)
            return cube[unitGuid];
        end,
    };
end)();

A.getUnitCastInfoByUnit = A.getUnitCastInfoByUnit or (function()

    local function getByBlizzardCasting(...)
        local spellName, spellDisplayName, spellIcon, startTimeMilliseconds, endTimeMilliseconds, isTradeSkill, castGuid, notInterruptible, spellId = ...;
        if (spellName) then
            return {
                spellId = spellId,
                spellName = spellName,
                spellIcon = spellIcon,
                castStartTime = startTimeMilliseconds / 1000,
                castEndTime = endTimeMilliseconds / 1000,
                castIsShielded = notInterruptible,
                castProgressing = "CASTING",
            };
        end
    end

    local function getByBlizzardChanneling(...)
        local spellName, spellDisplayName, spellIcon, startTimeMilliseconds, endTimeMilliseconds, isTradeSkill, notInterruptible, spellId = ...;
        if (spellName) then
            return {
                spellId = spellId,
                spellName = spellName,
                spellIcon = spellIcon,
                castStartTime = startTimeMilliseconds / 1000,
                castEndTime = endTimeMilliseconds / 1000,
                castIsShielded = notInterruptible,
                castProgressing = "CHANNELING",
            };
        end
    end

    if (UnitCastingInfo and UnitChannelInfo) then
        return function(unit)
            return getByBlizzardCasting(UnitCastingInfo(unit))
                    or getByBlizzardChanneling(UnitChannelInfo(unit))
                    or {};
        end;
    end

    -- for 60's

    A.castCube.start();

    local MY_GUID = UnitGUID("player");

    return function(unit, spellIdOrName)
        local unitGuid = UnitGUID(unit);
        if (unitGuid == MY_GUID) then
            return getByBlizzardCasting(CastingInfo())
                    or getByBlizzardChanneling(ChannelInfo())
                    or {};
        end
        if (spellIdOrName) then
            A.castCube.add(unitGuid, spellIdOrName);
        end
        return A.castCube.get(unitGuid);
    end;
end)();

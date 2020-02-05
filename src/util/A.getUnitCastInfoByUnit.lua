A = A or {};

-- tracking cast endpoint via COMBAT_LOG_EVENT_UNFILTERED
A.castCube = A.castCube or (function()

    local subscribers = {};

    -- fn(unitGuid, castInfo)
    local function acceptSubscriber(unit, fn)
        if (not unit or not UnitExists(unit)) then
            return false;
        end
        local unitGuid = UnitGUID(unit);
        if (unitGuid and type(fn) == "function") then
            local key = tostring(fn);
            local t = subscribers[unitGuid];
            if (not t) then
                -- possible, different units point to a same unitGuid
                t = {};
                subscribers[unitGuid] = t;
            end
            -- possible, a same callback subscribes for multiple times
            t[tostring(fn)] = fn;
        end
    end

    local function emitCastEvent(unitGuid, a)
        local t = subscribers[unitGuid];
        if (not t) then
            return;
        end

        for k, fn in pairs(t) do
            if (fn) then
                if (fn(unitGuid, a)) then
                    -- unit changed
                    t[k] = nil;
                end
            end
        end
    end

    local cleuCube = {};

    local function queryCleuCube(unitGuid)
        if (not unitGuid) then
            return nil;
        end
        local a = cleuCube[unitGuid];
        if (not a) then
            return nil;
        end
        if (a.castEndTime) then
            return a;
        elseif (a.castEndTimePossible < time()) then
            a.castEndTime = 0;
            cleuCube[unitGuid] = nil;
            return nil;
        else
            return a;
        end
    end

    local function logCleuCastStart(unitGuid, timestamp, spellId, spellName, spellSchool)
        if (not unitGuid) then
            return;
        end
        spellId = spellId and spellId > 0 and spellId;
        local _spellName, _, spellIcon, castTimeMilliseconds, minRange, maxRange, _ = spellId and GetSpellInfo(spellId);
        spellName = spellName or _spellName;
        castTimeMilliseconds = castTimeMilliseconds or 10000; -- 10s
        local a = {
            unitGuid = unitGuid,
            castStartTime = timestamp,
            castEndTime = nil,
            -- would be the max possible end time
            -- sometimes we cannot hear the cast end event, e.g. due to out of CLEU range
            -- so necessary to have a safe exit
            castEndTimePossible = timestamp + castTimeMilliseconds,
            spellName = spellName,
            spellIcon = spellIcon,
            source = "CLEU",
        };
        cleuCube[unitGuid] = a;
        return a;
    end

    local function logCleuCastEnd(unitGuid, timestamp, reason)
        local a = cleuCube[unitGuid];
        if (a) then
            -- for those who holds the reference
            a.castEndTime = timestamp;
            a.castEndReason = reason;
        end
        cleuCube[unitGuid] = nil;
        return a; -- provide the reason
    end

    local function logCleuCastSucceeded(unitGuid, timestamp, spellId, spellName)
        if (not cleuCube[unitGuid]) then
            logCleuCastStart(unitGuid, timestamp, spellId, spellName);
            return logCleuCastEnd(unitGuid, timestamp, "INSTANT_SUCCEEDED");
        end
        return logCleuCastEnd(unitGuid, timestamp, "SUCCEEDED");
    end

    local function onCleuEvent(...)
        local timestamp, eventName, hidesCaster = ...;
        local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
        local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);
        if (srcGuid == UnitGUID("player")) then
            return;
        end

        if (eventName == "SPELL_CAST_START") then
            -- v11303 cannot hear item horse-mount, but can hear Hearthstone
            -- v11303 spellId is always 0
            local spellId, spellName, spellSchool = select(12, ...);
            local a = logCleuCastStart(srcGuid, timestamp, spellId, spellName, spellSchool);
            emitCastEvent(srcGuid, a);
        elseif (eventName == "SPELL_CAST_SUCCESS") then
            -- TODO animation for instant spell
            local a = logCleuCastSucceeded(srcGuid, timestamp, spellId, spellName, spellSchool);
            emitCastEvent(srcGuid, a);
        elseif (eventName == "SPELL_CAST_FAILED") then
            -- distinguish self-interrupt and failed-before-start
            local failedType = select(15, ...);
            if (failedType == SPELL_FAILED_INTERRUPTED) then
                local a = logCleuCastEnd(srcGuid, timestamp, "SELF_INTERRUPTED");
                emitCastEvent(srcGuid, a);
            end
        elseif (eventName == "SPELL_INTERRUPT") then
            local a = logCleuCastEnd(srcGuid, timestamp, "INTERRUPTED");
            emitCastEvent(srcGuid, a);
        elseif (eventName == "SPELL_AURA_APPLIED") then
        elseif (eventName == "SPELL_AURA_REMOVED") then
        end
    end

    -- cannot query at anytime; cache it
    local spellCastCube = {};

    local function querySpellCastCube(unitGuid)
        return unitGuid and spellCastCube[unitGuid];
    end

    local function logSpellCastStart(unit, castGuid, spellId)
        local timestamp = time();
        local unitGuid = UnitGUID(unit);
        local spellName, _, spellIcon, castTimeMilliseconds, minRange, maxRange, spId = GetSpellInfo(spellId);
        if (spellName) then
            local a = {
                castGuid = castGuid,
                spellId = spellId,
                spellName = spellName,
                spellIcon = spellIcon,
                castStartTime = timestamp,
                castEndTime = timestamp + castTimeMilliseconds / 1000,
                castIsShielded = nil,
                castProgress = nil,
                source = "SPELLCAST",
            };
            spellCastCube[unitGuid] = a;
            return unitGuid, a;
        end
        return unitGuid;
    end

    local function logSpellCastEnd(unit, reason)
        local timestamp = time();
        local unitGuid = UnitGUID(unit);
        local a = spellCastCube[unitGuid];
        if (a) then
            -- for those who holds the reference
            a.castEndTime = timestamp;
            a.castEndReason = reason;
        end
        spellCastCube[unitGuid] = nil;
        return unitGuid, a;
    end

    local f = CreateFrame("Frame", nil, nil, nil);

    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
    f:RegisterEvent("UNIT_SPELLCAST_DELAYED");
    f:RegisterEvent("UNIT_SPELLCAST_FAILED");
    f:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
    f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    --f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
    --f:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
    f:RegisterEvent("UNIT_SPELLCAST_START");
    f:RegisterEvent("UNIT_SPELLCAST_STOP");
    f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");

    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            onCleuEvent(CombatLogGetCurrentEventInfo());
        elseif (event == "UNIT_SPELLCAST_CHANNEL_START"
                or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
                or event == "UNIT_SPELLCAST_DELAYED"
                or event == "UNIT_SPELLCAST_INTERRUPTIBLE"
                or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
                or event == "UNIT_SPELLCAST_START") then
            -- v11303 UNIT_SPELLCAST_* triggerred only for "player"
            -- v11303 true spellId
            -- v11303 hear only player event, no pet, no party, etc
            -- v11303 can hear Hearthstone
            local unit, castGuid, spellId = ...;
            local unitGuid, a = logSpellCastStart(unit, castGuid, spellId);
            emitCastEvent(unitGuid, a);
        elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP"
                or event == "UNIT_SPELLCAST_FAILED"
                or event == "UNIT_SPELLCAST_FAILED_QUIET"
                or event == "UNIT_SPELLCAST_INTERRUPTED"
                or event == "UNIT_SPELLCAST_STOP"
                or event == "UNIT_SPELLCAST_SUCCEEDED") then
            local unit, castGuid, spellId = ...;
            local reason = string.match(event, "^UNIT_SPELLCAST_(.*)");
            local unitGuid, a = logSpellCastEnd(unit, reason);
            emitCastEvent(unitGuid, a);
        elseif (string.match(event, "^UNIT_SPELLCAST_")) then
            -- XXX
        end
    end);

    return {
        acceptSubscriber = acceptSubscriber,
        query = queryCleuCube,
    };
end)();

A.getUnitCastInfoByUnit = A.getUnitCastInfoByUnit or (function()

    local UnitCastingInfo = UnitCastingInfo or function(unit)
        if (unit and UnitIsUnit(unit, "player")) then
            return CastingInfo();
        end
    end

    local UnitChannelInfo = UnitChannelInfo or function(unit)
        if (unit and UnitIsUnit(unit, "player")) then
            return ChannelInfo();
        end
    end

    local function getByCasting(...)
        local spellName, spellDisplayName, spellIcon, startTimeMilliseconds, endTimeMilliseconds, isTradeSkill, castGuid, notInterruptible, spellId = ...;
        if (spellName) then
            local castInfo = {};
            castInfo.castGuid = castGuid;
            castInfo.spellId = spellId;
            castInfo.spellName = spellName;
            castInfo.spellIcon = spellIcon;
            castInfo.castStartTime = startTimeMilliseconds / 1000;
            castInfo.castEndTime = endTimeMilliseconds / 1000;
            castInfo.castIsShielded = notInterruptible;
            castInfo.castProgress = "CASTING";
            castInfo.source = "API";
            return castInfo;
        end
    end

    local function getByChanneling(...)
        local spellName, spellDisplayName, spellIcon, startTimeMilliseconds, endTimeMilliseconds, isTradeSkill, notInterruptible, spellId = ...;
        if (spellName) then
            local castInfo = {};
            castInfo.castGuid = nil;
            castInfo.spellId = spellId;
            castInfo.spellName = spellName;
            castInfo.spellIcon = spellIcon;
            castInfo.castStartTime = startTimeMilliseconds / 1000;
            castInfo.castEndTime = endTimeMilliseconds / 1000;
            castInfo.castIsShielded = notInterruptible;
            castInfo.castProgress = "CHANNELING";
            castInfo.source = "API";
            return castInfo;
        end
    end

    return function(unit)
        return getByCasting(UnitCastingInfo(unit))
                or getByChanneling(UnitChannelInfo(unit))
                or (unit and UnitExists(unit) and A.castCube.query(UnitGUID(unit)));
    end;
end)();

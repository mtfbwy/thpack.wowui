addonName, addon = ...;

if (addon.CastCube) then
    return;
end

addon.CastCube = {};
local CastCube = addon.CastCube;

function CastCube.malloc()
    local cube = {};
    cube.cleStorage = {};
    cube.uscStorage = {
        --unitGuid = castInfo
    };
    cube.clients = {};

    cube.driver = CreateFrame("Frame");
    cube.driver:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    --cube.driver:RegisterEvent("UNIT_SPELLCAST_CHANNEL_SENT");
    --cube.driver:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_DELAYED");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_FAILED");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
    --cube.driver:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
    --cube.driver:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_START");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_STOP");
    cube.driver:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");

    cube.driver:SetScript("OnEvent", function(self, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            CastCube.logCombatLogEvent(cube);
        else
            -- v11303 UNIT_SPELLCAST_* triggerred only for "player"
            -- v11303 true spellId
            -- v11303 hear only player event, no pet, no party, etc
            -- v11303 can hear Hearthstone
            local eventSuffix = string.match(event, "^UNIT_SPELLCAST_(.*)");
            if (eventSuffix) then
                local unit, castGuid, spellId = ...;
                CastCube.logSpellCastEvent(cube, unit, castGuid, spellId, eventSuffix);
            end
        end
    end);

    return cube;
end

function CastCube.logCastStart(self, eventSource, srcUnitGuid, spellId, spellName, castGuid, castStartTimeForced, castEndTimeForced)
    if (not srcUnitGuid) then
        return;
    end
    local storage = nil;
    if (eventSource == "CLEU") then
        storage = self.cleStorage;
    elseif (eventSource == "SPELLCAST") then
        storage = self.uscStorage;
    end
    if (not storage) then
        return;
    end
    spellId = spellId and spellId > 0 and spellId;
    local _spellName, _spellRank, spellIcon, castTimeMilliseconds, minRange, maxRange, _spellId = GetSpellInfo(spellId or spellName);
    if (not _spellName) then
        return;
    end

    spellName = spellName or _spellName;
    castTimeMilliseconds = castTimeMilliseconds or 10000; -- 10s for safe exit

    local castInfo = storage[srcUnitGuid] or {};
    castInfo.source = eventSource,
    castInfo.unitGuid = srcUnitGuid;
    castInfo.spellId = spellId;
    castInfo.spellName = spellName;
    castInfo.spellIcon = spellIcon;
    castInfo.castGuid = castGuid;
    castInfo.castType = nil;
    castInfo.castIsShielded = nil;
    --castInfo.castStartTime = nil;
    --castInfo.castEndTime = nil;
    --castInfo.castEndReason = nil;

    if (castStartTimeForced) then
        castInfo.castStartTime = castStartTimeForced;
        castInfo.castEndTime = castStartTimeForced + castTimeMilliseconds / 1000;
    end
    if (castEndTimeForced) then
        castInfo.castEndTime = castEndTimeForced;
    end
    if (castEndReasonForced) then
        castInfo.castEndReason = castEndReasonForced;
    end

    storage[srcUnitGuid] = castInfo;

    CastCube.shakeClient(self, srcUnitGuid, castInfo);
end

function CastCube.logCombatLogEvent(self)
    local timestamp, eventName, hidesCaster,
        srcGuid, srcName, srcFlags, srcRaidFlags,
        dstGuid, dstName, dstFlags, dstRaidFlags,
        arg12, arg13, arg14, arg15 = CombatLogGetCurrentEventInfo();

    if (eventName == "SPELL_CAST_START") then
        -- v11303 cannot hear item horse-mount, but can hear Hearthstone
        -- v11303 spellId is always 0
        local spellId, spellName, spellSchool = arg12, arg13, arg14;
        CastCube.logCastStart(self, "CLEU", srcGuid, spellId, spellName, nil, timestamp);
    elseif (eventName == "SPELL_CAST_SUCCESS") then
        CastCube.logCastStart(self, "CLEU", srcGuid, spellId, spellName, nil, nil, timestamp, "SUCC");
    elseif (eventName == "SPELL_CAST_FAILED") then
        -- distinguish self-interrupt and failed-before-start
        local failedType = arg15;
        if (failedType == SPELL_FAILED_INTERRUPTED) then
            CastCube.logCastStart(self, "CLEU", srcGuid, spellId, spellName, nil, nil, timestamp, "SELF_INTERRUPTED");
        end
    elseif (eventName == "SPELL_INTERRUPT") then
        CastCube.logCastStart(self, "CLEU", srcGuid, spellId, spellName, nil, nil, timestamp, "INTERRUPTED");
    end
end

function CastCube.logSpellCastEvent(self, srcUnit, castGuid, spellId, eventSuffix)
    local now = time();
    local srcUnitGuid = UnitGUID(srcUnit);
    local spellName, _spellRank, spellIcon, castTimeMilliseconds, minRange, maxRange, _spellId = GetSpellInfo(spellId);
    if (spellName) then
        -- it is a known spell
        local castInfo = self.uscStorage[srcUnitGuid] or {};
        castInfo.source = "SPELLCAST";
        castInfo.spellId = spellId;
        castInfo.spellName = spellName;
        castInfo.spellIcon = spellIcon;
        castInfo.castGuid = castGuid;
        castInfo.castType = nil;
        castInfo.castIsShielded = nil;
        castInfo.castStartTime = now;
        castInfo.castEndTime = now + castTimeMilliseconds / 1000;
        castInfo.castEndReason = nil;

        if (eventSuffix == "START"
            or eventSuffix == "CHANNEL_START") then
            castInfo.castStartTime = now;
            castInfo.castEndTime = now + castTimeMilliseconds / 1000;
        elseif (eventSuffix == "DELAYED"
            or eventSuffix == "CHANNEL_UPDATE") then
            castInfo.castEndTime = castInfo.castStartTime + castTimeMilliseconds / 1000;
        elseif (eventSuffix == "INTERRUPTIBLE"
            castInfo.castIsShielded = false;
            or eventSuffix == "NOT_INTERRUPTIBLE") then
            castInfo.castIsShielded = true;
        elseif (eventSuffix == "SUCCEEDED"
            or eventSuffix == "CHANNEL_STOP") then
            -- cast succeeded
            castInfo.castEndTime = now;
            castInfo.castEndReason = "SUCC";
        elseif (eventSuffix == "FAILED"
            or eventSuffix == "FAILED_QUIET"
            or eventSuffix == "INTERRUPTED") then
            castInfo.castEndTime = now;
            castInfo.castEndReason = "FAILED";
        elseif (eventSuffix == "SENT"
            or eventSuffix == "STOP") then
            -- dummy
        end

        self.uscStorage[srcUnitGuid] = castInfo;
    end
end

function CastCube.queryCleStorage(self, srcUnitGuid)
    return srcUnitGuid and self.cleStorage[srcUnitGuid];
end

function CastCube.queryUscStorage(self, srcUnitGuid)
    return srcUnitGuid and self.uscStorage[srcUnitGuid];
end

-- client should re-invoke this api when unit pointer changes and client frame show/hide
function CastCube.addClient(self, srcUnitGuid, callback)
    -- one callback can associate to only one srcUnitGuid
    local callbackKey = tostring(callback);
    for i, t in pairs(self.clients) do
        if (t) then
            t[callbackKey] = nil;
        end
    end
    if (srcUnitGuid and type(callback) == "function") then
        if (not self.clients[srcUnitGuid]) then
            -- possible: different units point to a same srcUnitGuid
            self.clients[srcUnitGuid] = {};
        end
        self.clients[srcUnitGuid][callbackKey] = callback;
    end
end

function CastCube.shakeClient(self, srcUnitGuid, castInfo)
    local t = self.clients[srcUnitGuid];
    if (t) then
        for j, fn in pairs(t) do
            fn(srcUnitGuid, castInfo);
        end
    end
end

--------

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

function CastCube.getUnitCastInfoByUnit(self, unit)
    local spellName, spellDisplayName, spellIcon, startTimeMilliseconds, endTimeMilliseconds, isTradeSkill, castGuid, notInterruptible, spellId = UnitCastingInfo(unit);
    if (spellName) then
        return {
            source = "WOWAPI",
            spellId = spellId,
            spellName = spellName,
            spellIcon = spellIcon,
            castGuid = castGuid,
            castType = "CASTING",
            castIsShielded = notInterruptible,
            castStartTime = startTimeMilliseconds / 1000,
            castEndTime = endTimeMilliseconds / 1000,
        };
    end

    local spellName, spellDisplayName, spellIcon, startTimeMilliseconds, endTimeMilliseconds, isTradeSkill, notInterruptible, spellId = UnitChannelInfo(unit);
    if (spellName) then
        return {
            source = "WOWAPI";
            spellId = spellId;
            spellName = spellName;
            spellIcon = spellIcon;
            castGuid = nil;
            castType = "CHANNELING";
            castIsShielded = notInterruptible;
            castStartTime = startTimeMilliseconds / 1000;
            castEndTime = endTimeMilliseconds / 1000;
        };
    end

    return unit and UnitExists(unit) and CastCube.query(self, UnitGUID(unit));
end

--------

CastCube.defaultInstance = CastCube.malloc();

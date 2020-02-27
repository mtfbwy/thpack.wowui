local _, unitClass = UnitClass("player");
if (unitClass ~= "WARRIOR") then
    return;
end

local dp = A and A.dp or 0.75;

local SPELL_NAME_OVERPOWER = GetSpellInfo(7384);
local SPELL_NAME_REVENGE = GetSpellInfo(6572);

local iconPlate = {
    config = {
        iconSize = 48 * dp,
        iconOffsetX = 4 * dp,
        anchorOffsetX = 160 * dp,
        anchorOffsetY = 120 * dp,
    },
    _iconFrames = {},
    _cleuHandlers = {},
};

iconPlate.driverFrame = (function(owner)
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f.owner = owner;
    f:SetSize(1, 1);
    f:SetPoint("TOPLEFT", UIParent, "CENTER", owner.config.anchorOffsetX, owner.config.anchorOffsetY);
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    f:RegisterEvent("PLAYER_DEAD");
    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            owner:_onCleuEvent(CombatLogGetCurrentEventInfo());
        elseif (event == "PLAYER_DEAD") then
            for spellName, iconFrame in pairs(owner._iconFrames) do
                owner:activateSpell(spellName, false);
            end
        end
    end);
    return f;
end)(iconPlate);

function iconPlate:_onCleuEvent(...)
    for spellName, cleuHandler in pairs(self._cleuHandlers) do
        cleuHandler(self, ...);
    end
end

function iconPlate:addSpell(spellName, cleuHandler)
    local spellName, _, spellIcon = GetSpellInfo(spellName);
    if (not spellIcon) then
        return;
    end

    local config = self.config;

    local iconFrame = self:_createIconFrame(spellName, spellIcon);
    iconFrame:SetSize(config.iconSize, config.iconSize);
    iconFrame:SetPoint("TOPLEFT", (config.iconSize + config.iconOffsetX) * table.size(self._iconFrames), 0);
    self._iconFrames[spellName] = iconFrame;
    self._cleuHandlers[spellName] = cleuHandler;
end

function iconPlate:_createIconFrame(spellName, spellIcon)
    local f = CreateFrame("Frame", nil, self.driverFrame, nil);
    f.owner = self;
    f:Hide();
    f.spellIcon = spellIcon;
    f.spellName = spellName;

    local iconView = f:CreateTexture();
    A.Frame.cropTextureRegion(iconView);
    iconView:SetTexture(spellIcon);
    iconView:SetAllPoints();
    f.iconView = iconView;

    local ttlBar = CreateFrame("StatusBar", nil, f, nil);
    ttlBar:SetStatusBarTexture(A.Res.tile32);
    ttlBar:SetStatusBarColor(0, 1, 0, 0.7);
    ttlBar:SetHeight(4);
    ttlBar:SetPoint("BOTTOMLEFT");
    ttlBar:SetPoint("BOTTOMRIGHT");
    ttlBar:SetScript("OnUpdate", function(self, elapsed)
        local iconFrame = self:GetParent();
        local endTime = iconFrame.endTime;
        if (not endTime) then
            iconFrame.owner:activateSpell(iconFrame.spellName, false);
        end

        local start, duration = GetSpellCooldown(iconFrame.spellName);
        if (start + duration > GetTime()) then
            -- in cooldown
            iconFrame:SetAlpha(0.55);
        else
            iconFrame:SetAlpha(1);
        end

        local remainingTime = endTime - time();
        if (remainingTime > 0) then
            self:SetValue(remainingTime);
        else
            iconFrame.owner:activateSpell(iconFrame.spellName, false);
        end
    end);
    f.ttlBar = ttlBar;

    return f;
end

function iconPlate:activateSpell(spellName, enabled, ttl)
    local iconFrame = self._iconFrames[spellName];
    if (iconFrame) then
        if (enabled) then
            iconFrame.endTime = time() + ttl;
            iconFrame.ttlBar:SetMinMaxValues(0, ttl);
            iconFrame:Show();
        else
            iconFrame:Hide();
            iconFrame.endTime = nil;
        end
    end

    self:_activateActionButtonGlow(spellName, enabled);
end

-- think the trigger gives a buff, which is the reagent of triggered spell
function iconPlate:_activateActionButtonGlow(spellName, enabled)
    local event = enabled and "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" or "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE";
    local actionButtonGroups = {
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarLeftButton",
        "MultiBarRightButton"
    };
    for _, g in ipairs(actionButtonGroups) do
        for i = 1, 12 do
            local actionButton = _G[g .. i];
            local handler = actionButton:GetScript("OnEvent");
            if (handler) then
                handler(actionButton, event, spellId);
            end
        end
    end
end

local MY_GUID = UnitGUID("player");

iconPlate:addSpell(SPELL_NAME_OVERPOWER, function(iconPlate, ...)
    local timestamp, eventName, hidesCaster = ...;
    local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
    local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

    local isSrcUnit = (srcGuid == MY_GUID);
    local isDstUnit = (dstGuid == MY_GUID);

    if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
        local spellId, spellName, spellSchool = select(12, ...);
        if (spellName == SPELL_NAME_OVERPOWER) then
            iconPlate:activateSpell(SPELL_NAME_OVERPOWER, false);
        end
        return;
    end

    if (isSrcUnit) then
        local missType;
        if (eventName == "SPELL_MISSED") then
            missType = select(15, ...);
        elseif (eventName == "SWING_MISSED") then
            missType = select(12, ...);
        end
        if (missType == "DODGE") then
            iconPlate:activateSpell(SPELL_NAME_OVERPOWER, true, 5);
        end
    end
end);

iconPlate:addSpell(SPELL_NAME_REVENGE, function(iconPlate, ...)
    local timestamp, eventName, hidesCaster = ...;
    local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
    local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

    local isSrcUnit = (srcGuid == MY_GUID);
    local isDstUnit = (dstGuid == MY_GUID);

    if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
        local spellId, spellName, spellSchool = select(12, ...);
        if (spellName == SPELL_NAME_REVENGE) then
            iconPlate:activateSpell(SPELL_NAME_REVENGE, false);
        end
        return;
    end

    if (isDstUnit) then
        local missType;
        if (eventName == "SPELL_MISSED") then
            missType = select(15, ...);
        elseif (eventName == "SWING_MISSED") then
            missType = select(12, ...);
        end
        if (missType == "BLOCK" or missType == "DODGE" or missType == "PARRY") then
            iconPlate:activateSpell(SPELL_NAME_REVENGE, true, 5);
        end
    end
end);

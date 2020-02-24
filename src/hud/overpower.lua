local _, unitClass = UnitClass("player");
if (unitClass ~= "WARRIOR") then
    return;
end

local SPELL_NAME_OVERPOWER = GetSpellInfo(7384);
local SPELL_NAME_REVENGE = GetSpellInfo(6572);

local function activateActionButton(spellName, enabled)
    local spellId = select(7, GetSpellInfo(spellName));
    if (not spellId) then
        return;
    end

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

-- think the trigger gives a buff, which is the reagent of triggered spell
local function activateIconFrame(iconFrame, enabled, ttl)
    if (iconFrame) then
        if (enabled) then
            iconFrame.endTime = time() + ttl;
            iconFrame.ttlBar:SetMinMaxValues(0, ttl);
            iconFrame:Show();
        else
            iconFrame:Hide();
            iconFrame.endTime = nil;
        end
        activateActionButton(iconFrame.spellName, enabled);
    end
end

local function createSpellIconFrame(parentFrame, spellName)
    local spellName, _, spellIcon = GetSpellInfo(spellName);

    local f = CreateFrame("Frame", nil, parentFrame, nil);
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
    ttlBar:SetHeight(2);
    ttlBar:SetPoint("BOTTOMLEFT");
    ttlBar:SetPoint("BOTTOMRIGHT");
    ttlBar:SetScript("OnUpdate", function(self, elapsed)
        local iconFrame = self:GetParent();
        local endTime = iconFrame.endTime;
        if (not endTime) then
            activateIconFrame(iconFrame, false);
        end

        local spellName = iconFrame.spellName;
        local start, duration = GetSpellCooldown(spellName);
        if (start + duration > GetTime()) then
            -- in cooldown
            iconFrame:SetAlpha(0.2);
        else
            iconFrame:SetAlpha(1);
        end

        local remainingTime = endTime - time();
        if (remainingTime > 0) then
            self:SetValue(remainingTime);
        else
            activateIconFrame(iconFrame, false);
        end
    end);
    f.ttlBar = ttlBar;

    return f;
end

local MY_GUID = UnitGUID("player");

local function onCleuEvent(f, ...)
    local timestamp, eventName, hidesCaster = ...;
    local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
    local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

    local isSrcUnit = (srcGuid == MY_GUID);
    local isDstUnit = (dstGuid == MY_GUID);

    if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
        local spellId, spellName, spellSchool = select(12, ...);
        if (spellName == SPELL_NAME_OVERPOWER) then
            activateIconFrame(f.overpowerIconFrame, false);
        elseif (spellName == SPELL_NAME_REVENGE) then
            activateIconFrame(f.revengeIconFrame, false);
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
            activateIconFrame(f.overpowerIconFrame, true, 5);
        end
    end

    if (isDstUnit) then
        local missType;
        if (eventName == "SPELL_MISSED") then
            missType = select(15, ...);
        elseif (eventName == "SWING_MISSED") then
            missType = select(12, ...);
        end
        if (missType == "BLOCK" or missType == "DODGE" or missType == "PARRY") then
            activateIconFrame(f.revengeIconFrame, true, 5);
        end
    end
end

local ICON_SIZE = 24;

local f = CreateFrame("Frame", nil, UIParent, nil);
f:SetSize(ICON_SIZE * 2 , ICON_SIZE);
f:SetPoint("CENTER", 20, -40);
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:SetScript("OnEvent", function(self, event, ...)
    onCleuEvent(self, CombatLogGetCurrentEventInfo());
end);

local overpowerIconFrame = createSpellIconFrame(f, SPELL_NAME_OVERPOWER);
overpowerIconFrame:SetSize(ICON_SIZE, ICON_SIZE);
overpowerIconFrame:SetPoint("TOPLEFT");
f.overpowerIconFrame = overpowerIconFrame;

local revengeIconFrame = createSpellIconFrame(f, SPELL_NAME_REVENGE);
revengeIconFrame:SetSize(ICON_SIZE, ICON_SIZE);
revengeIconFrame:SetPoint("TOPLEFT", ICON_SIZE, 0);
f.revengeIconFrame = revengeIconFrame;

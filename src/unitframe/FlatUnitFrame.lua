FlatUnitFrame = FlatUnitFrame or {};

function FlatUnitFrame.createUnitFrame(parentFrame)
    local uf = CreateFrame("Button", nil, parentFrame, nil);
    uf:SetSize(60, 20);
    uf:EnableMouse(false);
    if (parentFrame) then
        uf:SetFrameLevel(parentFrame:GetFrameLevel());
    end

    uf.eventHandlers = {};

    do
        local nameText = uf:CreateFontString(nil, "BACKGROUND", nil);
        nameText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
        nameText:SetShadowOffset(0, 0);
        nameText:SetJustifyH("CENTER");
        nameText:SetPoint("BOTTOM", uf, "BOTTOM", 0, 6); -- auto expand in x-axis
        uf.nameText = nameText;
    end

    do
        local levelText = uf:CreateFontString(nil, "BACKGROUND", nil);
        levelText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
        levelText:SetShadowOffset(0, 0);
        levelText:SetJustifyH("RIGHT");
        levelText:SetPoint("BOTTOMRIGHT", uf, "BOTTOMLEFT", -3, -3); -- XXX go with name?
        uf.levelText = levelText;
    end

    do
        local raidTargetIcon = uf:CreateTexture(nil, "ARTWORK");
        raidTargetIcon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons");
        raidTargetIcon:SetSize(32, 32);
        raidTargetIcon:SetPoint("BOTTOM", uf, "TOP", 0, 0);
        raidTargetIcon:Hide();
        uf.raidTargetIcon = raidTargetIcon;
    end

    do
        local selectionHighlight = uf:CreateTexture(nil, "BACKGROUND");
        selectionHighlight:SetTexture(A.Res.path .. "/3p/highlight.tga");
        selectionHighlight:SetVertexColor(1, 1, 1);
        selectionHighlight:SetTexCoord(0, 1, 0, 1);
        selectionHighlight:SetBlendMode("ADD");
        selectionHighlight:SetPoint("TOPLEFT", uf, "BOTTOMLEFT", 0, 4);
        selectionHighlight:SetPoint("TOPRIGHT", uf, "BOTTOMRIGHT", 0, 4);
        uf.selectionHighlight = selectionHighlight;
    end

    local function _checkUnitAndRefresh(self, unit)
        if (FlatUnitFrame._checkUnit(self, unit)) then
            -- low frequence event, refresh all for convenience
            FlatUnitFrame.refresh(self);
        end
    end

    uf.eventHandlers["main"] = {
        ["PLAYER_ENTERING_WORLD"] = FlatUnitFrame.refresh,
        ["PLAYER_TARGET_CHANGED"] = FlatUnitFrame.refreshSelectionTexture,
        ["RAID_TARGET_UPDATE"] = FlatUnitFrame.refreshRaidTargetIcon,
        ["UNIT_FACTION"] = _checkUnitAndRefresh,
        ["UNIT_LEVEL"] = _checkUnitAndRefresh,
        ["UNIT_NAME_UPDATE"] = _checkUnitAndRefresh,
        -- TODO vehicle
    };

    uf.eventHandlers["health"] = FlatUnitFrame.createHealthFrame(uf);

    return uf;
end

function FlatUnitFrame._checkUnit(uf, unit)
    return unit == FlatUnitFrame.getUnit(uf);
end

function FlatUnitFrame.getUnit(uf)
    return uf:GetAttribute("unit");
end

function FlatUnitFrame.setUnit(uf, unit)
    unit = unit and string.lower(unit);
    uf:SetAttribute("unit", unit);
end

function FlatUnitFrame.start(uf)
    for _, events in pairs(uf.eventHandlers) do
        for k, v in pairs(events) do
            uf:RegisterEvent(k);
        end
    end
    uf:SetScript("OnEvent", function(self, event, ...)
        for _, events in pairs(uf.eventHandlers) do
            local fn = events[event];
            if (type(fn) == "function") then
                fn(self, ...);
            end
        end
    end);

    FlatUnitFrame.refresh(uf);
    uf:Show();
end

function FlatUnitFrame.stop(uf)
    uf:Hide();
    uf:UnregisterAllEvents();
    uf:SetScript("OnEvent", nil);
end

function FlatUnitFrame.refresh(uf, unit)
    local unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit or not UnitExists(unit)) then
        return;
    end

    FlatUnitFrame.refreshNameText(uf, unit);

    FlatUnitFrame.refreshLevelText(uf, unit);

    FlatUnitFrame.refreshRaidTargetIcon(uf, unit);

    FlatUnitFrame.refreshSelectionTexture(uf, unit);

    FlatUnitFrame.refreshHealth(uf, unit);
end

function FlatUnitFrame.refreshNameText(uf, unit)
    local nameText = uf.nameText;
    if (not nameText) then
        return;
    end

    if (UnitIsUnit(unit, "player")) then
        nameText:SetText(nil);
    else
        local name = GetUnitName(unit);
        local nameColor = A.getUnitNameColorByUnit(unit);
        nameText:SetText(name);
        nameText:SetVertexColor(nameColor:toVertex());
    end
end

function FlatUnitFrame.refreshLevelText(uf, unit)
    local levelText = uf.levelText;
    if (not levelText) then
        return;
    end

    local myLevel = UnitLevel("player");
    local unitLevel = UnitLevel(unit);
    local unitLevelSuffix = A.getUnitLevelSuffixByUnit(unit);
    if (unitLevel == -1) then
        levelText:SetText(A.getUnitLevelSkullTextureString(18));
    elseif (myLevel == MAX_PLAYER_LEVEL and unitLevel == MAX_PLAYER_LEVEL and unitLevelSuffix == "") then
        levelText:SetText(nil);
    else
        levelText:SetText(unitLevel .. unitLevelSuffix);
        levelText:SetVertexColor(A.getUnitLevelColorByUnit(unit):toVertex());
    end
end

function FlatUnitFrame.refreshRaidTargetIcon(uf, unit)
    local raidTargetIcon = uf.raidTargetIcon;
    if (not raidTargetIcon) then
        return;
    end

    unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit or not UnitExists(unit)) then
        return;
    end

    local index = GetRaidTargetIndex(unit);
    if (index) then
        SetRaidTargetIconTexture(raidTargetIcon, index);
        raidTargetIcon:Show();
    else
        raidTargetIcon:Hide();
    end
end

function FlatUnitFrame.refreshSelectionTexture(uf, unit)
    local selectionHighlight = uf.selectionHighlight;
    if (not selectionHighlight) then
        return;
    end

    unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit or not UnitExists(unit)) then
        return;
    end

    local isSelected = UnitIsUnit(unit, "target");
    if (isSelected) then
        selectionHighlight:SetVertexColor(1, 1, 1, 0.2);
        selectionHighlight:Show();
    else
        selectionHighlight:Hide();
    end
end

----------------
-- health

function FlatUnitFrame.createHealthFrame(uf)
    local healthFrame = CreateFrame("Frame", nil, uf, nil);
    uf.healthFrame = healthFrame;

    local healthBar = CreateFrame("StatusBar", nil, healthFrame, nil);
    healthBar:SetFrameStrata("BACKGROUND");
    healthBar:SetFrameLevel(1);
    healthBar:SetMinMaxValues(0, 1);
    healthBar:SetStatusBarTexture(A.Res.healthbar32);
    healthBar:SetBackdrop({
        bgFile = A.Res.tile32,
    });
    healthBar:SetBackdropColor(0, 0, 0, 0.85);
    healthBar:SetSize(60, 4);
    healthBar:SetPoint("BOTTOM", uf, "BOTTOM", 0, 0);
    healthFrame.healthBar = healthBar;

    local healthGlowFrame = A.Frame.createBorderFrame(healthBar, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 5,
    });
    healthGlowFrame:SetBackdropBorderColor(0, 0, 0, 0.7);
    healthFrame.glowFrame = healthGlowFrame;

    -- TODO health bar glow for threat level

    local healthText = healthFrame:CreateFontString(nil, "ARTWORK", nil);
    healthText:SetFont(A.Res.path .. "/3p/impact.ttf", 12, "OUTLINE");
    healthText:SetVertexColor(1, 1, 1);
    healthText:SetShadowOffset(0, 0);
    healthText:SetJustifyH("LEFT");
    healthText:SetPoint("LEFT", healthBar, "RIGHT", 2, 1);
    healthFrame.healthText = healthText;

    return {
        ["PLAYER_REGEN_ENABLED"] = FlatUnitFrame.refreshHealth,
        ["PLAYER_REGEN_DISABLED"] = FlatUnitFrame.refreshHealth,
        ["UNIT_HEALTH_FREQUENT"] = function(self, ...)
            local unit = ...;
            if (FlatUnitFrame._checkUnit(self, unit)) then
                FlatUnitFrame.refreshHealth(self, unit);
            end
        end,
    };
end

function FlatUnitFrame.refreshHealth(uf, unit)
    local healthFrame = uf.healthFrame;
    if (not healthFrame) then
        return;
    end

    local unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local currentHealth = UnitHealth(unit);
    local maxHealth = UnitHealthMax(unit);
    local healthRate = currentHealth / maxHealth;

    local healthBar = healthFrame.healthBar;
    if (healthBar) then
        healthBar:SetValue(healthRate);
        if (UnitIsPlayer(unit) and UnitIsEnemy("player", unit)) then
            healthBar:SetStatusBarColor(A.getUnitClassColorByUnit(unit):toVertex());
        else
            healthBar:SetStatusBarColor(A.getUnitNameColorByUnit(unit):toVertex());
        end
    end

    local healthText = healthFrame.healthText;
    if (healthText) then
        local percentage = math.floor(healthRate * 100);
        if (percentage == 100 and not UnitAffectingCombat("player")) then
            healthText:SetText(nil);
        else
            healthText:SetText(percentage);
            healthText:SetVertexColor(A.getUnitHealthColorByRate(healthRate):toVertex());
        end
    end
end

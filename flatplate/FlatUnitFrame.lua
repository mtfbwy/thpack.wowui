addonName, addon = ...;

local FrameBook = addon.FrameBook;

if (FlatUnitFrame) then
    return;
end

FlatUnitFrame = {};

-- it is for name plate.
-- name plate does not parent to UIParent; set scale for pixel perfect
function FlatUnitFrame.createBaseFrame(parentFrame)
    local uf = CreateFrame("Button", nil, parentFrame, nil);
    uf:SetScale(UIParent:GetScale());
    uf:SetSize(60, 20);
    uf:EnableMouse(false);
    if (parentFrame) then
        uf:SetFrameLevel(parentFrame:GetFrameLevel());
    end

    uf.modules = {};
    return uf;
end

function FlatUnitFrame.getUnit(uf)
    return uf:GetAttribute("unit");
end

function FlatUnitFrame.setUnit(uf, unit)
    unit = unit and string.lower(unit);
    uf:SetAttribute("unit", unit);
end

function FlatUnitFrame._checkUnit(uf, unit)
    return unit == FlatUnitFrame.getUnit(uf);
end

function FlatUnitFrame.addModule(uf, name, createView)
    uf.modules[name] = { createView(uf) };
end

function FlatUnitFrame.createUnitFrame(parentFrame)
    local uf = FlatUnitFrame.createBaseFrame(parentFrame);
    uf.modules["main"] = {
        nil,
        {
            ["PLAYER_ENTERING_WORLD"] = FlatUnitFrame._refresh,
            -- low frequence event, refresh all for convenience
            ["UNIT_FACTION"] = FlatUnitFrame._checkUnitAndRefresh,
            ["UNIT_LEVEL"] = FlatUnitFrame._checkUnitAndRefresh,
            ["UNIT_NAME_UPDATE"] = FlatUnitFrame._checkUnitAndRefresh,
            -- TODO vehicle
        },
    };

    FlatUnitFrame.addModule(uf, "name", FlatUnitFrame.createNameText);
    FlatUnitFrame.addModule(uf, "raidTarget", FlatUnitFrame.createRaidTargetIcon);
    FlatUnitFrame.addModule(uf, "selection", FlatUnitFrame.createSelectionTexture);
    FlatUnitFrame.addModule(uf, "health", FlatUnitFrame.createHealthFrame);

    return uf;
end

function FlatUnitFrame._checkUnitAndRefresh(uf, unit)
    if (FlatUnitFrame._checkUnit(uf, unit)) then
        FlatUnitFrame._refresh(uf);
    end
end

function FlatUnitFrame._refresh(uf, unit)
    local unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit or not UnitExists(unit)) then
        return;
    end

    for _, module in pairs(uf.modules) do
        local f = module and module[1];
        if (f) then
            f(uf, unit);
        end
    end
end

function FlatUnitFrame.start(uf)
    for _, module in pairs(uf.modules) do
        local events = module and module[2];
        if (events) then
            for k, _ in pairs(events) do
                uf:RegisterEvent(k);
            end
        end
    end
    uf:SetScript("OnEvent", FlatUnitFrame._onEvent);

    FlatUnitFrame._refresh(uf);
    uf:Show();
end

function FlatUnitFrame.stop(uf)
    uf:Hide();
    uf:UnregisterAllEvents();
    uf:SetScript("OnEvent", nil);
end

function FlatUnitFrame._onEvent(uf, event, ...)
    for _, module in pairs(uf.modules) do
        local events = module and module[2];
        local f = events and events[event];
        if (f) then
            f(uf, ...);
        end
    end
end

----------------
-- unit name, level, gender, race, etc

function FlatUnitFrame.createNameText(uf)
    local nameText = uf:CreateFontString(nil, "BACKGROUND", nil);
    nameText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    nameText:SetShadowOffset(0, 0);
    nameText:SetJustifyH("CENTER");
    nameText:SetPoint("BOTTOM", uf, "BOTTOM", 0, 6); -- auto expand in x-axis
    uf.nameText = nameText;

    local levelText = uf:CreateFontString(nil, "BACKGROUND", nil);
    levelText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    levelText:SetShadowOffset(0, 0);
    levelText:SetJustifyH("RIGHT");
    levelText:SetPoint("BOTTOMRIGHT", uf, "BOTTOMLEFT", -3, -3); -- XXX go with name?
    uf.levelText = levelText;

    return FlatUnitFrame._refreshNameText;
end

function FlatUnitFrame._refreshNameText(uf, unit)
    unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local nameText = uf.nameText;
    if (nameText) then
        if (UnitIsUnit(unit, "player")) then
            nameText:SetText(nil);
        else
            local name = GetUnitName(unit);
            local nameColor = A.getUnitNameColorByUnit(unit);
            nameText:SetText(name);
            nameText:SetVertexColor(nameColor:toVertex());
        end
    end

    local levelText = uf.levelText;
    if (levelText) then
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
end

----------------
-- raid target icon

function FlatUnitFrame.createRaidTargetIcon(uf)
    local raidTargetIcon = uf:CreateTexture(nil, "ARTWORK");
    raidTargetIcon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons");
    raidTargetIcon:SetSize(32, 32);
    raidTargetIcon:SetPoint("BOTTOM", uf, "TOP", 0, 0);
    raidTargetIcon:Hide();
    uf.raidTargetIcon = raidTargetIcon;

    return FlatUnitFrame._refreshRaidTargetIcon, {
        ["RAID_TARGET_UPDATE"] = FlatUnitFrame._refreshRaidTargetIcon,
    };
end

function FlatUnitFrame._refreshRaidTargetIcon(uf, unit)
    local raidTargetIcon = uf.raidTargetIcon;
    if (not raidTargetIcon) then
        return;
    end

    unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit) then
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

----------------
-- selection

function FlatUnitFrame.createSelectionTexture(uf)
    local selectionTexture = uf:CreateTexture(nil, "BACKGROUND");
    selectionTexture:SetTexture(A.Res.path .. "/3p/highlight.tga");
    selectionTexture:SetVertexColor(1, 1, 1);
    selectionTexture:SetTexCoord(0, 1, 0, 1);
    selectionTexture:SetBlendMode("ADD");
    selectionTexture:SetPoint("TOPLEFT", uf, "BOTTOMLEFT", 0, 4);
    selectionTexture:SetPoint("TOPRIGHT", uf, "BOTTOMRIGHT", 0, 4);
    uf.selectionTexture = selectionTexture;

    return FlatUnitFrame._refreshSelectionTexture, {
        ["PLAYER_TARGET_CHANGED"] = FlatUnitFrame._refreshSelectionTexture,
    };
end

function FlatUnitFrame._refreshSelectionTexture(uf, unit)
    local selectionTexture = uf.selectionTexture;
    if (not selectionTexture) then
        return;
    end

    unit = unit or FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local isSelected = UnitIsUnit(unit, "target");
    if (isSelected) then
        selectionTexture:SetVertexColor(1, 1, 1, 0.2);
        selectionTexture:Show();
    else
        selectionTexture:Hide();
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

    local healthGlowFrame = FrameBook.createBorderFrame(healthBar, {
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

    return FlatUnitFrame._refreshHealthFrame, {
        ["PLAYER_REGEN_ENABLED"] = FlatUnitFrame._refreshHealthFrame,
        ["PLAYER_REGEN_DISABLED"] = FlatUnitFrame._refreshHealthFrame,
        ["UNIT_HEALTH_FREQUENT"] = FlatUnitFrame._checkUnitAndRefreshHealthFrame,
    };
end

function FlatUnitFrame._checkUnitAndRefreshHealthFrame(uf, unit)
    if (FlatUnitFrame._checkUnit(uf, unit)) then
        FlatUnitFrame._refreshHealthFrame(uf, unit);
    end
end

function FlatUnitFrame._refreshHealthFrame(uf, unit)
    local healthFrame = uf.healthFrame;
    if (not healthFrame) then
        return;
    end

    unit = unit or FlatUnitFrame.getUnit(uf);
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

----------------
-- cast

local function _tickCast(castFrame, elapsed)
    local uf = castFrame:GetParent();

    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local currentTime = time();
    local castInfo = castFrame.castInfo;
    if (not castInfo) then
        FlatUnitFrame._clearCast(uf);
        return;
    elseif (castInfo.castEndTimePossible and castInfo.castEndTimePossible <= currentTime) then
        FlatUnitFrame._clearCast(uf);
        return;
    elseif (not castInfo.castEndTime) then
        -- casting, but no eta
        -- dummy
        return;
    elseif (castInfo.castEndTime <= currentTime) then
        FlatUnitFrame._clearCast(uf);
        return;
    end

    -- progressing
    local totalSeconds = castInfo.castEndTime - castInfo.castStartTime;
    local elapsedSeconds = currentTime - castInfo.castStartTime;
    local rate = elapsedSeconds / totalSeconds;
    if (rate > 1) then
        rate = 1;
    end

    local castBar = castFrame.castBar;
    if (castBar) then
        if (castInfo.castProgressing == "CASTING") then
            castBar:SetValue(rate);
        elseif (castInfo.castProgressing == "CHANNELING") then
            castBar:SetValue(1 - rate);
        end
    end

    local castCountdownText = castFrame.castCountdownText;
    if (castCountdownText) then
        castCountdownText:SetFormattedText("%.1f", totalSeconds - elapsedSeconds);
    end
end

function FlatUnitFrame.createCastFrame(uf)
    local castFrame = CreateFrame("Frame", nil, uf, nil);
    castFrame:Hide();
    uf.castFrame = castFrame;

    local spellIconFrame = CreateFrame("Frame", nil, castFrame, nil);
    spellIconFrame:SetFrameStrata("MEDIUM");
    spellIconFrame:SetFrameLevel(2);
    spellIconFrame:SetBackdrop({
        bgFile = A.Res.tile32,
        insets = {
            left = -1,
            right = -1,
            top = -1,
            bottom = -1,
        },
    });
    spellIconFrame:SetBackdropColor(0, 0, 0, 0.85);
    spellIconFrame:SetSize(18, 18);
    spellIconFrame:SetPoint("BOTTOMRIGHT", uf, "BOTTOM", -34, -3);
    castFrame.spellIconFrame = spellIconFrame;

    local spellIcon = spellIconFrame:CreateTexture(nil, "ARTWORK", nil, 1);
    A.cropTextureRegion(spellIcon);
    spellIcon:SetAllPoints();
    spellIcon:SetTexture(A.Res.healthbar32);
    castFrame.spellIcon = spellIcon;

    local castGlowFrame = A.createBorderFrame(spellIconFrame, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 5,
    }, 1);
    castFrame.glowFrame = castGlowFrame;

    local spellNameText = castFrame:CreateFontString(nil, "BACKGROUND", nil);
    spellNameText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    spellNameText:SetShadowOffset(0, 0);
    spellNameText:SetJustifyH("LEFT");
    spellNameText:SetPoint("BOTTOMLEFT", uf, "BOTTOMLEFT", 0, 6);
    castFrame.spellNameText = spellNameText;

    -- castBar placeholder

    castFrame:SetScript("OnUpdate", _tickCast);

    return nil, {
        ["UNIT_SPELLCAST_CHANNEL_START"] = FlatUnitFrame._onInitCast,
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = FlatUnitFrame._onStopCast,
        ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = FlatUnitFrame._onInitCast,
        ["UNIT_SPELLCAST_DELAYED"] = FlatUnitFrame._onInitCast,
        ["UNIT_SPELLCAST_FAILED"] = FlatUnitFrame._onStopCast,
        ["UNIT_SPELLCAST_FAILED_QUIET"] = FlatUnitFrame._onStopCast,
        ["UNIT_SPELLCAST_INTERRUPTED"] = FlatUnitFrame._onStopCast,
        --["UNIT_SPELLCAST_INTERRUPTIBLE"] =
        --["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] =
        ["UNIT_SPELLCAST_START"] = FlatUnitFrame._onInitCast,
        ["UNIT_SPELLCAST_STOP"] = FlatUnitFrame._onStopCast,
        ["UNIT_SPELLCAST_SUCCEEDED"] = FlatUnitFrame._onStopCast,
    };
end

function FlatUnitFrame._onInitCast(uf, ...)
    -- 11303 UNIT_SPELLCAST_* triggerred only for "player"
    -- 11303 true spellId
    -- 11303 hear only player event, no pet, no party, etc
    -- 11303 can hear Hearthstone
    local unit, castGuid, spellId = ...;
end

function FlatUnitFrame._onStopCast(uf, ...)
    local unit, castGuid, spellId = ...;
    local reason = string.match(event, "^UNIT_SPELLCAST_(.*)");
end

function FlatUnitFrame._initCast(uf, castInfo)
    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local castFrame = uf.castFrame;
    if (not castFrame) then
        return;
    end

    if (not castInfo) then
        return;
    end

    local currentTime = time();
    if (castInfo.castEndTimePossible and castInfo.castEndTimePossible <= currentTime) then
        FlatUnitFrame._clearCast(uf);
        return;
    elseif (castInfo.castEndTime and castInfo.castEndTime <= currentTime) then
        FlatUnitFrame._clearCast(uf);
        return;
    end

    -- accept this castInfo?
    if (not castFrame.castInfo) then
        -- dummy
    elseif (castInfo.castProgress) then
        -- UnitCastingInfo
        -- dummy
    elseif (castInfo.castGuid) then
        -- UNIT_SPELLCAST_*
        -- dummy
    elseif (castInfo == castFrame.castInfo) then
        return;
    elseif (castFrame.castInfo.castProgress) then
        return;
    elseif (castFrame.castInfo.castGuid) then
        return;
    elseif (castInfo.castEndReason == "INSTANT_SUCCEEDED") then
        -- re-use this castInfo to play a quick animation
        castInfo.castEndTime = castInfo.castEndTime + 0.2;
        castInfo.castIsShielded = true;
    end

    castFrame.castInfo = castInfo;

    local spellNameText = castFrame.spellNameText;
    if (spellNameText) then
        spellNameText:SetText(castInfo.spellName);
    end

    local spellIcon = castFrame.spellIcon;
    if (spellIcon) then
        spellIcon:SetTexture(castInfo.spellIcon);
    end

    local castGlowFrame = castFrame.glowFrame;
    if (castGlowFrame) then
        if (castInfo.castIsShielded) then
            -- iron color
            castGlowFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.7);
        else
            castGlowFrame:SetBackdropBorderColor(0, 0, 0, 0.7);
        end
    end

    local castBar = castFrame.castBar;
    if (castBar) then
        if (not castInfo.castEndTime) then
            castBar:Hide();
        else
            castBar:Show();
        end
        if (castInfo.castProgressing == "CASTING") then
            castBar:SetStatusBarColor(Color.pick("Gold"):toVertex());
        elseif (castInfo.castProgressing == "CHANNELING") then
            castBar:SetStatusBarColor(Color.pick("Green"):toVertex());
        else
            castBar:SetStatusBarColor(Color.pick("Blue"):toVertex());
        end
    end

    local castCountdownText = castFrame.castCountdownText;
    if (castCountdownText) then
        castCountdownText:SetText(nil);
    end

    castFrame:Show();
end

function FlatUnitFrame._clearCast(uf)
    local castFrame = uf.castFrame;
    if (castFrame) then
        castFrame:Hide();
        castFrame.castInfo = nil;
    end
end

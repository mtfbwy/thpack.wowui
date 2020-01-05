FlatUnitFrame = FlatUnitFrame or {};

function FlatUnitFrame.createUnitFrame(parentFrame)
    local uf = CreateFrame("Button", nil, parentFrame, nil);
    uf:EnableMouse(false);
    if (parentFrame) then
        uf:SetFrameLevel(parentFrame:GetFrameLevel());
    end

    uf.eventHandlers = {};

    local healthBar, healthEventHandler = FlatUnitFrame.createHealthBar(uf);
    healthBar:SetSize(60, 4);
    healthBar:SetPoint("BOTTOM", uf, "BOTTOM", 0, 0);
    uf.healthBar = healthBar;
    uf.eventHandlers["health"] = healthEventHandler;

    local castBar, castFrame, castEventHandler = FlatUnitFrame.createCastBar(uf);
    if (castBar) then
        castBar:SetHeight(2);
        castBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, 1);
        castBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, 1);
        castBar:Hide();
        uf.castBar = castBar;
    end
    if (castFrame) then
        castFrame:SetSize(18, 18);
        castFrame:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMLEFT", -4, -3);
        castFrame:Hide();
        uf.castFrame = castFrame;
    end
    uf.eventHandlers["cast"] = castEventHandler;

    local nameTextRegion = uf:CreateFontString(nil, "BACKGROUND", nil);
    nameTextRegion:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    nameTextRegion:SetShadowOffset(0, 0);
    nameTextRegion:SetJustifyH("CENTER");
    nameTextRegion:SetPoint("BOTTOM", healthBar, "TOP", 0, 2);
    uf.nameTextRegion = nameTextRegion;

    local levelTextRegion = uf:CreateFontString(nil, "BACKGROUND", nil);
    levelTextRegion:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    levelTextRegion:SetShadowOffset(0, 0);
    levelTextRegion:SetJustifyH("RIGHT");
    -- logically should to the left of name, but it not balanced in appearance
    levelTextRegion:SetPoint("RIGHT", healthBar, "LEFT", -2, 1);
    uf.levelTextRegion = levelTextRegion;

    local raidMarkTextureRegion = uf:CreateTexture(nil, "ARTWORK");
    raidMarkTextureRegion:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons");
    raidMarkTextureRegion:SetSize(32, 32);
    raidMarkTextureRegion:SetPoint("BOTTOM", uf, "TOP", 0, 0);
    raidMarkTextureRegion:Hide();
    uf.raidMarkTextureRegion = raidMarkTextureRegion;

    local selectionHighlightTextureRegion = uf:CreateTexture(nil, "BACKGROUND");
    selectionHighlightTextureRegion:SetTexture(A.Res.path .. "/3p/highlight.tga");
    selectionHighlightTextureRegion:SetVertexColor(1, 1, 1);
    selectionHighlightTextureRegion:SetTexCoord(0, 1, 0, 1);
    selectionHighlightTextureRegion:SetBlendMode("ADD");
    selectionHighlightTextureRegion:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0);
    selectionHighlightTextureRegion:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
    uf.selectionHighlightTextureRegion = selectionHighlightTextureRegion;

    local function _checkUnitAndUpdate(self, ...)
        local unit = ...;
        if (unit == FlatUnitFrame.getUnit(self)) then
            -- low frequence event, update all for convenience
            FlatUnitFrame.update(self);
        end
    end

    local events = {
        ["PLAYER_ENTERING_WORLD"] = FlatUnitFrame.update,
        ["PLAYER_TARGET_CHANGED"] = FlatUnitFrame.updateSelection,
        ["UNIT_FACTION"] = _checkUnitAndUpdate,
        ["UNIT_LEVEL"] = _checkUnitAndUpdate,
        ["UNIT_NAME_UPDATE"] = _checkUnitAndUpdate,
        ["RAID_TARGET_UPDATE"] = FlatUnitFrame.updateRaidMark,
        -- TODO vehicle
    };

    uf.eventHandlers["main"] = events;

    return uf;
end

function FlatUnitFrame.createHealthBar(uf)
    local healthBar = CreateFrame("StatusBar", nil, uf, nil);
    healthBar:SetFrameStrata("BACKGROUND");
    healthBar:SetFrameLevel(1);
    healthBar:SetMinMaxValues(0, 1);
    healthBar:SetStatusBarTexture(A.Res.healthbar32);
    healthBar:SetBackdrop({
        bgFile = A.Res.tile32,
    });
    healthBar:SetBackdropColor(0, 0, 0, 0.85);

    local healthBarGlowFrame = A.Frame.createBorderFrame(healthBar, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 5,
    });
    healthBarGlowFrame:SetBackdropBorderColor(0, 0, 0, 0.7);
    healthBar.glowFrame = healthBarGlowFrame;
    -- TODO health bar glow for threat level

    local healthTextRegion = uf:CreateFontString(nil, "ARTWORK", nil);
    healthTextRegion:SetFont(A.Res.path .. "/3p/impact.ttf", 12, "OUTLINE");
    healthTextRegion:SetVertexColor(1, 1, 1);
    healthTextRegion:SetShadowOffset(0, 0);
    healthTextRegion:SetJustifyH("LEFT");
    -- no left/right point so it expands with content
    -- to the right due to flat is in narrow style
    healthTextRegion:SetPoint("LEFT", healthBar, "RIGHT", 2, 0);
    uf.healthTextRegion = healthTextRegion;

    local function _checkUnitAndUpdateHealth(self, ...)
        local unit = ...;
        if (unit == FlatUnitFrame.getUnit(self)) then
            FlatUnitFrame.updateHealth(self);
        end
    end

    local events = {
        ["PLAYER_REGEN_ENABLED"] = FlatUnitFrame.updateHealth,
        ["PLAYER_REGEN_DISABLED"] = FlatUnitFrame.updateHealth,
        ["UNIT_HEALTH_FREQUENT"] = _checkUnitAndUpdateHealth,
    };

    return healthBar, events;
end

function FlatUnitFrame.createCastBar(uf)
    --local castBar = CreateFrame("StatusBar", nil, uf, nil);
    --castBar:SetFrameStrata("MEDIUM");
    --castBar:SetFrameLevel(1);
    --castBar:SetMinMaxValues(0, 1);
    --castBar:SetStatusBarTexture(A.Res.path .. "/3p/norm.tga");

    local castFrame = CreateFrame("Frame", nil, uf, nil);
    castFrame:SetFrameStrata("MEDIUM");
    castFrame:SetFrameLevel(1);
    castFrame:SetBackdrop({
        bgFile = A.Res.tile32,
        insets = {
            left = -1,
            right = -1,
            top = -1,
            bottom = -1,
        },
    });
    castFrame:SetBackdropColor(0, 0, 0, 0.85);

    castFrame:SetScript("OnUpdate", function(self, elapsed)
        local uf = self:GetParent();
        local unit = FlatUnitFrame.getUnit(uf);
        if (not unit) then
            return;
        end

        if (not self.castInfo) then
            local castInfo = A.getUnitCastInfoByUnit(unit);
            if (not castInfo) then
                -- there may be a delay on setting cast info
                return;
            end
            -- init cast

            local spellIconTextureRegion = self.spellIconTextureRegion;
            if (spellIconTextureRegion) then
                spellIconTextureRegion:SetTexture(castInfo.spellIcon);
            end

            local castGlowFrame = self.glowFrame;
            if (castGlowFrame) then
                if (castInfo.castIsShielded) then
                    -- XXX gold for iron?
                    castGlowFrame:SetBackdropBorderColor(Color.pick("#ffd700cc"):toVertex());
                    --castGlowFrame:Show();
                else
                    castGlowFrame:SetBackdropBorderColor(0, 0, 0, 0.7);
                end
            end

            local spellNameTextRegion = self.spellNameTextRegion;
            if (spellNameTextRegion) then
                spellNameTextRegion:SetText(castInfo.spellName);
            end

            local castBar = uf.castBar;
            if (castBar) then
                if (castInfo.castProgressing == "CASTING") then
                    castBar:SetStatusBarColor(Color.pick("gold"):toVertex());
                elseif (castInfo.castProgressing == "CHANNELING") then
                    castBar:SetStatusBarColor(Color.pick("green"):toVertex());
                else
                    castBar:SetStatusBarColor(Color.pick("blue"):toVertex());
                end
            end

            self.castInfo = castInfo;
        end

        local castInfo = self.castInfo;
        local currentTime = GetTime();
        if (not castInfo.castEndTime) then
            -- it does not tell when to end
            -- dummy
        elseif (currentTime < castInfo.castEndTime) then
            local totalSeconds = castInfo.castEndTime - castInfo.castStartTime;
            local elapsedSeconds = currentTime - castInfo.castStartTime;
            local rate = elapsedSeconds / totalSeconds;
            if (rate > 1) then
                rate = 1;
            end

            local castBar = uf.castBar;
            if (castBar) then
                if (castInfo.castProgressing == "CASTING") then
                    castBar:SetValue(rate);
                elseif (castInfo.castProgressing == "CHANNELING") then
                    castBar:SetValue(1 - rate);
                end
                local castCountdownTextRegion = castBar.castCountdownTextRegion;
                if (castCountdownTextRegion) then
                    castCountdownTextRegion:SetFormattedText("%.1f", totalSeconds - elapsedSeconds);
                end
            end
        else
            -- do not end cast; leave to cast end event
            -- dummy
        end
    end);

    local spellIconTextureRegion = castFrame:CreateTexture(nil, "ARTWORK", nil, 1);
    A.Frame.cropTextureRegion(spellIconTextureRegion);
    spellIconTextureRegion:SetAllPoints();
    spellIconTextureRegion:SetTexture(A.Res.healthbar32);
    castFrame.spellIconTextureRegion = spellIconTextureRegion;

    local castGlowFrame = A.Frame.createBorderFrame(castFrame, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 5,
    }, 1);
    castFrame.glowFrame = castGlowFrame;

    local function _checkUnit(self, ...)
        local unit = ...;
        return unit == FlatUnitFrame.getUnit(self);
    end

    local function _checkUnitAndStartCast(self, ...)
        local unit, castGuid, spellId = ...;
        if (_checkUnit(self, ...)) then
            FlatUnitFrame.startCast(self);
        end
    end

    local function _checkUnitAndEndCast(self, ...)
        if (_checkUnit(self, ...)) then
            FlatUnitFrame.endCast(self);
        end
    end

    local events = {
        ["PET_ATTACK_START"] = function(self, ...)
            local unit = "pet";
            if (UnitIsUnit(unit, FlatUnitFrame.getUnit(self))) then
                FlatUnitFrame.startCast(self);
            end
        end,
        ["PET_ATTACK_STOP"] = function(self, ...)
            local unit = "pet";
            if (UnitIsUnit(unit, FlatUnitFrame.getUnit(self))) then
                FlatUnitFrame.endCast(self);
            end
        end,
        ["UNIT_SPELLCAST_CHANNEL_START"] = _checkUnitAndStartCast,
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = function(self, ...)
            if (_checkUnit(self, ...)) then
                FlatUnitFrame.endCast(self, "SUCCEEDED");
            end
        end,
        --["UNIT_SPELLCAST_CHANNEL_UPDATE"] = TODO,
        --["UNIT_SPELLCAST_DELAYED"] = TODO,
        ["UNIT_SPELLCAST_FAILED"] = function(self, ...)
            if (_checkUnit(self, ...)) then
                FlatUnitFrame.endCast(self, "FAILED");
            end
        end,
        ["UNIT_SPELLCAST_FAILED_QUIET"] = function(self, ...)
            if (_checkUnit(self, ...)) then
                FlatUnitFrame.endCast(self, "FAILED");
            end
        end,
        ["UNIT_SPELLCAST_INTERRUPTED"] = function(self, ...)
            if (_checkUnit(self, ...)) then
                FlatUnitFrame.endCast(self, "INTERRUPTED");
            end
        end,
        --["UNIT_SPELLCAST_INTERRUPTIBLE"] = _checkUnitAndStartCast,
        --["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = _checkUnitAndStartCast,
        ["UNIT_SPELLCAST_START"] = _checkUnitAndStartCast,
        ["UNIT_SPELLCAST_STOP"] = _checkUnitAndEndCast,
        ["UNIT_SPELLCAST_SUCCEEDED"] = function(self, ...)
            if (_checkUnit(self, ...)) then
                FlatUnitFrame.endCast(self, "SUCCEEDED");
            end
        end,
    };

    return castBar, castFrame, events;
end

function FlatUnitFrame.getUnit(uf)
    return uf:GetAttribute("unit");
end

function FlatUnitFrame.setUnit(uf, unit)
    uf:SetAttribute("unit", unit and string.lower(unit));
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
    uf:Show();
    FlatUnitFrame.update(uf);
end

function FlatUnitFrame.stop(uf)
    uf:Hide();
    uf:UnregisterAllEvents();
    uf:SetScript("OnEvent", nil);
end

function FlatUnitFrame.update(uf)
    FlatUnitFrame.updateHealth(uf);
    FlatUnitFrame.updateName(uf);
    FlatUnitFrame.updateLevel(uf);
    FlatUnitFrame.updateRaidMark(uf);
    FlatUnitFrame.updateSelection(uf);
end

function FlatUnitFrame.startCast(uf)
    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local castFrame = uf.castFrame;
    if (castFrame) then
        castFrame:Show();
    end

    local castBar = uf.castBar;
    if (castBar) then
        castBar:Show();
    end
end

function FlatUnitFrame.endCast(uf, reason)
    -- TODO animation for succeeded, failed, interrupted, etc
    local castFrame = uf.castFrame;
    if (castFrame) then
        castFrame:Hide();
        castFrame.castInfo = nil;
    end

    local castBar = uf.castBar;
    if (castBar) then
        castBar:Hide();
    end
end

function FlatUnitFrame.updateHealth(uf)
    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local currentHealth = UnitHealth(unit);
    local maxHealth = UnitHealthMax(unit);
    local healthRate = currentHealth / maxHealth;

    local healthBar = uf.healthBar;
    if (healthBar) then
        healthBar:SetValue(healthRate);
        if (UnitIsPlayer(unit) and UnitIsEnemy("player", unit)) then
            healthBar:SetStatusBarColor(A.getUnitClassColorByUnit(unit):toVertex());
        else
            healthBar:SetStatusBarColor(A.getUnitNameColorByUnit(unit):toVertex());
        end
    end

    local healthTextRegion = uf.healthTextRegion;
    if (healthTextRegion) then
        local percentage = math.floor(healthRate * 100);
        if (percentage == 100 and not UnitAffectingCombat("player")) then
            healthTextRegion:SetText();
        else
            healthTextRegion:SetText(percentage);
            local healthColor = A.getUnitHealthColor(healthRate);
            healthTextRegion:SetVertexColor(healthColor:toVertex());
        end
    end
end

function FlatUnitFrame.updateName(uf)
    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local nameTextRegion = uf.nameTextRegion;
    if (nameTextRegion) then
        if (UnitIsUnit(unit, "player")) then
            nameTextRegion:SetText();
        else
            local nameString = GetUnitName(unit);
            local nameColor = A.getUnitNameColorByUnit(unit);
            nameTextRegion:SetText(nameString);
            nameTextRegion:SetVertexColor(nameColor:toVertex());
        end
    end
end

function FlatUnitFrame.updateLevel(uf)
    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local levelTextRegion = uf.levelTextRegion;
    if (levelTextRegion) then
        local playerLevel = UnitLevel("player");
        local unitLevel = UnitLevel(unit);
        local unitLevelSuffix = A.getUnitLevelSuffixByUnit(unit);
        if (unitLevel == -1) then
            levelTextRegion:SetText(A.getUnitLevelSkullTextureString(18));
        elseif (playerLevel == MAX_PLAYER_LEVEL and unitLevel == MAX_PLAYER_LEVEL and unitLevelSuffix == "") then
            levelTextRegion:SetText(nil);
        else
            levelTextRegion:SetText(unitLevel .. unitLevelSuffix);
            levelTextRegion:SetVertexColor(A.getUnitLevelColorByUnit(unit):toVertex());
        end
    end
end

function FlatUnitFrame.updateRaidMark(uf)
    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit or not UnitExists(unit)) then
        return;
    end

    local raidMarkTextureRegion = uf.raidMarkTextureRegion;
    if (raidMarkTextureRegion) then
        local index = GetRaidTargetIndex(unit);
        if (index) then
            SetRaidTargetIconTexture(raidMarkTextureRegion, index);
            raidMarkTextureRegion:Show();
        else
            raidMarkTextureRegion:Hide();
        end
    end
end

function FlatUnitFrame.updateSelection(uf)
    local unit = FlatUnitFrame.getUnit(uf);
    if (not unit) then
        return;
    end

    local selectionHighlightTextureRegion = uf.selectionHighlightTextureRegion;
    if (selectionHighlightTextureRegion) then
        local isSelected = UnitIsUnit(unit, "target");
        if (isSelected) then
            selectionHighlightTextureRegion:SetVertexColor(1, 1, 1, 0.2);
            selectionHighlightTextureRegion:Show();
        else
            selectionHighlightTextureRegion:Hide();
        end
    end
end

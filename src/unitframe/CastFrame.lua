addonName, addon = ...;
if (addon.CastFrame) then
    return;
end

addon.CastFrame = {};
local CastFrame = addon.CastFrame;

function CastFrame.malloc(uf)
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

    local spellIconControl = spellIconFrame:CreateTexture(nil, "ARTWORK", nil, 1);
    spellIconControl:SetTexCoord(5/64, 59/64, 5/64, 59/64);
    spellIconControl:SetAllPoints();
    spellIconControl:SetTexture(A.Res.healthbar32);
    castFrame.spellIconControl = spellIconControl;

    local spellNameControl = castFrame:CreateFontString(nil, "BACKGROUND", nil);
    spellNameControl:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    spellNameControl:SetShadowOffset(0, 0);
    spellNameControl:SetJustifyH("LEFT");
    spellNameControl:SetPoint("BOTTOMLEFT", uf, "BOTTOMLEFT", 0, 6);
    castFrame.spellNameControl = spellNameControl;

    local castGlowFrame = FrameBook.createBorderFrame(spellIconFrame, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 5,
    }, 1);
    castFrame.castGlowFrame = castGlowFrame;

    -- TODO castBar

    -- for cast end events, it will play an ending animation
    castFrame.eventHandlers = {
        ["UNIT_SPELLCAST_CHANNEL_START"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_DELAYED"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_FAILED"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_FAILED_QUIET"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_INTERRUPTED"] = CastFrame.onCastStart,
        --["UNIT_SPELLCAST_INTERRUPTIBLE"] =
        --["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] =
        ["UNIT_SPELLCAST_START"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_STOP"] = CastFrame.onCastStart,
        ["UNIT_SPELLCAST_SUCCEEDED"] = CastFrame.onCastStart,
    };

    return castFrame;
end

function CastFrame.getUnit(self)
    return self:GetAttribute("unit");
end

function CastFrame.setUnit(self, unit)
    unit = unit and string.lower(unit);
    self:SetAttribute("unit", unit);
end

-- query for cast info and take action
function CastFrame.onCastStart(self, ...)
    -- 11303 UNIT_SPELLCAST_* triggerred only for "player"
    -- 11303 true spellId
    -- 11303 hear only player event, no pet, no party, etc
    -- 11303 can hear Hearthstone
    local unit, castGuid, spellId = ...;
    unit = unit and string.lower(unit);
    if (CastFrame.getUnit(self) != unit) then
        return;
    end

    castInfo; -- TODO fetch castInfo
    if (not castInfo) then
        return;
    end

    self.castInfo = castInfo;

    if (self.spellNameControl) then
        self.spellNameControl:SetText(castInfo.spellName);
    end

    if (self.spellIconControl) then
        self.spellIconControl:SetTexture(castInfo.spellIcon);
    end

    if (self.castGlowFrame) then
        if (castInfo.castIsShielded) then
            -- iron color
            self.castGlowFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.7);
        else
            self.castGlowFrame:SetBackdropBorderColor(0, 0, 0, 0.7);
        end
    end

    if (self.castBar) then
        if (castInfo.castType == "CASTING") then
            self.castBar:SetStatusBarColor(Color.pick("Gold"):toVertex());
        elseif (castInfo.castType == "CHANNELING") then
            self.castBar:SetStatusBarColor(Color.pick("Green"):toVertex());
        else
            error("E: invalid castType: " .. (castInfo.castType or "nil"));
        end
    end

    if (self.castCountdownTextControl) then
        -- init to empty string
        self.castCountdownTextControl:SetText(nil);
    end

    self:SetScript("OnUpdate", CastFrame.onCastProgress);
    self:Show();
end

-- play fade-out animation or so
function CastFrame.onCastEnd(self, ...)
    local unit, castGuid, spellId = ...;
    -- TODO
end

-- clear all status immediately
function CastFrame.reset(self)
    self:SetScript("OnUpdate", nil);
    self:Hide();
    self.castInfo = nil;
end

function CastFrame.onCastProgress(self, elapsed)
    local castInfo = self.castInfo;
    if (not castInfo) then
        CastFrame.reset(self);
        return;
    end

    local currentTime = time();
    if (not castInfo.castEndTime) then
        -- casting, but no eta
        -- dummy
        return;
    elseif (castInfo.castEndTime <= currentTime) then
        CastFrame.onCastEnd(self);
        return;
    end

    -- progressing
    local totalSeconds = castInfo.castEndTime - castInfo.castStartTime;
    local elapsedSeconds = currentTime - castInfo.castStartTime;
    local rate = elapsedSeconds / totalSeconds;
    if (rate > 1) then
        rate = 1;
    end

    if (self.castBar) then
        if (castInfo.castType == "CASTING") then
            castBar:SetValue(rate);
        elseif (castInfo.castType == "CHANNELING") then
            castBar:SetValue(1 - rate);
        end
    end

    if (self.castCountdownTextControl) then
        self.castCountdownTextControl:SetFormattedText("%.1f", totalSeconds - elapsedSeconds);
    end
end

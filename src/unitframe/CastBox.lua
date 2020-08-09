function createContentBox(parent, config)
    config.width = config.width or 200;
    config.height = config.height or 4;
    config.bgFile = config.bgFile or A.Res.tile32;
    config.borderFile = config.borderFile or A.Res.tile32;
    config.borderSize = config.borderSize or 1;

    local f = CreateFrame("Frame", nil, parent, nil);
    f:SetFrameLevel(2);
    f:SetSize(config.width, config.height);

    local bg = CreateFrame("Frame", nil, f, nil);
    bg:SetFrameLevel(f:GetFrameLevel() - 1);
    bg:SetBackdrop({
        bgFile = config.bgFile,
        edgeFile = config.borderFile,
        edgeSize = config.borderSize,
    });
    bg:SetBackdropColor(0, 0, 0, 0.4);
    bg:SetBackdropBorderColor(0, 0, 0, 0.85);
    bg:SetPoint("TOPLEFT", f, "TOPLEFT", -config.borderSize, config.borderSize);
    bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", config.borderSize, -config.borderSize);
    f.bgFrame = bg;

    return f;
end

--------

local CastBox = {};

function CastBox.create()
    local f = createContentBox(UIParent, {
        width = 160,
        height = 2,
        borderSize = 1,
    });
    f:SetPoint("CENTER", 0, -200);

    local bar = CreateFrame("StatusBar", nil, f, nil);
    bar:SetStatusBarTexture(A.Res.tile32);
    bar:SetStatusBarColor(1, 0.7, 0, 1);
    bar:SetMinMaxValues(0, 1);
    bar:SetValue(0.7749); -- for test
    bar:SetAllPoints(f);
    f.content = bar;

    local nameText = f:CreateFontString(nil, "ARTWORK", nil);
    nameText:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE");
    nameText:SetJustifyH("LEFT");
    nameText:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 4);
    nameText:SetText("spell name"); -- for test
    f.spellNameText = nameText;

    local timeText = f:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Small");
    timeText:SetJustifyH("RIGHT");
    timeText:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, 4);
    timeText:SetText(0.7749); -- for text
    f.spellTimeText = timeText;

    local iconFrame = createContentBox(f, {
        width = 32,
        height = 32,
        borderSize = 2,
    });
    iconFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", -8, -4);

    local iconTexture = iconFrame:CreateTexture(nil, "ARTWORK", nil, 1);
    iconTexture:SetTexCoord(5/64, 59/64, 5/64, 59/64); -- get rid of border
    iconTexture:SetTexture(A.Res.tile32);
    f.spellIconTexture = iconTexture;

    return f;
end

function CastBox.reset(self)
    self.casting = nil;
    self.channeling = nil;
end

function CastBox.onEvent(self, eventName, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        if (UnitIsUnit(self.unit, "player")) then
            -- am i casting?
            if (CastingInfo()) then
                CastBox.onEvent(self, "UNIT_SPELLCAST_START", self.unit);
            elseif (ChannelInfo()) then
                CastBox.onEvent(self, "UNIT_SPELLCAST_CHANNEL_START", unit);
            else
                CastBox.reset(self);
            end
        end
    elseif (event == "UNIT_SPELLCAST_START") then
        local unit = ...;
        local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = CastingInfo();
        if (not name) then
            return;
        end
        self.casting = true;
    elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then
        self.channeling = true;
    end
end

function CastBox.setUnit(self, unit)
    if (self.unit == unit) then
        return
    end

    self.unit = unit;
    self.reset();
    if (self.unit) then
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
        self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        self:RegisterEvent("UNIT_SPELLCAST_DELAYED");
        self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
        self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
        self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit);
        self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit);
        self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit);
        CastBox.onEvent(self, "PLAYER_ENTERING_WORLD");
    else
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        self:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
        self:UnregisterEvent("UNIT_SPELLCAST_START");
        self:UnregisterEvent("UNIT_SPELLCAST_STOP");
        self:UnregisterEvent("UNIT_SPELLCAST_FAILED");
        self:Hide();
    end
end

local castbox = CastBox.create();
castbox:Show();

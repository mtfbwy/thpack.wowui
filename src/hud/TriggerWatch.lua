local A = A;
local dp = A and A.dp or 0.75;

--------

local function activateActionButtonGlow(spellName, enabled)
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
            local onEvent = actionButton:GetScript("OnEvent");
            if (onEvent) then
                onEvent(actionButton, event, spellId);
            end
        end
    end
end

--------

local IconFrame = {};

-- icon's 躯壳
function IconFrame.createIconFrame(parentFrame)
    local f = CreateFrame("Frame", nil, parentFrame, nil);
    f:Hide();

    -- TODO glow

    local iconView = f:CreateTexture();
    A.cropTextureRegion(iconView);
    iconView:SetAllPoints();
    f.iconView = iconView;

    local ttlBar = CreateFrame("StatusBar", nil, f, nil);
    ttlBar:SetStatusBarTexture(A.Res.tile32);
    ttlBar:SetStatusBarColor(0, 1, 0, 0.85);
    ttlBar:SetHeight(4);
    ttlBar:SetPoint("BOTTOMLEFT");
    ttlBar:SetPoint("BOTTOMRIGHT");
    ttlBar:SetMinMaxValues(0, 5);
    f.ttlBar = ttlBar;

    local countText = f:CreateFontString(nil, "OVERLAY", nil);
    countText:SetFont("fonts/ARKai_C.ttf", 12, "OUTLINE");
    countText:SetShadowColor(0, 0, 0, 1);
    countText:SetShadowOffset(0, 0);
    countText:SetJustifyH("RIGHT");
    countText:SetPoint("BOTTOMRIGHT", ttlBar, "TOPRIGHT", -1, 2);
    f.countText = countText;

    return f;
end

function IconFrame.tickSpellTriggerCountdown(iconFrame, elapsed)
    local now = GetTime();

    local cooldownStartTime, cooldownDuration, cooldownEnabled = GetSpellCooldown(iconFrame.spellName);
    local cooldownEndTime = cooldownEnabled and cooldownStartTime + cooldownDuration or 0;

    while (#iconFrame.buffs > 0) do
        local buff = iconFrame.buffs[1];
        if (buff.endTime < now or buff.endTime < cooldownEndTime) then
            IconFrame.onSpellTriggerCountdown(iconFrame, "DECREASE");
        else
            break;
        end
    end

    local count = #iconFrame.buffs;
    if (count == 0) then
        IconFrame.onSpellTriggerCountdown(iconFrame, "CLEAR");
        iconFrame:Hide();
        return;
    end

    if (count == 1) then
        iconFrame.countText:SetText();
    else
        iconFrame.countText:SetText(count);
    end

    -- the last is the longest
    local buff = iconFrame.buffs[count];
    iconFrame.ttlBar:SetValue(buff.endTime - now);

    -- check cooldown
    if (cooldownEndTime > now) then
        -- in cooldown
        iconFrame:SetAlpha(0.7);
    else
        iconFrame:SetAlpha(1);
    end

    -- TODO check mana
    -- TODO check instance
end

-- think the trigger gives a buff, which is the reagent of triggered spell
function IconFrame.onSpellTriggerCountdown(iconFrame, op, ttl)
    if (not iconFrame.buffs) then
        iconFrame.buffs = {};
    end
    if (op == "INCREASE") then
        local now = GetTime();
        table.insert(iconFrame.buffs, {
            startTime = now,
            endTime = now + ttl,
        });
        iconFrame:Show();

        -- for visual impulse
        activateActionButtonGlow(iconFrame.spellName, false);
        activateActionButtonGlow(iconFrame.spellName, true);

        PlaySoundFile("sound/spells/clearcasting_impact_chest.ogg");
    elseif (op == "DECREASE") then
        table.remove(iconFrame.buffs, 1); -- remove the oldest
        if (table.size(iconFrame.buffs) == 0) then
            activateActionButtonGlow(iconFrame.spellName, false);
        end
    elseif (op == "CLEAR") then
        table.clear(iconFrame.buffs);
        activateActionButtonGlow(iconFrame, false);
    end
end

--------

-- manage icon frame positions
local iconPlacer = {};
iconPlacer.anchorFrame = (function()
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:SetPoint("TOPLEFT", UIParent, "CENTER", 200 * dp, 120 * dp);
    f:SetSize(1, 1);
    return f;
end)();
iconPlacer.anchorFrame.owner = iconPlacer;
iconPlacer.nextIndex = 0;
iconPlacer.knownMods = {};
iconPlacer.runningMods = {};

function iconPlacer:placeIconFrame(iconFrame)
    local ICON_SIZE = 72 * dp;
    local ICON_MARGIN = 4 * dp;
    local X_SLOTS = 4;

    local i = self.nextIndex;
    local yPos = math.floor(i / X_SLOTS);
    local xPos = i - yPos * X_SLOTS;

    iconFrame:ClearAllPoints();
    iconFrame:SetPoint("TOPLEFT", self.anchorFrame, "TOPLEFT",
            xPos * (ICON_SIZE + ICON_MARGIN),
            yPos * (ICON_SIZE + ICON_MARGIN));
    iconFrame:SetSize(ICON_SIZE, ICON_SIZE);

    self.nextIndex = i + 1;
end

function iconPlacer:registerSpellTriggerCountdown(spellId, checkTrigger, checkCost)
    table.insert(self.knownMods, {
        cti = "SpellTriggerCountdown",
        spellId = spellId,
        checkTrigger = checkTrigger,
        checkCost = checkCost,
    });
end

function iconPlacer:onInit()
    for i, mod in ipairs(self.knownMods) do
        local spellLocalName = GetSpellInfo(mod.spellId);
        local spellLocalName, _, spellIcon = GetSpellInfo(spellLocalName);
        if (spellLocalName) then
            local iconFrame = IconFrame.createIconFrame(self.anchorFrame);
            iconFrame.spellName = spellLocalName;
            iconFrame.iconView:SetTexture(spellIcon);
            if (mod.cti == "SpellTriggerCountdown") then
                iconFrame:SetScript("OnUpdate", IconFrame.tickSpellTriggerCountdown);
            end
            self:placeIconFrame(iconFrame);
            mod.iconFrame = iconFrame;

            table.insert(self.runningMods, mod);
        end
    end
end

function iconPlacer:onCleuEvent(...)
    -- dispatch
    for i, mod in ipairs(self.runningMods) do
        local changes, increases, ttl = mod.checkTrigger(mod.iconFrame, ...);
        if (changes) then
            IconFrame.onSpellTriggerCountdown(mod.iconFrame, increases and "INCREASE" or "DECREASE", ttl);
        end
    end
end

function iconPlacer:start()
    local f = self.anchorFrame;
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    f:RegisterEvent("PLAYER_DEAD");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            self.owner:onCleuEvent(CombatLogGetCurrentEventInfo());
        elseif (event == "PLAYER_DEAD") then
            for i, mod in ipairs(self.owner.runningMods) do
                IconFrame.onSpellTriggerCountdown(mod.iconFrame, "CLEAR");
            end
        elseif (event == "PLAYER_ENTERING_WORLD") then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
            self.owner:onInit();
            if (table.size(self.owner.runningMods) == 0) then
                -- no valid trigger, halt
                self:UnregisterAllEvents();
            end
        end
    end);
end

iconPlacer:start();

--------

local SPELL_ID_OVERPOWER1 = 7384;
iconPlacer:registerSpellTriggerCountdown(SPELL_ID_OVERPOWER1, function(iconFrame, ...)
    local timestamp, eventName, hidesCaster = ...;
    local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
    local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

    local isSrcUnit = (srcGuid == UnitGUID("player"));

    if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
        local spellId, spellName, spellSchool = select(12, ...);
        if (spellName == iconFrame.spellName) then
            return true, false;
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
            return true, true, 5;
        end
    end
end);

local SPELL_ID_REVENGE1 = 6572;
iconPlacer:registerSpellTriggerCountdown(SPELL_ID_REVENGE1, function(iconFrame, ...)
    local timestamp, eventName, hidesCaster = ...;
    local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
    local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

    local isSrcUnit = (srcGuid == UnitGUID("player"));
    local isDstUnit = (dstGuid == UnitGUID("player"));

    if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
        local spellId, spellName, spellSchool = select(12, ...);
        if (spellName == iconFrame.spellName) then
            return true, false;
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
            return true, true, 5;
        end
    end
end);

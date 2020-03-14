local A = A;
local dp = A and A.dp or 0.75;

--------

-- manage icon frame positions
local gridFrame = (function()
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:SetPoint("TOPLEFT", UIParent, "CENTER", 160 * dp, 120 * dp);
    f:SetSize(1, 1);

    f.nextIndex = 0;

    return f;
end)();

-- icon's 躯壳
function gridFrame:createIconFrame()
    local f = CreateFrame("Frame", nil, self, nil);
    f:Hide();

    -- TODO glow

    local iconControl = f:CreateTexture();
    A.Frame.cropTextureRegion(iconControl);
    iconControl:SetAllPoints();
    f.iconControl = iconControl;

    local ttlBar = CreateFrame("StatusBar", nil, f, nil);
    ttlBar:SetStatusBarTexture(A.Res.tile32);
    ttlBar:SetStatusBarColor(0, 1, 0, 0.85);
    ttlBar:SetHeight(4);
    ttlBar:SetPoint("BOTTOMLEFT");
    ttlBar:SetPoint("BOTTOMRIGHT");
    f.ttlBar = ttlBar;

    return f;
end

function gridFrame:layoutIconFrame(iconFrame)
    local ICON_SIZE = 48 * dp;
    local ICON_MARGIN = 4 * dp;
    local X_SLOTS = 4;

    local i = f.nextIndex;
    local yPos = math.floor(i / X_SLOTS);
    local xPos = i - yPos * X_SLOTS;

    iconFrame:ClearAllPoints();
    iconFrame:SetPoint("TOPLEFT", self, "TOPLEFT",
            xPos * (ICON_SIZE + ICON_MARGIN),
            yPos * (ICON_SIZE + ICON_MARGIN));
    iconFrame:SetSize(ICON_SIZE, ICON_SIZE);

    f.nextIndex = f.nextIndex + 1;

    return i;
end

--------

local gridManager = {};
gridManager.anchorFrame = gridFrame;
gridManager.mods = {};

function gridManager:activateActionButtonGlow(spellName, enabled)
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

function gridManager:registerSpellTriggerCountdown(spellId, onCleuEvent)
    table.insert(self.mods, {
        cti = "SpellTriggerCountdown",
        spellId = spellId,
        onCleuEvent = onCleuEvent
    });
end

-- think the trigger gives a buff, which is the reagent of triggered spell
function gridManager:activateSpellTriggerCountdown(iconFrame, enabled, ttl)
    if (enabled) then
        local now = time();
        iconFrame.buffs = iconFrame.buffs or {};
        table.insert(iconFrame.buffs, {
            startTime = now,
            endTime = now + ttl,
        });
        iconFrame:Show();
    else
        table.remove(iconFrame.buffs, 1); -- remove the oldest
    end
    if (enabled) then
        self:activateActionButtonGlow(iconFrame.spellName, true);
    elseif (not iconFrame.buffs or table.size(iconFrame.buffs) == 0) then
        self.activateActionButtonGlow(iconFrame.spellName, false);
    end
end

function gridManager:tickSpellTriggerCountdown(iconFrame, elapsed)
    local n = table.size(iconFrame.buffs);
    if (n == 0) then
        iconFrame:Hide();
        return;
    end

    local last = iconFrame.buffs[n];

    local now = time();
    local remainingTime = endTime - time();
    if (now < last.endTime) then
        iconFrame.ttlBar:SetValue(now);
    else
        table.clear(iconFrame.buffs);
        return;
    end

    -- check cooldown
    local spellName = iconFrame.spellName;
    local start, duration = GetSpellCooldown(spellName);
    if (start + duration > GetTime()) then
        -- in cooldown
        iconFrame:SetAlpha(0.7);
    else
        iconFrame:SetAlpha(1);
    end

    -- TODO check mana
    -- TODO check instance
end

function gridManager:initMod(mod)
    local grid = self;

    local spellId = mod.spellId;
    local localName, _, _, = GetSpellInfo(spellId);
    local spellName, _, spellIcon = GetSpellInfo(localName);

    --GetSpellInfo(name) will return nil if spell not in spellbook
    if (spellName) then
        local iconFrame = grid.anchorFrame:createIconFrame();
        iconFrame.spellName = spellName;
        iconFrame.iconControl:SetTexture(spellIcon);
        grid.anchorFrame:layoutIconFrame(iconFrame);
        if (mod.cti == "SpellTriggerCountdown") then
            iconFrame:SetScript("OnUpdate", function(self, elapsed)
                grid:tickSpellTriggerCountdown(self, elapsed);
            end);
        end
        mod.iconFrame = iconFrame;
        return true;
    end
    return false;
end

function gridManager:start()
    local grid = self;

    local f = grid.anchorFrame;
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    f:RegisterEvent("PLAYER_DEAD");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            -- dispatch
            for i, mod in ipairs(self.mods) do
                mod.onCleuEvent(mod.iconFrame, event, ...);
            end
        elseif (event == "PLAYER_DEAD") then
            for i, mod in ipairs(self.mods) do
                grid:activateSpellTriggerCountdown(mod.iconFrame, false);
            end
        elseif (event == "PLAYER_ENTERING_WORLD") then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
            local mods = grid.mods;
            grid.mods = {};
            for i, mod in ipairs(mods) do
                if (grid:initMod(mod)) then
                    table.insert(grid.mods, mod);
                end
            end
            if (table.size(grid.mods) == 0) then
                -- no valid trigger, halt
                self:UnregisterAllEvents();
            end
        end
    end);
end

gridManager:start();

--------

local SPELL_ID_OVERPOWER1 = 7384;
gridPlate:registerSpellTriggerCountdown(SPELL_ID_OVERPOWER1, function(grid, iconFrame, ...)
    local timestamp, eventName, hidesCaster = ...;
    local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
    local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

    local isSrcUnit = (srcGuid == UnitGUID("player"));

    if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
        local spellId, spellName, spellSchool = select(12, ...);
        if (spellName == iconFrame.spellName) then
            grid:activateSpellTriggerCountdown(iconFrame, false);
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
            grid:activateSpellTriggerCountdown(iconFrame, true, 5);
        end
    end
end);

local SPELL_ID_REVENGE1 = 6572;
gridPlate:registerSpellTriggerCountdown(SPELL_ID_REVENGE1, function(grid, iconFrame, ...)
    local timestamp, eventName, hidesCaster = ...;
    local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
    local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

    local isSrcUnit = (srcGuid == UnitGUID("player"));
    local isDstUnit = (dstGuid == UnitGUID("player"));

    if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
        local spellId, spellName, spellSchool = select(12, ...);
        if (spellName == iconFrame.spellName) then
            grid:activateSpellTriggerCountdown(iconFrame, false);
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
            grid:activateSpellTriggerCountdown(iconFrame, true, 5);
        end
    end
end);

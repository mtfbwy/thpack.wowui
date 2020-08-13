local _, classNameEn = UnitClass("player");

local isEpClass = false;
if (classNameEn == "ROGUE"
        or classNameEn == "DRUID") then
    isEpClass = true;
end

local isMpClass = false;
if (classNameEn == "MAGE"
        or classNameEn == "PRIEST"
        or classNameEn == "WARLOCK"
        or classNameEn == "DRUID"
        or classNameEn == "HUNTER"
        or classNameEn == "SHAMAN"
        or classNameEn == "PALADIN") then
    isMpClass = true;
end

if (not isEpClass and not isMpClass) then
    return;
end

--------

local STAT_KEY_MP5 = "ITEM_MOD_POWER_REGEN0_SHORT";

local ITEM_SETS = {
    ["Augur's Regalia"] = {
        itemIds = { 19609, 19956, 19830, 19829,19828 },
        effects = {
            [2] = {
                [STAT_KEY_MP5] = 3,
            },
        }
    },
    ["Freethinker's Armor"] = {
        itemIds = { 19952, 19588, 19827, 19826, 19825 },
        effects = {
            [2] = {
                [STAT_KEY_MP5] = 3,
            },
        }
    },
    ["Haruspex's Garb"] = {
        itemIds = { 19613, 19955, 19840, 19839, 19838 },
        effects = {
            [2] = {
                [STAT_KEY_MP5] = 3,
            },
        }
    },
}

local function getEquippedItemSetsBonusMp5()
    local counts = {};
    for i = 1, 18 do
        local itemId = GetInventoryItemID("player", i);
        for k, o in pairs(ITEM_SETS) do
            if (array.contains(o.itemIds, itemId)) then
                local n = (counts[k] or 0) + 1;
                counts[k] = n;
            end
        end
    end
    local mp5 = 0;
    for k, count in pairs(counts) do
        local itemSet = ITEM_SETS[k];
        for i = 1, count do
            local bonusMp5 = itemSet.effects[i] and itemSet.effects[i][STAT_KEY_MP5];
            if (bonusMp5) then
                mp5 = mp5 + bonusMp5 + 1;
            end
        end
    end
    return mp5;
end

local function getEquippedItemsMp5()
    local mp5 = 0;
    for i = 1, 18 do
        local itemLink = GetInventoryItemLink("player", i);
        if (itemLink) then
            local itemStats = GetItemStats(itemLink);
            local itemMp5 = itemStats and itemStats[STAT_KEY_MP5];
            if (itemMp5) then
                mp5 = mp5 + itemMp5 + 1;
            end
        end
    end
    mp5 = mp5 + getEquippedItemSetsBonusMp5();
    return mp5;
end

local function getManaRegenTalentMultiplier()
    local mul = 1;
    if (classNameEn == "PRIEST") then
        -- Meditation
        local _, _, _, _, points = GetTalentInfo(1, 8);
        mul = mul + points * 0.05;
    elseif (classNameEn == "MAGE") then
        -- Arcane Meditation
        local _, _, _, _, points = GetTalentInfo(1, 12);
        mul = mul + points * 0.05;
    elseif (classNameEn == "DRUID") then
        -- Reflection
        local _, _, _, _, points = GetTalentInfo(3, 6);
        mul = mul + points * 0.05;
    end
    return mul;
end

--------

local energyData = {
    unit = "player",
    pulseTime = 0,
    energy = 0,
};

local function findEnergyPulseProgress(data)
    local PULSE_INTERVAL = 2;
    local PULSE_AMOUNT = 20;
    local now = GetTime();
    local energy = UnitPower(data.unit, Enum.PowerType.Energy);
    local diff = energy - data.energy;
    -- exclude [Thistle Tea] and [Adrenaline Rush]
    if (diff > PULSE_AMOUNT - 1 and diff < PULSE_AMOUNT + 1) then
        data.pulseTime = now;
    end
    data.energy = energy;
    return (now - data.pulseTime) / PULSE_INTERVAL % 1;
end

local manaData = {
    unit = "player",
    pulseTime = 0,
    nextPulseTime = 0,
    mana = 0,
};

local function findManaPulseProgress(data, onCastSucc)
    local PULSE_COOLDOWN = 5;
    local PULSE_INTERVAL = 2;
    local PULSE_MAX_INTERVAL = (math.ceil(PULSE_COOLDOWN / PULSE_INTERVAL) + 1) * PULSE_INTERVAL;

    local now = GetTime();
    local mana = UnitPower(data.unit, Enum.PowerType.Mana);

    if (mana > data.mana) then
        -- increased mana, is it pulse?
        local diff = mana - data.mana;
        -- GetManaRegen() gives 0.00xxx within 5s after a mana-cost cast
        local baseRegen, castRegen = GetManaRegen();
        if (baseRegen >= 1) then
            local spiritRegen = baseRegen * getManaRegenTalentMultiplier();
            local mp5Regen = getEquippedItemsMp5() / 5;
            local totalRegen = (spiritRegen + mp5Regen) * PULSE_INTERVAL;
            if (diff > totalRegen - 1 and diff < totalRegen + 1) then
                data.pulseTime = now;
            end
        end
    elseif (onCastSucc and mana < data.mana) then
        -- mp consumed, start cooldown
        local sinceLastPulse = (now - data.pulseTime) % PULSE_INTERVAL;
        local pulseInterval = math.ceil((sinceLastPulse + PULSE_COOLDOWN) / PULSE_INTERVAL) * PULSE_INTERVAL;
        local lastPulseTimeAsIf = now - sinceLastPulse - (PULSE_MAX_INTERVAL - pulseInterval);
        data.pulseTime = lastPulseTimeAsIf;
        data.nextPulseTime = lastPulseTimeAsIf + PULSE_MAX_INTERVAL;
    end
    data.mana = mana;

    if (now < data.nextPulseTime) then
        return (now - data.pulseTime) / PULSE_MAX_INTERVAL;
    else
        return (now - data.pulseTime) / PULSE_INTERVAL % 1;
    end
end

--------

local f = CreateFrame("Frame", nil, PlayerFrameManaBar, nil);
f:SetAllPoints();

f.energyData = energyData;
f.manaData = manaData;

f.spark = f:CreateTexture(nil, "OVERLAY");
f.spark:SetTexture("Interface/CastingBar/UI-CastingBar-Spark");
f.spark:SetSize(6, 18);
f.spark:SetBlendMode("ADD");

f:SetScript("OnUpdate", function(self, elapsed)
    local powerType = UnitPowerType("player");
    if (powerType == Enum.PowerType.Energy) then
        local energyProgress = findEnergyPulseProgress(self.energyData);
        self.spark:ClearAllPoints();
        self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * energyProgress, 0);
        self.spark:Show();
    elseif (powerType == Enum.PowerType.Mana) then
        local manaProgress = findManaPulseProgress(self.manaData, false);
        self.spark:ClearAllPoints();
        self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * manaProgress, 0);
        self.spark:Show();
    else
        self.spark:Hide();
    end
end);

if (isMpClass) then
    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
end

f:SetScript("OnEvent", function(self, event, ...)
    if (event == "UNIT_SPELLCAST_SUCCEEDED") then
        findManaPulseProgress(self.manaData, true);
    end
end);

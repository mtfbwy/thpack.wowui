if (GearBook) then
    return;
end

GearBook = {};
local GearBook = GearBook;

local STAT_KEY_MP5 = "ITEM_MOD_POWER_REGEN0_SHORT";

-- lv60, p5
local GEAR_SETS_11300 = {
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

--------

local function getUnitGearSetEligibleBonusMp5(unit)
    local statKey = STAT_KEY_MP5;
    local counts = {};
    for i = 1, 18 do
        local itemId = GetInventoryItemID(unit, i);
        for k, o in pairs(GEAR_SETS_11300) do
            if (array.contains(o.itemIds, itemId)) then
                local n = (counts[k] or 0) + 1;
                counts[k] = n;
            end
        end
    end
    local mp5 = 0;
    for k, count in pairs(counts) do
        local itemSet = GEAR_SETS_11300[k];
        for i = 1, count do
            local bonusMp5 = itemSet.effects[i] and itemSet.effects[i][statKey];
            if (bonusMp5) then
                mp5 = mp5 + bonusMp5 + 1;
            end
        end
    end
    return mp5;
end

function GearBook.getUnitEquippedGearsMp5(unit)
    local statKey = STAT_KEY_MP5;
    local mp5 = 0;
    for i = 1, 18 do
        local itemLink = GetInventoryItemLink(unit, i);
        if (itemLink) then
            local itemStats = GetItemStats(itemLink);
            local itemMp5 = itemStats and itemStats[statKey];
            if (itemMp5) then
                mp5 = mp5 + itemMp5 + 1;
            end
        end
    end
    mp5 = mp5 + getUnitGearSetEligibleBonusMp5(unit);
    return mp5;
end

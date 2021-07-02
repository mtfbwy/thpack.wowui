-- stick to your own path

-- statistics on player's current status
-- what really matters:
--  tank e.g. warrior
--      defense rank, armor, block, block amount, dodge, parry
--  healer e.g. priest
--      sp, heal power, spell crit
--  caster e.g. mage
--      spell power, spell crit, spell hit
--  melee dps e.g. rogue
--      ap, dps, dph, crit, hit
--  ranged dps e.g. hunter
--      ranged ap, ranged dps, ranged dph, ranged crit, hit

local StatBook = {};

function StatBook.getPrimaryStat(primary)
    primary = primary or {};
    primary.health = UnitHealthMax("player");
    primary.mana = UnitPowerMax("player", Enum.PowerType.Mana);
    primary.manaRegenPerTick = getManaRegenPerTick();
    return primary;
end

local function getMeleeDps()
    local mainhandCooldown, offhandCooldown = UnitAttackSpeed("player");
    local mainhandMinDamage, mainhandMaxDamage, offhandMinDamage, offhandMaxDamage, posBuff, negBuff, multiple = UnitDamage("player");
    -- fist cooldown = 2.0
    local mhDph = ((mainhandMinDamage + mainhandMaxDamage) / 2 + posBuff + negBuff) * multiple;
    local mhDps = mhDph / mainhandCooldown;
    if (not offhandCooldown) then
        return mhDps, mhDph;
    else
        local ohDph = ((offhandMinDamage + offhandMaxDamage) / 2 + posBuff + negBuff) * multiple;
        local ohDps = ohDph / offhandCooldown;
        local ohMultiplier = 0.5; -- TODO some talents will affect this const
        return mhDps + ohDps * ohMultiplier, mhDph;
    end
end

-- including wand
local function getRangedDps()
    local cooldown, minDamage, maxDamage, posBuff, negBuff, multiple = UnitRangedDamage("player");
    if (weaponCooldown and weaponCooldown > 0) then
        local dph = ((minDamage + maxDamage) / 2 + posBuff + negBuff) * multiple;
        local dps = dph / cooldown;
        return dps, dph;
    end
end

function StatBook.fillMightBonus(data)
    local ap;
    do
        local base, posBuff, negBuff = UnitAttackPower("player");
        ap = (base + posBuff + negBuff) or 0;
    end

    local rangedAp;
    do
        local base, posBuff, negBuff = UnitRangedAttackPower("player");
        rangedAp = (base + posBuff + negBuff) or 0;
    end

    data = data or {};
    data.dps, data.mhDph = getMeleeDps();
    data.ap = ap;
    data.critChance = GetCritChance() or 0;
    data.rangedDps, data.rangedDph = getRangedDps();
    data.rangedAp = rangedAp;
    data.rangedCritChance = GetRangedCritChance() or 0;
    data.hitChance = GetHitModifier() or 0;
    return data;
end

function StatBook.fillDefenseBonus(data)
    local rank = 0;
    for i = 1, GetNumSkillLines(), 1 do
        local skillName, _, _, base, _, bonus = GetSkillLineInfo(i);
        if (skillName == DEFENSE) then
            rank = base + bonus;
            break;
        end
    end
    if (rank == 0) then
        local base, bonus = UnitDefense("player");
        rank = base + bonus;
    end

    local _, effectiveArmor, _, _, _ = UnitArmor("player");

    data = data or {};
    data.rank = rank;
    data.armor = effectiveArmor or 0;
    data.blockChance = GetBlockChance() or 0;
    data.blockAmount = GetShieldBlock() or 0;
    data.dodgeChance = GetDodgeChance() or 0;
    data.parryChance = GetParryChance() or 0;
    return data;
end

function StatBook.fillMagicBonus(data)
    data = data or {};
    data.physical = GetSpellBonusDamage(1);
    data.holy = GetSpellBonusDamage(2);
    data.fire = GetSpellBonusDamage(3);
    data.nature = GetSpellBonusDamage(4);
    data.frost = GetSpellBonusDamage(5);
    data.shadow = GetSpellBonusDamage(6);
    data.arcane = GetSpellBonusDamage(7);
    data.healing = GetSpellBonusHealing();
    data.critChance = GetSpellCritChance() or 0;
    data.hitChance = GetSpellHitModifier() or 0;
    return data;
end

--------

local Placer = {};

-- a board consists of several rows
function Placer.createBoardView(parentView, dx, dy)
    local f = CreateFrame("Frame", nil, parentView, nil);
    f:SetSize(1, 1);
    f:SetPoint("TOPLEFT", dx, dy);

    f.rowViews = {};

    return f;
end

-- a row consists of a Texture and a FontString
function Placer.createRowView(boardView)
    local ICON_HEIGHT = 20;
    local LINE_WIDTH = 60;
    local LINE_HEIGHT = 14;
    local FONT_SIZE = 12;

    local rowIndex = array.size(boardView.rowViews);

    local icon = boardView:CreateTexture(nil, "OVERLAY");
    icon:SetPoint("TOPLEFT", 0, -(ICON_HEIGHT + 2) * rowIndex);
    icon:SetSize(ICON_HEIGHT, ICON_HEIGHT);

    local text = self:CreateFontString(nil, "OVERLAY", nil);
    text:SetFont(STANDARD_TEXT_FONT, FONT_SIZE, "OUTLINE");
    text:SetJustifyH("LEFT");
    text:SetPoint("LEFT", icon, "RIGHT", 4, 0);
    text:SetSize(LINE_WIDTH, LINE_HEIGHT);

    return {
        icon = icon,
        text = text,
    };
end

function Placer.getOrCreateRowView(boardView, index)
    -- lua: array index starts from 1
    while (array.size(boardView.rowViews) < index) do
        local rowView = Placer.createRowView(boardView);
        array.insert(boardView.rowViews, rowView);
    end
    return boardView.rowViews[index];
end

function Placer.refreshBoardView(boardView, rowItems, startIndex)
    while (startIndex <= array.size(rowItems)) do
        local rowItem = rowItems[startIndex];
        if (rowItem[3]) then
            local rowView = Placer.getOrCreateRowView(boardView, startIndex);
            rowView.icon:SetTexture(rowItem[2]);
            rowView.text:SetText(rowView[3]);
        end
        startIndex = startIndex + 1;
    end
    while (startIndex <= array.size(boardView.rowViews)) do
        local rowView = boardView.rowViews[startIndex];
        rowView.icon:SetTexture(nil);
        rowView.text:SetText(nil);
    end
    return startIndex;
end

function Placer.getMightRowItems(isMelee)
    -- 132223:ability_meleedamage
    -- 132333:ability_warrior_battleshout
    -- 132090:ability_backstab
    -- 132222:ability_marksmanship
    -- 132329:ability_trueshot
    -- 132169:ability_hunter_criticalshot
    if (isMelee == nil) then
        error("isMelee should be true or false, not nil");
    local data = StatBook.fillMightBonus()
    if (isMelee) then
        local meleeWeaponTextureId = GetInventoryItemTexture("player", INVSLOT_MAINHAND) or 132223;
        local meleeDpsString = string.format("%.01f", data.mhDps);
        return {
            { "meleeDps", meleeWeaponTextureId, meleeDpsString },
            { "meleeAp", 135906, string.format("%d", data.ap) },
            { "meleeCritChance", 132090, string.format("%.02f%%", data.critChance), },
            { "hitChance", 132222, string.format("+%.01f%%", data.hitChance) },
        };
    else
        local rangedDpsTextureId = GetInventoryItemTexture("player", INVSLOT_RANGED);
        return {
            { "rangedDps", rangedDpsTextureId, string.format("%.01f", data.rangedDps) },
            { "rangedAp", 132329, string.format("%d", data.rangedAp) },
            { "rangedCritChance", 132090, string.format("%.02f%%", data.rangedCritChance) },
            { "hitChance", 132222, string.format("+%.01f%%", data.hitChance) },
        };
    end
end

function Placer.getDefenseRowItems()
    -- 132341:ability_warrior_defensivestance
    -- 135893:spell_holy_devotionaura
    -- 136047:spell_nature_invisibilty
    -- 132269:ability_parry
    -- 132110:ability_defend
    local data = StatBook.fillDefenseBonus();
    return {
        { "defense", 132341, string.format("%d/%d", data.rank, data.armor) },
        { "dodgeChance", 136047, string.format("%.1f%%", data.dodgeChance) },
        { "parryChance", 132269, string.format("%.1f%%", data.parryChance) },
        { "block", 132110, string.format("%.1f%%/%d", data.blockChance, data.blockAmount) },
    };
end

function Placer.getMagicRowItems()
    -- 136096:spell_nature_starfall
    local data = StatBook.fillMagicBonus();
    local sp = math.min(
        data.holy,
        data.fire,
        data.nature,
        data.frost,
        data.shadow,
        data.arcane);
    return {
        { "spell", 136096, string.format("%d/%d", sp, data.healing) },
        { "spellCritChance", 132090, string.format("%.02f%%", data.critChance) },
        { "spellHitChance", 132222, string.format("+%.01f%%", data.hitChance) },
    };
end

--------

local _, classToken = UnitClass("player");
local mightBoard = Placer.createBoardView(CharacterModelFrame, 6, -36); -- 6, -212
local magicBoard = Placer.createBoardView(CharacterModelFrame, 160, -146);

local function refreshBoards()
    local mightRowItems = nil;
    local defenseRowItems = nil;
    local magicRowItems = nil;
    if (false) then
    elseif (classToken == "MAGE") then
        magicRowItems = Placer.getMagicRowItems();
    elseif (classToken == "PRIEST") then
        magicRowItems = Placer.getMagicRowItems();
    elseif (classToken == "WARLOCK") then
        magicRowItems = Placer.getMagicRowItems();
    elseif (classToken == "ROGUE") then
        mightRowItems = Placer.getMightRowItems(true);
    elseif (classToken == "DRUID") then
        mightRowItems = Placer.getMightRowItems(true);
        defenseRowItems = Placer.getDefenseRowItems();
        magicRowItems = Placer.getMagicRowItems();
    elseif (classToken == "HUNTER") then
        mightRowItems = Placer.getMightRowItems(false);
        magicRowItems = Placer.getMagicRowItems();
    elseif (classToken == "SHAMAN") then
        mightRowItems = Placer.getMightRowItems(true);
        magicRowItems = Placer.getMagicRowItems();
    elseif (classToken == "WARRIOR") then
        mightRowItems = Placer.getMightRowItems(true);
        defenseRowItems = Placer.getDefenseRowItems();
    elseif (classToken == "PALADIN") then
        mightRowItems = Placer.getMightRowItems(true);
        defenseRowItems = Placer.getDefenseRowItems();
        magicRowItems = Placer.getMagicRowItems();
    end

    local index = 1;
    if (mightRowItems) then
        index = Placer.refreshBoardView(mightBoard, mightRowItems, index);
    end
    if (defenseRowItems) then
        Placer.refreshBoardView(mightBoard, defenseRowItems, index);
    end
    if (magicRowItems) then
        Placer.refreshBoardView(magicBoard, magicRowItems, 1);
    end
end

local function onElapse(self, elapsed)
    self.ttl = self.ttl - elapsed;
    if (self.ttl < 0) then
        self.ttl = nil;
        self:SetScript("OnUpdate", nil);
        refreshBoards();
    end
end

local function delayRefresh(self)
    -- immediate refresh leads to incorrect result
    self.ttl = 0.5; -- long enough
    if (not self:GetScript("OnUpdate")) then
        self:SetScript("OnUpdate", onElapse);
    end
end

mightBoard:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
mightBoard:RegisterEvent("SKILL_LINES_CHANGED");
mightBoard:RegisterUnitEvent("UNIT_ATTACK", "player");
mightBoard:RegisterUnitEvent("UNIT_ATTACK_POWER", "player");
mightBoard:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");
mightBoard:RegisterUnitEvent("UNIT_AURA", "player");
mightBoard:RegisterUnitEvent("UNIT_RANGED_ATTACK_POWER", "player");
mightBoard:RegisterUnitEvent("UNIT_RANGEDDAMAGE", "player");
mightBoard:RegisterUnitEvent("UNIT_STATS", "player");
mightBoard:SetScript("OnEvent", delayRefresh);

CharacterModelFrame:HookScript("OnShow", function(self)
    delayRefresh(mightBoard);
end);

--CharacterModelFrameRotateRightButton:Hide();
--CharacterModelFrameRotateLeftButton:Hide();

--CharacterResistanceFrame:Hide();
--CharacterAttributesFrame:Hide();
--CharacterModelFrame:SetHeight(302);

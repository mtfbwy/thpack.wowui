-- must stick to what you want and follow your own path

local function getData(cti)
    local data = {};

    if (not cti or cti == "primary") then
        data.primary = {
            health = UnitHealthMax("player"),
            mana = UnitPowerMax("player", Enum.PowerType.Mana),
            manaRegen = GetManaRegen(),
        };
    end

    if (not cti or cti == "defensive") then
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

        data.defensive = {
            rank = rank,
            armor = effectiveArmor or 0,
            dodge = GetDodgeChance() or 0,
            parry = GetParryChance() or 0,
            blockChance = GetBlockChance() or 0,
            blockAmount = GetShieldBlock() or 0,
        };
    end

    if (not cti or cti == "melee") then
        local mainhandDps;
        local offhandDps;
        do
            local mainhandCooldown, offhandCooldown = UnitAttackSpeed("player");
            local mainhandMinDamage, mainhandMaxDamage, offhandMinDamage, offhandMaxDamage, _, _, _ = UnitDamage("player");
            -- fist defaults to 2.0
            mainhandDps = (mainhandMinDamage + mainhandMaxDamage) / 2 / mainhandCooldown;
            if (offhandCooldown) then
                offhandDps = (offhandMinDamage + offhandMaxDamage) / 2 / offhandCooldown;
            end
        end

        local ap;
        do
            local base, posBuff, negBuff = UnitAttackPower("player");
            ap = (base + posBuff + negBuff) or 0;
        end

        data.melee = {
            mainhandDps = mainhandDps,
            offhandDps = offhandDps,
            ap = ap,
            crit = GetCritChance() or 0,
            hitBonus = GetHitModifier() or 0,
        };
    end

    if (not cti or cti == "ranged" or cti == "spell") then
        local rangedDps = nil;
        do
            local weaponCooldown, minDamage, maxDamage, posBuff, negBuff, multiple = UnitRangedDamage("player");
            if (weaponCooldown and weaponCooldown > 0) then
                rangedDps = (minDamage + maxDamage) / 2 / weaponCooldown;
            end
        end

        local rangedAp;
        do
            local base, posBuff, negBuff = UnitRangedAttackPower("player");
            rangedAp = (base + posBuff + negBuff) or 0;
        end

        data.ranged = cti == "spell"
            and {
                rangedDps = rangedDps,
            } or {
                rangedDps = rangedDps,
                rangedAp = rangedAp,
                rangedCrit = GetRangedCritChance() or 0,
                hitBonus = GetHitModifier() or 0,
            };
    end

    if (not cti or cti == "spell") then
        data.spell = {
            spellBonus = {
                physical = GetSpellBonusDamage(1),
                holy = GetSpellBonusDamage(2),
                fire = GetSpellBonusDamage(3),
                nature = GetSpellBonusDamage(4),
                frost = GetSpellBonusDamage(5),
                shadow = GetSpellBonusDamage(6),
                arcane = GetSpellBonusDamage(7),
                healing = GetSpellBonusHealing(),
            },
            spellCrit = GetSpellCritChance() or 0,
            spellHitBonus = GetSpellHitModifier() or 0,
        };
    end

    return data;
end

--------

local AnchorFrame = {};

function AnchorFrame.createAnchor()
    local f = CreateFrame("Frame", nil, CharacterModelFrame, nil);
    f:SetSize(1, 1);
    f:Hide();
    return f;
end

function AnchorFrame.createRow(self, numOffsetLines)
    local ICON_HEIGHT = 20;
    local LINE_HEIGHT = 14;
    --local keyText = self:CreateFontString(nil, "OVERLAY", nil);
    --keyText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    --keyText:SetJustifyH("RIGHT");
    --keyText:SetPoint("TOPLEFT", 0, -LINE_HEIGHT * i);
    --keyText:SetSize(30, LINE_HEIGHT);
    local keyIcon = self:CreateTexture(nil, "OVERLAY");
    keyIcon:SetPoint("TOPLEFT", 0, -(ICON_HEIGHT + 2) * numOffsetLines);
    keyIcon:SetSize(ICON_HEIGHT, ICON_HEIGHT);
    local valueText = self:CreateFontString(nil, "OVERLAY", nil);
    valueText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    valueText:SetJustifyH("LEFT");
    valueText:SetPoint("LEFT", keyIcon, "RIGHT", 4, 0);
    valueText:SetSize(60, LINE_HEIGHT);
    return {
        keyIcon = keyIcon,
        valueText = valueText,
    };
end

-- to view model
function AnchorFrame.getRowItems(data)
    local rowItems = {};

    if (data.primary) then
        -- 134830:inv_potion_50
        -- 134851:inv_potion_71
        -- 135970:spell_holy_sealofwisdom
        array.insert(rowItems, { "health", 134830, tostring(data.primary.health) });
        if (data.primary.mana > 0) then
            array.insert(rowItems, { "mana", 134851, tostring(data.primary.mana) });
            array.insert(rowItems, { "manaRegen", 135970, string.format("%d", data.primary.manaRegen) });
        end
    end

    if (data.defensive) then
        local defensive = data.defensive;
        -- 132341:ability_warrior_defensivestance
        -- 135893:spell_holy_devotionaura
        -- 136047:spell_nature_invisibilty
        -- 132269:ability_parry
        -- 132110:ability_defend
        array.concat(rowItems, {
            { "defensiveRank", 132341, string.format("%d", defensive.rank) },
            { "armor", 135893, string.format("%d", defensive.armor) },
            { "dodge", 136047, string.format("%.1f%%", defensive.dodge) },
            { "parry", 132269, string.format("%.1f%%", defensive.parry) },
            { "block", 132110, string.format("%.1f%%/%d", defensive.blockChance, defensive.blockAmount) },
        });
    end

    if (data.melee) then
        local melee = data.melee;
        -- 132223:ability_meleedamage
        -- 132333:ability_warrior_battleshout
        -- 132090:ability_backstab
        -- 132222:ability_marksmanship
        local meleeWeaponTextureId = GetInventoryItemTexture("player", INVSLOT_MAINHAND) or 132223;
        local meleeDpsString = melee.offhandDps
            and string.format("%.01f/%.01f", melee.mainhandDps, melee.offhandDps)
            or string.format("%.01f", melee.mainhandDps);
        array.concat(rowItems, {
            { "dps", meleeWeaponTextureId, meleeDpsString },
            { "ap", 135906, string.format("%d", melee.ap) },
            { "crit", 132090, string.format("%.02f%%", melee.crit), },
            { "hit", 132222, string.format("+%.01f%%", melee.hitBonus) },
        });
    end

    if (data.ranged) then
        local ranged = data.ranged;
        -- 132329:ability_trueshot
        -- 132169:ability_hunter_criticalshot
        if (ranged.rangedDps) then
            local rangedDpsTextureId = GetInventoryItemTexture("player", INVSLOT_RANGED);
            array.insert(rowItems, { "rangedDps", rangedDpsTextureId, string.format("%.01f", ranged.rangedDps) });
        end
        if (ranged.rangedAp) then
            array.concat(rowItems, {
                { "rangedAp", 132329, string.format("%d", ranged.rangedAp) },
                { "rangedCrit", 132090, string.format("%.02f%%", ranged.rangedCrit) },
                { "hit", 132222, string.format("+%.01f%%", data.hitBonus) },
            });
        end
    end

    if (data.spell) then
        local subdata = data.spell;
        local sp = math.min(subdata.spellBonus.holy,
            subdata.spellBonus.fire,
            subdata.spellBonus.nature,
            subdata.spellBonus.frost,
            subdata.spellBonus.shadow,
            subdata.spellBonus.arcane);
        -- 136096:spell_nature_starfall
        array.concat(rowItems, {
            { "sp", 136096, string.format("%d/%d", sp, subdata.spellBonus.healing) },
            { "spellCrit", 132090, string.format("%.02f%%", subdata.spellCrit) },
            { "spellHit", 132222, string.format("+%.01f%%", subdata.spellHitBonus) },
        });
    end

    return rowItems;
end

function AnchorFrame.render(self, cti)
    local data = getData(cti);
    local rowItems = AnchorFrame.getRowItems(data) or {};
    self.rows = self.rows or {};
    local i = 1; -- iteration on data
    local j = 1; -- iteration on view
    while (i <= array.size(rowItems)) do
        local rowItem = rowItems[i];
        if (rowItem[3]) then
            local row = self.rows[j];
            if (not row) then
                array.insert(self.rows, AnchorFrame.createRow(self, j - 1));
                row = self.rows[j];
            end
            row.keyIcon:SetTexture(rowItem[2]);
            row.valueText:SetText(rowItem[3]);
            j = j + 1;
        end
        i = i + 1;
    end
    while (j <= array.size(self.rows)) do
        local row = self.rows[j];
        row.keyIcon:SetTexture(nil);
        row.valueText:SetText(nil);
    end
end

function AnchorFrame.onElapse(self, elapsed)
    self.ttl = self.ttl - elapsed;
    if (self.ttl < 0) then
        self.ttl = nil;
        self:SetScript("OnUpdate", nil);
        if (type(self.refresh) == "function") then
            self.refresh(self);
        end
    end
end

function AnchorFrame.delayRefresh(self)
    -- immediate refresh leads to incorrect result
    -- delay long enough
    self.ttl = 0.5;
    if (not self:GetScript("OnUpdate")) then
        self:SetScript("OnUpdate", AnchorFrame.onElapse);
    end
end

--------

local function createAnchorOfCti(cti)
    local f = AnchorFrame.createAnchor();
    f.refresh = function(self)
        AnchorFrame.render(self, cti);
    end;
    f:SetScript("OnEvent", AnchorFrame.delayRefresh);

    CharacterModelFrame:HookScript("OnShow", function(self)
        f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
        f:RegisterEvent("SKILL_LINES_CHANGED");
        f:RegisterUnitEvent("UNIT_ATTACK", "player");
        f:RegisterUnitEvent("UNIT_ATTACK_POWER", "player");
        f:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");
        f:RegisterUnitEvent("UNIT_AURA", "player");
        f:RegisterUnitEvent("UNIT_RANGED_ATTACK_POWER", "player");
        f:RegisterUnitEvent("UNIT_RANGEDDAMAGE", "player");
        f:RegisterUnitEvent("UNIT_STATS", "player");
        local onEvent = f:GetScript("OnEvent");
        if (type(onEvent) == "function") then
            onEvent(f, "INIT");
        end
        f:Show();
    end);

    CharacterModelFrame:HookScript("OnHide", function(self)
        f:Hide();
        f:UnregisterAllEvents();
    end);

    return f;
end

if (false) then
    local f = createAnchorOfCti("defensive");
    f:SetPoint("TOPLEFT", 6, -36);
end

if (true) then
    local f = createAnchorOfCti("primary");
    --f:SetPoint("TOPLEFT", 6, -212);
    f:SetPoint("TOPLEFT", 6, -36);
end

local _, class = UnitClass("player");
if (class == "WARRIOR" or class == "ROGUE") then
    local f = createAnchorOfCti("melee");
    f:SetPoint("TOPLEFT", 6, -69);
elseif (class == "HUNTER") then
    local f = createAnchorOfCti("ranged");
    f:SetPoint("TOPLEFT", 6, -108);
else
    local f = createAnchorOfCti("spell");
    f:SetPoint("TOPLEFT", 6, -108);
end

--CharacterModelFrameRotateRightButton:Hide();
--CharacterModelFrameRotateLeftButton:Hide();

--CharacterResistanceFrame:Hide();
--CharacterAttributesFrame:Hide();
--CharacterModelFrame:SetHeight(302);

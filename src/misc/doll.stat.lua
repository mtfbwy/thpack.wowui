-- must stick to what you want and follow your own path

local AnchorFrame = {};

function AnchorFrame.createAnchor()
    local f = CreateFrame("Frame", nil, CharacterModelFrame, nil);
    f:SetSize(1, 1);
    f:SetPoint("TOPLEFT");
    f:Hide();
    return f;
end

function AnchorFrame.createRow(self, numOffsetLines, dx, dy)
    local ICON_HEIGHT = 20;
    local LINE_HEIGHT = 14;
    --local keyText = self:CreateFontString(nil, "OVERLAY", nil);
    --keyText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
    --keyText:SetJustifyH("RIGHT");
    --keyText:SetPoint("TOPLEFT", 0, -LINE_HEIGHT * i);
    --keyText:SetSize(30, LINE_HEIGHT);
    local keyIcon = self:CreateTexture(nil, "OVERLAY");
    keyIcon:SetPoint("TOPLEFT", 0 + dx, -(ICON_HEIGHT + 2) * numOffsetLines + dy);
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

    local withDefense = 1;
    local withMelee = 0;
    local withRanged = 0;
    local withSpell = 0;
    local _, class = UnitClass("player");
    if (class == "WARRIOR") then
        withDefense = 3;
        withMelee = 9;
    elseif (class == "PALADIN") then
        withDefense = 3;
        withMelee = 9;
        withSpell = 9;
    elseif (class == "HUNTER") then
        withRanged = 9;
        withSpell = 1;
    elseif (class == "ROGUE") then
        withMelee = 9;
    elseif (class == "DRUID") then
        withDefense = 3;
        withMelee = 1;
        withSpell = 1;
    elseif (class == "MAGE" or class == "WARLOCK" or class == "PRIEST") then
        withRanged = 2;
        withSpell = 9;
    end

    -- must have: primary
    do
        -- 134830:inv_potion_50 as health
        -- 134851:inv_potion_71 as mana
        -- 134800:INV_Potion_20 as mixed
        -- 135970:spell_holy_sealofwisdom as manaRegen TODO change to blue drop
        local primary = data.primary;
        if (primary.mana > 0) then
            local primaryString = tostring(primary.health) .. "/" .. tostring(primary.mana);
            array.insert(rowItems, { "primary", 134800, primaryString });
            local totalRegen = (primary.spiritManaRegen or 0) + primary.gearManaRegen;
            local manaRegenString = string.format("+%d/%d", totalRegen, primary.gearMp5);
            array.insert(rowItems, { "manaRegen", 135970, manaRegenString });
        else
            array.insert(rowItems, { "primary", 134830, tostring(primary.health) });
        end
    end

    if (withDefense >= 1) then
        -- 132341:ability_warrior_defensivestance
        -- 135893:spell_holy_devotionaura
        -- 136047:spell_nature_invisibilty
        -- 132269:ability_parry
        -- 132110:ability_defend
        local defense = data.physical.defense;
        local defenseString = string.format("%d/%d", defense.rank, defense.armor);
        array.insert(rowItems, { "defense", 132341, defenseString });
        if (withDefense >= 3) then
            array.insert(rowItems, { "dodge", 136047, string.format("%.1f%%", defense.dodge) });
            array.insert(rowItems, { "parry", 132269, string.format("%.1f%%", defense.parry) });
        end
        if (withDefense == 9) then
            array.insert(rowItems,
                { "block", 132110, string.format("%.1f%%/%d", defense.blockChance, defense.blockAmount) });
        end
    end

    if (withMelee >= 1) then
        -- 132223:ability_meleedamage
        -- 132333:ability_warrior_battleshout
        -- 132090:ability_backstab
        -- 132222:ability_marksmanship
        local melee = data.physical;
        local meleeWeaponTextureId = GetInventoryItemTexture("player", INVSLOT_MAINHAND) or 132223;
        local meleeDpsString = melee.offhandDps
            and string.format("%.01f/%.01f", melee.mainhandDps, melee.offhandDps)
            or string.format("%.01f", melee.mainhandDps);
        array.insert(rowItems, { "meleeDps", meleeWeaponTextureId, meleeDpsString });
        if (withMelee == 9) then
            array.concat(rowItems, {
                { "meleeAp", 135906, string.format("%d", melee.meleeAp) },
                { "meleeCrit", 132090, string.format("%.02f%%", melee.meleeCrit), },
                { "hit", 132222, string.format("+%.01f%%", melee.hitBonus) },
            });
        end
    end

    if (withRanged >= 1) then
        -- 132329:ability_trueshot
        -- 132169:ability_hunter_criticalshot
        local magical = data.magical;
        if (withRanged == 2) then
            if (magical.wandDps) then
                local rangedDpsTextureId = GetInventoryItemTexture("player", INVSLOT_RANGED);
                array.insert(rowItems, { "wandDps", rangedDpsTextureId, string.format("%.01f", magical.wandDps) });
            end
        elseif (withRanged == 9) then
            local ranged = data.physical;
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
    end

    local spellRowItems = {};
    if (withSpell >= 1) then
        -- 136096:spell_nature_starfall
        local magical = data.magical;
        local sp = math.min(magical.spellBonus.holy,
            magical.spellBonus.fire,
            magical.spellBonus.nature,
            magical.spellBonus.frost,
            magical.spellBonus.shadow,
            magical.spellBonus.arcane);
        array.insert(spellRowItems, { "sp", 136096, string.format("%d/%d", sp, magical.spellBonus.healing) });
        if (withSpell == 9) then
            array.concat(spellRowItems, {
                { "spellCrit", 132090, string.format("%.02f%%", magical.spellCrit) },
                { "spellHit", 132222, string.format("+%.01f%%", magical.spellHitBonus) },
            });
        end
    end

    return rowItems, spellRowItems;
end

function AnchorFrame.render(self, rowItems, spellRowItems)
    self.rows = self.rows or {};
    AnchorFrame.renderRowItems(self, self.rows, rowItems, 6, -36);
    if (spellRowItems) then
        self.spellRows = self.spellRows or {};
        AnchorFrame.renderRowItems(self, self.spellRows, spellRowItems, 160, -146);
    end
end

function AnchorFrame.renderRowItems(self, rows, rowItems, dx, dy)
    local i = 1; -- iteration on data
    local j = 1; -- iteration on view
    while (i <= array.size(rowItems)) do
        local rowItem = rowItems[i];
        if (rowItem[3]) then
            local row = rows[j];
            if (not row) then
                array.insert(rows, AnchorFrame.createRow(self, j - 1, dx, dy));
                row = rows[j];
            end
            row.keyIcon:SetTexture(rowItem[2]);
            row.valueText:SetText(rowItem[3]);
            j = j + 1;
        end
        i = i + 1;
    end
    while (j <= array.size(rows)) do
        local row = rows[j];
        row.keyIcon:SetTexture(nil);
        row.valueText:SetText(nil);
    end
end

function AnchorFrame.onElapse(self, elapsed)
    self.ttl = self.ttl - elapsed;
    if (self.ttl < 0) then
        self.ttl = nil;
        self:SetScript("OnUpdate", nil);

        local data = CharacterBook.getCharacterAttributes("all");
        local rowItems, spellRowItems = AnchorFrame.getRowItems(data);
        if (array.size(rowItems) + array.size(spellRowItems) <= 8) then
            array.concat(rowItems, spellRowItems);
            spellRowItems = {};
        end
        AnchorFrame.render(self, rowItems, spellRowItems);
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

local function deployAnchorFrame()
    local f = AnchorFrame.createAnchor();
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

if (false) then
    local f = createAnchorOfCti("primary");
    --f:SetPoint("TOPLEFT", 6, -212);
    f:SetPoint("TOPLEFT", 6, -36);
end

deployAnchorFrame();

--CharacterModelFrameRotateRightButton:Hide();
--CharacterModelFrameRotateLeftButton:Hide();

--CharacterResistanceFrame:Hide();
--CharacterAttributesFrame:Hide();
--CharacterModelFrame:SetHeight(302);

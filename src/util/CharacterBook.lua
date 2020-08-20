if (CharacterBook) then
    return;
end

CharacterBook = {};
local CharacterBook = CharacterBook;

--------

local function getSpiritManaRegenTalentMultiplier()
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

function CharacterBook.getManaRegenPerPulse()
    local NUM_SECONDS_PER_PULSE = 2;
    -- GetManaRegen() gives 0.00xxx within 5s after a mana-cost cast
    local baseRegen = GetManaRegen();
    if (baseRegen >= 1) then
        baseRegen = baseRegen * getSpiritManaRegenTalentMultiplier();
    else
        baseRegen = 0;
    end
    local mp1 = GearBook.getUnitEquippedGearsMp5("player") / 5;
    return baseRegen * NUM_SECONDS_PER_PULSE, mp1 * NUM_SECONDS_PER_PULSE;
end

-- including wand
local function getRangedDps()
    local weaponCooldown, minDamage, maxDamage, posBuff, negBuff, multiple = UnitRangedDamage("player");
    if (weaponCooldown and weaponCooldown > 0) then
        return (minDamage + maxDamage) / 2 / weaponCooldown;
    end
end

function CharacterBook.getCharacterAttributes(cti)
    if (not cti) then
        cti = "all";
    end

    CharacterBook.characterAttributes = CharacterBook.characterAttributes or {};
    local data = CharacterBook.characterAttributes;

    if (cti == "all" or cti == "primary") then
        local spiritManaRegen, gearManaRegen = CharacterBook.getManaRegenPerPulse();
        data.primary = data.primary or {};
        data.primary.health = UnitHealthMax("player");
        data.primary.mana = UnitPowerMax("player", Enum.PowerType.Mana);
        data.primary.spiritManaRegen = spiritManaRegen;
        data.primary.gearManaRegen = gearManaRegen;
    end

    if (cti == "all" or cti == "physical") then
        local mainhandDps;
        local offhandDps;
        do
            local mainhandCooldown, offhandCooldown = UnitAttackSpeed("player");
            local mainhandMinDamage, mainhandMaxDamage, offhandMinDamage, offhandMaxDamage, _, _, _ = UnitDamage("player");
            -- fist cooldown defaults to 2.0
            mainhandDps = (mainhandMinDamage + mainhandMaxDamage) / 2 / mainhandCooldown;
            if (offhandCooldown) then
                offhandDps = (offhandMinDamage + offhandMaxDamage) / 2 / offhandCooldown;
            end
        end

        local meleeAp;
        do
            local base, posBuff, negBuff = UnitAttackPower("player");
            meleeAp = (base + posBuff + negBuff) or 0;
        end

        local rangedAp;
        do
            local base, posBuff, negBuff = UnitRangedAttackPower("player");
            rangedAp = (base + posBuff + negBuff) or 0;
        end

        data.physical = data.physical or {};
        data.physical.mainhandDps = mainhandDps;
        data.physical.offhandDps = offhandDps;
        data.physical.meleeAp = meleeAp;
        data.physical.meleeCrit = GetCritChance() or 0;
        data.physical.hitBonus = GetHitModifier() or 0;
        data.physical.rangedDps = getRangedDps();
        data.physical.rangedAp = rangedAp;
        data.physical.rangedCrit = GetRangedCritChance() or 0;

        do
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

            data.physical.defense = data.physical.defense or {};
            local defense = data.physical.defense;
            defense.rank = rank;
            defense.armor = effectiveArmor or 0;
            defense.dodge = GetDodgeChance() or 0;
            defense.parry = GetParryChance() or 0;
            defense.blockChance = GetBlockChance() or 0;
            defense.blockAmount = GetShieldBlock() or 0;
        end
    end

    if (cti == "all" or cti == "magical") then
        data.magical = data.magical or {};
        data.magical.spellCrit = GetSpellCritChance() or 0;
        data.magical.spellHitBonus = GetSpellHitModifier() or 0;
        data.magical.wandDps = getRangedDps();

        data.magical.spellBonus = data.magical.spellBonus or {};
        local spellBonus = data.magical.spellBonus;
        spellBonus.physical = GetSpellBonusDamage(1);
        spellBonus.holy = GetSpellBonusDamage(2);
        spellBonus.fire = GetSpellBonusDamage(3);
        spellBonus.nature = GetSpellBonusDamage(4);
        spellBonus.frost = GetSpellBonusDamage(5);
        spellBonus.shadow = GetSpellBonusDamage(6);
        spellBonus.arcane = GetSpellBonusDamage(7);
        spellBonus.healing = GetSpellBonusHealing();
    end

    return data;
end

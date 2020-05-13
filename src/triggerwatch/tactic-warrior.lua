if (select(2, UnitClass("player")) ~= "WARRIOR") then
    return;
end

local A = A;

local getStance = GetShapeshiftForm;

local function getMainHandWeaponDph()
    local ap = UnitAttackPower("player");
    local minDph, maxDph, _, _, pos, neg = UnitDamage("player");
    return minDph - ap / 14, maxDph - ap / 14;
end

local function getUnitBuffEndTime(unit, spellName)
    local uptime = 2419200;
    for i = 1, 40, 1 do
        local buffName, _, _, _, duration, endTime, _, _, _, buffSpellId = UnitAura(unit, i);
        if (not buffName) then
            return 0;
        end
        local buffSpellName = GetSpellInfo(buffSpellId);
        if (buffSpellName == spellName) then
            return (duration > 0 and endTime) and endTime or (uptime + 604800);
        end
    end
end

local function isFineTarget()
    return UnitExists("target") and UnitIsEnemy("player", "target") and not UnitIsDead("target");
end

-- the behavior for fury warrior in dungeon or raid but not in battleground:
--  isEnabled: when ui can show
--  isReadyToCast: when isEnabled && you press hotkey and you cast
--  isSuggested: when isEnabled && it believes you should cast
--  e.g. [Overpower]:
--      isEnabled = when triggered
--      isSuggested: isEnabled && (in battle stance || (not in battle stance && rage <= 15))
--  e.g. [Battle Shout]:
--      isSuggested: when no such buff && in battle && enough rage
--  e.g. 毛乱舞 [Hamstring]:
--      isSuggested: when no Flurry buff && Bloodthirst cooldown > gcd && Whirlwind cooldown > gcd && rage > 70
--  e.g. 毛副手命中 [Heroic Strike]:
--      isSuggested: when main hand cooldown started 0.3s && rage > 30 + 15
--      isChecked: when pressed; ui show inner highlight, same as action button
--      isLanding: when isChecked && (main hand cooldown < 0.5s || off hand cooldown > 1s)
--      or:
--      isSuggested: when main hand cooldown - off hand cooldown > 0.6
--      isLanding: when isChecked && main hand cooldown < 0.5
--  e.g. [Execute]:
--      isEnabled: when target health < 22%
--      isReadyToCast: when target health < 20% and enough range
--      isSuggested: when isReadyToCast

local addonName, addon = ...;
local grid = addon.TriggerWatch.GridCtrl.instance;

--------
-- [Execute]

local SPELL_ID_EXECUTE = 5308;
grid:registerCell(SPELL_ID_EXECUTE, function(cell)
    function cell.refreshCell(cell)
        cell.isEnabled = isFineTarget() and (UnitHealth("target") / UnitHealthMax("target") < 0.22);
        if (not cell.isEnabled) then
            return;
        end

        local now = GetTime();
        local fineCooldown = SpellBook.getSpellCooldownEndTime(cell.spellName) - now < 0.1;

        cell.isReadyToCast = fineCooldown and SpellBook.hasSpellCastResource(cell.spellName);

        cell.isSuggested = cell.isReadyToCast;
    end
end);

--------
-- [Battle Shout]
--  isSuggested: when no such buff && in battle && enough rage

local SPELL_ID_BATTLE_SHOUT = 6673;
grid:registerCell(SPELL_ID_BATTLE_SHOUT, function(cell)
    function cell.refreshCell(cell)
        local inCombat = UnitAffectingCombat("player");
        local buffEndTime = getUnitBuffEndTime("player", cell.spellName);
        local now = GetTime();

        cell.isEnabled = inCombat and (buffEndTime - now < 3);
        if (not cell.isEnabled) then
            return;
        end

        local hasBuffBattleShout = buffEndTime > 0;
        local fineCooldown = SpellBook.getSpellCooldownEndTime(cell.spellName) - now < 0.1;

        cell.isReadyToCast = not hasBuffBattleShout and fineCooldown and SpellBook.hasSpellCastResource(cell.spellName);

        cell.isSuggested = cell.isReadyToCast;
    end
end);

--------
-- [Bloodthirst]
--  isEnabled: in battle
--  isSuggested: rage >= 30 && not in cooldown

local SPELL_ID_BLOODTHIRST = 23881;
grid:registerCell(SPELL_ID_BLOODTHIRST, function(cell)
    function cell.refreshCell(cell)
        local inCombat = UnitAffectingCombat("player");
        local ttc = SpellBook.getSpellCooldownEndTime(cell.spellName) - GetTime();

        cell.isEnabled = inCombat and isFineTarget() and (ttc < 1);
        if (not cell.isEnabled) then
            return;
        end

        cell.isReadyToCast = (ttc < 0.1) and SpellBook.hasSpellCastResource(cell.spellName);

        cell.isSuggested = cell.isReadyToCast;
    end
end);

--------
-- [Whirlwind]

local SPELL_ID_WHIRLWIND = 1680;
grid:registerCell(SPELL_ID_WHIRLWIND, function(cell)
    function cell.initCell(cell)
        if (not getProto(cell).initCell(cell)) then
            return false;
        end

        cell.spellNameBloodthirst = SpellBook.getSpellName(SPELL_ID_BLOODTHIRST);
        return true;
    end

    function cell.refreshCell(cell)
        local inCombat = UnitAffectingCombat("player");
        local now = GetTime();
        local ttc = SpellBook.getSpellCooldownEndTime(cell.spellName) - now;

        cell.isEnabled = inCombat and (ttc < 1);
        if (not cell.isEnabled) then
            return;
        end

        cell.isReadyToCast = (ttc < 0.1) and SpellBook.hasSpellCastResource(cell.spellName);

        local bloodthirstAfterNextGcd = SpellBook.getSpellCooldownEndTime(cell.spellNameBloodthirst) - now > 1.5;
        local _, maxDph = getMainHandWeaponDph();
        local rage = UnitPower("player", Enum.PowerType.Rage);

        if (bloodthirstAfterNextGcd) then
            cell.isSuggested = (maxDph > 150) and (rage > 60) or (rage > 85);
        else
            cell.isSuggested = false;
        end
    end
end);

--------
-- 毛乱舞 [Hamstring]:

local SPELL_ID_HAMSTRING = 1715;
local SPELL_ID_FLURRY = 12319;
grid:registerCell(SPELL_ID_HAMSTRING, function(cell)
    function cell.initCell(cell)
        if (not getProto(cell).initCell(cell)) then
            return false;
        end

        cell.spellNameFlurry = SpellBook.getSpellName(SPELL_ID_FLURRY, "notCheck");
        local talentName, _, _, _, talentRank = GetTalentInfo(2, 16);
        if (talentName ~= cell.spellNameFlurry or talentRank == 0) then
            return false;
        end

        cell.spellNameBloodthirst = SpellBook.getSpellName(SPELL_ID_BLOODTHIRST);
        cell.spellNameWhirlwind = SpellBook.getSpellName(SPELL_ID_WHIRLWIND);

        return true;
    end

    function cell.refreshCell(cell)
        local now = GetTime();
        local fineCooldown = SpellBook.getSpellCooldownEndTime(cell.spellName) - now < 0.1;
        local hasBuffFlurry = getUnitBuffEndTime("player", cell.spellNameFlurry) > 0;
        local bloodthirstAfterNextGcd = SpellBook.getSpellCooldownEndTime(cell.spellNameBloodthirst) - now > 1.5;
        local whirlwindAfterNextGcd = SpellBook.getSpellCooldownEndTime(cell.spellNameWhirlwind) - now > 1.5;
        local rage = UnitPower("player", Enum.PowerType.Rage);

        cell.isEnabled = isFineTarget() and fineCooldown and SpellBook.hasSpellCastResource(cell.spellName) and not hasBuffFlurry and bloodthirstAfterNextGcd and whirlwindAfterNextGcd and rage > 70;
        if (not cell.isEnabled) then
            return;
        end

        cell.isReadyToCast = true;

        cell.isSuggested = true;
    end
end);

--------
-- [Overpower]
--  isEnabled: when triggered
--  isSuggested: isEnabled && (in battle stance || (not in battle stance && rage <= 15))

local SPELL_ID_OVERPOWER = 7384;
grid:registerCell(SPELL_ID_OVERPOWER, function(cell)
    -- think the trigger gives a buff, which is the reagent of triggered spell
    cell.buffs = {};

    function cell.onCleuEvent(cell, ...)
        local timestamp, eventName, hidesCaster = ...;
        local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
        local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

        local isSrcUnit = (srcGuid == UnitGUID("player"));

        if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
            local spellId, spellName, spellSchool = select(12, ...);
            if (spellName == cell.spellName) then
                array.remove(cell.buffs, 1);
                if (array.size(cell.buffs) == 0) then
                    cell.uiFlipActionButtonOverlayGlow = -1;
                end
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
                local now = GetTime();
                array.insert(cell.buffs, {
                    startTime = now,
                    endTime = now + 5,
                });

                cell.uiFlipActionButtonOverlayGlow = 1;
            end
        end
    end

    function cell.refreshCell(cell)
        local now = GetTime();
        local cooldownEndTime = SpellBook.getSpellCooldownEndTime(cell.spellName);

        local oldCount = array.size(cell.buffs);
        while (array.size(cell.buffs) > 0) do
            local buff = cell.buffs[1];
            if (buff.endTime < now or buff.endTime < cooldownEndTime) then
                array.remove(cell.buffs, 1);
            else
                break;
            end
        end
        local count = array.size(cell.buffs);

        if (oldCount > 0 and count == 0) then
            cell.uiFlipActionButtonOverlayGlow = -1;
        end

        cell.isEnabled = count > 0;
        if (not cell.isEnabled) then
            return;
        end

        local lastBuff = cell.buffs[count];
        cell.ttl = lastBuff and (lastBuff.endTime - now) or 0;

        local fineCooldown = cooldownEndTime - now < 0.1;
        local inBattleStance = (getStance() == 1);
        local fineStanceCooldown = SpellBook.getStanceCooldownEndTime(1) - now < 0.1;
        local rage = UnitPower("player", Enum.PowerType.Rage);

        cell.isReadyToCast = isFineTarget() and (inBattleStance or fineStanceCooldown) and fineCooldown and (rage >= 5);

        cell.isSuggested = cell.isReadyToCast and (inBattleStance or rage <= 15);
    end
end);

--------
-- [Revenge]
--  isEnabled when triggered
--  isSuggested: never

local SPELL_ID_REVENGE = 6572;
grid:registerCell(SPELL_ID_REVENGE, function(cell)
    cell.buffs = {};

    function cell.onCleuEvent(cell, ...)
        local timestamp, eventName, hidesCaster = ...;
        local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
        local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

        local isSrcUnit = (srcGuid == UnitGUID("player"));
        local isDstUnit = (dstGuid == UnitGUID("player"));

        if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
            local spellId, spellName, spellSchool = select(12, ...);
            if (spellName == cell.spellName) then
                array.remove(cell.buffs, 1);
                if (array.size(cell.buffs) == 0) then
                    cell.uiFlipActionButtonOverlayGlow = -1;
                end
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
                local now = GetTime();
                array.insert(cell.buffs, {
                    startTime = now,
                    endTime = now + 5,
                });

                cell.uiFlipActionButtonOverlayGlow = 1;
            end
        end
    end

    function cell.refreshCell(cell)
        local now = GetTime();
        local cooldownEndTime = SpellBook.getSpellCooldownEndTime(cell.spellName);

        local oldCount = array.size(cell.buffs);
        while (array.size(cell.buffs) > 0) do
            local buff = cell.buffs[1];
            if (buff.endTime < now or buff.endTime < cooldownEndTime) then
                array.remove(cell.buffs, 1);
            else
                break;
            end
        end
        local count = array.size(cell.buffs);

        if (oldCount > 0 and count == 0) then
            cell.uiFlipActionButtonOverlayGlow = -1;
        end

        cell.isEnabled = count > 0;
        if (not cell.isEnabled) then
            return;
        end

        local lastBuff = cell.buffs[count];
        cell.ttl = lastBuff and (lastBuff.endTime - now) or 0;

        local fineCooldown = cooldownEndTime - now < 0.1;
        local inProtStance = getStance() == 2;
        local fineStanceCooldown = SpellBook.getStanceCooldownEndTime(2) - now > 0.1;
        local rage = UnitPower("player", Enum.PowerType.Rage);

        cell.isReadyToCast = isFineTarget() and (inProtStance or fineStanceCooldown) and fineCooldown and (rage >= 5);

        cell.isSuggested = false;
    end
end);

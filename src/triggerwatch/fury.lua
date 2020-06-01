if (select(2, UnitClass("player")) ~= "WARRIOR") then
    return;
end

local A = A;

local getStance = GetShapeshiftForm;

local function getMainHandWeaponDph()
    local ap = UnitAttackPower("player");
    local minDph, maxDph, _, _, posBuff, negBuff = UnitDamage("player");
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

local function isFineTargetRange(spellName)
    return IsSpellInRange(spellName, "target") == 1;
end

local function isFineTargetUnit()
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
local tw = addon.TriggerWatch.instance;

--------
-- [Execute]

local SPELL_ID_EXECUTE = 5308;
tw:register(function(item)

    item.hintSpellId = SPELL_ID_EXECUTE;

    function item.onUpdate(self)
        self:updateSpell();
        local fineTargetHealth = UnitHealth("target") / UnitHealthMax("target") < 0.215;
        self.stateShown = isFineTargetUnit() and fineTargetHealth;
        self.stateEnabled = self.stateEnabled and isFineTargetRange(self.hintSpellName);
        self.suggestion = self.stateEnabled and "cast" or nil;
    end
end);

--------
-- [Battle Shout]

local SPELL_ID_BATTLE_SHOUT = 6673;
tw:register(function(item)

    item.hintSpellId = SPELL_ID_BATTLE_SHOUT;

    function item.onUpdate(self)
        self:updateSpell();

        local inCombat = UnitAffectingCombat("player");
        local buffTtl = getUnitBuffEndTime("player", self.hintSpellName) - GetTime();

        -- in battle && buff almost gone
        self.stateShown = inCombat and (buffTtl < 2);
        self.stateEnabled = self.stateEnabled and (buffTtl < 0);
        self.suggestion = self.stateEnabled and "cast" or nil;
    end
end);

--------
-- [Bloodthirst]
--  isEnabled: in battle
--  isSuggested: rage >= 30 && not in cooldown

local SPELL_ID_BLOODTHIRST = 23881;
tw:register(function(item)

    item.hintSpellId = SPELL_ID_BLOODTHIRST;

    function item.onUpdate(self)
        self:updateSpell();
        local inCombat = UnitAffectingCombat("player");
        self.stateShown = inCombat and isFineTargetUnit() and (self.ttc < 1);
        self.stateEnabled = self.stateEnabled and isFineTargetRange(self.hintSpellName);
        self.suggestion = self.stateEnabled and "cast" or nil;
    end
end);

--------
-- [Whirlwind]

local SPELL_ID_WHIRLWIND = 1680;
tw:register(function(item)

    item.hintSpellId = SPELL_ID_WHIRLWIND;

    function item.onInit(self)
        getProto(self).onInit(self);

        self.spellNameBloodthirst = SpellBook.getSpellName(SPELL_ID_BLOODTHIRST);
        return true;
    end

    function item.onUpdate(self)
        self:updateSpell();
        local inCombat = UnitAffectingCombat("player");
        local bloodthirstTtc = SpellBook.getSpellCooldownEndTime(self.spellNameBloodthirst) - GetTime();
        local now = GetTime();

        self.stateShown = inCombat and (self.ttc < 1);

        local _, weaponMaxDph = getMainHandWeaponDph();
        local rage = UnitPower("player", Enum.PowerType.Rage);

        if (bloodthirstTtc < 1.5) then
            self.suggestion = nil;
        elseif (weaponMaxDph > 150) then
            self.suggestion = rage > 60 and "cast" or nil;
        else
            self.suggestion = rage > 85 and "cast" or nil;
        end
    end
end);

--------
-- 毛乱舞 [Hamstring]:

local SPELL_ID_HAMSTRING = 1715;
local SPELL_ID_FLURRY = 12319;
tw:register(function(item)

    item.hintSpellId = SPELL_ID_HAMSTRING;

    function item.onInit(self)
        getProto(self).onInit(self);

        self.spellNameFlurry = SpellBook.getSpellName(SPELL_ID_FLURRY, "notCheck");
        local talentName, _, _, _, talentRank = GetTalentInfo(2, 16);
        if (talentName ~= self.spellNameFlurry or talentRank == 0) then
            return false;
        end

        self.spellNameBloodthirst = SpellBook.getSpellName(SPELL_ID_BLOODTHIRST);
        self.spellNameWhirlwind = SpellBook.getSpellName(SPELL_ID_WHIRLWIND);

        return true;
    end

    function item.onUpdate(self)
        self:updateSpell();
        local now = GetTime();
        local hasBuffFlurry = getUnitBuffEndTime("player", self.spellNameFlurry) > 0;
        local bloodthirstTtc = SpellBook.getSpellCooldownEndTime(self.spellNameBloodthirst) - now;
        local whirlwindTtc = SpellBook.getSpellCooldownEndTime(self.spellNameWhirlwind) - now;
        local rage = UnitPower("player", Enum.PowerType.Rage);

        local isCastable = self.stateEnabled and isFineTargetUnit() and isFineTargetRange(self.hintSpellName);
        self.stateShown = isCastable and not hasBuffFlurry and bloodthirstTtc > 1.5 and whirlwindTtc > 1.5 and rage > 70;
        self.stateEnabled = self.stateShown;
        self.suggestion = self.stateEnabled and "cast" or nil;
    end
end);

--------
-- [Overpower]
--  isEnabled: when triggered
--  isSuggested: isEnabled && (in battle stance || (not in battle stance && rage <= 15))

local SPELL_ID_OVERPOWER = 7384;
tw:register(function(item)

    item.hintSpellId = SPELL_ID_OVERPOWER;

    -- think the trigger gives a buff, which is the reagent of triggered spell
    item.buffs = {};

    function item.onCleu(self, ...)
        local timestamp, eventName, hidesCaster = ...;
        local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
        local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

        local isSrcUnit = (srcGuid == UnitGUID("player"));

        if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
            local spellId, spellName, spellSchool = select(12, ...);
            if (spellName == self.hintSpellName) then
                array.remove(self.buffs, 1);
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
                array.insert(self.buffs, {
                    startTime = now,
                    endTime = now + 5,
                });
            end
        end
    end

    function item.onUpdate(self)
        self:updateSpell();
        local now = GetTime();
        local cooldownEndTime = SpellBook.getSpellCooldownEndTime(self.hintSpellName);

        local oldCount = array.size(self.buffs);
        while (array.size(self.buffs) > 0) do
            local buff = self.buffs[1];
            if (buff.endTime < now or buff.endTime < cooldownEndTime) then
                array.remove(self.buffs, 1);
            else
                break;
            end
        end
        local count = array.size(self.buffs);

        self.stateShown = count > 0 and isFineTargetUnit();

        local lastBuff = self.buffs[count];
        self.ttl = lastBuff and (lastBuff.endTime - now) or 0;

        local inBattleStance = (getStance() == 1);
        local fineStanceCooldown = SpellBook.getStanceCooldownEndTime(1) - now < 0.1;
        local rage = UnitPower("player", Enum.PowerType.Rage);

        self.stateEnabled = self.stateEnabled and isFineTargetRange(self.hintSpellName) and (inBattleStance or fineStanceCooldown);
        self.suggestion = (self.stateEnabled and (inBattleStance or rage < 23)) and "cast" or nil;
    end
end);

--------
-- [Revenge]
--  isEnabled when triggered
--  isSuggested: never

local SPELL_ID_REVENGE = 6572;
tw:register(function(item)

    item.hintSpellId = SPELL_ID_REVENGE;

    item.buffs = {};

    function item.onCleu(self, ...)
        local timestamp, eventName, hidesCaster = ...;
        local srcGuid, srcName, srcFlags, srcRaidFlags = select(4, ...);
        local dstGuid, dstName, dstFlags, dstRaidFlags = select(8, ...);

        local isSrcUnit = (srcGuid == UnitGUID("player"));
        local isDstUnit = (dstGuid == UnitGUID("player"));

        if (isSrcUnit and eventName == "SPELL_CAST_SUCCESS") then
            local spellId, spellName, spellSchool = select(12, ...);
            if (spellName == self.hintSpellName) then
                array.remove(self.buffs, 1);
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
                array.insert(self.buffs, {
                    startTime = now,
                    endTime = now + 5,
                });
            end
        end
    end

    function item.onUpdate(self)
        self:updateSpell();
        local now = GetTime();
        local cooldownEndTime = SpellBook.getSpellCooldownEndTime(self.hintSpellName);

        local oldCount = array.size(self.buffs);
        while (array.size(self.buffs) > 0) do
            local buff = self.buffs[1];
            if (buff.endTime < now or buff.endTime < cooldownEndTime) then
                array.remove(self.buffs, 1);
            else
                break;
            end
        end
        local count = array.size(self.buffs);

        self.stateShown = count > 0 and isFineTargetUnit();

        local lastBuff = self.buffs[count];
        self.ttl = lastBuff and (lastBuff.endTime - now) or 0;

        local inProtStance = getStance() == 2;
        local fineStanceCooldown = SpellBook.getStanceCooldownEndTime(2) - now > 0.1;
        local rage = UnitPower("player", Enum.PowerType.Rage);

        self.stateEnabled = self.stateEnabled and isFineTargetRange(self.hintSpellName) and (inProtStance or fineStanceCooldown);

        self.suggestion = (self.stateEnabled and inProtStance) and "cast" or nil;
    end
end);

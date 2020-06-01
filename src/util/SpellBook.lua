if (SpellBook) then
    return;
end

SpellBook = {};

function SpellBook.getSpellName(spellIdOrName, notCheck)
    local localName = GetSpellInfo(spellIdOrName);
    if (notCheck) then
        return localName;
    end
    if (localName) then
        return GetSpellInfo(localName);
    end
    return nil;
end

function SpellBook.getSpellCooldownEndTime(spellIdOrName)
    local spellName = SpellBook.getSpellName(spellIdOrName);
    if (not spellName) then
        -- not learned, 28d
        return GetTime() + 2419200, "unknown";
    end
    local startTime, duration, castDone = GetSpellCooldown(spellName);
    if (castDone == 0) then
        -- spell is lasting, e.g. [Stealth]
        return 0, "casting";
    else
        return startTime + duration, nil;
    end
end

function SpellBook.getSpellRange(spellIdOrName)
    local localName, _, _, _, minRange, maxRange = GetSpellInfo(spellIdOrName);
    if (not localName) then
        return nil;
    else
        return minRange, maxRange;
    end
end

function SpellBook.getStanceCooldownEndTime(index)
    local startTime, duration, isReady = GetShapeshiftFormCooldown(index);
    return isReady and 0 or (startTime + duration);
end

function SpellBook.hasLearnedSpell(spellIdOrName)
    return SpellBook.getSpellName(spellIdOrName) ~= nil;
end

-- check learned
-- check mana/reagent
-- check reactive condition
-- not check cooldown
-- not check target
-- not check range
-- see also: GetSpellPowerCost
function SpellBook.hasSpellCastResource(spellIdOrName)
    return IsUsableSpell(spellIdOrName);
end

if (SpellBook) then
    return;
end

SpellBook = {};

function SpellBook.getSpellName(spellIdOrName)
    local localName = GetSpellInfo(spellIdOrName);
    if (localName) then
        return GetSpellInfo(localName);
    end
    return nil;
end

function SpellBook.getSpellCooldownEndTime(spellIdOrName)
    local spellName = SpellBook.getSpellName(spellIdOrName);
    if (not spellName) then
        return 2419200;
    end
    local startTime, duration, isActive = GetSpellCooldown(spellName);
    return (isActive == 0) and 604800 or (startTime + duration);
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

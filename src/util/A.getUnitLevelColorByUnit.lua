A = A or {};

A.getUnitLevelColorByUnit = A.getUnitLevelColorByUnit or function(unit)
    if (UnitCanAttack("player", unit)) then
        local level = UnitLevel(unit);
        local c = GetCreatureDifficultyColor(level);
        return Color.fromVertex(c.r, c.g, c.b);
    else
        -- Blizzard yellow
        return Color.fromVertex(1.0, 0.82, 0.0);
    end
end;

A.getUnitLevelSuffixByUnit = A.getUnitLevelSuffixByUnit or function(unit)
    if (UnitIsPlayer(unit)) then
        return "";
    end

    local classification = UnitClassification(unit);
    if (classification == "worldboss") then
        return "x";
    elseif (classification == "elite") then
        return "+";
    elseif (classification == "rare") then
        return "$";
    elseif (classification == "rareelite") then
        return "*";
    elseif (classification == "trivial") then
        return "-";
    elseif (false) then
        -- TODO quest mob
        return "!";
    end
    return "";
end;

A.getUnitLevelSkullTextureString = A.getUnitLevelSkullTextureString or function(fontSize)
    return string.format(
            "|T%s:%d:%d:0:0:100:100:0:100:0:100|t",
            "Interface/TargetingFrame/UI-TargetingFrame-Skull",
            fontSize, fontSize);
end;

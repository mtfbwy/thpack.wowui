local addonName, addon = ...;
local A = addon.A;

----------------------------------------

A.getColoredString = A.getColoredString or function(color, s)
    return string.format("|cff%06x%s|r", color:toInt24(), s);
end;

----------------------------------------

A.getMasterUnitByUnit = A.getMasterUnitByUnit or function(unit)
    if (unit == "pet" or unit == "vehicle") then
        return "player";
    end

    local partypetn = unit:match("^partypet(%d+)$");
    if (partypetn) then
        return "party" .. partypetn;
    end

    local raidpetn = unit:match("^raidpet(%d+)$");
    if (raidpetn) then
        return "raid" .. raidpetn;
    end
end

----------------------------------------
-- name color

-- TargetFrame_CheckFaction()
-- UnitIsEnemy()
-- UnitIsFriend()
-- UnitIsDead()
-- UnitIsGhose()
-- UnitReaction()
-- UnitSelectionColor()
A.getUnitNameColorByUnit = A.getUnitNameColorByUnit or function(unit)
    if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
        -- kind of bright gray
        return Color.pick("#999999");
    end

    -- tuned color as text fore color
    local red = Color.fromVertex(0.8, 0.2, 0.2);
    local green = Color.fromVertex(0.2, 0.6, 0.2);
    local blue = Color.pick("#5582fa");
    local yellow = Color.fromVertex(0.6, 0.6, 0.2);

    if (UnitIsPlayer(unit)) then
        -- horde against alliance
        if (UnitCanAttack(unit, "player")) then
            if (UnitCanAttack("player", unit)) then
                return red;
            else
                -- only he can attack! (in enemy-occupied territory)
                return Color.pick("#ff4500");
            end
        elseif (UnitCanAttack("player", unit)) then
            -- i feel safe
            return yellow;
        else
            -- friend
            if (UnitIsPVP(unit)) then
                return green;
            else
                return blue;
            end
        end
    else
        -- npc or pet or summonee
        if (UnitIsEnemy("player", unit)) then
            return red;
        elseif (UnitIsFriend("player", unit)) then
            return green;
        else
            return yellow;
        end
    end
end;

----------------------------------------
-- class

A.getUnitClassColorByUnit = A.getUnitClassColorByUnit or function(unit, useAlignedColor)
    local _, enUnitClass = UnitClass(unit);
    if (useAlignedColor) then
        return Color.pick(enUnitClass);
    end
    local c = RAID_CLASS_COLORS[enUnitClass];
    return c and Color.fromVertex(c.r, c.g, c.b);
end;

A.getUnitClassTextureStringByUnit = A.getUnitClassTextureStringByUnit or function(unit, fontSize)
    if (not unit or not UnitIsPlayer(unit)) then
        return "";
    end

    -- large enough for class texture
    local classTexture = "Interface/WorldStateFrame/Icons-Classes";
    local coords = CLASS_ICON_TCOORDS[select(2, UnitClass(unit))];
    if (coords) then
        return string.format(
                "|T%s:%s:%s:0:0:100:100:%s:%s:%s:%s|t",
                classTexture, fontSize, fontSize,
                coords[1] * 100, coords[2] * 100, coords[3] * 100, coords[4] * 100);
    end
    return "";
end;

A.getUnitClassColorTextureStringByUnit = A.getUnitClassColorTextureStringByUnit or function(unit, fontSize)
    if (not unit or not UnitIsPlayer(unit)) then
        return "";
    end

    local rr, gg, bb = A.getUnitClassColorByUnit(unit):toComponents();
    return string.format(
            "|T%s:%s:%s:0:0:100:100:0:100:0:100:%s:%s:%s|t",
            A.Res.tile32, fontSize, fontSize,
            rr, gg, bb);
end;

----------------------------------------
-- level

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

----------------------------------------
-- health

A.getUnitHealthColorByRate = A.getUnitHealthColorByRate or function(healthRate)
    -- color gradient is difficult to distinguish
    if (healthRate < 0.2) then
        -- 斩杀线
        return Color.pick("#ff0000");
    elseif (healthRate < 0.4) then
        return Color.pick("#ffff00");
    else
        return Color.pick("#ffffff");
    end
end;

A.getUnitHealthColorByUnit = A.getUnitHealthColorByUnit or function(unit)
    local currentHealth = UnitHealth(unit);
    local maxHealth = UnitHealthMax(unit);
    local healthRate = currentHealth / maxHealth;
    return A.getUnitHealthColorByRate(healthRate);
end;

A.getUnitManaTypeColorByUnit = A.getUnitManaTypeColorByUnit or function(unit)
    local typ = UnitPowerType(unit);
    if (typ == 0) then
        return Color.pick("RoyalBlue");
    elseif (typ == 1) then
        return Color.pick("FireBrick");
    elseif (typ == 2) then
        return Color.pick("Coral");
    elseif (typ == 3) then
        return Color.pick("Gold");
    elseif (typ == 6) then
        return Color.pick("Turquoise");
    else
        return Color.pick("White");
    end
end;

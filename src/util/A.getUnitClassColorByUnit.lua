A = A or {};

-- use aligned color
A.getUnitClassColorByUnit = A.getUnitClassColorByUnit or function(unit)
    local _, enUnitClass = UnitClass(unit);
    return Color.pick(enUnitClass);
end;

A.getUnitOffensiveColorByUnit = A.getUnitOffensiveColorByUnit or function(unit)
    if (UnitPlayerControlled(unit)) then
        if (UnitCanAttack(unit, "player")) then
            if (UnitCanAttack("player", unit)) then
                -- normal hostile
                return Color.pick("red");
            else
                -- only he can attack
                return Color.pick("orangered");
            end
        elseif (UnitCanAttack("player", unit)) then
            return Color.pick("yellow");
        else
            -- friendly
            if (UnitIsPVP(unit)) then
                return Color.pick("green");
            else
                return Color.pick("blue");
            end
        end
    else
        if (UnitIsEnemy("player", unit)) then
            return Color.pick("red");
        elseif (UnitIsFriend("player", unit)) then
            return Color.pick("green");
        else
            return Color.pick("yellow");
        end
    end
end;

A.getUnitManaTypeColorByUnit = A.getUnitManaTypeColorByUnit or function(unit)
    local typ = UnitPowerType(unit);
    if (typ == 0) then
        return Color.pick("royalblue");
    elseif (typ == 1) then
        return Color.pick("firebrick");
    elseif (typ == 2) then
        return Color.pick("coral");
    elseif (typ == 3) then
        return Color.pick("gold");
    elseif (typ == 6) then
        return Color.pick("turquoise");
    else
        return Color.pick("white");
    end
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

    local color = A.getUnitClassColorByUnit(unit);
    local r, g, b = color:toRgba();
    return string.format(
            "|T%s:%s:%s:0:0:100:100:0:100:0:100:%s:%s:%s|t",
            A.Res.tile32, fontSize, fontSize,
            r, g, b);
end;

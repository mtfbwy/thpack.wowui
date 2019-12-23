A = A or {};

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

    local color = A.getUnitClassColorByUnit(unit);
    local r, g, b = color:toRgba();
    return string.format(
            "|T%s:%s:%s:0:0:100:100:0:100:0:100:%s:%s:%s|t",
            A.Res.tile32, fontSize, fontSize,
            r, g, b);
end;

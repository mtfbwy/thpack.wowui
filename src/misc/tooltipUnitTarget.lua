(function()
    function getUnitClassTextureString(unit, height, width)
        if (not unit or not UnitIsPlayer(unit)) then
            return "";
        end

        -- large enough for class texture
        local classTexture = "Interface/WorldStateFrame/Icons-Classes";
        local coords = CLASS_ICON_TCOORDS[select(2, UnitClass(unit))];
        if (coords) then
            return string.format(
                    "|T%s:%s:%s:0:0:100:100:%s:%s:%s:%s|t",
                    classTexture,
                    height, width,
                    coords[1] * 100, coords[2] * 100, coords[3] * 100, coords[4] * 100);
        end
        return "";
    end

    function getUnitClassColorTextureString(unit, height, width)
        if (not unit or not UnitIsPlayer(unit)) then
            return "";
        end

        local color = A.Color.getUnitClassColorByUnit(unit);
        local r, g, b = color:toRgba();
        return string.format(
                "|T%s:%s:%s:0:0:100:100:0:100:0:100:%s:%s:%s|t",
                A.Res.tile32,
                height, width,
                0, 100, 0, 100,
                r, g, b);
    end

    function getColoredString(color, s)
        return string.format("|cff%06x%s|r", color:toInt24(), s);
    end

    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit();
        if not unit then
            return;
        end

        if (UnitIsPlayer(unit)) then
            -- add class texture to title line
            local unitName = UnitName(unit);
            local _, fontSize = GameTooltipTextLeft1:GetFont();
            local replaced, numTimes = GameTooltipTextLeft1:GetText():gsub(
                    unitName,
                    getUnitClassTextureString(unit, fontSize, fontSize) .. unitName);
            if (numTimes > 0) then
                GameTooltipTextLeft1:SetText(replaced);
            end
        end

        -- add unit target
        local unitTarget = unit .. "target";
        if (UnitExists(unitTarget)) then
            local prefix = "=> ";
            if (UnitIsUnit(unitTarget, "player")) then
                self:AddLine(prefix .. getColoredString(A.Color.pick("red"), "!!!"), 1, 1, 1);
            else
                local offensiveColor = A.Color.getUnitOffensiveColorByUnit(unitTarget);
                self:AddLine(
                        string.format("%s%s%s",
                                prefix,
                                getUnitClassColorTextureString(unitTarget, 8, 8),
                                getColoredString(offensiveColor, UnitName(unitTarget))),
                        1, 1, 1);
            end
        end
    end);
end)();

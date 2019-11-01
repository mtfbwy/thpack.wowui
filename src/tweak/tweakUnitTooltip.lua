(function()
    function getUnitClassTextureString(unit, height, width)
        if (not unit or not UnitIsPlayer(unit)) then
            return "";
        end

        height = math.floor(height or 8);
        width = math.floor(width or height);

        if (height >= 16) then
            -- large enough for class texture
            local classTexture = "Interface/WorldStateFrame/Icons-Classes";
            local coords = CLASS_ICON_TCOORDS[select(2, UnitClass(unit))];
            if (coords) then
                return string.format(
                        "|T%s:%s:%s:0:0:100:100:%s:%s:%s:%s|t",
                        classTexture, height, width,
                        coords[1] * 100, coords[2] * 100, coords[3] * 100, coords[4] * 100);
            end
        else
            -- small class color lump
            local color = A.Color.fromUnitClass(unit);
            local r, g, b, a = A.Color.toVertex(color);
            local s = string.format(
                    "|T%s:%s:%s:0:0:100:100:%s:%s:%s:%s:%s:%s:%s|t",
                    A.Res.texBackground, height, width,
                    0, 100, 0, 100,
                    math.floor(r * 255), math.floor(g * 255), math.floor(b * 255));
            return s;
        end
    end

    function getColoredString(color, s)
        return string.format("|cff%06x%s|r", A.Color.toInt24(color), s);
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
                    getUnitClassTextureString(unit, fontSize) .. unitName);
            if (numTimes > 0) then
                GameTooltipTextLeft1:SetText(replaced);
            end
        end

        -- add unit target
        local unitTarget = unit .. "TARGET";
        if (UnitExists(unitTarget)) then
            local prefix = "=> ";
            if (UnitIsUnit(unitTarget, "PLAYER")) then
                self:AddLine(prefix .. getColoredString("red", "!!!"), 1, 1, 1);
            else
                local hostileColor = A.Color.fromUnitHostile(unitTarget);
                self:AddLine(
                        string.format("%s%s%s",
                                prefix,
                                getUnitClassTextureString(unitTarget, 8),
                                getColoredString(hostileColor, UnitName(unitTarget))),
                        1, 1, 1);
            end
        end
    end);
end)();

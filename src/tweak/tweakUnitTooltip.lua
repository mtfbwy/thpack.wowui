(function()

    function getUnitString(unit)
        if (not unit or not UnitExists(unit)) then
            return "";
        end

        local unitName = UnitName(unit);
        local hostileColor = Addon.Color.fromUnitHostile(unit);

        if (UnitIsPlayer(unit)) then
            local classColor = Addon.Color.fromUnitClass(unit);
            return string.format("|cff%06x%s|r|cff%06x%s|r",
                    Addon.Color.toInt24(hostileColor), "@",
                    Addon.Color.toInt24(classColor), unitName);
        else
            return string.format("|cff%06x%s|r",
                    Addon.Color.toInt24(hostileColor), unitName);
        end
    end

    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit();
        if not unit then
            return;
        end

        local unitString = getUnitString(unit);

        local unitTargetString;
        local unitTarget = unit .. "target";
        if (UnitIsUnit(unitTarget, "player")) then
            unitTargetString = "|cffff0000!!!|r";
        else
            unitTargetString = getUnitString(unitTarget);
        end

        self:AddDoubleLine(unitString, "→ " .. unitTargetString, 1, 1, 1);
    end);
end)();

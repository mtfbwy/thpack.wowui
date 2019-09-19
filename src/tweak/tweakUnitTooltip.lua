(function()
    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit();
        if not unit then
            return;
        end

        local unitString = "";
        if (UnitIsPlayer(unit)) then
            local classColor = A.Color.fromUnitClass(unit);
            unitString = string.format("|cff%06x%s|r",
                    A.Color.toInt24(classColor), UnitClass(unit));
        end

        local unitTargetString = nil;
        local unitTarget = unit .. "target";
        if (UnitExists(unitTarget)) then
            if (UnitIsUnit(unitTarget, "player")) then
                unitTargetString = "|cffff0000!!!|r";
            elseif (UnitIsPlayer(unitTarget)) then
                local hostileColor = A.Color.fromUnitHostile(unitTarget);
                unitTargetString = string.format("|cff%06x%s|r",
                        A.Color.toInt24(hostileColor),
                        UnitName(unitTarget));
            end
        end
        if (unitTargetString) then
            unitTargetString = "→ " .. unitTargetString;
        end
        self:AddDoubleLine(unitString, unitTargetString, 1, 1, 1, 1, 1, 1);
    end);
end)();

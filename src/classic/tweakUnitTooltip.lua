(function()

    function getUnitNameText(unit)
        if (not unit or not UnitExists(unit)) then
            return "";
        end

        local classText = "";
        if (UnitIsPlayer(unit)) then
            local classColor = Color.fromUnitClass(unit);
            classText = "|cff" .. Color.toInt(classColor) .. "@|r"
        end

        local name = UnitName(unit);
        local hostileColor = Color.fromUnitHostile(unit);
        local nameText = "|cff" .. Color.toInt(hostileColor) .. name .. "|r"

        return classText .. nameText;
    end

    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit();
        if not unit then
            return;
        end

        local unitText = getUnitNameText(unit);

        local unitTargetText;
        local unitTarget = unit .. "target";
        if (UnitIsUnit(unitTarget, "player")) then
            unitTargetText = "|cffff0000!!!|r";
        else
            unitTargetText = getUnitNameText(unitTarget);
        end

        self:AddDoubleLine(unitText .. " → ", unitTargetText, 1, 1, 1);
    end);
end)();

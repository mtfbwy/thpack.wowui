(function()

    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit();
        if unit then
            if UnitIsPlayer(unit) then
                self:SetBackdropBorderColor(Color.toVertex(Color.fromUnitClass(unit)));
            else
                self:SetBackdropBorderColor(UnitSelectionColor(unit));
            end
            local unitTarget = unit .. "target"
            if UnitExists(unitTarget) then
                local t = UnitName(unitTarget)
                if UnitIsPlayer(unitTarget) then
                    if UnitIsUnit(unitTarget, "player") then
                        t = "|cffff0000!!!|r"
                    elseif UnitIsFriend(unitTarget, "player") then
                        t = "|cff00ff00" .. t .. "|r"
                    else
                        t = "|cffff0000" .. t .. "|r"
                    end
                end
                self:AddLine("→ " .. t, 1, 1, 1)
            end
        end
    end);
end)();

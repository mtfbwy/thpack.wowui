local addonName, addon = ...;
local A = addon.A;

-- add buff caster name to game tooltip
(function()
    local addBuffCasterName = function(self, unit, index, filter)
        local srcUnit = select(7, UnitAura(unit, index, filter));
        if (srcUnit) then
            local srcMasterUnit = A.getMasterUnitByUnit(srcUnit);
            local tipFormat = srcMasterUnit and "by %s(%s)%s" or "by %s%s%s";
            srcUnit = srcMasterUnit or srcUnit;

            local nameColor = A.getUnitNameColorByUnit(srcUnit);
            local classColor = A.getUnitClassColorByUnit(srcUnit);
            local tip = string.format(tipFormat,
                    A.getColoredString(nameColor, "["),
                    A.getColoredString(classColor, GetUnitName(srcUnit, true)),
                    A.getColoredString(nameColor, "]"));

            self:AddLine("");
            self:AddLine(tip);
            self:Show();
        end
    end

    hooksecurefunc(GameTooltip, "SetUnitAura", addBuffCasterName)
    hooksecurefunc(GameTooltip, "SetUnitBuff", addBuffCasterName)
end)();

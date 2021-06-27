local addonName, addon = ...;
local A = addon.A;

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local _, unit = self:GetUnit();
    if not unit then
        return;
    end

    -- add class texture to title line
    if (UnitIsPlayer(unit)) then
        local unitName = UnitName(unit);
        local _, fontSize = GameTooltipTextLeft1:GetFont();
        local replaced, numTimes = GameTooltipTextLeft1:GetText():gsub(
                unitName,
                A.getUnitClassTextureStringByUnit(unit, fontSize) .. unitName);
        if (numTimes > 0) then
            GameTooltipTextLeft1:SetText(replaced);
        end
    end

    -- add unit's target
    local unitTarget = unit .. "target";
    if (UnitExists(unitTarget)) then
        local prefix = "=> ";
        if (UnitIsUnit(unitTarget, "player")) then
            self:AddLine(prefix .. A.getColoredString(Color.pick("Red"), "!!!"), 1, 1, 1);
        else
            local nameColor = A.getUnitNameColorByUnit(unitTarget);
            self:AddLine(
                    string.format("%s%s%s",
                            prefix,
                            A.getUnitClassTextureStringByUnit(unitTarget, 13),
                            A.getColoredString(nameColor, UnitName(unitTarget))),
                    1, 1, 1);
        end
    end
end);

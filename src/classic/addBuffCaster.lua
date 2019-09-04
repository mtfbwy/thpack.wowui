-- add buff caster name to game tooltip
(function()
    local addCasterName = function(self, unit, index, filter)
        local src = select(7, UnitAura(unit, index, filter));
        if src then
            self:AddLine("");
            local text = "by " .. GetUnitName(src, 1);
            if src == "pet" or src == "vehicle" then
                text = string.format("(%s)", GetUnitName("player", true));
            else
                local ppet = src:match("^partypet(%d+)$");
                local rpet = src:match("^raidpet(%d+)$");
                if ppet then
                    text = string.format("(%s)", GetUnitName("party" .. ppet, true));
                elseif rpet then
                    text = string.format("(%s)", GetUnitName("raid" .. rpet, true));
                end
            end
            self:AddLine(text);
            self:Show();
        end
    end
    hooksecurefunc(GameTooltip, "SetUnitAura", addCasterName)
    hooksecurefunc(GameTooltip, "SetUnitBuff", addCasterName)
end)();

(function()
    hooksecurefunc("TimeManagerClockButton_Update", function()
        TimeManagerClockTicker:SetVertexColor(select(2, Util.getLag()));
    end);
end)();

-- addon memory and gc
(function()

    function calculateAddonMemory()
        UpdateAddOnMemoryUsage();

        local a = {};
        local totalMemory = 0;
        for i = 1, GetNumAddons() do
            local addonName, _, _, enabled = GetAddOnInfo(i);
            if (enabled) then
                local addonMemory = GetAddOnMemoryUsage(i);
                table.insert(a, {
                    addonName = addonName,
                    addonMemory = addonMemory
                });
                totalMemory = totalMemory + addonMemory;
            end
        end

        return totalMemory, a;
    end

    -- avoid seeing fast growing memory
    local lastUpdate = 0;

    function TimeManagerClockButton_UpdateTooltip()
        if GetSessionTime() <= lastUpdate + 2 then
            return;
        end

        local totalMemory, detail = calculateAddonMemory();

        lastUpdate = GetSessionTime();

        GameTooltip:ClearLines();

        if TimeManagerClockTicker.alarmFiring then
            if gsub(Settings.alarmMessage, "%s", "") ~= "" then
                GameTooltip:AddLine(
                        Settings.alarmMessage,
                        HIGHLIGHT_FONT_COLOR.r,
                        HIGHLIGHT_FONT_COLOR.g,
                        HIGHLIGHT_FONT_COLOR.b,
                        1);
            end
            GameTooltip:AddLine(TIMEMANAGER_ALARM_TOOLTIP_TURN_OFF);
        end

        GameTooltip:AddLine(format("%d fps / %d ms", Util.getFps(), Util.getLag()), 1, 1, 1);

        if (totalMemory > 0) then
            GameTooltip:AddDoubleLine("Total Memory", string.format("|cff00ff00%.1f KB|r", totalMemory));
            GameTooltip:AddLine("------------------------");
        end

        for i, v in pairs(detail) do
            GameTooltip:AddDoubleLine(v.addonName, string.format("|cff00ff00%.1f KB|r", v.addonMemory));
        end

        GameTooltip:AddLine("(right click to gc)");

        GameTooltip:Show();
    end

    TimeManagerClockButton:HookScript("OnClick", function(self, button)
        if (button == "RightButton") then
            collectgarbage("collect");
            lastUpdate = 0;
        end
    end);
end)();

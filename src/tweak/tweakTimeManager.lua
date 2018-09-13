P.ask("Util").answer("tweakTimeManager", function(Util)

    hooksecurefunc("TimeManagerClockButton_Update", function()
        TimeManagerClockTicker:SetVertexColor(select(2, Util.getLag()));
    end)

    local lastUpdate = 0;

    function TimeManagerClockButton_UpdateTooltip()
        -- avoid seeing fast growing memory
        if not GameTooltip:IsShown() then
            lastUpdate = GetSessionTime();
        else
            if GetSessionTime() > lastUpdate + 2 then
                lastUpdate = GetSessionTime();
            else
                return;
            end
        end

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

        GameTooltip:AddLine(format("%d fps", Util.getFps()) .. " / " .. format("%d ms", Util.getLag()), 1, 1, 1);

        UpdateAddOnMemoryUsage();

        local totalMemory = 0;
        for i = 1, GetNumAddOns() do
            local addonName, _, _, enabled = GetAddOnInfo(i);
            if (enabled) then
                local addonMemory = GetAddOnMemoryUsage(i);
                GameTooltip:AddDoubleLine(addonName, format("|cff00ff00%.1f KB|r", addonMemory));
                totalMemory = totalMemory + addonMemory;
            end
        end
        if (totalMemory > 0) then
            GameTooltip:AddLine("----------------------------------");
        end
        GameTooltip:AddDoubleLine("Total Memory", format("|cff00ff00%.1f KB|r", totalMemory));
        GameTooltip:AddLine("(right click to gc)");
        GameTooltip:Show();
    end

    TimeManagerClockButton:SetScript("OnClick", function(self, button)
        if self.alarmFiring then
            PlaySound("igMainMenuQuit");
            TimeManager_TurnOffAlarm();
        else
            if (button == "LeftButton") then
                TimeManager_Toggle();
            else
                collectgarbage("collect");
                lastUpdate = 0;
            end
        end
    end);
end);

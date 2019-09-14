-- addon memory and gc
(function()

    local hostButton = MainMenuBarPerformanceBarFrameButton;
    if (hostButton == nil) then
        return;
    end

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

    hostButton:SetScript("OnEnter", nil);
    hostButton:SetScript("OnLeave", nil);

    hostButton:SetScript("OnUpdate", function()
        if GetSessionTime() <= lastUpdate + 2 then
            return;
        end

        local totalMemory, detail = calculateAddonMemory();

        lastUpdate = GetSessionTime();

        GameTooltip:ClearLines();

        GameTooltip:AddLine(format("%d fps / %d ms", Addon.getFps(), Addon.getLag()), 1, 1, 1);

        if (totalMemory > 0) then
            GameTooltip:AddDoubleLine("Total Memory", string.format("|cff00ff00%.1f KB|r", totalMemory));
            GameTooltip:AddLine("------------------------");
        end

        for i, v in pairs(detail) do
            GameTooltip:AddDoubleLine(v.addonName, string.format("|cff00ff00%.1f KB|r", v.addonMemory));
        end

        GameTooltip:AddLine("(click to gc)");

        GameTooltip:Show();
    end);

    hostButton:SetScript("OnClick", function(self, button)
       collectgarbage("collect");
       lastUpdate = 0;
    end);
end)();

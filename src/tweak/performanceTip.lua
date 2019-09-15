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
        for i = 1, GetNumAddOns() do
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

    function updateTooltip()
        local totalMemory, detail = calculateAddonMemory();

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
    end

    hostButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        updateTooltip();
        GameTooltip:Show();
    end);

    hostButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end);

    hostButton:SetScript("OnClick", function(self)
        collectgarbage("collect");
        self.lastUpdate = 0;
        updateTooltip();
    end);
end)();

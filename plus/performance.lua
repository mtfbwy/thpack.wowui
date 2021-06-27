local addonName, addon = ...;
local A = addon.A;

(function()

    local getFps = function()
        local fps = GetFramerate();
        if (fps < 12) then
            return fps, 1, 0, 0;
        elseif (fps < 24) then
            return fps, 1, 1, 0;
        else
            return fps, 0, 1, 0;
        end
    end;

    A.addSlashCommand("thplusGetFps", "/fps", function()
        local fps, r, g, b = getFps();
        A.logi(string.format("fps: %d", fps), r, g, b);
    end);

    local getLag = function()
        local lag = select(4, GetNetStats());
        if lag < 300 then
            return lag, 0, 1, 0;
        elseif lag < 600 then
            return lag, 1, 1, 0;
        else
            return lag, 1, 0, 0;
        end
    end;

    A.addSlashCommand("thplusGetLag", "/lag", function()
        local lag, r, g, b = getLag();
        A.logi(string.format("lag: %d ms", lag), r, g, b);
    end);

    -- addon memory and gc

    local hostButton = MainMenuBarPerformanceBarFrameButton;
    if (hostButton == nil) then
        return;
    end

    local function calculateAddonMemory()
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

    local function updateTooltip()
        local totalMemory, detail = calculateAddonMemory();

        GameTooltip:ClearLines();
        GameTooltip:AddLine(string.format("%d fps / %d ms", (getFps()), (getLag())), 1, 1, 1);
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

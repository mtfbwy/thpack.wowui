(function()
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(self, event, ...)
        self:UnregisterAllEvents();
        local uf = FlatUnitFrame.createUnitFrame(UIParent);
        uf:SetSize(100, 20);
        uf:SetPoint("CENTER", UIParent, "CENTER", 0, -40);
        FlatUnitFrame.setUnit(uf, "player");
        FlatUnitFrame.start(uf);
    end);
end)(...);

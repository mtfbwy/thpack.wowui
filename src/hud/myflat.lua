(function()
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(self, event, ...)
        self:UnregisterAllEvents();
        local uf = FlatUnitFrame.createUnitFrame(UIParent);
        uf.raidMarkTextureRegion = nil;
        uf:SetSize(100, 20);
        uf:SetPoint("CENTER", UIParent, "CENTER", 0, -60 * A.dp);
        FlatUnitFrame.setUnit(uf, "player");
        FlatUnitFrame.start(uf);
    end);
end)(...);

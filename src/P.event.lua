(function()
    local f = CreateFrame("frame");
    f:RegisterEvent("VARIABLES_LOADED");
    f:RegisterEvent("PLAYER_LOGIN");
    f:SetScript("OnEvent", function(self, eventName, ...)
        self:UnregisterEvent(eventName);
        P.ask().answer(eventName, nil);
    end);
end)();

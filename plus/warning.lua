-- de-duplicate last error messsage
(function()
    local lastError = nil;
    local lastErrorTimestamp = nil;
    local blizEventHandler = UIErrorsFrame:GetScript("OnEvent");
    UIErrorsFrame:SetScript("OnEvent", function(self, event, id, err, ...)
        if (event == "UI_ERROR_MESSAGE") then
            local now = GetTime();
            if (err == lastError and now - lastErrorTimestamp < 2) then
                return;
            end
            lastError = err;
            lastErrorTimestamp = now;
            -- ERR_ABILITY_COOLDOWN
            -- ERR_SPELL_COOLDOWN
            -- ERR_OUT_OF_ENERGY
            -- ERR_OUT_OF_FOCUS
            -- ERR_OUT_OF_MANA
            -- ERR_OUT_OF_RAGE
            -- ERR_OUT_OF_RANGE
        end
        blizEventHandler(self, event, id, err, ...);
    end);
end)();

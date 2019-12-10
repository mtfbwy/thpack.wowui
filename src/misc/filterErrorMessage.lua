(function()
    -- move up a bit
    UIErrorsFrame:ClearAllPoints();
    UIErrorsFrame:SetPoint("TOP", 0, -30);

    local eventHandler = UIErrorsFrame:GetScript("OnEvent");
    UIErrorsFrame:SetScript("OnEvent", function(self, event, id, err, ...)
        if (event == "UI_ERROR_MESSAGE") then
            if (false
                    or err == ERR_ABILITY_COOLDOWN
                    or err == ERR_SPELL_COOLDOWN
                    or err == ERR_OUT_OF_ENERGY
                    or err == ERR_OUT_OF_FOCUS
                    or err == ERR_OUT_OF_MANA
                    or err == ERR_OUT_OF_RAGE
                    or err == ERR_OUT_OF_RANGE) then
                return;
            end
        end
        eventHandler(self, event, id, err, ...);
    end);
end)();

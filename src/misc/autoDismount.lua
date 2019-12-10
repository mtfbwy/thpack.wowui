(function()
    local NOT_STANDING_MESSAGES = {
        SPELL_FAILED_NOT_STANDING,
        ERR_CANTATTACK_NOTSTANDING,
        ERR_LOOT_NOTSTANDING,
        ERR_TEXTNOTSTANDING,
    };

    local NOT_WITH_MOUNTED_MESSAGES = {
        ERR_ATTACK_MOUNTED,
        ERR_MOUNT_ALREADYMOUNTED,
        ERR_NOT_WHILE_MOUNTED,
        ERR_TAXIPLAYERALREADYMOUNTED,
        PLAYER_LOGOUT_FAILED_ERROR,
        SPELL_FAILED_NOT_MOUNTED,
    };

    local f = CreateFrame("Frame");
    f:RegisterEvent("UI_ERROR_MESSAGE");
    f:SetScript("OnEvent", function(self, event, errType, err)
        if (table.containsValue(NOT_STANDING_MESSAGES, err)) then
            DoEmote("STAND");
        elseif (table.containsValue(NOT_WITH_MOUNTED_MESSAGES, err)) then
            if (IsMounted()) then
                Dismount();
            end
        end
    end);
end)();

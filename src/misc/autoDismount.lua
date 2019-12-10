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

    local NOT_WITH_SHAPESHIFTED_MESSAGES = {
        ERR_CANT_INTERACT_SHAPESHIFTED,
        ERR_EMBLEMERROR_NOTABARDGEOSET,
        ERR_MOUNT_SHAPESHIFTED,
        ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
        ERR_NOT_WHILE_SHAPESHIFTED,
        ERR_TAXIPLAYERSHAPESHIFTED,
        SPELL_FAILED_NO_ITEMS_SHAPESHIFTED,
        SPELL_FAILED_NOT_SHAPESHIFTED,
        SPELL_NOT_SHAPESHIFTED,
        SPELL_NOT_SHAPESHIFTED_NOSPACE,
    };

    local SHAPESHIFTED_BUFFS = {
        CAT_FORM = 768,
        TRAVEL_FORM = 783,
        GHOST_WOLF = 2645,
        AQUATIC_FORM = 1066,
        BEAR_FORM = 5487,
        DIRE_BEAR_FORM = 9634,
    };

    local f = CreateFrame("Frame");
    f:RegisterEvent("UI_ERROR_MESSAGE");
    f:SetScript("OnEvent", function(self, event, errType, err)
        if (array.contains(NOT_STANDING_MESSAGES, err)) then
            DoEmote("STAND");
        elseif (array.contains(NOT_WITH_MOUNTED_MESSAGES, err)) then
            if (IsMounted()) then
                Dismount();
            end
        elseif (not InCombatLockdown() and array.contains(NOT_WITH_SHAPESHIFTED_MESSAGES, err)) then
            -- CancelUnitBuff() is protected
            for i = 1, 40 do
                local buffId = select(10, UnitBuff("player", i));
                if (array.contains(SHAPESHIFTED_BUFFS, buffId)) then
                    CancelUnitBuff("player", i);
                    break;
                end
            end
        end
    end);
end)();

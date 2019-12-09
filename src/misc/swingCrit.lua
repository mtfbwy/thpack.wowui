(function()

    function playCritSoundEffect()
        PlaySoundFile(A.Res.audioFight);
    end

    local playerGuid = UnitGUID("player");

    local f = CreateFrame("Frame");
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    f:SetScript("OnEvent", function(self, event)
        local eventInfo = { CombatLogGetCurrentEventInfo() };
        local subEvent = eventInfo[2];
        local srcGuid = eventInfo[4];
        local isCritical = eventInfo[18];
        if (subEvent == "SWING_DAMAGE") then
            if (srcGuid == playerGuid and isCritical) then
                playCritSoundEffect();
            end
        end
    end);
end)();

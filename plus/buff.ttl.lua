(function()
    local function getTimeRepresentString(seconds)
        if (seconds <= 0) then
            return ""
        elseif (seconds < 60) then
            local d, h, m, s = ChatFrame_TimeBreakDown(seconds);
            return string.format("%ds", s);
        elseif (seconds < 600) then
            local d, h, m, s = ChatFrame_TimeBreakDown(seconds);
            return string.format("%d:%02d", m, s);
        elseif (seconds < 3600) then
            local d, h, m, s = ChatFrame_TimeBreakDown(seconds);
            return string.format("%dm", m);
        else
            local d, h, m, s = ChatFrame_TimeBreakDown(seconds);
            return string.format("%dh%02d", h, m);
        end
    end

    hooksecurefunc("AuraButton_UpdateDuration", function(buffButton, remainingSeconds)
        if (SHOW_BUFF_DURATIONS ~= "1") then
            return;
        end

        if (not remainingSeconds) then
            return;
        end

        local timeString = getTimeRepresentString(remainingSeconds);
        local countdownTextView = _G[buffButton:GetName() .. "Duration"];
        countdownTextView:SetFont(STANDARD_TEXT_FONT, 12);
        countdownTextView:SetText(timeString);
    end);
end)();

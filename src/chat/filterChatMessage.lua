(function()

    function hash(s)
        local value = 0;
        for i = 1, #s do
            local k = string.byte(s, i);
            value = value * 31 + k;
        end
        return value;
    end

    local chatBlacklist = {};

    A.addSlashCommand("thpackAddToChatBlacklist", "/addToChatBlacklist", function(s)
        table.clear(chatBlacklist);
    end);

    A.addSlashCommand("thpackClearChatBlacklist", "/clearChatBlacklist", function()
        if (s) then
            chatBlacklist[s] = true;
        end
    end);

    local MY_GUID = UnitGUID("player");
    local messageTable = {};

    -- true to skip message; false to keep message
    function filterOutChatMessage(chatFrame, event, ...)
        local message, author = ...;
        local subChannel = select(9, ...);
        local authorGuid = select(12, ...);

        if (authorGuid == MY_GUID) then
            return false, ...;
        elseif (chatBlacklist[authorGuid] or chatBlacklist[author]) then
            return true;
        end

        -- XXX cannot get author level by guid
        local authorLevel = 6;
        if (authorLevel < 6) then
            return true;
        end

        -- deduplicate
        local messageKey = chatFrame .. "-" .. authorGuid .. "-" .. #message .. "-" .. hash(message);
        local messageTime = GetTime();

        local oldTime = messageTable[messageKey];
        if (oldTime ~= nil && (messageTime - oldTime < 30)) then
            return true;
        end

        messageTable[messageKey] = messageTime;
        return false, ...;
    end

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(self, event, ...)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filterOutChatMessage);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filterOutChatMessage);
        self:UnregisterAllEvents();
    end);
end)();

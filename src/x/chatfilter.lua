function string.split(x, sep)
    local a = {};
    local i = 1;
    while (true) do
        local j = string.find(x, sep, i, true);
        if (not j) then
            local term = string.sub(x, i);
            table.insert(a, term);
            break;
        elseif (j ~= i) then
            local term = string.sub(x, i, j - 1);
            table.insert(a, term);
        end
        i = j + #sep;
    end
    return a;
end

local blacklist = {
    ["author"] = {
        ["^威尼斯.*"] = 1,
        ["^心花阁.*"] = 1,
        ["^小野猫.*"] = 1,
        ["^龙五.*"] = 1,
        ["^叶星城.*"] = 1,
        ["^拉斯维加.*"] = 1,
        ["^进宝.*"] = 1,
    },
    ["message"] = {
    },
};

local CMD_ID = "thpackChatfilter";
local CMD_PREFIX = "/chatfilter";
_G["SLASH_" .. CMD_ID .. "1"] = CMD_PREFIX;
SlashCmdList[CMD_ID] = function(x)
    local a = string.split(x, " ");
    for i, v in ipairs(a) do
        local match = string.match(v, "a:(.*)");
        if (match) then
            blacklist["author"][match] = 1;
        end

        match = string.match(v, "m:(.*)");
        if (match) then
            blacklist["message"][match] = 1;
        else
            blacklist["message"][v] = 1;
        end
    end
end;

local REALM = GetRealmName();

-- true to skip message; false to keep message
function suppressChatMessage(chatFrame, channel, message, author, ...)
    --local authorGuid = select(12, ...);

    -- author e.g. "陈不文-伦鲁迪洛尔"
    local i = string.find(author, "-", 1, true);
    if (i and i > 0) then
        --realm = string.sub(author, i + 1);
        author = string.sub(author, 1, i - 1);
    end

    -- consider merged realm(s), discard realm name
    for p, enabled in pairs(blacklist["author"]) do
        if (string.match(author, p)) then
            message = string.format("|cff999999suppressed(a:%s)|r", p);
            return false, message, author, ...;
        end
    end
    for p, enabled in pairs(blacklist["message"]) do
        if (string.find(message, p, 1, true)) then
            message = string.format("|cff999999suppressed(m:%s)|r", p);
            return false, message, author, ...;
        end
    end
    return false, message, author, ...;
end

local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:SetScript("OnEvent", function(self, event, ...)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", suppressChatMessage);
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", suppressChatMessage);
    self:UnregisterAllEvents();
end);

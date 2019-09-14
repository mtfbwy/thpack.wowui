-- 空输入时按tab在各个频道中切换
-- 不改变以下两个变量，避免产生taint
--CHAT_WHISPER_GET = "%s→\32"
--CHAT_WHISPER_INFORM_GET = "→%s\32"
(function()
    local nextChatType = {
        ["SAY"] = "PARTY",
        ["PARTY"] = "RAID",
        ["RAID"] = "INSTANCE_CHAT",
        ["INSTANCE_CHAT"] = "GUILD",
        ["GUILD"] = "SAY",
    }

    local isApplicable = {
        ["SAY"] = function() return 1 end,
        ["PARTY"] = function() return not IsInRaid() and IsInGroup(LE_PARTY_CATEGORY_HOME); end,
        ["RAID"] = IsInRaid,
        -- ["INSTANCE_CHAT"] = IsInInstance,
        ["INSTANCE_CHAT"] = function() return IsInGroup(LE_PARTY_CATEGORY_INSTANCE); end,
        ["GUILD"] = IsInGuild,
    }

    function ChatEdit_CustomTabPressed(self)
        if self:GetText() ~= "" then
            return
        end
        local chatType = self:GetAttribute("chatType")
        repeat
            chatType = nextChatType[chatType] or "SAY"
        until isApplicable[chatType]()
        self:SetAttribute("chatType", chatType)
        ChatEdit_UpdateHeader(self)
    end

    ChatTypeInfo["WHISPER"].sticky = 0;
    ChatFrame1EditBox:SetAltArrowKeyMode(nil);
end)();

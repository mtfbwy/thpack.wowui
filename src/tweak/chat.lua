-- 空输入框时按tab在各个频道中切换
-- 不改变以下两个变量，避免产生taint
--CHAT_WHISPER_GET = "%s→\32"
--CHAT_WHISPER_INFORM_GET = "→%s\32"
T.ask().answer("tweakChat", function()
    local nextChatType = {
        ["SAY"] = "RAID",
        ["RAID"] = "INSTANCE_CHAT",
        ["INSTANCE_CHAT"] = "GUILD",
        ["GUILD"] = "SAY",
    }

    local isAvailable = {
        ["GUILD"] = IsInGuild,
        ["INSTANCE_CHAT"] = IsInInstance,
        ["RAID"] = IsInRaid,
        ["SAY"] = function() return 1 end,
    }

    function ChatEdit_CustomTabPressed(self)
        if self:GetText() ~= "" then
            return
        end
        local chatType = self:GetAttribute("chatType")
        repeat
            chatType = nextChatType[chatType] or "SAY"
        until isAvailable[chatType]()
        self:SetAttribute("chatType", chatType)
        ChatEdit_UpdateHeader(self)
    end

    ChatTypeInfo["WHISPER"].sticky = 0;
    ChatFrame1EditBox:SetAltArrowKeyMode(nil);
end);

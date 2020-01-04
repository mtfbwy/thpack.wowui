-- notify the player when cast succeed
(function()

    local announcements = {
        ["寒冰屏障"]    = "冰箱",
        ["消失"]    = "消失",
        ["圣盾术"]  = "无敌",
        ["圣疗术"]  = "圣疗",
        ["斩杀"]    = "斩杀",
        ["雷霆风暴"] = "雷霆风暴",
    }

    local function announce(skillName, forcedMode)
        local msg = announcements[skillName] or skillName;
        local mode, s = string.match(msg, "(.+):(.+)");
        if (mode == nil) then
            mode = "notify";
            s = msg;
        end
        mode = forcedMode or mode;
        if (mode == "notify") then
            A.post(s, nil, 0.1, 1.2, 0.2);
            A.postSound();
        else
            SendChatMessage(s, mode);
        end
    end

    local enabled = false;

    A.addSlashCommand("thpackKongfu", "/kongfu", function(x)
        if (x == "on") then
            enabled = true;
            A.logi("你已经是武林高手");
        elseif (x == "off") then
            enabled = false;
            A.logi("你不再是武林高手");
        else
            A.logi("武林高手过招时总会喊出自己的招式。");
            A.logi("Usage: /kongfu on | off");
        end
    end);

    local f = CreateFrame("frame");
    f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    f:SetScript("OnEvent", function(self, event, ...)
        local unit, castId, skillId = ...
        local skillName = GetSpellInfo(skillId);
        if (unit == "player") then
            if (enabled) then
                announce(skillName, "say");
            elseif (announcements[skillName] ~= nil) then
                announce(skillName);
            end
        end
    end);

    A.logi(string.format("kongfu loaded. Type \"%s\" to learn more.", "/kongfu"));
end)();

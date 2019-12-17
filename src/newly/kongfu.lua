-- a top-center text to warn something
P.ask("pp").answer("Duang", function(pp)

    local fontDefault = A.Res.fontDefault;
    local dp = pp.dp;

    -- relative to the canvas
    local normalSize = 32 * dp;
    local variableSize = 0.25 * normalSize;

    local f = CreateFrame("frame", nil, UIParent);
    f:SetFrameStrata("HIGH");
    f:SetToplevel(true);
    f:SetHeight(normalSize + variableSize);
    f:SetPoint("topleft", 0, -0.1 * UIParent:GetHeight());
    f:SetPoint("topright", 0, -0.1 * UIParent:GetHeight());

    local fs = f:CreateFontString()
    fs:SetFont(fontDefault, normalSize, "outline");
    fs:SetJustifyH("center");
    fs:SetAllPoints();
    fs:Show();

    local function notify(text, colorString, withSound, t1, t2, t3)
        text = text or "nil";
        local color = A.Color.pick(colorString or "#ffffffff");
        t1 = t1 or 0.1;
        t2 = t2 or 1.5;
        t3 = t3 or 0.4;

        if withSound then
            PlaySound(8959); -- RAID_WARNING
        end

        t2 = t1 + t2;
        t3 = t2 + t3;

        fs:SetText(text);
        fs:SetTextColor(color:toVertex());
        fs.startTime = GetTime();
        fs:SetAlpha(0);
        fs.time1, fs.time2, fs.time3 = t1, t2, t3;
        f:SetScript("OnUpdate", function()
            local t = GetTime() - fs.startTime;
            local t1, t2, t3 = fs.time1, fs.time2, fs.time3;
            -- font size animation
            if t < t1 then
                -- enlarge
                fs:SetTextHeight(normalSize + variableSize * t / t1);
            elseif t < t1 + t1 then
                -- back to normal
                fs:SetTextHeight(normalSize + variableSize * (t1 + t1 - t) / t1);
            elseif t1 + t1 <= t and not fs.freezesSize then
                fs.freezesSize = 1;
                fs:SetTextHeight(normalSize);
            end
            -- font alpha animation
            if t < t1 then
                fs:SetAlpha(t / t1);
            elseif t < t2 then
                if not fs.freezesAlpha then
                    fs.freezesAlpha = 1;
                    fs:SetAlpha(1);
                end
            elseif t < t3 then
                fs:SetAlpha((t3 - t) / (t3 - t2));
            else
                f:Hide();
                f:SetScript("OnUpdate", nil);
                fs:SetAlpha(0);
                fs.freezesSize = nil;
                fs.freezesAlpha = nil;
                fs.startTime = nil;
                fs.time1 = nil;
                fs.time2 = nil;
                fs.time3 = nil;
            end
        end);
        f:Show();
    end;

    A.addSlashCommand("thpackNotify", "/notify", function(msg)
        notify(msg, "#00ff00", 1);
    end);

    return {
        notify = notify
    };
end);

-- notify the player when cast succeed
P.ask("Duang").answer("kongfu", function(Duang)

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
            Duang.notify(s, nil, true, 0.1, 1.2, 0.2);
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
end);

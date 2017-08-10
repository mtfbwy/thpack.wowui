-- a center-top frame to warn something
T.ask("resource", "env", "api").answer("notifier", function(res, env, api)

    -- not to dot, not to pixel, but relative to the canvas
    local normalSize = 32 * env.on1024;
    local largerSize = 1.25 * normalSize;
    local diffSize = 0.25 * normalSize;

    local f = CreateFrame("frame", nil, UIParent);
    f:SetFrameStrata("high");
    f:SetToplevel(true);
    f:SetHeight(largerSize);
    f:SetPoint("topleft", 0, -0.1 * UIParent:GetHeight());
    f:SetPoint("topright", 0, -0.1 * UIParent:GetHeight());

    local fs = f:CreateFontString()
    fs:SetFont(res.font.DEFAULT, normalSize, "outline");
    fs:SetJustifyH("center");
    fs:SetAllPoints();
    fs:Show();

    local function notify(text, color, withSound, t1, t2, t3)
        text = text or "nil";
        color = color or "FFFFFFFF";
        t1 = t1 or 0.1;
        t2 = t2 or 1.5;
        t3 = t3 or 0.4;

        if withSound then
            PlaySound("RaidWarning");
        end

        t2 = t1 + t2;
        t3 = t2 + t3;

        fs:SetText(text);
        fs:SetTextColor(api.color.toVertex(color));
        fs.startTime = GetTime();
        fs:SetAlpha(0);
        fs.time1, fs.time2, fs.time3 = t1, t2, t3;
        f:SetScript("OnUpdate", function()
            local t = GetTime() - fs.startTime;
            local t1, t2, t3 = fs.time1, fs.time2, fs.time3;
            -- font size animation
            if t < t1 then
                -- enlarge
                fs:SetTextHeight(normalSize + diffSize * t / t1);
            elseif t < t1 + t1 then
                -- back to normal
                fs:SetTextHeight(largerSize - diffSize * (t - t1) / t1);
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

    api.addCmd("thNotify", "/notify", function(msg)
        notify(msg, "00FF00", 1);
    end);

    return {
        notify = notify
    };
end);

-- notify the player when cast succeed
T.ask("api", "notifier").answer("kongfu", function(api, notifier)

    local announcements = {
        ["寒冰屏障"]    = "冰箱",
        ["消失"]    = "消失",
        ["圣盾术"]  = "无敌",
        ["圣疗术"]  = "圣疗",
        ["斩杀"]    = "say:斩杀",
    }

    local function announce(skillName, forcedMode)
        local msg = announcements[skillName] or skillName;
        local mode, text = string.match(msg, "(.+):(.+)");
        if (mode == nil) then
            mode = "notify";
            text = msg;
        end
        mode = forcedMode or mode;
        if (mode == "notify") then
            notifier.notify(text, nil, true, 0.1, 1.2, 0.2);
        else
            SendChatMessage(text, mode);
        end
    end

    local enablesKongfu = false;
    api.addCmd("thKongfu", "/kongfu", function(x)
        if (x == "on") then
            enablesKongfu = true;
            L.logi("你已经是武林高手");
        elseif (x == "off") then
            enablesKongfu = false;
            L.logi("你不再是武林高手");
        end
    end);

    local f = CreateFrame("frame");
    f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    f:SetScript("OnEvent", function(self, event, ...)
        local unit, skillName = ...
        if (unit == "player") then
            if (enablesKongfu) then
                announce(skillName, "say");
            elseif (announcements[skillName] ~= nil) then
                announce(skillName);
            end
        end
    end);
end);

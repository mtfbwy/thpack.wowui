-- a top-center text to warn something
P.ask("res", "api", "api.Color").answer("api.notify", function(res, api, _)

    local dip = res.dip;
    local Color = api.Color;

    -- relative to the canvas
    local normalSize = 32 * dip;
    local variableSize = 0.25 * normalSize;

    local f = CreateFrame("frame", nil, UIParent);
    f:SetFrameStrata("HIGH");
    f:SetToplevel(true);
    f:SetHeight(normalSize + variableSize);
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
            PlaySound(8959); -- RAID_WARNING
        end

        t2 = t1 + t2;
        t3 = t2 + t3;

        fs:SetText(text);
        fs:SetTextColor(Color.toVertex(color));
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

    api.addCmd("thpackNotify", "/notify", function(msg)
        notify(msg, "00FF00", 1);
    end);

    api.notify = notify;
end);

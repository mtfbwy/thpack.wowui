post = post or (function()
    local dp = A and A.dp or 0.75;

    -- relative to the canvas
    local normalSize = 32 * dp;
    local variableSize = 0.6 * normalSize;

    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:SetFrameStrata("HIGH");
    f:SetToplevel(true);
    f:SetPoint("TOPLEFT", 0, -100 * dp);
    f:SetPoint("TOPRIGHT", 0, -100 * dp);
    f:SetHeight(normalSize + variableSize);
    f:Hide();

    local warnTextRegion = f:CreateFontString(nil, "OVERLAY", nil);
    warnTextRegion:SetFont("fonts/arkai_t.ttf", normalSize, "OUTLINE");
    warnTextRegion:SetJustifyH("CENTER");
    warnTextRegion:SetAllPoints();
    f.warnTextRegion = warnTextRegion;

    f:SetScript("OnUpdate", function(self, elapsed)
        local warnTextRegion = self.warnTextRegion;
        if (not warnTextRegion) then
            return;
        end

        local model = self.model;
        if (not model) then
            self:Hide();
            warnTextRegion:SetAlpha(0);
            return;
        end

        local t = GetTime() - model.startTime;
        local t1 = model.time1;
        local t2 = model.time2;
        local t3 = model.time3;

        -- font size animation
        if (t < t1) then
            -- enlarge
            warnTextRegion:SetTextHeight(normalSize + variableSize * t / t1);
        elseif (t < t1 + t1) then
            -- back to normal
            warnTextRegion:SetTextHeight(normalSize + variableSize * (t1 + t1 - t) / t1);
        elseif (t >= t1 + t1 and not model.sizeStable) then
            model.sizeStable = true;
            warnTextRegion:SetTextHeight(normalSize);
        end

        -- font alpha animation
        if (t < t1) then
            warnTextRegion:SetAlpha(t / t1);
        elseif (t < t2) then
            if not model.alphaStable then
                model.alphaStable = true;
                warnTextRegion:SetAlpha(1);
            end
        elseif (t < t3) then
            warnTextRegion:SetAlpha((t3 - t) / (t3 - t2));
        else
            self.model = nil;
        end
    end);

    return function(message, color, enteringTimeSpan, lastingTimeSpan, leavingTimeSpan)
        if (not message or message == "") then
            return;
        end

        color = color or Color.pick("White");

        local t1 = enteringTimeSpan or 0.15;
        local t2 = t1 + (lastingTimeSpan or 1.5);
        local t3 = t2 + (leavingTimeSpan or 0.4);

        f.model = {
            startTime = GetTime(),
            time1 = t1,
            time2 = t2,
            time3 = t3,
        };
        f.warnTextRegion:SetText(message);
        f.warnTextRegion:SetVertexColor(color:toVertex());
        f.warnTextRegion:SetAlpha(0);
        f:Show();
    end;
end)();

A.postSound = A.postSound or function(soundFile)
    -- 8959: RAID_WARNING
    PlaySound(soundFile or 8959);
end;

T.ask("resource", "env").answer("api", function(res, env)

    function safeInvoke(callback)
        if (not InCombatLockdown()) then
            callback();
            return;
        end
        local safeInvokeAsyncHolder = CreateFrame("frame");
        safeInvokeAsyncHolder:RegisterEvent("PLAYER_REGEN_ENABLED");
        safeInvokeAsyncHolder:SetScript("OnEvent", function(self, event)
            self:UnregisterAllEvents();
            self:SetScript("OnEvent", nil);
            safeInvokeAsyncHolder = nil;
            callback();
        end);
    end

    function setTimeout(callback, seconds)
        if (seconds <= 0) then
            callback();
            return;
        end
        local setTimeoutAsyncHolder = CreateFrame("frame");
        ssetTimeoutAsyncHolder:SetScript("OnUpdate", function(self, elapsed)
            seconds = seconds - elapsed;
            if (seconds > 0) then
                return;
            end
            self:SetScript("OnUpdate", nil);
            ssetTimeoutAsyncHolder = nil;
            callback();
        end);
    end

    function getFps()
        local fps = GetFramerate();
        if (fps < 12) then
            return fps, 1, 0, 0;
        elseif (fps < 24) then
            return fps, 1, 1, 0;
        else
            return fps, 0, 1, 0;
        end
    end

    function getLag()
        local lag = select(4, GetNetStats());
        if lag < 300 then
            return lag, 0, 1, 0;
        elseif lag < 600 then
            return lag, 1, 1, 0;
        else
            return lag, 1, 0, 0;
        end
    end

    function getUnitHp(unit)
        return UnitHealth(unit), UnitHealthMax(unit)
    end

    function getUnitPp(unit, powerType)
        return UnitPower(unit, powerType), UnitPowerMax(unit, powerType)
    end

    function addCmd(id, cmd, callback)
        _G["SLASH_" .. id .. "1"] = cmd;
        SlashCmdList[id] = callback;
    end

    local function createBlizButton(sideDots, parent, templateName)
        local button = CreateFrame("button", nil, parent);
        button:SetSize(sideDots, sideDots);

        local hiTexture = button:CreateTexture(nil, "highlight");
        hiTexture:SetTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]]);
        hiTexture:SetPoint("topleft", sideDots * -1/64, sideDots * 1/64);
        hiTexture:SetPoint("bottomright", sideDots * -1/64, sideDots * 1/64);
        button:SetHighlightTexture(hiTexture);

        local bgTexture = button:CreateTexture(nil, "background");
        bgTexture:SetTexture([[Interface\Minimap\UI-Minimap-Background]]);
        bgTexture:SetVertexColor(0, 0, 0, 0.6);
        bgTexture:SetPoint("topleft", sideDots * 4/64, "topleft", sideDots * -4/64);
        bgTexture:SetPoint("bottomright", sideDots * -4/64, "topleft", sideDots * 4/64);

        local bdTexture = button:CreateTexture(nil, "overlay");
        bdTexture:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]]);
        bdTexture:SetTexCoord(0, 38/64, 0, 38/64);
        bdTexture:SetAllPoints();

        local artTexture = button:CreateTexture(nil, "artwork");
        artTexture:SetPoint("topleft", sideDots * 12/64, sideDots * -10/64);
        artTexture:SetPoint("bottomright", sideDots * -12/64, sideDots * 14/64);

        return button, artTexture;
    end

    local function createFrame(frameType, parent, templateName)
        local frame = CreateFrame(frameType, nil, parent, templateName);
        frame:SetFrameStrata("low");
        frame:SetFrameLevel(1);
        return frame;
    end

    local function setFrameBackdrop(frame, borderPixels, outsetPixels)
        local hasBorder = (borderPixels > 0);
        borderPixels = (hasBorder and borderPixels) or 1; -- 0 leads to a mess
        frame:SetBackdrop({
            bgFile = res.texture.SQUARE,
            edgeFile = res.texture.SQUARE,
            edgeSize = borderPixels * env.dotsPerPixel,
            insets = {
                left    = -outsetPixels * env.dotsPerPixel,
                right   = -outsetPixels * env.dotsPerPixel,
                top     = -outsetPixels * env.dotsPerPixel,
                bottom  = -outsetPixels * env.dotsPerPixel
            },
            tile = false,
            tileSize = 0
        });

        frame:SetBackdropColor(res.color.toSequence("333333"));

        -- 材质不透明，欲隐藏边框，必须设置透明度
        local borderColor = (hasBorder and "999999") or "99999900";
        frame:SetBackdropBorderColor(res.color.toSequence(borderColor));
    end

    -- 边框与光晕都源于backdrop->edgeFile，因此两者不可共存于同一frame中
    local function createFrameGlow(frame, offPixels)
        local frameGlow = createFrame("frame", frame);
        frameGlow:SetFrameStrata(frame:GetFrameStrata());
        frameGlow:SetFrameLevel(frame:GetFrameLevel());
        frameGlow:SetBackdrop({
            edgeFile = res.texture.GLOW1,
            edgeSize = 5 * env.dotsPerPixel
        });
        local outsetPixels = 5 + offPixels;
        frameGlow:SetBackdropBorderColor(res.color.toSequence("FFFFFF"))
        frameGlow:SetPoint("topleft", -outsetPixels * env.dotsPerPixel, outsetPixels * env.dotsPerPixel);
        frameGlow:SetPoint("bottomright", outsetPixels * env.dotsPerPixel, -outsetPixels * env.dotsPerPixel);
        frameGlow:SetFrameLevel(0);
        return frameGlow;
    end

    local function createProgressbar(parent, backdropOutsetPixels)
        local bar = createFrame("statusbar", parent);
        setFrameBackdrop(bar, 0, backdropOutsetPixels); -- 边框透明
        bar:SetMinMaxValues(0, 1);
        bar:SetStatusBarTexture(res.texture.SQUARE);
        bar:SetStatusBarColor(res.color.toSequence("008000")); -- for test
        bar:SetValue(0.8); -- for test

        local text1 = bar:CreateFontString();
        text1:SetFont(res.font.DEFAULT, 14 * env.dotsRelative, "outline");
        text1:SetJustifyH("left");
        text1:SetPoint("left", 2 * env.dotsPerPixel, -env.dotsPerPixel);
        bar.text1 = text1;

        local text2 = bar:CreateFontString();
        text2:SetFont(res.font.LBRITED, 14 * env.dotsRelative, "outline");
        text2:SetJustifyH("right");
        text2:SetPoint("right", -env.dotsPerPixel, -env.dotsPerPixel);
        bar.text2 = text2;

        return bar
    end

    local function createAnchor(sideDots, parent)
        local anchor = createFrame("frame", parent);
        anchor:SetSize(sideDots, sideDots);
        setFrameBackdrop(anchor, 0, 0);
        anchor:SetBackdropColor(res.color.toSequence("33333300"));

        anchor:SetScript("OnEnter", function(self)
            self:SetBackdropColor(res.color.toSequence("333333"));
            GameTooltip:SetOwner(self);
            GameTooltip:AddLine("hold control to drag");
            GameTooltip:Show();
        end);

        anchor:SetScript("OnLeave", function(self)
            self:SetBackdropColor(res.color.toSequence("33333300"));
            GameTooltip:Hide();
        end);

        anchor:SetMovable(true);
        anchor:RegisterForDrag("LeftButton");
        anchor:SetScript("OnMouseDown", function(self, button)
            if (IsLeftControlKeyDown() and button == "LeftButton") then
                self:StartMoving();
            end
        end);
        anchor:SetScript("OnMouseUp", function(self, button)
            self:StopMovingOrSizing();
        end);

        return anchor;
    end

    local function listenToEvents(frame, events)
        for k,v in pairs(events) do
            frame:RegisterEvent(k)
        end
        frame:SetScript("OnEvent", function(self, event, ...)
            if events[event] then
                events[event](self, ...);
            end
        end);
    end

    return {
        safeInvode = safeInvoke,
        setTimeout = setTimeout,
        getFps = getFps,
        getLag = getLag,
        getUnitHp = getUnitHp,
        getUnitPp = getUnitPp,
        addCmd = addCmd,
        createBlizButton = createBlizButton,
        createAnchor = createAnchor,
        createFrame = createFrame,
        createFrameGlow = createFrameGlow,
        createProgressbar = createProgressbar,
        listenToEvents = listenToEvents,
        setFrameBackdrop = setFrameBackdrop,
    };
end);

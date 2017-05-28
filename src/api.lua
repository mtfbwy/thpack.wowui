T.ask().answer("api.color", function()

    local COLOR_NAME = {
        -- RAID_CLASS_COLORS[CLASS]
        ["deathknight"] = "#cc0033",
        ["demonhunter"] = "#9933cc",
        ["druid"]       = "#ff6600",
        ["hunter"]      = "#99cc66",
        ["mage"]        = "#99ccff", -- source: 0.41,0.80,0.94
        ["monk"]        = "#00ff99", -- source: 0.00,1.00,0.59
        ["paladin"]     = "#ff99cc", -- source: 0.96,0.55,0.73
        ["priest"]      = "#ffffff",
        ["rogue"]       = "#ffff66",
        ["shaman"]      = "#3366ff",
        ["warlock"]     = "#9999cc",
        ["warrior"]     = "#cc9966",

        ["coral"]       = "#ff7f50",
        ["crimson"]     = "#dc143c",
        ["darkorange"]  = "#ff8c00",
        ["darkred"]     = "#8b0000",
        ["dodgerblue"]  = "#1e90ff",
        ["firebrick"]   = "#b22222",
        ["forestgreen"] = "#228b22",
        ["gold"]        = "#ffd700",
        ["gray"]        = "#808080",
        ["green"]       = "#00ff00",
        ["hotpink"]     = "#ff69b4",     -- paladin
        ["maroon"]      = "#800000",
        ["mediumpurple"]    = "9370d8",
        ["orangered"]   = "#ff4500",
        ["royalblue"]   = "#4169e1",     -- shaman
        ["skyblue"]     = "#87ceeb",     -- mage
        ["turquoise"]   = "#40e0d0",
        ["white"]       = "#ffffff",
        ["yellowgreen"] = "#9acd32",     -- hunter
    };

    local function pick(key)
        assert(type(key) == "string");
        return COLOR_NAME[key];
    end

    local function fromUnitClass(unit)
        local _, unitClass = UnitClass(unit);
        return pick(string.lower(unitClass or ""));
    end

    local function fromUnitHostile(unit)
        if UnitIsEnemy("player", unit) then
            return pick("orangered");
        elseif UnitIsFriend("player", unit) then
            return pick("green");
        else
            return pick("gold");
        end
    end

    local function fromPowerType(powerType)
        if powerType == 0 then
            return pick("royalblue");
        elseif powerType == 1 then
            return pick("firebrick");
        elseif powerType == 2 then
            return pick("coral");
        elseif powerType == 3 then
            return pick("gold");
        elseif powerType == 6 then
            return pick("turquoise");
        else
            return pick("white");
        end
    end

    local function fromUnitPowerType(unit)
        local powerType = UnitPowerType(unit or "player");
        return fromPowerType(powerType);
    end

    local function fromVertex(r, g, b, a)
        a = a or 1;
        return string.format("#%2X%2X%2X%2X", r * 255, g * 255, b * 255, a * 255);
    end

    local function toVertex(color)
        local color = pick(color) or color;
        local r = tonumber(strsub(color, 2, 3), 16);
        local g = tonumber(strsub(color, 4, 5), 16);
        local b = tonumber(strsub(color, 6, 7), 16);
        local a = tonumber(strsub(color, 8, 9), 16);
        r = not r or r / 255;
        g = not g or g / 255;
        b = not b or b / 255;
        a = not a or a / 255;
        return r, g, b, a;
    end

    return {
        fromUnitClass = fromUnitClass,
        fromUnitHostile = fromUnitHostile,
        fromPowerType = fromPowerType,
        fromUnitPowerType = fromUnitPowerType,
        fromVertex = fromVertex,
        toVertex = toVertex,
    };
end);

T.ask().answer("api.case", function()

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

    function getUnitMp(unit, powerType)
        powerType = powerType or UnitPowerType(unit);
        return UnitPower(unit, powerType), UnitPowerMax(unit, powerType), powerType;
    end

    function addCmd(id, cmd, callback)
        _G["SLASH_" .. id .. "1"] = cmd;
        SlashCmdList[id] = callback;
    end

    local function attachEvents(frame, events)
        for k,v in pairs(events) do
            frame:RegisterEvent(k)
        end
        frame:HookScript("OnEvent", function(self, event, ...)
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
        getUnitMp = getUnitMp,
        addCmd = addCmd,
        attachEvents = attachEvents,
    };
end);

T.ask("resource", "env", "api.color").answer("api.widget", function(res, env, Color)
    -- frame strata > frame level
    local FRAME_STRATA_BACKGROUND = "BACKGROUND";
    local FRAME_STRATA_LOW = "LOW";
    local FRAME_STRATA_MEDIUM = "MEDIUM";
    local FRAME_STRATA_HIGH = "HIGH";
    local FRAME_STRATA_DIALOG = "DIALOG";
    local FRAME_STRATA_FULLSCREEN = "FULLSCREEN";
    local FRAME_STRATA_FULLSCREEN_DIALOG = "FULLSCREEN_DIALOG";
    local FRAME_STRATA_TOOLTIP = "TOOLTIP";

    local LAYER_BACKGROUND = "BACKGROUND";
    local LAYER_BORDER = "BORDER";
    local LAYER_ARTWORK = "ARTWORK";
    local LAYER_OVERLAY = "OVERLAY";
    local LAYER_HIGHLIGHT = "HIGHLIGHT";

    local function createBlizButton(sideDots, parent, template)
        local button = CreateFrame("button", nil, parent, template);
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

    local function createFrame(frameType, parent, template)
        local frame = CreateFrame(frameType, nil, parent, template);
        frame:SetFrameStrata(FRAME_STRATA_LOW);
        frame:SetFrameLevel(1);
        return frame;
    end

    local function setFrameBackdrop(frame, borderSize, marginSize)
        local hasBorder = (borderSize > 0);
        borderSize = (hasBorder and borderSize) or 1 * env.pixel; -- 0 leads to a mess
        frame:SetBackdrop({
            bgFile = res.texture.SQUARE,
            edgeFile = res.texture.SQUARE,
            edgeSize = borderSize,
            insets = {
                left    = -marginSize,
                right   = -marginSize,
                top     = -marginSize,
                bottom  = -marginSize
            },
            tile = false,
            tileSize = 0
        });

        frame:SetBackdropColor(Color.toVertex("#333333"));

        -- 材质不透明，欲隐藏边框，必须设置透明度
        local borderColor = (hasBorder and "#999999") or "#99999900";
        frame:SetBackdropBorderColor(Color.toVertex(borderColor));
    end

    -- 边框与光晕都源于backdrop->edgeFile，因此必须再造一个frame
    -- 光晕的浮动动画暂时不要想了
    local function setFrameGlow(parent, gapSize, extendedSize)
        extendedSize = extendedSize or 5 * env.pixel;
        local glow = createFrame("frame", parent);
        glow:SetFrameStrata(parent:GetFrameStrata());
        glow:SetFrameLevel(parent:GetFrameLevel() - 1);
        glow:SetBackdrop({
            edgeFile = res.texture.GLOW1,
            edgeSize = extendedSize
        });
        local marginSize = gapSize + extendedSize;
        glow:SetBackdropBorderColor(Color.toVertex("white"))
        glow:SetPoint("topleft", -marginSize, marginSize);
        glow:SetPoint("bottomright", marginSize, -marginSize);
        parent.glow = glow;
        return glow;
    end

    -- get rid of texture border
    local function cropTexture(texture)
        texture:SetTexCoord(5/64, 59/64, 5/64, 59/64);
    end

    local function createAnchor(sideDots, parent)
        local anchor = createFrame("frame", parent);
        anchor:SetSize(sideDots, sideDots);
        setFrameBackdrop(anchor, 0, 0);
        anchor:SetBackdropColor(Color.toVertex("#33333300"));

        anchor:SetScript("OnEnter", function(self)
            self:SetBackdropColor(Color.toVertex("#333333"));
            GameTooltip:SetOwner(self);
            GameTooltip:AddLine("hold ctrl to drag");
            GameTooltip:Show();
        end);

        anchor:SetScript("OnLeave", function(self)
            self:SetBackdropColor(Color.toVertex("#33333300"));
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

    return {
        createBlizButton = createBlizButton,
        createFrame = createFrame,
        setFrameBackdrop = setFrameBackdrop,
        setFrameGlow = setFrameGlow,
        cropTexture = cropTexture,
        createAnchor = createAnchor,
    };
end);

T.ask("api.color", "api.case", "api.widget").answer("api", function(Color, Case, Widget)
    local t = tmerge(Case, Widget);
    t.color = Color;
    return t;
end);

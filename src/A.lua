if A then
    return;
end

-- place holder
_G.A = {};

----------------

local A = (function()

    local logi = function(...)
        (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage(...);
    end;

    local logd = function(...)
        local a = { ... };
        if (#a == 0) then
            logi("-- 1 - nil: nil");
            return;
        end
        for i, v in pairs(a) do
            local vType = type(v);
            if (vType == "string" or vType == "number") then
                logi(string.format("-- %d - %s: %s", i, vType, tostring(v)));
            else
                logi(string.format("-- %d - %s", i, (tostring(v) or "N/A")));
            end
        end
    end;

    local addSlashCommand = function(id, slashCommand, fn)
        _G["SLASH_" .. id .. "1"] = slashCommand;
        SlashCmdList[id] = fn;
    end;

    local getFps = function()
        local fps = GetFramerate();
        if (fps < 12) then
            return fps, 1, 0, 0;
        elseif (fps < 24) then
            return fps, 1, 1, 0;
        else
            return fps, 0, 1, 0;
        end
    end;

    local getLag = function()
        local lag = select(4, GetNetStats());
        if lag < 300 then
            return lag, 0, 1, 0;
        elseif lag < 600 then
            return lag, 1, 1, 0;
        else
            return lag, 1, 0, 0;
        end
    end;

    return {
        logd = logd,
        logi = logi,
        addSlashCommand = addSlashCommand,
        getFps = getFps,
        getLag = getLag,
    };
end)(...);

----------------

A.Res = (function(addonName)

    local resRoot = "interface/addons/" .. addonName .. "/res";

    return {
        texBlizBar = "Interface/TargetingFrame/UI-StatusBar",
        texBlizBarSpark = "Interface/CastingBar/UI-CastingBar-Spark",

        texBackground = resRoot .. "/background", -- simple white square texture
        texProgressbar = resRoot .. "/progressbar",

        texComboPoint1 = resRoot .. "/combopoint1",
        texNorm1 = resRoot .. "/norm1", -- norm: status bar texture
        texGlow1 = resRoot .. "/glow1", -- glow: status bar shining

        fontDefault = "fonts/arkai_t.ttf",
        fontCombat = "fonts/arkai_c.ttf",
        fontAvqest = resRoot .. "avqest.ttf",
        fontHooge0557 = resRoot .. "hooge0557.ttf",
        fontLbrited = resRoot .. "lbrited.ttf",
    };
end)(...);

----------------

A.Color = (function()

    local colorHex = {
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

        ["transparent"] = "#00000000",
        ["black"]       = "#000000",
        ["red"]         = "#ff0000",
        ["green"]       = "#00ff00",
        ["blue"]        = "#0000ff",
        ["yellow"]      = "#ffff00",
        ["magenta"]     = "#ff00ff",
        ["cyan"]        = "#00ffff",
        ["white"]       = "#ffffff",

        -- html color name
        ["coral"]       = "#ff7f50",
        ["crimson"]     = "#dc143c",
        ["darkorange"]  = "#ff8c00",
        ["darkred"]     = "#8b0000",
        ["dodgerblue"]  = "#1e90ff",
        ["firebrick"]   = "#b22222",
        ["forestgreen"] = "#228b22",
        ["gold"]        = "#ffd700",
        ["gray"]        = "#808080",
        ["hotpink"]     = "#ff69b4",     -- paladin
        ["maroon"]      = "#800000",
        ["mediumpurple"]    = "#9370d8",
        ["orangered"]   = "#ff4500",
        ["royalblue"]   = "#4169e1",     -- shaman
        ["skyblue"]     = "#87ceeb",     -- mage
        ["turquoise"]   = "#40e0d0",
        ["yellowgreen"] = "#9acd32",     -- hunter
        ["azure"]       = "#f0ffff",
        ["snow"]        = "#fffafa",
    };

    function pick(key)
        return colorHex[key or ""];
    end

    function fromUnitClass(unit)
        local _, unitClass = UnitClass(unit);
        return pick(string.lower(unitClass or ""));
    end

    function fromUnitHostile(unit)
        if UnitIsEnemy("player", unit) then
            return pick("red");
        elseif UnitIsFriend("player", unit) then
            return pick("green");
        else
            return pick("yellow");
        end
    end

    function fromPowerType(powerType)
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

    function fromUnitPowerType(unit)
        local powerType = UnitPowerType(unit or "player");
        return fromPowerType(powerType);
    end

    function fromVertex(r, g, b, a)
        a = a or 1;
        return string.format("#%2x%2x%2x%2x", r * 255, g * 255, b * 255, a * 255);
    end

    function toInt24(color)
        if (color == nil) then
            return nil;
        end
        return tonumber(string.sub(color, 2, 7), 16);
    end

    function toVertex(color)
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
        fromUnitPowerType = fromUnitPowerType,
        fromPowerType = fromPowerType,
        fromVertex = fromVertex,
        toInt24 = toInt24,
        toVertex = toVertex,
    };
end)(...);

----------------

_G.A = A;
_G.logd = A.logd;
_G.logi = A.logi;

----------------

A.addSlashCommand("thpackReload", "/reload", ReloadUI);

A.addSlashCommand("thpackDebug", "/debug", function(x)
    logi("-------- printing: " .. x);
    logd(loadstring("return " .. x)());
end);

A.addSlashCommand("thpackGetExp", "/exp", function()
    local currentExp = UnitXP("player");
    local maxExp = UnitXPMax("player");
    local bonusExp = GetXPExhaustion();
    if (bonusExp) then
        logi(string.format("exp: %d / %d (%d)", currentExp, maxExp, currentExp + bonusExp));
    else
        logi(string.format("exp: %d / %d", currentExp, maxExp));
    end
end);

A.addSlashCommand("thpackGetFps", "/fps", function()
    local fps, r, g, b = A.getFps();
    logi(string.format("fps: %d", fps), r, g, b);
end);

A.addSlashCommand("thpackGetLag", "/lag", function()
    local lag, r, g, b = A.getLag();
    logi(string.format("lag: %d ms", lag), r, g, b);
end);

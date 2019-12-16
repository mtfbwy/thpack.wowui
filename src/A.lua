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
        hpbar32 = resRoot .. "/hpbar32.tga",
        tile32 = resRoot .. "/tile32.tga", -- simple white square texture

        tgaCombopoint1 = resRoot .. "/combopoint1.tga",
        tgaGlow1 = resRoot .. "/glow1.tga",

        oggFight = resRoot .. "/Fight.ogg",

        fontDefault = "fonts/arkai_t.ttf",
        fontCombat = "fonts/arkai_c.ttf",
        fontAvqest = resRoot .. "font/avqest.ttf",
        fontHooge0557 = resRoot .. "font/hooge0557.ttf",
        fontLbrited = resRoot .. "font/lbrited.ttf",
    };
end)(...);

----------------

A.Color = Color;

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

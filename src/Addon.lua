_G.Addon = (function()

    _G.logi = function(...)
        (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage(...);
    end;

    _G.logd = function(...)
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
        addSlashCommand = addSlashCommand,
        getFps = getFps,
        getLag = getLag,
    };
end)(...);

----------------

Addon.addSlashCommand("thpackReload", "/reload", ReloadUI);

Addon.addSlashCommand("thpackDebug", "/debug", function(x)
    logi("-------- printing: " .. x);
    logd(loadstring("return " .. x)());
end);

Addon.addSlashCommand("thpackGetExp", "/exp", function()
    local curExp = UnitXP("player");
    local maxExp = UnitXPMax("player");
    local bonusExp = GetXPExhaustion();
    if (bonusExp) then
        logi(string.format("exp: %d / %d (%d)", curExp, maxExp, curExp + bonusExp));
    else
        logi(string.format("exp: %d / %d", curExp, maxExp));
    end
end);

Addon.addSlashCommand("thpackGetFps", "/fps", function()
    local fps, r, g, b = Addon.getFps();
    logi(string.format("fps: %d", fps), r, g, b);
end);

Addon.addSlashCommand("thpackGetLag", "/lag", function()
    local lag, r, g, b = Addon.getLag();
    logi(string.format("lag: %d ms", lag), r, g, b);
end);

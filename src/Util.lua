_G.Util = {};

Util.addCmd = function(id, cmd, callback)
    _G["SLASH_" .. id .. "1"] = cmd;
    SlashCmdList[id] = callback;
end;

Util.getFps = function()
    local fps = GetFramerate();
    if (fps < 12) then
        return fps, 1, 0, 0;
    elseif (fps < 24) then
        return fps, 1, 1, 0;
    else
        return fps, 0, 1, 0;
    end
end;

Util.getLag = function()
    local lag = select(4, GetNetStats());
    if lag < 300 then
        return lag, 0, 1, 0;
    elseif lag < 600 then
        return lag, 1, 1, 0;
    else
        return lag, 1, 0, 0;
    end
end;

Util.addCmd("thpackDebug", "/debug", function(x)
    logi("-------- printing: " .. x);
    logd(loadstring("return " .. x)());
end);

Util.addCmd("thpackReload", "/reload", ReloadUI);

Util.addCmd("thpackExp", "/exp", function()
    local curExp = UnitXP("player");
    local maxExp = UnitXPMax("player");
    local bonusExp = GetXPExhaustion();
    if (bonusExp) then
        logi(string.format("exp: %d / %d (%d)", curExp, maxExp, curExp + bonusExp));
    else
        logi(string.format("exp: %d / %d", curExp, maxExp));
    end
end);

Util.addCmd("thpackFps", "/fps", function()
    local fps, r, g, b = Util.getFps();
    logi(string.format("fps: %d", fps), r, g, b);
end);

Util.addCmd("thpackLag", "/lag", function()
    local lag, r, g, b = Util.getLag();
    logi(string.format("lag: %d ms", lag), r, g, b);
end);

if (P ~= nil) then
    P.ask().answer("Util", function()
        return Util;
    end);
end


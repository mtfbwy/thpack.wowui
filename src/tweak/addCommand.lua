P.ask("Util").answer("addCommand", function(Util)

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
end);

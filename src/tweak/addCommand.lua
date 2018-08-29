P.ask("api").answer("addCommand", function(api)

    api.addCmd("thpackDebug", "/debug", function(x)
        logi("-------- printing: " .. x);
        logd(loadstring("return " .. x)());
    end);

    api.addCmd("thpackReload", "/reload", ReloadUI);

    api.addCmd("thpackExp", "/exp", function()
        local curExp = UnitXP("player");
        local maxExp = UnitXPMax("player");
        local bonusExp = GetXPExhaustion();
        if (bonusExp) then
            logi(string.format("exp: %d / %d (%d)", curExp, maxExp, curExp + bonusExp));
        else
            logi(string.format("exp: %d / %d", curExp, maxExp));
        end
    end);

    api.addCmd("thpackFps", "/fps", function()
        local fps, r, g, b = api.getFps();
        logi(string.format("fps: %d", fps), r, g, b);
    end);

    api.addCmd("thpackLag", "/lag", function()
        local lag, r, g, b = api.getLag();
        logi(string.format("lag: %d ms", lag), r, g, b);
    end);
end);

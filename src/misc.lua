T.ask("api").answer(function(api)
    api.addCmd("thExp", "/exp", function()
        local curExp = UnitXP("player");
        local maxExp = UnitXPMax("player");
        local bonusExp = GetXPExhaustion();
        if (bonusExp) then
            L.logi(string.format("exp: %d / %d (%d)", curExp, maxExp, curExp + bonusExp));
        else
            L.logi(string.format("exp: %d / %d", curExp, maxExp));
        end
    end);

    api.addCmd("thFps", "/fps", function()
        local fps, r, g, b = api.getFps();
        L.logi(string.format("fps: %d", fps), r, g, b);
    end);

    api.addCmd("thLag", "/lag", function()
        local lag, r, g, b = api.getLag();
        L.logi(string.format("lag: %d ms", lag), r, g, b);
    end);
end);

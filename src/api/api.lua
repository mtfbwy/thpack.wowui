P.ask("res").answer("api", function(res)

    local api = {};

    function api.addCmd(id, cmd, callback)
        _G["SLASH_" .. id .. "1"] = cmd;
        SlashCmdList[id] = callback;
    end

    function api.getFps()
        local fps = GetFramerate();
        if (fps < 12) then
            return fps, 1, 0, 0;
        elseif (fps < 24) then
            return fps, 1, 1, 0;
        else
            return fps, 0, 1, 0;
        end
    end

    function api.getLag()
        local lag = select(4, GetNetStats());
        if lag < 300 then
            return lag, 0, 1, 0;
        elseif lag < 600 then
            return lag, 1, 1, 0;
        else
            return lag, 1, 0, 0;
        end
    end

    return api;
end);

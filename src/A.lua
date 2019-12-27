_G.A = _G.A or (function()

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

    return {
        logd = logd,
        logi = logi,
        addSlashCommand = addSlashCommand,
    };
end)(...);

----------------

A.addSlashCommand("thpackDebug", "/debug", function(x)
    A.logi("-------- printing: " .. x);
    A.logd(loadstring("return " .. x)());
end);

A.addSlashCommand("thpackReload", "/reload", ReloadUI);

----------------

A.Color = Color;

----------------

A.Res = (function(addonName)

    local path = "interface/addons/" .. addonName .. "/res";

    return {
        path = path,
        combopoint16 = path .. "/combopoint16.tga",
        healthbar32 = path .. "/healthbar32.tga",
        tile32 = path .. "/tile32.tga", -- simple white square texture
    };
end)(...);

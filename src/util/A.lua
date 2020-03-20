A = A or {};

A.logi = A.logi or function(...)
    (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage(...);
end;

A.logd = A.logd or function(...)
    local a = { ... };
    if (#a == 0) then
        A.logi("-- 1 - nil: nil");
        return;
    end
    for i, v in pairs(a) do
        local vType = type(v);
        if (vType == "string" or vType == "number") then
            A.logi(string.format("-- %d - %s: %s", i, vType, tostring(v)));
        else
            A.logi(string.format("-- %d - %s", i, (tostring(v) or "N/A")));
        end
    end
end;

A.addSlashCommand = A.addSlashCommand or function(id, slashCommand, fn)
    _G["SLASH_" .. id .. "1"] = slashCommand;
    SlashCmdList[id] = fn;
end;

----------------

A.addSlashCommand("thpackDebug", "/debug", function(x)
    A.logi("-------- printing: " .. x);
    A.logd(loadstring("return " .. x)());
end);

A.addSlashCommand("thpackReload", "/reload", ReloadUI);

----------------

A.Res = A.Res or (function(addonName)

    local path = "interface/addons/" .. addonName .. "/res";

    return {
        path = path,
        combopoint16 = path .. "/combopoint16.tga",
        healthbar32 = path .. "/healthbar32.tga",
        tile32 = path .. "/tile32.tga", -- simple white square texture
    };
end)(...);

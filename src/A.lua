local addonName, addon = ...;
addon.A = {};
local A = addon.A;

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

----------------------------------------
-- debug

A.addSlashCommand("thpackReload", "/reload", ReloadUI);

A.addSlashCommand("thpackPrint", "/pr", function(x)
    A.logi("-------- printing: " .. x);
    A.logd(loadstring("return " .. x)());
end);

A.addSlashCommand("thpackExp", "/exp", function()
    local exp = UnitXP("player");
    local maxExp = UnitXPMax("player");
    local bonusExp = GetXPExhaustion();
    if (bonusExp) then
        A.logi(string.format("exp: %d / %d (%d)", exp, maxExp, exp + bonusExp));
    else
        A.logi(string.format("exp: %d / %d", exp, maxExp));
    end
end);

if A then
    return;
end

----------------

_G.A = (function()

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

A.Color = Color;

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
    };
end)(...);

----------------

A.addSlashCommand("thpackReload", "/reload", ReloadUI);

A.addSlashCommand("thpackDebug", "/debug", function(x)
    A.logi("-------- printing: " .. x);
    A.logd(loadstring("return " .. x)());
end);

A.addSlashCommand("thpackGetExp", "/exp", function()
    local currentExp = UnitXP("player");
    local maxExp = UnitXPMax("player");
    local bonusExp = GetXPExhaustion();
    if (bonusExp) then
        A.logi(string.format("exp: %d / %d (%d)", currentExp, maxExp, currentExp + bonusExp));
    else
        A.logi(string.format("exp: %d / %d", currentExp, maxExp));
    end
end);

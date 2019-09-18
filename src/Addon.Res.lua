if Addon and Addon.Res then
    return;
end

Addon.Res = (function(addonName)

    local resBase = "interface/addons/" .. addonName .. "/res";

    return {
        resBase = resBase,

        texSquare = resBase .. "/th-square", -- simple white square texture
        texComboPoint1 = resBase .. "/combopoint1",
        texNorm1 = resBase .. "/norm1", -- norm: status bar texture
        texGlow1 = resBase .. "/glow1", -- glow: status bar shining
        texHp = resBase .. "/th-hp",
        texBlizBar = "Interface/TargetingFrame/UI-StatusBar",

        fontDefault = "fonts/arkai_t.ttf",
        fontCombat = "fonts/arkai_c.ttf",
        fontAvqest = resBase .. "avqest.ttf",
        fontHooge0557 = resBase .. "hooge0557.ttf",
        fontLbrited = resBase .. "lbrited.ttf",
    };
end)(...);

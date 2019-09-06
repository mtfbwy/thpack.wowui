P.ask().answer("res", function()

    local resPath = "interface/addons/" .. P._addon .. "/res";

    local texture = {
        SQUARE = resPath .. "/th-square", -- simple white square texture
        COMBOPOINT1 = resPath .. "/combopoint1",
        NORM1 = resPath .. "/norm1", -- norm: status bar texture
        GLOW1 = resPath .. "/glow1", -- glow: status bar shining
        HP = resPath .. "/th-hp",

        BLIZ_BAR = "Interface/TargetingFrame/UI-StatusBar",
    };

    local font = {
        DEFAULT = "fonts/arkai_t.ttf",
        COMBAT = "fonts/arkai_c.ttf",
        AVQEST = resPath .. "avqest.ttf",
        HOOGE0557 = resPath .. "hooge0557.ttf",
        LBRITED = resPath .. "lbrited.ttf",
    };

    return {
        texture = texture,
        font = font,
    };
end);

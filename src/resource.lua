T.ask().answer("resource", function()
    local PATH = [[interface\addons\]] .. T.name .. [[\res\]];

    local TEXTURE = {
        SQUARE = PATH .. "th-square", -- simple white square texture
        COMBOPOINT1 = PATH .. "combopoint1",
        NORM1 = PATH .. "norm1", -- norm: status bar texture
        GLOW1 = PATH .. "glow1", -- glow: status bar shining
    };

    local FONT = {
        DEFAULT = [[fonts\arkai_t.ttf]],
        COMBAT = [[fonts\arkai_c.ttf]],
        AVQEST = PATH .. "avqest.ttf",
        HOOGE0557 = PATH .. "hooge0557.ttf",
        LBRITED = PATH .. "lbrited.ttf",
    };

    return {
        texture = TEXTURE,
        font = FONT,
    };
end);

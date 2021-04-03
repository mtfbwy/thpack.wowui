A.Res = A.Res or (function(addonName)

    local path = "interface/addons/" .. addonName .. "/res";

    return {
        path = path,
        combopoint16 = path .. "/combopoint16.tga",
        healthbar32 = path .. "/healthbar32.tga",
        tile32 = path .. "/tile32.tga", -- simple white square texture
    };
end)(...);

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

    -- RAID_CLASS_COLORS[CLASS]
    local classColors = {
        ["deathknight"] = "CC0033",
        ["demonhunter"] = "9933CC",
        ["druid"]   = "FF6600",
        ["hunter"]  = "99CC66",
        ["mage"]    = "99CCFF", -- source: 0.41,0.80,0.94
        ["monk"]    = "00FF99", -- source: 0.00,1.00,0.59
        ["paladin"] = "FF99CC", -- source: 0.96,0.55,0.73
        ["priest"]  = "FFFFFF",
        ["rogue"]   = "FFFF66",
        ["shaman"]  = "3366FF",
        ["warlock"] = "9999CC",
        ["warrior"] = "CC9966",
    };

    local colorNames = {
        ["coral"]   = "FF7F50",
        ["crimson"] = "DC143C",
        ["darkorange"]  = "FF8C00",
        ["darkred"] = "8B0000",
        ["dodgerblue"]  = "1E90FF",
        ["firebrick"]   = "B22222",
        ["forestgreen"] = "228B22",
        ["gold"]    = "FFD700",
        ["gray"]    = "808080",
        ["green"]   = "00FF00",
        ["hotpink"] = "FF69B4",     -- paladin
        ["maroon"]  = "800000",
        ["mediumpurple"]    = "9370D8",
        ["orangered"]   = "FF4500",
        ["royalblue"]   = "4169E1",     -- shaman
        ["skyblue"] = "87CEEB",     -- mage
        ["turquoise"]   = "40E0D0",
        ["white"]   = "FFFFFF",
        ["yellowgreen"] = "9ACD32",     -- hunter
    };

    local pick = function(key)
        assert(type(key) == "string");
        return classColors[key] or colorNames[key];
    end;

    local COLOR = {};

    COLOR.fromClass = function(unit)
        local _, unitClass = UnitClass(unit);
        return classColors[string.lower(unitClass)];
    end;

    COLOR.fromAttidute = function(unit)
        if UnitIsEnemy("player", unit) then
            return pick("orangered");
        elseif UnitIsFriend("player", unit) then
            return pick("green");
        else
            return pick("gold");
        end
    end;

    COLOR.fromPowerType = function(powerType)
        if powerType == 0 then
            return pick("royalblue");
        elseif powerType == 1 then
            return pick("firebrick");
        elseif powerType == 2 then
            return pick("coral");
        elseif powerType == 3 then
            return pick("gold");
        elseif powerType == 6 then
            return pick("turquoise");
        else
            return pick("white");
        end
    end;

    COLOR.fromUnitPowerType = function(unit)
        local powerType = UnitPowerType(unit or "player");
        return COLOR.fromPowerType(powerType);
    end;

    COLOR.fromVertex = function(r, g, b, a)
        a = a or 1
        return string.format("%2X%2X%2X%2X", r * 255, g * 255, b * 255, a * 255);
    end;

    COLOR.toSequence = function(color)
        --c = c or "9D9D9D"
        color = pick(color) or color
        local r = tonumber(strsub(color, 1, 2), 16);
        local g = tonumber(strsub(color, 3, 4), 16);
        local b = tonumber(strsub(color, 5, 6), 16);
        local a = tonumber(strsub(color, 7, 8), 16);
        r = not r or r / 255;
        g = not g or g / 255;
        b = not b or b / 255;
        a = not a or a / 255;
        return r, g, b, a;
    end;

    COLOR.toVertex = function(color)
        if color[0] == '#' then
            return COLOR.toSequence(strsub(color, 1, 6));
        else
            return COLOR.toSequence(color);
        end
    end;

    return {
        texture = TEXTURE,
        font = FONT,
        color = COLOR
    };
end);

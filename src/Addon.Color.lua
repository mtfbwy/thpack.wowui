Addon.Color = (function()

    local colorHex = {
        -- RAID_CLASS_COLORS[CLASS]
        ["deathknight"] = "#cc0033",
        ["demonhunter"] = "#9933cc",
        ["druid"]       = "#ff6600",
        ["hunter"]      = "#99cc66",
        ["mage"]        = "#99ccff", -- source: 0.41,0.80,0.94
        ["monk"]        = "#00ff99", -- source: 0.00,1.00,0.59
        ["paladin"]     = "#ff99cc", -- source: 0.96,0.55,0.73
        ["priest"]      = "#ffffff",
        ["rogue"]       = "#ffff66",
        ["shaman"]      = "#3366ff",
        ["warlock"]     = "#9999cc",
        ["warrior"]     = "#cc9966",

        ["transparent"] = "#00000000",
        ["black"]       = "#000000",
        ["red"]         = "#ff0000",
        ["green"]       = "#00ff00",
        ["blue"]        = "#0000ff",
        ["yellow"]      = "#ffff00",
        ["magenta"]     = "#ff00ff",
        ["cyan"]        = "#00ffff",
        ["white"]       = "#ffffff",

        -- html color name
        ["coral"]       = "#ff7f50",
        ["crimson"]     = "#dc143c",
        ["darkorange"]  = "#ff8c00",
        ["darkred"]     = "#8b0000",
        ["dodgerblue"]  = "#1e90ff",
        ["firebrick"]   = "#b22222",
        ["forestgreen"] = "#228b22",
        ["gold"]        = "#ffd700",
        ["gray"]        = "#808080",
        ["hotpink"]     = "#ff69b4",     -- paladin
        ["maroon"]      = "#800000",
        ["mediumpurple"]    = "#9370d8",
        ["orangered"]   = "#ff4500",
        ["royalblue"]   = "#4169e1",     -- shaman
        ["skyblue"]     = "#87ceeb",     -- mage
        ["turquoise"]   = "#40e0d0",
        ["yellowgreen"] = "#9acd32",     -- hunter
        ["azure"]       = "#f0ffff",
        ["snow"]        = "#fffafa",
    };

    function pick(key)
        return colorHex[key or ""];
    end

    function fromUnitClass(unit)
        local _, unitClass = UnitClass(unit);
        return pick(string.lower(unitClass or ""));
    end

    function fromUnitHostile(unit)
        if UnitIsEnemy("player", unit) then
            return pick("red");
        elseif UnitIsFriend("player", unit) then
            return pick("green");
        else
            return pick("yellow");
        end
    end

    function fromPowerType(powerType)
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
    end

    function fromUnitPowerType(unit)
        local powerType = UnitPowerType(unit or "player");
        return fromPowerType(powerType);
    end

    function fromVertex(r, g, b, a)
        a = a or 1;
        return string.format("#%2X%2X%2X%2X", r * 255, g * 255, b * 255, a * 255);
    end

    function toInt(color)
        if (color == nil) then
            return nil;
        end
        return string.sub(color, 2);
    end

    function toVertex(color)
        local color = pick(color) or color;
        local r = tonumber(strsub(color, 2, 3), 16);
        local g = tonumber(strsub(color, 4, 5), 16);
        local b = tonumber(strsub(color, 6, 7), 16);
        local a = tonumber(strsub(color, 8, 9), 16);
        r = not r or r / 255;
        g = not g or g / 255;
        b = not b or b / 255;
        a = not a or a / 255;
        return r, g, b, a;
    end

    return {
        fromUnitClass = fromUnitClass,
        fromUnitHostile = fromUnitHostile,
        fromUnitPowerType = fromUnitPowerType,
        fromPowerType = fromPowerType,
        fromVertex = fromVertex,
        toInt = toInt,
        toVertex = toVertex,
    };
end)(...);

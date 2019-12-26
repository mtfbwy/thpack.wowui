local Color = newProto(nil, function(o)
    -- default to opaque white
    o._rgb = 0xffffff;
    o._a = 0xff;
end);

function Color:toInt24()
    return self._rgb;
end

function Color:toRgba()
    local i = self._rgb or 0;
    local b = i % 0x100;
    i = math.floor(i / 0x100);
    local g = i % 0x100;
    i = math.floor(i / 0x100);
    local r = i;
    return r, g, b, self._a;
end

function Color:toString()
    -- align to css
    return string.format("#%06x%02x", self._rgb, self._a);
end

function Color:toVertex()
    local r, g, b, a = self:toRgba();
    return r / 0xff, g / 0xff, b / 0xff, a / 0xff;
end

function Color.fromString(s)
    if (type(s) ~= "string") then
        return nil;
    end

    if (s:sub(1, 1) ~= "#") then
        return nil;
    end

    if (#s == 7) then
        local color = Color:malloc();
        color._rgb = tonumber(s:sub(2, 7), 16);
        color._a = 0xff;
        return color;
    elseif (#s == 9) then
        local color = Color:malloc();
        color._rgb = tonumber(s:sub(2, 7), 16);
        color._a = tonumber(s:sub(8, 9), 16);
        return color;
    end
end

function Color.fromVertex(r, g, b, a)
    r = math.floor(r * 0xff);
    g = math.floor(g * 0xff);
    b = math.floor(b * 0xff);
    a = a and math.floor(a * 0xff) or 0xff;
    local color = Color:malloc();
    color._rgb = r * 0x10000 + g * 0x100 + b;
    color._a = a;
    return color;
end

Color._names = {
    ["transparent"] = "#00000000", -- transparent black
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

Color._unitClasses = {
    ["deathknight"] = "#cc0033", -- c41e3a
    ["demonhunter"] = "#9933cc", -- a330c9
    ["druid"]       = "#ff6600", -- ff7c0a
    ["hunter"]      = "#99cc66", -- aad372
    ["mage"]        = "#66ccff", -- 69ccf0 0.41,0.80,0.94
    ["monk"]        = "#00ff99", -- 00ff96
    ["paladin"]     = "#ff99cc", -- f48cba
    ["priest"]      = "#ffffff", -- ffffff
    ["rogue"]       = "#ffff66", -- fff468
    ["shaman"]      = "#0066ff", -- 0070de
    ["warlock"]     = "#9999cc", -- 9482c9
    ["warrior"]     = "#cc9966", -- c69b6d
};

function Color.pick(colorString)
    colorString = string.lower(colorString or "");
    colorString = Color._names[colorString] or Color._unitClasses[colorString] or colorString;
    return Color.fromString(colorString);
end

-- use aligned color
function Color.getUnitClassColorByUnit(unit)
    local _, enUnitClass = UnitClass(unit);
    return Color.pick(enUnitClass);
end

function Color.getUnitOffensiveColorByUnit(unit)
    if (UnitPlayerControlled(unit)) then
        if (UnitCanAttack(unit, "player")) then
            if (UnitCanAttack("player", unit)) then
                -- normal hostile
                return Color.pick("red");
            else
                -- only he can attack
                return Color.pick("orangered");
            end
        elseif (UnitCanAttack("player", unit)) then
            return Color.pick("yellow");
        else
            -- friendly
            if (UnitIsPVP(unit)) then
                return Color.pick("green");
            else
                return Color.pick("blue");
            end
        end
    else
        if (UnitIsEnemy("player", unit)) then
            return Color.pick("red");
        elseif (UnitIsFriend("player", unit)) then
            return Color.pick("green");
        else
            return Color.pick("yellow");
        end
    end
end

function Color.getUnitManaTypeColorByUnit(unit)
    local typ = UnitPowerType(unit);
    if (typ == 0) then
        return Color.pick("royalblue");
    elseif (typ == 1) then
        return Color.pick("firebrick");
    elseif (typ == 2) then
        return Color.pick("coral");
    elseif (typ == 3) then
        return Color.pick("gold");
    elseif (typ == 6) then
        return Color.pick("turquoise");
    else
        return Color.pick("white");
    end
end

_G.Color = Color;

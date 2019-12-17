local Color = Color;

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
};

function Color.pick(key)
    key = string.lower(key or "");
    local colorString = Color._names[key] or Color._unitClasses[key] or key;
    return Color.fromString(colorString);
end

function Color.getUnitClassColorByUnit(unit)
    local _, unitClass = UnitClass(unit);
    return Color.pick(unitClass);
end

function Color.getUnitOffensiveColorByUnit(unit)
    if (UnitPlayerControlled(unit)) then
        if (UnitCanAttack(unit, "player")) then
            if (UnitCanAttack("player", unit)) then
                -- normal hostile
                return Color.pick("red");
            else
                -- only he can attack
                return Color.pick("orange");
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

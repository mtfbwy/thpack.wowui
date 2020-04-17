Color = Color or (function()

    local Color = newProto(nil, function(o)
        -- rrggbb default to 000000 but aa default to 0xFF
        -- must have alpha channel
        o._rgb = 0x000000; -- black
        o._a = 0xff; -- opaque
    end);

    -- rr, gg, bb, aa
    function Color:toComponents()
        local i = self._rgb or 0;
        local b = i % 0x100;
        i = math.floor(i / 0x100);
        local g = i % 0x100;
        local r = math.floor(i / 0x100);
        return r, g, b, self._a;
    end

    function Color:toInt24()
        return self._rgb;
    end

    function Color:toInt32()
        return self._rgb * 0x100 + self._a;
    end

    function Color:toString()
        -- align to css
        return string.format("#%06x%02x", self._rgb, self._a);
    end

    -- .r, .g, .b, .a
    function Color:toVertex()
        local rr, gg, bb, aa = self:toComponents();
        return rr / 0xff, gg / 0xff, bb / 0xff, aa / 0xff;
    end

    local function align33(i)
        local index = i / 0x33;
        if (index >= 4.5) then
            return 0xff;
        else
            return math.floor(index + 0.5) * 0x33;
        end
    end

    function Color:toWebSafe()
        local rr, gg, bb, aa = self:toComponents();
        return Color.fromComponents(
            align33(rr),
            align33(gg),
            align33(bb),
            align33(aa))
    end

    function Color.fromComponents(rr, gg, bb, aa)
        local color = Color:malloc();
        color._rgb = rr * 0x10000 + gg * 0x100 + bb;
        if (aa ~= nil) then
            color._a = aa;
        end
        return color;
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
        local rr = math.floor(r * 0xff);
        local gg = math.floor(g * 0xff);
        local bb = math.floor(b * 0xff);
        local aa = a and math.floor(a * 0xff) or 0xff;
        return Color.fromComponents(rr, gg, bb, aa);
    end

    return Color;
end)();

Color.pick = Color.pick or (function()

    local ansiColorCodes = {
        ["transparent"] = "#00000000",
        ["black"]   = "#000000",
        ["red"]     = "#ff0000",
        ["green"]   = "#00ff00",
        ["blue"]    = "#0000ff",
        ["yellow"]  = "#ffff00",
        ["magenta"] = "#ff00ff",
        ["cyan"]    = "#00ffff",
        ["white"]   = "#ffffff",
    };

    local htmlColorCodes = {
        -- Red color names
        ["IndianRed"] = "#CD5C5C",
        ["LightCoral"] = "#F08080",
        ["Salmon"] = "#FA8072",
        ["DarkSalmon"] = "#E9967A",
        ["LightSalmon"] = "#FFA07A",
        ["Crimson"] = "#DC143C",
        ["Red"] = "#FF0000",
        ["FireBrick"] = "#B22222",
        ["DarkRed"] = "#8B0000",

        -- Pink color names
        ["Pink"] = "#FFC0CB",
        ["LightPink"] = "#FFB6C1",
        ["HotPink"] = "#FF69B4",
        ["DeepPink"] = "#FF1493",
        ["MediumVioletRed"] = "#C71585",
        ["PaleVioletRed"] = "#DB7093",

        -- Orange color names
        ["LightSalmon"] = "#FFA07A",
        ["Coral"] = "#FF7F50",
        ["Tomato"] = "#FF6347",
        ["OrangeRed"] = "#FF4500",
        ["DarkOrange"] = "#FF8C00",
        ["Orange"] = "#FFA500",

        -- Yellow color names
        ["Gold"] = "#FFD700",
        ["Yellow"] = "#FFFF00",
        ["LightYellow"] = "#FFFFE0",
        ["LemonChiffon"] = "#FFFACD",
        ["LightGoldenrodYellow"] = "#FAFAD2",
        ["PapayaWhip"] = "#FFEFD5",
        ["Moccasin"] = "#FFE4B5",
        ["PeachPuff"] = "#FFDAB9",
        ["PaleGoldenrod"] = "#EEE8AA",
        ["Khaki"] = "#F0E68C",
        ["DarkKhaki"] = "#BDB76B",

        -- Purple color names
        ["Lavender"] = "#E6E6FA",
        ["Thistle"] = "#D8BFD8",
        ["Plum"] = "#DDA0DD",
        ["Violet"] = "#EE82EE",
        ["Orchid"] = "#DA70D6",
        ["Fuchsia"] = "#FF00FF",
        ["Magenta"] = "#FF00FF",
        ["MediumOrchid"] = "#BA55D3",
        ["MediumPurple"] = "#9370DB",
        ["Amethyst"] = "#9966CC",
        ["BlueViolet"] = "#8A2BE2",
        ["DarkViolet"] = "#9400D3",
        ["DarkOrchid"] = "#9932CC",
        ["DarkMagenta"] = "#8B008B",
        ["Purple"] = "#800080",
        ["Indigo"] = "#4B0082",
        ["SlateBlue"] = "#6A5ACD",
        ["DarkSlateBlue"] = "#483D8B",
        ["MediumSlateBlue"] = "#7B68EE",

        -- Green color names
        ["GreenYellow"] = "#ADFF2F",
        ["Chartreuse"] = "#7FFF00",
        ["LawnGreen"] = "#7CFC00",
        ["Lime"] = "#00FF00",
        ["LimeGreen"] = "#32CD32",
        ["PaleGreen"] = "#98FB98",
        ["LightGreen"] = "#90EE90",
        ["MediumSpringGreen"] = "#00FA9A",
        ["SpringGreen"] = "#00FF7F",
        ["MediumSeaGreen"] = "#3CB371",
        ["SeaGreen"] = "#2E8B57",
        ["ForestGreen"] = "#228B22",
        ["Green"] = "#008000",
        ["DarkGreen"] = "#006400",
        ["YellowGreen"] = "#9ACD32",
        ["OliveDrab"] = "#6B8E23",
        ["Olive"] = "#808000",
        ["DarkOliveGreen"] = "#556B2F",
        ["MediumAquamarine"] = "#66CDAA",
        ["DarkSeaGreen"] = "#8FBC8F",
        ["LightSeaGreen"] = "#20B2AA",
        ["DarkCyan"] = "#008B8B",
        ["Teal"] = "#008080",

        -- Blue color names
        ["Aqua"] = "#00FFFF",
        ["Cyan"] = "#00FFFF",
        ["LightCyan"] = "#E0FFFF",
        ["PaleTurquoise"] = "#AFEEEE",
        ["Aquamarine"] = "#7FFFD4",
        ["Turquoise"] = "#40E0D0",
        ["MediumTurquoise"] = "#48D1CC",
        ["DarkTurquoise"] = "#00CED1",
        ["CadetBlue"] = "#5F9EA0",
        ["SteelBlue"] = "#4682B4",
        ["LightSteelBlue"] = "#B0C4DE",
        ["PowderBlue"] = "#B0E0E6",
        ["LightBlue"] = "#ADD8E6",
        ["SkyBlue"] = "#87CEEB",
        ["LightSkyBlue"] = "#87CEFA",
        ["DeepSkyBlue"] = "#00BFFF",
        ["DodgerBlue"] = "#1E90FF",
        ["CornflowerBlue"] = "#6495ED",
        ["MediumSlateBlue"] = "#7B68EE",
        ["RoyalBlue"] = "#4169E1",
        ["Blue"] = "#0000FF",
        ["MediumBlue"] = "#0000CD",
        ["DarkBlue"] = "#00008B",
        ["Navy"] = "#000080",
        ["MidnightBlue"] = "#191970",

        -- Brown color names
        ["Cornsilk"] = "#FFF8DC",
        ["BlanchedAlmond"] = "#FFEBCD",
        ["Bisque"] = "#FFE4C4",
        ["NavajoWhite"] = "#FFDEAD",
        ["Wheat"] = "#F5DEB3",
        ["BurlyWood"] = "#DEB887",
        ["Tan"] = "#D2B48C",
        ["RosyBrown"] = "#BC8F8F",
        ["SandyBrown"] = "#F4A460",
        ["Goldenrod"] = "#DAA520",
        ["DarkGoldenrod"] = "#B8860B",
        ["Peru"] = "#CD853F",
        ["Chocolate"] = "#D2691E",
        ["SaddleBrown"] = "#8B4513",
        ["Sienna"] = "#A0522D",
        ["Brown"] = "#A52A2A",
        ["Maroon"] = "#800000",

        -- White color names
        ["White"] = "#FFFFFF",
        ["Snow"] = "#FFFAFA",
        ["Honeydew"] = "#F0FFF0",
        ["MintCream"] = "#F5FFFA",
        ["Azure"] = "#F0FFFF",
        ["AliceBlue"] = "#F0F8FF",
        ["GhostWhite"] = "#F8F8FF",
        ["WhiteSmoke"] = "#F5F5F5",
        ["Seashell"] = "#FFF5EE",
        ["Beige"] = "#F5F5DC",
        ["OldLace"] = "#FDF5E6",
        ["FloralWhite"] = "#FFFAF0",
        ["Ivory"] = "#FFFFF0",
        ["AntiqueWhite"] = "#FAEBD7",
        ["Linen"] = "#FAF0E6",
        ["LavenderBlush"] = "#FFF0F5",
        ["MistyRose"] = "#FFE4E1",

        -- Grey color names
        ["Gainsboro"] = "#DCDCDC",
        ["LightGrey"] = "#D3D3D3",
        ["Silver"] = "#C0C0C0",
        ["DarkGray"] = "#A9A9A9",
        ["Gray"] = "#808080",
        ["DimGray"] = "#696969",
        ["LightSlateGray"] = "#778899",
        ["SlateGray"] = "#708090",
        ["DarkSlateGray"] = "#2F4F4F",
        ["Black"] = "#000000",
    };

    local retailClassColors = {
        ["DEATHKNIGHT"] = "#c31d39",
        ["DEMONHUNTER"] = "#a22fc8",
        ["DRUID"]       = "#fe7b09",
        ["HUNTER"]      = "#a9d271",
        ["MAGE"]        = "#3ec5e9",
        ["MONK"]        = "#00fe95",
        ["PALADIN"]     = "#f38bb9",
        ["PRIEST"]      = "#fefefe",
        ["ROGUE"]       = "#fef367",
        ["SHAMAN"]      = "#006fdc",
        ["WARLOCK"]     = "#8686ec",
        ["WARRIOR"]     = "#c59a6c",
    };

    return function(colorString)
        colorString = colorString or "";
        colorString = ansiColorCodes[colorString]
                or htmlColorCodes[colorString]
                or retailClassColors[colorString]
                or colorString;
        return Color.fromString(colorString);
    end;
end)();

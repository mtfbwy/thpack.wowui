local Color = newProto(nil, function(o)
    -- default to opaque white
    o._rgb = 0xffffff;
    o._a = 0xff;
end);

function Color:toInt24()
    return o._rgb;
end

function Color:toRgba()
    local i = self_rgb or 0;
    local b = i % 0xff;
    i = i / 0xff;
    local g = i % 0xff;
    i = i / 0xff;
    local r = i % 0xff;
    return r, g, b, self._a;
end

function Color:toString()
    -- align to css
    return string.format("#%06x%02x", self._rgb, self._a or 0xff);
end

function Color:toVertex()
    local r, g, b, a = self:toRgba();
    return r / 0xff, g / 0xff, b / 0xff, a / 0xff;
end

function Color.fromString(s)
    if (type(s) ~= "string") then
        return nil;
    end

    if ((#s == 7 or #s == 9) and s[0] == "#") then
        local r = tonumber(strsub(s, 2, 3), 16);
        local g = tonumber(strsub(s, 4, 5), 16);
        local b = tonumber(strsub(s, 6, 7), 16);
        local a = tonumber(strsub(s, 8, 9) or "ff", 16);

        local color = Color:malloc();
        color._rgb = r * 0x10000 + g * 0x100 + b;
        color._a = a;
        return color;
    end
end

function Color.fromVertex(r, g, b, a)
    r = math.floor(r * 0xff);
    g = math.floor(g * 0xff);
    b = math.floor(b * 0xff);
    a = math.floor(a * 0xff);

    local color = Color:malloc();
    color._rgb = r * 0x10000 + g * 0x100 + b;
    color._a = a;
    return color;
end

_G.Color = Color;

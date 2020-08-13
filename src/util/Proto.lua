function getProto(self)
    return getmetatable(self).__index;
end

function setProto(self, super)
    return setmetatable(self, { __index = super });
end

-- ctor(o) as user-defined constructor
-- client would call malloc() to create instance
function newProto(super, ctor)
    local proto = {};
    setProto(proto, super);
    proto.__malloc = ctor;

    function proto:malloc()
        local o = {};
        setProto(o, self);

        local q = {};
        local p = getProto(o);
        while (p ~= nil) do
            table.insert(q, p);
            p = getProto(p);
        end
        while (#q > 0) do
            p = table.remove(q);
            local fn = rawget(p, "__malloc");
            if (type(fn) == "function") then
                fn(o);
            end
        end

        return o;
    end

    return proto;
end

--------

function table.clear(o)
    for k in next, o do
        rawset(o, k, nil);
    end
    return o;
end

function table.containsKey(o, key)
    return o[key] ~= nil;
end

function table.containsValue(o, value)
    for i, v in pairs(o) do
        if (v == value) then
            return true;
        end
    end
    return false;
end

function table.getOrAdd(o, key, value)
    if (o[key] == nil) then
        o[key] = value;
    end
    return o[key];
end

function table.keys(o)
    local keys = {};
    for k, v in pairs(o) do
        table.insert(keys, k);
    end
    return keys;
end

function table.merge(o, ...)
    local a = {...};
    for i = 1, #a do
        if type(a[i]) ~= "table" then
            error("E: invalid argument: expect a table");
        end
        for k, v in pairs(a[i]) do
            if o[k] == nil then
                o[k] = v;
            end
        end
    end
    return o;
end

function table.size(o)
    local n = 0;
    for k, v in pairs(o) do
        n = n + 1;
    end
    return n;
end

--------

_G.array = array or {};

array.clear = table.clear;

array.concat = function(a, a1)
    for _, v1 in ipairs(a1) do
        array.insert(a, v1);
    end
    return a;
end

array.contains = function(a, value)
    for i, v in ipairs(a) do
        if (v == value) then
            return true;
        end
    end
    return false;
end

array.foreach = function(a, callback)
    for i, v in ipairs(a) do
        callback(i, v);
    end
end;

array.insert = table.insert;

array.remove = table.remove;

array.size = table.getn;

array.join = table.concat;

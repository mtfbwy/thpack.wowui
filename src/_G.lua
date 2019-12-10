function table.keys(o)
    local keys = {};
    for k, v in pairs(o) do
        table.insert(keys, k);
    end
    return keys;
end

function table.merge(o, ...)
    local OVERWRITES = false;
    local a = {...};
    for i = 1, #a do
        if type(a[i]) ~= "table" then
            error("E: invalid argument: expect a table");
        end
        for k, v in pairs(a[i]) do
            if o[k] == nil or OVERWRITES then
                o[k] = v;
            end
        end
    end
    return o;
end

function table.containsValue(o, value)
    for i, v in pairs(o) do
        if (v == value) then
            return true;
        end
    end
    return false;
end

----------------

function getProto(self)
    return getmetatable(self).__index;
end

function setProto(self, super)
    return setmetatable(self, { __index = super });
end

function newProto(super, fn)
    local proto = {};
    setProto(proto, super);

    fn(proto);

    function proto:create()
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
            if (type(rawget(p, "__new")) == "function") then
                p.__new(o);
            end
        end

        return o;
    end

    return proto;
end

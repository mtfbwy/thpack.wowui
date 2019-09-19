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

----------------

function getProto(self)
    return getmetatable(self).__index;
end

function setProto(self, super)
    return setmetatable(self, { __index = super });
end

function newProto(super, ctor)
    local proto = {};
    setProto(proto, super);

    proto.__ctor = ctor;

    proto.create = function()
        local o = {};
        setProto(o, proto);

        local q = {};
        local p = getProto(o);
        while (p ~= nil) do
            table.insert(q, p);
            p = getProto(p);
        end
        while (#q > 0) do
            p = table.remove(q);
            if (type(rawget(p, "__ctor")) == "function") then
                p.__ctor(o);
            end
        end

        return o;
    end;

    return proto;
end

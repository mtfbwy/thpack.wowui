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

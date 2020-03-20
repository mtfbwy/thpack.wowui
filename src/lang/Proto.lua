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

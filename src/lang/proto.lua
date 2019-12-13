function getProto(self)
    return getmetatable(self).__index;
end

function setProto(self, super)
    return setmetatable(self, { __index = super });
end

-- client would define __onCreate for customized constructor
-- client would call malloc() to create instance
function newProto(super, fn)
    local proto = {};
    setProto(proto, super);

    fn(proto);

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
            if (type(rawget(p, "__onCreate")) == "function") then
                p.__onCreate(o);
            end
        end

        return o;
    end

    return proto;
end

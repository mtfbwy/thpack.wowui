function newClass(superClass, ctor)
    if (superClass ~= nil and type(superClass) ~= "table") then
        error(string.format("E: invalid argument: table expected"));
        return;
    end
    if (ctor ~= nil and type(ctor) ~= "function") then
        error(string.format("E: invalid argument: function expected"));
        return;
    end

    local Class = {};

    Class.ctor = ctor;

    Class.create = function(self, ...)
        local o = {};
        local stack = { Class };
        while (superClass ~= nil) do
            table.insert(stack, superClass);
            superClass = getmetatable(superClass).__index;
        end
        local args = { ... };
        while (#stack > 0) do
            local C = table.remove(stack);
            if (type(C.ctor) == "function") then
                C.ctor(o, ...);
            end
        end
        setmetatable(o, { __index = Class });
        return o;
    end;

    return Class;
end

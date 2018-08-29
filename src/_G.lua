---------------------
-- facility

function dummy()
    -- dummy
end

function logd(...)
    local a = { ... };
    if (#a == 0) then
        logi("-- 1 - nil: nil");
        return;
    end
    for i, v in pairs(a) do
        local vType = type(v);
        if (vType == "string" or vType == "number") then
            logi(string.format("-- %d - %s: %s", i, vType, tostring(v)));
        else
            logi(string.format("-- %d - %s", i, (tostring(v) or "N/A")));
        end
    end
end

function logi(...)
    (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage(...);
end

function newClass(superClass, ctor)
    if (type(superClass) ~= "nil" and type(superClass) ~= "table") then
        error(string.format("E: invalid argument: table expected"));
        return;
    end
    if (ctor == nil) then
        ctor = dummy;
    elseif (type(ctor) ~= "function") then
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

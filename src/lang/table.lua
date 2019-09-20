function table.clear(o)
    for k in next, o do
        rawset(o, k, nil);
    end
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

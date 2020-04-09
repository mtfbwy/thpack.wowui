_G.Table = {};

function Table.clear(o)
    for k in next, o do
        rawset(o, k, nil);
    end
    return o;
end
table.clear = Table.clear;

function Table.containsKey(o, key)
    return o[key] ~= nil;
end
table.containsKey = Table.containsKey;

function Table.containsValue(o, value)
    for i, v in pairs(o) do
        if (v == value) then
            return true;
        end
    end
    return false;
end
table.containsValue = Table.containsValue;

function Table.getOrAdd(o, key, value)
    if (o[key] == nil) then
        o[key] = value;
    end
    return o[key];
end
table.getOrAdd = Table.getOrAdd;

function Table.keys(o)
    local keys = {};
    for k, v in pairs(o) do
        table.insert(keys, k);
    end
    return keys;
end
table.keys = Table.keys;

function Table.merge(o, ...)
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
table.merge = Table.merge;

function Table.size(o)
    local n = 0;
    for k, v in pairs(o) do
        n = n + 1;
    end
    return n;
end
table.size = Table.size;

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

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
-- log

function logi(...)
    (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage(...);
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

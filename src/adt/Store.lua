Store = newProto(nil, function(self)
    self._store = {};
end);

function Store:get(key)
    return self._store[key];
end

function Store:put(key, value)
    local old = self._store[key];
    self._store[key] = value;
    return old;
end

function Store:contains(key)
    return self:get(key) ~= nil;
end

function Store:remove(key)
    local old = self._store[key];
    table.remove(self._store, key);
    return old;
end

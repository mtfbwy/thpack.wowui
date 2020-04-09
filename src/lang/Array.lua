_G.Array = {};

function Array.insert(a, i, value)
    return table.insert(a, i, value);
end

function Array.remove(a, i)
    return table.remove(a, i);
end

function Array.size(a)
    return #a;
end

function Array.join(a, sep, i, j)
    return table.concat(a, sep, i, j);
end

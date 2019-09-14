_G.P = (function()

    local generateModName = (function()
        local nameIndex = -1;
        return function()
            nameIndex = nameIndex + 1;
            return "noname-" .. nameIndex;
        end;
    end)();

    local modStore = Store:create();

    local mayReadyQueue = {};

    local dependencyMap = {
        -- blockerName = [ name, name, ... ]
    };

    local isExecuting = false;

    local execute = function()
        if (isExecuting) then
            return;
        end

        isExecuting = true;

        if (#mayReadyQueue == 0) then
            isExecuting = false;
            return;
        end

        local mod = table.remove(mayReadyQueue, 1);
        if (mod.statusCode == 200) then
            isExecuting = false;
            return;
        end

        -- verify upstream mods all executed and prepare args
        local blockerModResults = {};
        for i = 1, #mod.upstreamModNames do
            local blockerMod = modStore:get(mod.upstreamModNames[i]);
            if (blockerMod == nil or blockerMod.statusCode ~= 200) then
                isExecuting = false;
                return;
            end
            table.insert(blockerModResults, blockerMod.result);
        end

        if (type(mod.fn) == "function") then
            mod.result = mod.fn(unpack(blockerModResults)) or true;
        else
            mod.result = true;
        end
        mod.statusCode = 200;

        -- notify downstream mods
        for i, blockedModName in pairs(dependencyMap[mod.name] or {}) do
            mayReady(modStore:get(blockedModName));
        end

        isExecuting = false;
    end;

    local workTrigger = Timer:create()
        :schedule(execute, 25, 1000)
        :stop();

    local workThrottler = Timer:create()
        :schedule(function()
                workTrigger:stop();
            end, 4000, 1)
        :stop();

    function mayReady(mod)
        table.insert(mayReadyQueue, mod);
        if (not workThrottler:isRunning()) then
            workTrigger:reschedule();
            workThrottler:reschedule();
        else
            workThrottler:reschedule();
        end
    end

    function accept(modName, modFn, upstreamModNames)
        if (modStore:contains(modName)) then
            error(string.format("E: name conflict: [%s]", modName));
            return;
        end

        modStore:put(modName, {
            upstreamModNames = upstreamModNames or {},
            name = modName,
            fn = modFn,
            statusCode = 0, -- 0:created,200:OK,400:error
            result = nil
        });

        local mod = modStore:get(modName);

        for i = 1, #mod.upstreamModNames do
            local blockerModName = mod.upstreamModNames[i];
            if (dependencyMap[blockerModName] == nil) then
                dependencyMap[blockerModName] = {};
            end
            table.insert(dependencyMap[blockerModName], mod.name);
        end
        mayReady(mod);
    end

    local ask = function(...)
        local a = {...};
        return {
            answer = function(name, fn)
                if (name == nil) then
                    name = generateModName(); -- for debugging
                elseif (type(name) ~= "string") then
                    error(string.format("E: invalid argument: string expected"));
                    return;
                end

                if (fn ~= nil and type(fn) ~= "function") then
                    error(string.format("E: invalid argument: function expected"));
                    return;
                end

                accept(name, fn, a);
            end
        };
    end;

    -- tracking
    Timer:create():schedule(function()
        Timer:create():schedule(function()
            local blockedModNames = {};
            local modNames = table.keys(dependencyMap);
            for i = 1, #modNames do
                local modName = modNames[i];
                local mod = modStore:get(modName);
                if (mod == nil or mod.statusCode ~= 200) then
                    table.insert(blockedModNames, modName);
                end
            end
            if (#blockedModNames > 0) then
                logi(string.format("W: Not executed: %s", table.concat(blockedModNames, ", ")));
            end
        end, 1000, 12);
    end, 4000, 1);

    return {
        _version = 877,
        ask = ask
    };
end)(...);

if P then
    return;
end

----------------

_G.P = (function()

    local generateModName = (function()
        local nameIndex = -1;
        return function()
            nameIndex = nameIndex + 1;
            return "noname-" .. nameIndex;
        end;
    end)();

    local mods = {};

    local mayReadyModsQueue = {};

    local dependencyModNameTable = {
        -- upstreamModName = [ modName, modName, ... ]
    };

    local isExecuting = false;

    local execute = function()
        if (isExecuting) then
            return;
        end

        isExecuting = true;

        if (#mayReadyModsQueue == 0) then
            isExecuting = false;
            return;
        end

        local mod = table.remove(mayReadyModsQueue, 1);
        if (mod.statusCode == 200) then
            isExecuting = false;
            return;
        end

        -- verify upstream mods all executed and prepare args
        local blockerModResults = {};
        for i = 1, #mod.upstreamModNames do
            local blockerMod = mods[mod.upstreamModNames[i]];
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
        for i, blockedModName in pairs(dependencyModNameTable[mod.name] or {}) do
            mayReady(mods[blockedModName]);
        end

        isExecuting = false;
    end;

    local workTrigger = Timer:malloc()
        :schedule(execute, 60, 1000)
        :stop();

    local workThrottler = Timer:malloc()
        :schedule(function()
                workTrigger:stop();
            end, 4000, 1)
        :stop();

    function mayReady(mod)
        table.insert(mayReadyModsQueue, mod);
        if (not workThrottler:isRunning()) then
            workTrigger:reschedule();
            workThrottler:reschedule();
        else
            workThrottler:reschedule();
        end
    end

    function accept(modName, modFn, upstreamModNames)
        if (table.containsKey(mods, modName)) then
            error(string.format("E: name conflict: [%s]", modName));
            return;
        end

        mods[modName] = {
            upstreamModNames = upstreamModNames or {},
            name = modName,
            fn = modFn,
            statusCode = 0, -- 0:created,200:OK,400:error
            result = nil
        };

        local mod = mods[modName];

        for i = 1, #mod.upstreamModNames do
            local blockerModName = mod.upstreamModNames[i];
            if (dependencyModNameTable[blockerModName] == nil) then
                dependencyModNameTable[blockerModName] = {};
            end
            table.insert(dependencyModNameTable[blockerModName], mod.name);
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
    Timer:malloc():schedule(function()
        Timer:malloc():schedule(function()
            local blockedModNames = {};
            local modNames = table.keys(dependencyModNameTable);
            for i = 1, #modNames do
                local modName = modNames[i];
                local mod = mods[modName];
                if (mod == nil or mod.statusCode ~= 200) then
                    table.insert(blockedModNames, modName);
                end
            end
            if (#blockedModNames > 0) then
                A.logi(string.format("W: Not executed: %s", table.concat(blockedModNames, ", ")));
            end
        end, 1000, 12);
    end, 4000, 1);

    return {
        ask = ask
    };
end)(...);

----------------

(function()
    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_LOGIN");
    f:SetScript("OnEvent", function(self, eventName, ...)
        self:UnregisterEvent(eventName);
        P.ask().answer(eventName, nil);
    end);
end)();

----------------

P.ask().answer("cvar", function()

    SetCVar("screenshotQuality", 10);

    RegisterCVar("profanityFilter", 0);
    SetCVar("profanityFilter", 0);

    SetCVar("lootUnderMouse", 0);
    SetCVar("autoLootDefault", 1);
    SetCVar("autoLootRate", 0);
    SetCVar("autoOpenLootHistory", 0);

    SetCVar("alwaysShowActionBars", 1);

    SetCVar("nameplateMaxDistance", 50);
    SetCVar("nameplateOtherTopInset", GetCVarDefault("nameplateOtherTopInset"));
    SetCVar("nameplateOtherBottomInset", GetCVarDefault("nameplateOtherBottomInset"));

    RegisterCVar("targetNearestDistance", 50);
    SetCVar("targetNearestDistance", 50);
    RegisterCVar("targetNearestDistanceRadius", 50);
    SetCVar("targetNearestDistanceRadius", 50);

    RegisterCVar("CombatLogRangeCreature", 50);
    SetCVar("CombatLogRangeCreature", 50);
    RegisterCVar("CombatLogRangeHostilePlayers", 50);
    SetCVar("CombatLogRangeHostilePlayers", 50);

    -- enable name colored by class in chat frame
    SetCVar("chatClassColorOverride", 0);

    SetCVar("scriptErrors", 1);

    RegisterCVar("taintLog", 1);
    SetCVar("taintLog", 1);
end);

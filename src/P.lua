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
        :schedule(execute, 60, 1000)
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
        ask = ask
    };
end)(...);

----------------

(function()
    P.ask().answer("INVOLVED");

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_LOGIN");
    f:SetScript("OnEvent", function(self, eventName, ...)
        self:UnregisterEvent(eventName);
        P.ask().answer(eventName, nil);
    end);
end)();

----------------

P.ask("INVOLVED").answer("cvar", function()

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

    SetCVar("scriptErrors", 1);

    RegisterCVar("taintLog", 1);
    SetCVar("taintLog", 1);
end);

----------------

-- pixel perfect
P.ask("cvar").answer("pp", function()

    if (CONFIG == nil) then
        CONFIG = {};
    end

    local screenResolution;
    if (CONFIG.screenResolution ~= nil) then
        screenResolution = CONFIG.screenResolution;
        logi(string.format("[%s] loaded. (see %s)", screenResolution, "/screenResolution"));
    else
        -- once upon a time screenResolution is GetCVar("gxResolution")
        local possibleResolutions = { GetScreenResolutions() };
        local resolutionIndex = GetCurrentResolution();
        if (resolutionIndex <= 0) then
            resolutionIndex = 1;
        end
        screenResolution = possibleResolutions[resolutionIndex];
        logi(string.format("[%s] detected. (see %s)", screenResolution, "/screenResolution"));
    end

    local yResolution = tonumber(string.match(screenResolution, "%d+x(%d+)"));
    if (yResolution < 768) then
        logi(string.format("Y-Resolution has min value 768. [%s] ignored.", screenResolution));
        yResolution = 768;
    end

    -- canvas has default height 768 and forced to keep aspect ratio
    --      canvasHeight = 768 (point) / scale
    --      screenHeight = yResolution (pixel)
    --      =>  1 (pixel/point) = 768 / scale / yResolution
    -- scale can be uiScale or UIParent:GetEffectiveScale()
    -- uiScale must in [0.64, 1]
    -- effectiveScale has no limit but will not saved in config

    -- because of the system error from float to int, as long as 1 (pixel) != 1 (point), there must be pixel miss at somewhere
    -- and, too small a point is not friendly; 1/2/3/... (pixel/point) is acceptable
    --      => n (pixel/point) = n * 768 / scale / yResolution

    SetCVar("useUiScale", 0);

    local scale = math.floor(yResolution / 768) * 768 / yResolution;

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(self, event)
        UIParent:SetScale(scale);
        self:UnregisterAllEvents();
    end);

    local pointPerPixel = 768 / scale / yResolution;

    -- no "percentage" due to 100% x 100% is likely a square
    -- thus introduce dp: the screen height is forced 1024dp
    local pointPerDp =  yResolution / 1024;

    -- extra command for user to force his screen resolution
    A.addSlashCommand("thpackScreenResolution", "/screenResolution", function(x)
        if (x == nil or x == "") then
            logi("Pixel-perfect depends on screen resolution.");
            logi("  e.g. /screenResolution reset");
            logi("  e.g. /screenResolution 1024x768");
        elseif (x == "unset" or x == "reset" or x == "clear" or x == "nil") then
            CONFIG.screenResolution = nil;
            logi("Screen resolution is reset. The change will take effect after reload.");
        else
            CONFIG.screenResolution = x;
            logi(string.format("Screen resolution [%s] saved. The change will take effect after reload.", x));
        end
    end);

    -- keep 6 digits after the point
    function round6(number)
        return math.floor(number * 1000000 + 0.5) / 1000000;
    end

    return {
        px = round6(pointPerPixel),
        dp = round6(pointPerDp),
    };
end);

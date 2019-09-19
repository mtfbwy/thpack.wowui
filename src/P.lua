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
    local f = CreateFrame("frame");
    f:RegisterEvent("VARIABLES_LOADED");
    f:RegisterEvent("PLAYER_LOGIN");
    f:SetScript("OnEvent", function(self, eventName, ...)
        self:UnregisterEvent(eventName);
        P.ask().answer(eventName, nil);
    end);
end)();

----------------

P.ask("VARIABLES_LOADED").answer("cvar", function()

    SetCVar("screenshotQuality", 10);

    RegisterCVar("profanityFilter", 0);
    SetCVar("profanityFilter", 0);

    SetCVar("lootUnderMouse", 0);
    SetCVar("autoLootDefault", 1);
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

-- I am easily pleased with pixel-perfect art
P.ask("cvar").answer("pp", function()

    if (Config == nil) then
        Config = {};
    end

    local screenResolution;
    if (Config.screenResolution ~= nil) then
        screenResolution = Config.screenResolution;
        logi(string.format("Pixel perfect: Screen resolution [%s] loaded.", screenResolution));
    else
        -- once upon a time screenResolution is GetCVar("gxResolution")
        local possibleResolutions = { GetScreenResolutions() };
        local resolutionIndex = GetCurrentResolution();
        if (resolutionIndex <= 0) then
            resolutionIndex = 1;
        end
        screenResolution = possibleResolutions[resolutionIndex];
        logi(string.format("Pixel perfect: Screen resolution [%s] detected.", screenResolution));
    end
    logi(string.format("  Type \"%s\" to learn more.", "/screenResolution"));

    local screenHeight = tonumber(string.match(screenResolution, "%d+x(%d+)"));
    if (screenHeight < 768) then
        logi(string.format("  Screen height has min value 768. Screen resolution [%s] ignored.", screenResolution));
        screenHeight = 768;
    end

    -- UIParent is a canvas just fitting the screen; its aspect ratio always matches the screen's aspect ratio.
    -- effective scale affects the height value; when set to 1, the height value is 768
    -- and the width value is around 1366 in 16:9 screen.
    -- the formula:
    --      canvasHeight in point = screenHeight in pixel
    --      canvasHeight = 768 / uiScale
    --      =>  1 pixel/point = 768 / uiScale / screenHeight
    -- to let the value be 1, simply set uiScale = 768 / screenHeight

    -- but because of the system error from float to int, the drawer cannot always get perfect int pixels.
    -- as long as 1 pixel != 1 point, there must be pixel miss at somewhere.
    -- to make pixel perfect, i have to force uiScale:
    local uiScale = 768 / screenHeight;
    SetCVar("useUiScale", 1);
    SetCVar("uiScale", uiScale);

    -- Bliz UI always accept numbers in unit of points
    -- 1 (pixel) = 768 / uiScale / screenHeight (point)
    local pointPerPixel = 768 / uiScale / screenHeight;

    -- sometimes I need percentage, but always remember:
    -- 100percent x 100percent rectangle probably won't fill the whole screen
    local pointPerPercent = 768 / uiScale / 100;

    -- thus introduce dp.
    -- the screen height is fixed to 1024dp,
    -- independent of uiScale and won't connect to percentage.
    local pointPerDp =  768 / uiScale / 1024;

    -- extra command for user to force his screen resolution
    -- although it might be too late - every frame has been settled when UI accepts user's typing
    A.addSlashCommand("thpackScreenResolution", "/screenResolution", function(x)
        if (x == nil or x == "") then
            logi("Pixel-perfect art depends on screen resolution.");
            logi("  e.g. /screenResolution reset");
            logi("  e.g. /screenResolution 1024x768");
        elseif (x == "unset" or x == "reset" or x == "clear" or x == "nil") then
            Config.screenResolution = nil;
            logi("Screen resolution is reset. The change will take effect after reload.");
        else
            Config.screenResolution = x;
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

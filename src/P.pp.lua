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

    RegisterCVar("taintLog", 1);
    SetCVar("taintLog", 1);

    local uiScale = 0.85;
    SetCVar("useUiScale", 1);
    SetCVar("uiScale", uiScale);
end);

-- I am easily pleased with pixel-perfect art
P.ask("cvar").answer("pp", function()

    if (Config == nil) then
        Config = {};
    end

    local screenResolution;
    if (Config.screenResolution ~= nil) then
        screenResolution = Config.screenResolution;
        logi(string.format("Screen resolution [%s] loaded.", screenResolution));
    else
        -- once upon a time screenResolution is GetCVar("gxResolution")
        local possibleResolutions = { GetScreenResolutions() };
        local resolutionIndex = GetCurrentResolution();
        if (resolutionIndex <= 0) then
            resolutionIndex = 1;
        end
        screenResolution = possibleResolutions[resolutionIndex];
        logi(string.format("Screen resolution [%s] detected.", screenResolution));
    end
    logi(string.format("Type \"%s\" to learn more.", "/screenResolution"));

    local screenHeight = tonumber(string.match(screenResolution, "%d+x(%d+)"));
    if (screenHeight < 768) then
        logi(string.format("Screen height has min value 768. Screen resolution [%s] ignored.", screenResolution));
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

    -- more percisely, uiScale would be:
    -- self:GetScale() * self:GetParent():GetScale() * ... * UIParent():GetEffectiveScale()
    local uiScale = 1;
    if (GetCVar("useUiScale")) then
        uiScale = GetCVar("uiScale");
    end

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
    Addon.addSlashCommand("thpackScreenResolution", "screenResolution", function(x)
        if (x == nil or x == "") then
            logi("Pixel-perfect art depends on screen resolution.");
            logi("Usage: /screenResolution reset | <width>x<height>");
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

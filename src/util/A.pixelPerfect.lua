-- pixel perfect
(function()

    if (CONFIG == nil) then
        CONFIG = {};
    end

    local A = A or {
        -- add fake dependencies in case
        addSlashCommand = function() end,
        logi = function() end,
    };

    -- extra command for user to force his screen resolution
    A.addSlashCommand("thpackScreenResolution", "/screenResolution", function(x)
        if (x == nil or x == "") then
            A.logi("Pixel-perfect depends on screen resolution.");
            A.logi("  e.g. /screenResolution reset");
            A.logi("  e.g. /screenResolution 1024x768");
        elseif (x == "unset" or x == "reset" or x == "clear" or x == "nil") then
            CONFIG.screenResolution = nil;
            A.logi("Screen resolution is reset. The change will take effect after reload.");
        else
            CONFIG.screenResolution = x;
            A.logi(string.format("Screen resolution [%s] saved. The change will take effect after reload.", x));
        end
    end);

    local screenResolution;
    if (CONFIG.screenResolution ~= nil) then
        screenResolution = CONFIG.screenResolution;
        A.logi(string.format("pixel-perfect: [%s] loaded. (see %s)", screenResolution, "/screenResolution"));
    else
        -- once upon a time screenResolution is GetCVar("gxResolution")
        local possibleResolutions = { GetScreenResolutions() };
        local resolutionIndex = GetCurrentResolution();
        if (resolutionIndex == nil or resolutionIndex < 1) then
            resolutionIndex = 1;
        end
        screenResolution = possibleResolutions[resolutionIndex];
        A.logi(string.format("pixel-perfect: [%s] detected. (see %s)", screenResolution, "/screenResolution"));
    end

    local yResolution = tonumber(string.match(screenResolution, "%d+x(%d+)"));
    if (yResolution < 768) then
        A.logi(string.format("pixel-perfect: Y-Resolution has min value 768. [%s] ignored.", screenResolution));
        yResolution = 768;
    end

    -- point is the unit used by Blizzard UI
    -- canvas has default height 768 (point) and forced to keep aspect ratio
    --      canvasHeight = 768 (point) / scale
    --      screenHeight = yResolution (pixel)
    --      =>  1 (pixel/point) = 768 / scale / yResolution
    -- scale can be uiScale or UIParent:GetEffectiveScale()
    -- uiScale must in [0.64, 1]
    -- effectiveScale has no limit but will not saved in config

    -- prefer effectiveScale to uiScale
    SetCVar("useUiScale", 0);

    -- keep a point integer multiple of pixel
    local numPixelsPerPoint = math.floor(yResolution / 768 + 0.2);

    local f = CreateFrame("Frame");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:SetScript("OnEvent", function(self, event)
        self:UnregisterAllEvents();
        local scale = numPixelsPerPoint * 768 / yResolution;
        UIParent:SetScale(scale);
        A.logi(string.format("pixel-perfect: set: 1 (point) = %d (pixel)", numPixelsPerPoint));
        A.logi(string.format("pixel-perfect: set: scale = %.06f", scale));
    end);

    -- not use "percentage" because 100% x 100% is likely a square
    -- thus introduce dp: the screen height is forced 1024dp
    local numPointsPerDp = yResolution / numPixelsPerPoint / 1024;

    -- keep 6 digits after the point
    local function round6(number)
        return math.floor(number * 1000000 + 0.5) / 1000000;
    end

    -- Blizzard UI accepts points only. Convert all the units into points.
    A.px = round6(1 / numPixelsPerPoint);
    A.dp = round6(numPointsPerDp);
end)();

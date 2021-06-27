local addonName, addon = ...;
local A = addon.A;

----------------------------------------
-- pixel perfect

(function()

    WTF = WTF or {}; -- used to be saved variables

    -- extra command for user to force his client resolution
    -- this is necessary for those mods using A.px and A.dp
    A.addSlashCommand("thpackClientResolution", "/resolution", function(x)
        if (x == nil or x == "") then
            A.logi("Pixel-perfect depends on correct resolution.");
            A.logi("  e.g. /resolution reset");
            A.logi("  e.g. /resolution 1024x768");
        elseif (x == "unset" or x == "reset" or x == "clear" or x == "nil") then
            WTF.clientResolution = nil;
            A.logi("Resolution is reset. Reload to apply.");
        else
            WTF.clientResolution = x;
            A.logi(string.format("Resolution [%s] is saved. Reload to apply.", x));
        end
    end);

    local function getSavedClientResolution()
        if (WTF and WTF.clientResolution) then
            local clientResolution = WTF.clientResolution;
            A.logi(string.format("Resolution [%s] loaded. (see %s)", clientResolution, "/resolution"));
            return clientResolution;
        end
    end

    local function getClientResolution()
        -- once upon a time the resolution is GetCVar("gxResolution")
        local clientResolution;
        local index = GetCurrentResolution();
        if (index and index > 0) then
            clientResolution = select(index, GetScreenResolutions());
        else
            clientResolution = GetCVar("gxWindowedResolution");
        end
        A.logi(string.format("Resolution [%s] detected. (see %s)", clientResolution, "/resolution"));
        return clientResolution;
    end

    local function getClientHeight(clientResolution)
        return tonumber(string.match(clientResolution, "%d+x(%d+)"));
    end

    -- keep 6 digits after the decimal point
    local function round6(number)
        return math.floor(number * 1000000 + 0.5) / 1000000;
    end

    local function setup(clientResolution)
        -- Blizzard UI in unit of points
        -- canvas has default height of 768 points and is forced to keep aspect ratio
        -- when scaled:
        --  canvasHeight in points: 768 / scale
        --  clientHeight in pixels: clientHeight
        --  =>  1 (pixel/point) = 768 / scale / clientHeight

        local clientHeight = getClientHeight(clientResolution);

        -- essential! keep a point integer multiple of pixel
        local numPixelsPerPoint = math.floor(clientHeight / 768 + 0.2);
        if (numPixelsPerPoint == 0) then
            numPixelsPerPoint = 1;
        end

        A.numPixelsPerPoint = numPixelsPerPoint;

        A.scale = numPixelsPerPoint * 768 / clientHeight;

        A.px = round6(1 / numPixelsPerPoint);

        -- introduce dp: the client height is forced 1024dp
        A.dp = round6(clientHeight / numPixelsPerPoint / 1024);
    end

    -- not use UiScale cause it must be in [0.64, 1]
    SetCVar("useUiScale", 0);

    local f = CreateFrame("Frame", nil, nil, nil);
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("DISPLAY_SIZE_CHANGED");
    f:SetScript("OnEvent", function(self, event)
        if (event == "PLAYER_ENTERING_WORLD") then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
            setup(getSavedClientResolution() or getClientResolution());
        elseif (event == "DISPLAY_SIZE_CHANGED") then
            setup(getClientResolution());
        end
        UIParent:SetScale(A.scale);
        A.logi(string.format("set: 1 (point) => [%d] (pixel)", A.numPixelsPerPoint));
        A.logi(string.format("set: scale => [%.06f]", A.scale));
    end);
end)();

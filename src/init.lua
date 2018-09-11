--------------------
-- init

(function()
    local f = CreateFrame("frame");
    f:RegisterEvent("VARIABLES_LOADED");
    f:RegisterEvent("PLAYER_LOGIN");
    f:SetScript("OnEvent", function(self, eventName, ...)
        self:UnregisterEvent(eventName);
        P.ask().answer(eventName, nil);
    end);
end)();

P.ask("PLAYER_LOGIN").answer(nil, function()

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
end);

P.ask("VARIABLES_LOADED").answer("res", function(_)

    local resPath = "interface/addons/" .. P._name .. "/res";

    local TEXTURE = {
        SQUARE = resPath .. "/th-square", -- simple white square texture
        COMBOPOINT1 = resPath .. "/combopoint1",
        NORM1 = resPath .. "/norm1", -- norm: status bar texture
        GLOW1 = resPath .. "/glow1", -- glow: status bar shining
        HP = resPath .. "/th-hp",
    };

    local FONT = {
        DEFAULT = [[fonts\arkai_t.ttf]],
        COMBAT = [[fonts\arkai_c.ttf]],
        AVQEST = resPath .. "avqest.ttf",
        HOOGE0557 = resPath .. "hooge0557.ttf",
        LBRITED = resPath .. "lbrited.ttf",
    };

    local uiScale = 0.85;
    SetCVar("useUiScale", 1);
    SetCVar("uiScale", uiScale);

    _G["SLASH_thpackScreenHeight1"] = "/screenHeight";
    SlashCmdList["thpackScreenHeight"] = function(x)
        if (x == nil or x == "") then
            logi("Screen height is the number of pixels in y-axis, that is, the vertial value of screen resolution.");
            logi("Screen height affects pixel-perfect art like border size and insets.");
            logi("Usage: /screenHeight reset | <number>");
        elseif (x == "unset" or x == "reset" or x == "nil") then
            SCREEN_HEIGHT = nil;
            logi("Screen height reset. The change will take effect after reload.");
        elseif (tonumber(x) >= 768) then
            x = math.floor(tonumber(x));
            SCREEN_HEIGHT = x;
            logi(string.format("Screen height [%s] saved. The change will take effect after reload.", x));
        else
            logi(string.format("Screen height has min value 768. [%s] ignored.", x));
        end
    end;

    local screenHeight = 768;
    if SCREEN_HEIGHT ~= nil then
        screenHeight = SCREEN_HEIGHT;
        logi(string.format("Screen height [%s] loaded.", screenHeight));
    else
        local resolution = ({GetScreenResolutions()})[GetCurrentResolution()];
        screenHeight = string.match(resolution, "%d+x(%d+)");
        logi(string.format("Screen height [%s] detected.", screenHeight));
    end
    logi(string.format("Type \"%s\" to learn more.", "/screenHeight"));

    -- I am easily pleased with pixel art
    -- for tooltip I like 1 px border and 1 px margin
    -- but uiScale is magic
    -- when set to 1, UIParent's height appears 768
    -- and the width is on screen aspect ratio, i.e. in 16:9 machine it is around 1366
    -- then UIParent is the *canvas*
    -- note within canvas, all number's unit is anonymous, let's say it "dot"
    -- so it comes: 768 / uiScale (dot) == screenHeight (pixel)
    -- once upon a time screenHeight == string.match(GetCVar("gxResolution"), "%d+x(%d+)")
    -- but now I have to ask for it
    -- although it might be too late - every frame have been settled when user types something

    function round6(number)
        return math.floor(number * 1000000 + 0.5) / 1000000;
    end

    function dot2pixel(numDots)
        return numDots * screenHeight * uiScale / 768;
    end

    -- bliz UI recv number in unit of dot
    function pixel2dot(numPixels)
        -- more percisely, uiScale would be:
        -- self:GetScale() * self:GetParent():GetScale() * ... * UIParent():GetEffectiveScale()
        return numPixels * 768 / (uiScale * screenHeight);
    end

    -- sometimes I want to keep the ratio of size against the screen
    -- the ratio designed in a 1024-heighted *design canvas*
    -- the name, let's say dip
    function dip2dot(numDips)
        return numDips * 0.75 / uiScale; -- 768 / 1024 = 0.75
    end

    return {
        texture = TEXTURE,
        font = FONT,
        dot = 1, -- for anyone parenting to UIParent
        pixel = round6(pixel2dot(1)),
        dip = round6(dip2dot(1)),
    };
end);

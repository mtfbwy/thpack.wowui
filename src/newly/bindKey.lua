P.ask("VARIABLES_LOADED", "PLAYER_LOGIN").answer("bindKey", function()

    function clearAllOtherHotkeys(config)
        local modifiers = [[ctrl-:alt-:shift-:ctrl-shift-:]]
        local keys = [[button3:button4:mousewheelup:mousewheeldown]];
        keys = keys .. ":" .. [[0:1:2:3:4:5:6:7:8:9]];
        keys = keys .. ":" .. [[a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z]];
        keys = keys .. ":" .. [[tab:space:`:-:=:[:]:\:/:;:':,:.]];
        keys = keys .. ":" .. [[escape:f1:f2:f3:f4:f5:f6:f7:f8:f9:f10:f11:f12]];
        keys = keys .. ":" .. [[insert:delete:home:end:pageup:pagedown]];
        keys = keys .. ":" .. [[up:down:left:right]];
        keys = keys .. ":" .. [[numlock:numpadplus:numpadminus:numpadmultiply:numpaddivide:numpaddecimal]];
        keys = keys .. ":" .. [[numpad0:numpad1:numpad2:numpad3:numpad4:numpad5:numpad6:numpad7:numpad8:numpad9]];

        for k in string.gmatch(keys, "([^:]+)") do
            for m in string.gmatch(modifiers, "([^:]*)") do
                if (config[m .. k] == nil) then
                    config[m .. k] = "NONE";
                end
            end
        end
    end

    function setHotkeys(config)
        if (config == nil) then
            return;
        end
        for key, v in pairs(config) do
            SetBinding(string.upper(key), v);
        end
    end

    function saveHotkeys()
        local i = GetCurrentBindingSet();
        if i and (i == 1 or i == 2) then
            SaveBindings(i);
        end
    end

    local rawConfig = {
        any = {
            ["escape"] = "TOGGLEGAMEMENU",
            ["tab"] = "TARGETNEARESTENEMY",
            ["space"] = "JUMP",

            ["ctrl-mousewheelup"] = "CAMERAZOOMIN",
            ["ctrl-mousewheeldown"] = "CAMERAZOOMOUT",

            ["f2"] = "THPACK_TOGGLE_MAP",

            ["f8"] = "ALLNAMEPLATES",
            ["f9"] = "INTERACTTARGET",
            ["f10"] = "TOGGLEGAMEMENU",
            ["f11"] = "TOGGLECHARACTER4",
            ["shift-f11"] = "TOGGLELFGPARENT",
            ["f12"] = "macro macro",

            ["w"] = "MOVEFORWARD",
            ["a"] = "STRAFELEFT",
            ["s"] = "MOVEBACKWARD",
            ["d"] = "STRAFERIGHT",

            ["alt-w"] = "TOGGLEAUTORUN",
            ["alt-a"] = "PETATTACK",
            ["alt-s"] = "macro alt-s",
            ["alt-d"] = "macro alt-d",

            [";"] = "REPLY",
            ["shift-;"] = "REPLY2",
            ["'"] = "OPENALLBAGS",
            ["/"] = "OPENCHATSLASH",
            ["m"] = "TOGGLEWORLDMAP",

            ["1"] = "ACTIONBUTTON1",
            ["2"] = "ACTIONBUTTON2",
            ["3"] = "ACTIONBUTTON3",
            ["4"] = "ACTIONBUTTON4",
            ["5"] = "ACTIONBUTTON5",

            ["q"] = "MULTIACTIONBAR1BUTTON1",
            ["e"] = "MULTIACTIONBAR1BUTTON2",
            ["r"] = "MULTIACTIONBAR1BUTTON3",
            ["t"] = "MULTIACTIONBAR1BUTTON4",
            ["f"] = "MULTIACTIONBAR1BUTTON5",
            ["g"] = "MULTIACTIONBAR1BUTTON6",
            ["z"] = "MULTIACTIONBAR1BUTTON7",
            ["x"] = "MULTIACTIONBAR1BUTTON8",
            ["c"] = "MULTIACTIONBAR1BUTTON9",
            ["v"] = "MULTIACTIONBAR1BUTTON10",
            ["b"] = "MULTIACTIONBAR1BUTTON11",
            ["shift-s"] = "MULTIACTIONBAR1BUTTON12",

            ["button3"] = "macro m3",
            ["button4"] = "macro m4",
            ["mousewheelup"] = "macro m3f",
            ["mousewheeldown"] = "macro m3b",
        }
    };

    local config = (function()
        local classConfig = rawConfig[string.lower(select(2, UnitClass("player")))] or {};
        local config = {
            [0] = rawConfig.any,
            [1] = classConfig[1],
            [2] = classConfig[2],
            [3] = classConfig[3],
        };
        for k, v in pairs(classConfig[0] or {}) do
            config[0][k] = v;
        end

        clearAllOtherHotkeys(config[0]);

        rawConfig = nil;

        return config;
    end)();

    function setGeneralHotkeys()
        if (config[0] ~= nil) then
            setHotkeys(config[0]);
            saveHotkeys();
            config[0] = nil;
        end

        local school = GetSpecialization() or 0;
        if school > 0 then
            setHotkeys(config[school]);
            saveHotkeys();
        end
    end

    local enabled = false;

    local pending = nil;

    A.addSlashCommand("thpackBindKey", "/bindKey", function(x)
        if (x == "on") then
            enabled = true;
            if InCombatLockdown() then
                pending = 1;
            else
                pending = nil;
                setGeneralHotkeys();
            end
        elseif (x == "off") then
            enabled = false;
        else
            A.logi("Usage: /bindKey on | off");
        end
    end);

    local f = CreateFrame("frame");
    f:RegisterEvent("PLAYER_REGEN_ENABLED");
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");

    f:SetScript("OnEvent", function(self, event, ...)
        if (not enabled) then
            return;
        end
        -- Which event brings talents when login?
        -- 3.3: (PLAYER_TALENT_UPDATE) (PLAYER_LOGIN) PLAYER_ALIVE
        -- 4.1: PLAYER_TALENT_UPDATE
        if (event == "ACTIVE_TALENT_GROUP_CHANGED") then
            if (InCombatLockdown()) then
                pending = 1;
            else
                pending = nil;
                setGeneralHotkeys();
            end
        elseif (event == "PLAYER_REGEN_ENABLED") then
            if (pending) then
                pending = nil;
                setGeneralHotkeys();
            end
        end
    end);

    A.logi(string.format("bindKey loaded. Type \"%s\" to learn more.", "/bindKey"));
end);

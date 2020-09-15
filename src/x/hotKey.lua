(function()

    local raw = {
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

    local function getAllHotKeys(raw)
        local modifiers = [[ctrl-:alt-:shift-:ctrl-shift-:]]
        local keysString = [[button3:button4:mousewheelup:mousewheeldown]];
        keysString = keysString .. ":" .. [[0:1:2:3:4:5:6:7:8:9]];
        keysString = keysString .. ":" .. [[a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z]];
        keysString = keysString .. ":" .. [[tab:space:`:-:=:[:]:\:/:;:':,:.]];
        keysString = keysString .. ":" .. [[escape:f1:f2:f3:f4:f5:f6:f7:f8:f9:f10:f11:f12]];
        keysString = keysString .. ":" .. [[insert:delete:home:end:pageup:pagedown]];
        keysString = keysString .. ":" .. [[up:down:left:right]];
        keysString = keysString .. ":" .. [[numlock:numpadplus:numpadminus:numpadmultiply:numpaddivide:numpaddecimal]];
        keysString = keysString .. ":" .. [[numpad0:numpad1:numpad2:numpad3:numpad4:numpad5:numpad6:numpad7:numpad8:numpad9]];

        local allClearHotKeys = {};
        for k in string.gmatch(keysString, "([^:]+)") do
            for m in string.gmatch(modifiers, "([^:]*)") do
                allClearHotKeys[m .. k] = "NONE";
            end
        end

        local _, class = UnitClass("player");
        local classConfig = raw[class] or {};
        return {
            [0] = table.merge(allClearHotKeys, classConfig[0] or {}, raw["any"]),
            [1] = classConfig[1] or {},
            [2] = classConfig[2] or {},
            [3] = classConfig[3] or {},
        };
    end

    local function saveHotKeys()
        local i = GetCurrentBindingSet();
        if i and (i == 1 or i == 2) then
            SaveBindings(i);
        end
    end

    local function setAllHotKeys()
        local hotKeys = getAllHotKeys();

        for key, bindings in pairs(hotKeys[0] or {}) do
            SetBinding(string.upper(key), v);
        end
        --saveHotKeys();

        local school = GetSpecialization() or 0;
        if school > 0 then
            for key, bindings in pairs(hotKeys[0] or {}) do
                SetBinding(string.upper(key), v);
            end
            --saveHotKeys();
        end
    end

    local pending = nil;

    local f = CreateFrame("frame");
    --f:RegisterEvent("PLAYER_REGEN_ENABLED");
    --f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");

    f:SetScript("OnEvent", function(self, event, ...)
        -- Which event brings talents when login?
        -- 3.3: (PLAYER_TALENT_UPDATE) (PLAYER_LOGIN) PLAYER_ALIVE
        -- 4.1: PLAYER_TALENT_UPDATE
        if (event == "PLAYER_ENTERING_WORLD") then
            setAllHotKeys();
        end
    end);

    A.logi(string.format("Hot keys binded. loaded."));
end)();

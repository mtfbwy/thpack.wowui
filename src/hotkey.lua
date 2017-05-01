T.ask("VARIABLES_LOADED", "PLAYER_LOGIN", "env", "character").answer("hotkey", function(_, _, env, character)
    local rawConfig = {
        any = {
            ["escape"]  = "TOGGLEGAMEMENU",
            ["insert"]  = "FOCUSTARGET",
            ["space"]   = "JUMP",
            ["f9"]  = "INTERACTTARGET",
            ["f10"] = "TOGGLEGAMEMENU",
            ["f11"] = "TOGGLECHARACTER4",   ["shift-f11"]   = "TOGGLELFGPARENT",
            ["f12"] = "macro macro",
            ["tab"] = "TARGETNEARESTENEMY",
            ["1"]   = "ACTIONBUTTON1",
            ["2"]   = "ACTIONBUTTON2",
            ["3"]   = "ACTIONBUTTON3",
            ["4"]   = "ACTIONBUTTON4",
            ["5"]   = "ACTIONBUTTON5",
            ["w"]   = "MOVEFORWARD",    ["alt-w"]   = "TOGGLEAUTORUN",
            ["a"]   = "STRAFELEFT",     ["alt-a"]   = "PETATTACK",
            ["s"]   = "MOVEBACKWARD",   ["alt-s"]   = "macro alt-s",    ["shift-s"] = "macro shift-s",
            ["d"]   = "STRAFERIGHT",    ["alt-d"]   = "macro alt-d",
            [";"]   = "REPLY",          ["shift-;"] = "REPLY2",
            ["'"]   = "OPENALLBAGS",
            ["/"]   = "OPENCHATSLASH",
            ["m"]   = "TH_TOGGLE_MAP",  ["shift-m"] = "TOGGLEWORLDMAP",
            ["button3"] = "macro m3",
            ["button4"] = "macro m4",
            ["mousewheelup"]    = "macro m3f",      ["ctrl-mousewheelup"]   = "CAMERAZOOMIN",
            ["mousewheeldown"]  = "macro m3b",      ["ctrl-mousewheeldown"] = "CAMERAZOOMOUT",
            ["ctrl-v"]  = "ALLNAMEPLATES",
            ["q"]   = "MULTIACTIONBAR1BUTTON1",
            ["e"]   = "MULTIACTIONBAR1BUTTON2",
            ["r"]   = "MULTIACTIONBAR1BUTTON3",
            ["t"]   = "MULTIACTIONBAR1BUTTON4",
            ["f"]   = "MULTIACTIONBAR1BUTTON5",
            ["g"]   = "MULTIACTIONBAR1BUTTON6",
            ["z"]   = "MULTIACTIONBAR1BUTTON7",
            ["x"]   = "MULTIACTIONBAR1BUTTON8",
            ["c"]   = "MULTIACTIONBAR1BUTTON9",
            ["v"]   = "MULTIACTIONBAR1BUTTON10",
            ["b"]   = "MULTIACTIONBAR1BUTTON11",
        }
    };

    local config = (function()
        local classConfig = rawConfig[character.class] or {};
        local config = {
            [0] = rawConfig.any,
            [1] = classConfig[1] or {},
            [2] = classConfig[2] or {},
            [3] = classConfig[3] or {},
        };
        for k, v in pairs(classConfig[0] or {}) do
            config[0][k] = v;
        end

        if (GetBindingByKey("8") ~= nil) then
            -- clear all other key binding
            local modifiers = [[ctrl-:alt-:shift-:ctrl-shift-:]]
            local keys = [[button3:button4:mousewheelup:mousewheeldown]];
            keys = keys .. ":" .. [[0:1:2:3:4:5:6:7:8:9]];
            keys = keys .. ":" .. [[a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:x:y:z]];
            keys = keys .. ":" .. [[tab:space:`:-:=:[:]:\:/:;:':,:.]];
            keys = keys .. ":" .. [[escape:f1:f2:f3:f4:f5:f6:f7:f8:f9:f10:f11:f12]];
            keys = keys .. ":" .. [[insert:delete:home:end:pageup:pagedown]];
            keys = keys .. ":" .. [[up:down:left:right]];
            keys = keys .. ":" .. [[numlock:numpadplus:numpadminus:numpadmultiply:numpaddivide:numpaddecimal]];
            keys = keys .. ":" .. [[numpad0:numpad1:numpad2:numpad3:numpad4:numpad5:numpad6:numpad7:numpad8:numpa    d9]];

            -- using table instead string.gmatch would be a bit faster, but less grace
            for k in string.gmatch(keys, "([^:]+)") do
                for m in string.gmatch(modifiers, "([^:]*)") do
                    if (config[0][m .. k] == nil) then
                        config[0][m .. k] = "NONE";
                    end
                end
            end
        end

        rawConfig = nil;

        return config;
    end)();

    local function saveBinding()
        local i = GetCurrentBindingSet();
        if i and (i == 1 or i == 2) then
            SaveBindings(i);
        end
    end

    local function bindKeys(map)
        for key, v in pairs(map) do
            SetBinding(string.upper(key), v);
        end
    end

    local function bindCommon()
        bindKeys(config[0]);
        saveBinding();
        config[0] = nil;
        --collectgarbage("collect");
    end

    local function bindTalent()
        local school = GetSpecialization() or 0;
        if school > 0 then
            bindKeys(config[school]);
            saveBinding();
        end
    end

    local pendingCommon = nil;
    local pendingTalent = nil;

    if InCombatLockdown() then
        pendingCommon = 1;
        pendingTalent = 1;
    else
        bindCommon();
        bindTalent();
    end

    local f = CreateFrame("frame");
    f:RegisterEvent("PLAYER_REGEN_ENABLED");
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");

    f:SetScript("OnEvent", function(self, event, ...)
        -- Which event brings talents when login?
        -- 3.3: (PLAYER_TALENT_UPDATE) (PLAYER_LOGIN) PLAYER_ALIVE
        -- 4.1: PLAYER_TALENT_UPDATE
        if (event == "ACTIVE_TALENT_GROUP_CHANGED") then
            if (InCombatLockdown()) then
                pendingTalent = 1;
            else
                bindTalent();
                pendingTalent = nil;
            end
        elseif (event == "PLAYER_REGEN_ENABLED") then
            if (pendingCommon) then
                bindCommon();
                pendingCommon = nil;
            end
            if (pendingTalent) then
                bindTalent();
                pendingTalent = nil;
            end
        end
    end);
end);

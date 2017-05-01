_G["tmerge"] = function(...)
    local args = {...};
    local merged = {};
    for i = 1, #args do
        local t = args[i];
        if (type(t) ~= "table") then
            error("E: invalid argument: expect a table");
        end
        for k, v in pairs(t) do
            merged[k] = v;
        end
    end
    return merged;
end

------------------------------------------------------------
-- framework

_G["T"] = (function(NAME)
    local VERSION = "1.1.3";

    local evMappin = {
        -- "id" = ev
    };

    function getEv(id)
        return evMappin[id];
    end

    function setEv(ev)
        evMappin[ev.id] = ev;
    end

    -- overall ticker and async holder
    local f = CreateFrame("frame");

    -- the start point
    f:RegisterEvent("VARIABLES_LOADED");
    f:RegisterEvent("PLAYER_LOGIN");
    f:SetScript("OnEvent", function(self, event, ...)
        self:UnregisterEvent(event);
        ask().answer(event);
    end);

    local looper = (function()
        local queuing = {
            -- ev, ev, ...
        };

        local blocked = {
            -- blocking.id = [ blocked.id, blocked.id, ... ]
        };

        local isCalculating = false;

        function awake()
            if (f:GetScript("OnUpdate") == nil) then
                f:SetScript("OnUpdate", function(self, elapsed)
                    if (isCalculating) then
                        return
                    end
                    isCalculating = true;
                    pickAndCalc();
                    if (#queuing == 0) then
                        sleep();
                    end
                    isCalculating = false;
                end);
            end
        end

        function sleep()
            f:SetScript("OnUpdate", nil);
        end

        function pickAndCalc()
            local ev = tremove(queuing, 1);
            if (ev.fn ~= nil) then
                local formerResults = {};
                for i = 1, #ev.formers do
                    local formerEv = getEv(ev.formers[i]);
                    formerResults[i] = formerEv.result;
                end
                ev.result = ev.fn(unpack(formerResults)) or {};
            else
                ev.result = {};
            end
            if (blocked[ev.id] ~= nil) then
                for i, blockedEvId in pairs(blocked[ev.id]) do
                    local blockedEv = getEv(blockedEvId);
                    blockedEv.numWaiting = blockedEv.numWaiting - 1;

                    if (blockedEv.numWaiting == 0) then
                        markQueuing(blockedEv);
                    end
                end
                blocked[ev.id] = nil;
            end
        end

        function markQueuing(ev)
            tinsert(queuing, ev);
            awake();
        end

        function accept(id)
            local ev = getEv(id);
            for i = 1, #ev.formers do
                local formerId = ev.formers[i];
                local formerEv = getEv(formerId);
                if (formerEv == nil or formerEv.result == nil) then
                    if (not blocked[formerId]) then
                        blocked[formerId] = {};
                    end
                    tinsert(blocked[formerId], ev.id);
                    ev.numWaiting = ev.numWaiting + 1;
                end
            end
            if (ev.numWaiting == 0) then
                markQueuing(ev);
            end
        end;

        return {
            accept = accept
        };
    end)();

    local runningNumber = 0;
    function genId()
        runningNumber = runningNumber + 1;
        return "ev-" .. runningNumber;
    end;

    function ask(...)
        local formerIds = {...};

        -- Mappin answer(String evId, Callable callback);
        -- Mappin answer(String evId);
        -- Mappin answer(Callable callback);
        function answer(evId, callback)
            if (type(evId) ~= "string") then
                callback = evId;
                evId = genId();
            end
            if (getEv(evId) ~= nil) then
                error(string.format("E: invalid argument: framework: [%s] exists already", evId));
                return;
            end
            setEv({
                id = evId,
                fn = callback,
                formers = formerIds,
                numWaiting = 0,
                result = nil
            });
            looper.accept(evId);
        end;

        return {
            answer = answer
        };
    end;

    return {
        name = NAME,
        version = VERSION,
        ask = ask
    };
end)(...);

-- enabling logger
_G["L"] = (function()
    function loge(message, modName, methodName)
        modName = modName or "Noname";
        methodName = methodName or "noname";
        message = message .. "@" .. modName .. "." .. methodName;
        error(message);
    end

    function logi(...)
        (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage(...);
    end

    function logd(...)
        local vector = { ... };
        if (#vector == 0) then
            logi("-- 1 - nil: nil");
            return;
        end
        for i, v in pairs(vector) do
            local vType = type(v);
            if (vType == "string" or vType == "number") then
                logi(string.format("-- %d - %s: %s", i, vType, tostring(v)));
            else
                logi(string.format("-- %d - %s", i, (tostring(v) or "N/A")));
            end
        end
    end

    return {
        logi = logi,
        logd = logd,
        loge = loge,
    };
end)();

-- enabling console
(function()
    _G["SLASH_thDebug1"] = "/debug";
    SlashCmdList["thDebug"] = function(x)
        L.logi("-------- printing: " .. x);
        L.logd(loadstring("return " .. x)());
    end;

    _G["SLASH_thReload1"] = "/reload";
    SlashCmdList["thReload"] = ReloadUI;
end)();

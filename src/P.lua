--------------------
-- framework

_G["P"] = (function(NAME)

    local VERSION = 873;

    local genName = (function()
        local i = -1;
        return function()
            i = i + 1;
            return "noname-" .. i;
        end;
    end)();

    local store = Store:create();

    local accept = (function()

        local readys = {};

        local blockers = {
            -- blockerName = [ name, name, ... ]
        };

        local isWorking = false;

        function work()
            if (isWorking) then
                return;
            end
            if (#readys == 0) then
                return;
            end
            isWorking = true;

            local o = table.remove(readys, 1);
            local blockerResults = {};
            for i = 1, #o.blockerNames do
                local blocker = store:get(o.blockerNames[i]);
                blockerResults[i] = blocker.result;
            end
            o.result = o.fn(unpack(blockerResults)) or {};

            for i, blockedName in pairs(blockers[o.name] or {}) do
                local blocked = store:get(blockedName);
                blocked.p = blocked.p - 1;
                if (blocked.p == 0) then
                    markReady(blocked);
                end
            end
            blockers[o.name] = nil;

            isWorking = false;
        end

        local workTrigger = Timer:create()
            :schedule(work, 25, 1000)
            :stop();

        local workThrottler = Timer:create()
            :schedule(function()
                    workTrigger:stop();
                end, 4000, 1)
            :stop();

        function markReady(o)
            table.insert(readys, o);
            if (not workThrottler:isRunning()) then
                workTrigger:reschedule();
                workThrottler:reschedule();
            else
                workThrottler:reschedule();
            end
        end

        function accept(name)
            local o = store:get(name);
            for i = 1, #o.blockerNames do
                local blockerName = o.blockerNames[i];
                local blocker = store:get(blockerName);
                if (blocker == nil or blocker.result == nil) then
                    if (blockers[blockerName] == nil) then
                        blockers[blockerName] = {};
                    end
                    table.insert(blockers[blockerName], o.name);
                    o.p = o.p + 1;
                end
            end
            if (o.p == 0) then
                markReady(o);
            end
        end

        Timer:create():schedule(function()
            local isLogging = false;
            Timer:create():schedule(function()
                local blockerSize = 0;
                for i, v in pairs(blockers) do
                    blockerSize = blockerSize + 1;
                end
                if (blockerSize > 0 or isLogging) then
                    logi("W: [" .. blockerSize .. "] blockers remaining");
                end
                local readysSize = #readys;
                if (readysSize > 0 or isLogging) then
                    logi("W: [" .. readysSize .. "] readys remaining");
                end
                isLogging = blockerSize > 0 or readysSize > 0;
            end, 1000, 12);
        end, 4000, 1);

        return accept;
    end)();

    function ask(...)
        local a = {...};
        return {
            answer = function(name, fn)
                if (name == nil) then
                    name = genName();
                elseif (type(name) ~= "string") then
                    error(string.format("E: invalid argument: String expected"));
                    return;
                elseif (store:contains(name)) then
                    error(string.format("E: name conflict: [%s] already exists", name));
                    return;
                end
                if (fn == nil) then
                    fn = dummy;
                elseif (type(fn) ~= "function") then
                    error(string.format("E: invalid argument: function expected"));
                    return;
                end
                store:put(name, {
                    blockerNames = a or {},
                    name = name,
                    fn = fn,
                    p = 0,
                    result = nil
                });
                accept(name);
            end
        };
    end;

    return {
        _name = NAME,
        _version = VERSION,
        ask = ask
    };
end)(...);

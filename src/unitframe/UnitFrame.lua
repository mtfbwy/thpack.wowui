T.ask("unitframe.Portrait", "unitframe.HpBar", "unitframe.MpBar", "unitframe.CastingBar")
    .answer("unitframe.UnitFrame", function(Portrait, HpBar, MpBar, CastingBar)

    local p = {};

    function p.addSubscriber(uf, subscriber, typeName)
        subscriber.events = subscriber.events or {};

        local Adt = nil;
        if type(typeName) == "string" then
            if typeName == "Portrait" then
                Adt = Portrait;
            elseif typeName == "HpBar" then
                Adt = HpBar;
            elseif typeName == "MpBar" then
                Adt = MpBar;
            elseif typeName == "CastingBar" then
                Adt = CastingBar;
            end
            if Adt == nil then
                L.logi("E: invalid subscriber type: [" .. (typeName or "(nil)") .. "]");
                return;
            end
        elseif type(typeName) == "table" then
            Adt = typeName;
        end
        if Adt ~= nil then
            table.merge(subscriber, Adt.p);
            table.merge(subscriber.events, Adt.events);
        end

        table.insert(uf.subscribers, subscriber);
        if subscriber.events["OnCreate"] then
            subscriber.events["OnCreate"](subscriber);
        end
    end

    function p.onEvent(uf, event, ...)
        local handled = false;
        for i in pairs(uf.subscribers) do
            local subscriber = uf.subscribers[i];
            if subscriber.events[event] then
                handled = subscriber.events[event](subscriber, ...) or handled;
            end
        end
        -- if not handled then
        --     L.logi("E: not handled event: [" .. event .. "]");
        -- end
    end

    function p.start(uf)
        -- for i, scriptName in pairs { "OnMouseUp", "OnMouseDown", "OnEnter", "OnLeave" } do
        --     uf:HookScript(scriptName, function(self, ...)
        --         self:onEvent(scriptName, ...);
        --     end);
        -- end
        for i in pairs(uf.subscribers) do
            local subscriber = uf.subscribers[i];
            for k in pairs(subscriber.events or {}) do
                uf:RegisterEvent(k);
            end
        end
        uf:SetScript("OnEvent", uf.onEvent);

        uf:SetScript("OnUpdate", function(uf, elapsed)
            uf:onEvent("OnTick", elapsed);
        end);
    end

    return {
        p = p,
    };
end);

T.ask("widget.Color").answer("unitframe.HpBar", function(Color)

    function isApplicable(hpBar)
        return hpBar and hpBar:GetObjectType() == "StatusBar"
            and hpBar.m and hpBar.m.unit;
    end

    local p = {};

    function p.updateValue(hpBar, unit)
        local hp = UnitHealth(unit) or 0;
        local hpMax = UnitHealthMax(unit) or 1;
        local hpRatio = hp / hpMax;

        hpBar:SetValue(hpRatio);

        if hpBar.text then
            if hpRatio < 0.1 or hpRatio > 0.95 then
                hpBar.text:SetText(hp);
            else
                hpBar.text:SetFormattedText("%.1d%%", hpRatio);
            end
        end
    end

    p.refresh = p.updateValue;

    local callback = {};

    local function checkEventUnit(hpBar, eventUnit)
        return eventUnit and string.lower(eventUnit) == hpBar.m.unit;
    end

    function callback.onUpdateValue(hpBar, eventUnit)
        if checkEventUnit(hpBar, eventUnit) then
            hpBar:updateValue(eventUnit);
        end
    end

    local events = {
        ["UNIT_HEALTH"] = callback.onUpdateValue,
        ["UNIT_HEALTH_FREQUENT"] = callback.onUpdateValue,
        ["UNIT_MAXHEALTH"] = callback.onUpdateValue,
    };

    return {
        p = p,
        events = events,
    };
end);

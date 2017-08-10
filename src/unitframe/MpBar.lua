T.ask("widget.Color").answer("unitframe.MpBar", function(Color)

    local p = {};

    function p.updateValue(mpBar, unit)
        local powerType = UnitPowerType(unit);
        local mp = UnitPower(unit, powerType);
        local mpMax = UnitPowerMax(unit, powerType);
        mpBar:SetValue(mp / mpMax);
    end

    function p.updateColor(mpBar, unit)
        local powerType = UnitPowerType(unit);
        mpBar:SetStatusBarColor(Color.toVertex(Color.fromPowerType(powerType)));
    end

    function p.refresh(mpBar, unit)
        mpBar:updateValue(unit);
        mpBar:updateColor(unit);
    end

    local callback = {};

    local function checkEventUnit(mpBar, eventUnit)
        return eventUnit and string.lower(eventUnit) == mpBar.m.unit;
    end

    function callback.onUpdateValue(mpBar, eventUnit)
        if checkEventUnit(mpBar, eventUnit) then
            mpBar:updateValue(eventUnit);
        end
    end

    function callback.onUpdateColor(mpBar, eventUnit)
        if checkEventUnit(mpBar, eventUnit) then
            mpBar:updateColor(eventUnit);
        end
    end

    local events = {
        ["UNIT_POWER"] = callback.onUpdateValue,
        ["UNIT_POWER_FREQUENT"] = callback.onUpdateValue,
        ["UNIT_MAXPOWER"] = callback.onUpdateValue,
        ["UNIT_DISPLAYPOWER"] = callback.onUpdateColor,
    };

    return {
        p = p,
        events = events,
    };
end);

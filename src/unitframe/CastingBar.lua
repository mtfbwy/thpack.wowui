T.ask("widget.Color", "widget.Image").answer("unitframe.CastingBar", function(Color, Image)

    local p = {};

    function p.clear(castingBar)
        castingBar.m.spellId = nil;
        castingBar.m.elapsed = 0;
        castingBar.m.total = 0;
        castingBar.m.isChanneling = false;
        castingBar.m.notInterruptible = false;
        castingBar:Hide();
        if castingBar.text then
            castingBar.text:SetText(nil);
        end
        if castingBar.nameText then
            castingBar.nameText:SetText(nil);
        end
        if castingBar.icon then
            castingBar.icon:SetTexture(nil);
        end
    end

    function p.updateValue(castingBar)
        -- TODO when channeling, the void increasing and the active texture is in the right
        local elapsed = castingBar.m.elapsed;
        local total = castingBar.m.total;
        local isChanneling = castingBar.m.isChanneling;
        if elapsed >= total then
            castingBar:clear()
        else
            if isChanneling then
                castingBar:SetValue(1 - elapsed / total);
            else
                castingBar:SetValue(elapsed / total);
            end
            if castingBar.text then
                castingBar.text:SetFormattedText("%.1f", total - elapsed);
            end
            castingBar:Show();
        end
    end

    local colorOnCastingStart = "gold";
    local colorOnCastingEnd = "green";
    local colorOnCastingInterrupted = "red";
    local colorOnCastingNotInterruptible = Color.fromVertex(0.7, 0.7, 0.7);
    local colorOnChanneling = "green";

    function p.updateColor(castingBar, notInterruptible)
        local isChanneling = castingBar.m.isChanneling;
        if notInterruptible == nil then
            notInterruptible = castingBar.m.notInterruptible;
        else
            castingBar.m.notInterruptible = notInterruptible;
        end
        local color = colorOnCastingStart;
        if notInterruptible then
            color = colorOnCastingNotInterruptible;
        elseif isChanneling then
            color = colorOnChanneling;
        end
        castingBar:SetStatusBarColor(Color.toVertex(color));
    end

    local function onUpdate(castingBar, elapsed)
        castingBar.m.elapsed = castingBar.m.elapsed + elapsed;
        if castingBar.m.elapsed >= castingBar.m.total then
            castingBar:SetScript("OnUpdate", nil);
        end
        castingBar:updateValue();
    end

    function p.refresh(castingBar, unit)
        local isChanneling = false;
        local name, _, _, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
        if not startTime or not endTime then
            name, _, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
            if not startTime or not endTime then
                -- in case the last target is casting
                castingBar:clear();
                return;
            end
            isChanneling = true;
        end

        castingBar:Show();

        startTime = startTime / 1000;
        local elapsed = GetTime() - startTime;
        local total = endTime / 1000 - startTime;

        castingBar.m.spellId = select(7, GetSpellInfo(name));
        castingBar.m.elapsed = elapsed;
        castingBar.m.total = total;
        castingBar.m.isChanneling = isChanneling;
        castingBar.m.notInterruptible = notInterruptible;

        if elapsed < total then
            if castingBar.icon then
                Image.p.setImage(castingBar.icon, texture);
            end
            if castingBar.nameText then
                castingBar.nameText:SetText(name);
            end
            castingBar:updateColor(false);
        end

        castingBar:SetScript("OnUpdate", onUpdate);
    end

    local callback = {};

    local function checkEventUnit(castingBar, eventUnit)
        return eventUnit and string.lower(eventUnit) == castingBar.m.unit;
    end

    function callback.onRefresh(castingBar, eventUnit)
        if checkEventUnit(castingBar, eventUnit) then
            castingBar:refresh(eventUnit);
        end
    end

    function callback.onEnd(castingBar, eventUnit)
        if checkEventUnit(castingBar, eventUnit) then
            if castingBar.m.total then
                castingBar.m.elapsed = castingBar.m.total;
            end
        end
    end

    local events = {
        ["UNIT_SPELLCAST_START"] = callback.onRefresh,
        ["UNIT_SPELLCAST_FAILED"] = callback.onRefresh,
        ["UNIT_SPELLCAST_INTERRUPTED"] = callback.onEnd,
        ["UNIT_SPELLCAST_INTERRUPTIBLE"] = callback.onRefresh,
        ["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = callback.onRefresh,
        ["UNIT_SPELLCAST_DELAYED"] = callback.onRefresh,
        ["UNIT_SPELLCAST_STOP"] = callback.onEnd,
        ["UNIT_SPELLCAST_CHANNEL_START"] = callback.onRefresh,
        ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = callback.onRefresh,
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = callback.onEnd,
    };

    return {
        p = p,
        events = events,
    };
end);

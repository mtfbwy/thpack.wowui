T.ask("env", "api", "Bar", "ClassIcon", "UnitFrame").answer("unitFrames", function(
        env, api, Bar, ClassIcon, UnitFrame)

    local function onCastingUpdate(unitFrame, elapsed)
        unitFrame.m.elapsed = unitFrame.m.elapsed + elapsed;
        if unitFrame.m.elapsed >= unitFrame.m.total then
            unitFrame:SetScript("OnUpdate", nil);
        end
        Bar.updateCastingBar(
                unitFrame.barFrame.castingBar,
                unitFrame.m.elapsed,
                unitFrame.m.total,
                unitFrame.m.isChannelling);
    end

    local function onCastingStart(unitFrame, unit)
        if not unit or string.lower(unit) ~= unitFrame.m.unit then
            return;
        end
        local elapsed, total, isChannelling =
                Bar.initializeCastingBar(unitFrame.barFrame.castingBar, unitFrame.m.unit);
        if elapsed == nil then
            return;
        end
        unitFrame.m.elapsed = elapsed;
        unitFrame.m.total = total;
        unitFrame.m.isChannelling = isChannelling;
        unitFrame:SetScript("OnUpdate", onCastingUpdate);
    end

    local function onCastingEnd(unitFrame, unit)
        if not unit or string.lower(unit) ~= unitFrame.m.unit then
            return;
        end
        if unitFrame.m.total then
            unitFrame.m.elapsed = unitFrame.m.total;
        end
    end

    local function onChangeTarget(unitFrame)
        if unitFrame.m.unit ~= "target" then
            return;
        end
        UnitFrame.update(unitFrame, "target");
    end

    local function onUpdatePortrait(unitFrame, unit)
        if not unit or unitFrame.m.unit ~= string.lower(unit) then
            return;
        end
        UnitFrame.updatePortrait(unitFrame, unitFrame.m.unit);
    end

    local function onUpdateHp(unitFrame, unit)
        if not unit or unitFrame.m.unit ~= string.lower(unit) then
            return;
        end
        Bar.updateHpBar(unitFrame.barFrame.hpBar, unitFrame.m.unit);
    end

    local function onUpdateMp(unitFrame, unit)
        if not unit or unitFrame.m.unit ~= string.lower(unit) then
            return;
        end
        Bar.updateMpBar(unitFrame.barFrame.mpBar, unitFrame.m.unit);
    end

    local events = {
        ["UNIT_SPELLCAST_START"] = onCastingStart,
        ["UNIT_SPELLCAST_FAILED"] = onCastingStart,
        ["UNIT_SPELLCAST_INTERRUPTED"] = onCastingEnd,
        ["UNIT_SPELLCAST_INTERRUPTIBLE"] = function(unitFrame, unit)
            if not unit or string.lower(unit) ~= unitFrame.m.unit then
                return;
            end
            Bar:setCastingBarShielded(unitFrame.barFrame.castingBar, false);
        end,
        ["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = function(unitFrame, unit)
            if not unit or string.lower(unit) ~= unitFrame.m.unit then
                return;
            end
            Bar:setCastingBarShielded(unitFrame.barFrame.castingBar, true);
        end,
        ["UNIT_SPELLCAST_DELAYED"] = onCastingStart,
        ["UNIT_SPELLCAST_STOP"] = onCastingEnd,
        ["UNIT_SPELLCAST_CHANNEL_START"] = onCastingStart,
        ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = onCastingStart,
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = onCastingEnd,

        ["PLAYER_ENTERING_WORLD"] = onChangeTarget,
        ["PLAYER_TARGET_CHANGED"] = onChangeTarget,
        ["PARTY_MEMBER_ENABLE"] = onUpdatePortrait,
        ["UNIT_CONNECTION"] = onChangeTarget,
        ["UNIT_HEALTH_FREQUENT"] = onUpdateHp,
        ["UNIT_MAXHEALTH"] = onUpdateHp,
        ["UNIT_POWER"] = onUpdateMp,
        ["UNIT_POWER_BAR_SHOW"] = onUpdateMp,
        ["UNIT_POWER_BAR_HIDE"] = onUpdateMp,
        ["UNIT_DISPLAYPOWER"] = onUpdateMp,
        ["UNIT_MAXPOWER"] = onUpdateMp,
        ["UNIT_PORTRAIT_UPDATE"] = onUpdatePortrait,
        ["UNIT_MODEL_CHANGED"] = onUpdatePortrait,
    };

    local function createTargetFrame()
        local unit = "target";
        local unitFrame = UnitFrame.create(UIParent);
        unitFrame.m = { unit = unit, };
        api.attachEvents(unitFrame, events);
        unitFrame:SetPoint("bottom", 0, 240 * env.dotsRelative);

        unitFrame.imageFrame:SetScript("OnEnter", function(self)
            if InCombatLockdown() then
                return;
            end
            if ClassIcon.update(self.classIcon, unit) then
                self.classIcon:Show();
            else
                self.classIcon:Hide();
            end
        end);

        unitFrame.imageFrame.classIcon:SetScript("OnLeave", function(self)
            self:Hide();
        end);

        unitFrame.imageFrame.classIcon:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                local unit = "target";
                if UnitIsPlayer(unit) and not UnitCanAttack("player", unit) then
                    if InspectFrame and InspectFrame:IsShown() then
                        InspectFrame:Hide();
                    else
                        InspectUnit(unit);
                    end
                end
            end
        end);

        unitFrame:Hide();

        return unitFrame;
    end

    local targetFrame = createTargetFrame();
    onChangeTarget(targetFrame); -- in case player has selected a target
end);

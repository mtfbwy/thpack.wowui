-- it is a demo of war3 hero layout
P.ask("pp", "A.Frame").answer("HeroUnitFrame", function(pp, _)

    local dp = pp.dp;
    local px = pp.px;

    function enablePortrait(f, borderSize)
        local portraitFrame = A.Frame.createFrame(f);
        -- TODO set bg
        portraitFrame:SetAllPoints();

        -- dead glow
        local deadGlowFrame = A.Frame.createDefaultGlowFrame(portraitFrame);
        deadGlowFrame:SetBackdropBorderColor(1, 1, 1, 0.15);
        deadGlowFrame:Hide();
        portraitFrame.deadGlowFrame = deadGlowFrame;

        local portraitTextureRegion = A.Frame.createTextureRegion(f.portraitFrame);
        portraitTextureRegion:SetPoint("TOPLEFT", borderSize, -borderSize);
        portraitTextureRegion:SetPoint("BOTTOMRIGHT", -borderSize, borderSize);
        portraitFrame.portraitTextureRegion = portraitTextureRegion;

        portraitFrame:RegisterEvent("PARTY_MEMBER_ENABLE");
        portraitFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE");
        portraitFrame:RegisterEvent("UNIT_MODEL_CHANGED");
        portraitFrame:SetScript("OnEvent", function(self, eventName, unit, ...)
            if (unit == nil or unit ~= self:GetParent():GetAttribute("unit")) then
                return;
            end
            if (not UnitIsConnected(unit)) then
                self.portraitTextureRegion:SetTexture("interface/icons/inv_misc_questionmark");
                return;
            end

            -- TODO square portrait
            SetPortraitTexture(self.portraitTextureRegion, unit);

            -- local portrait3d = unitFrame.portrait3d;
            -- portrait3d:ClearModel();
            -- if UnitIsVisible(unit) then
            --     portrait3d:SetUnit(unit)
            --     if portrait3d:GetModel() == [[character\worgen\male\worgenmale.m2]] then
            --         portrait3d:SetCamera(1)
            --     else
            --         portrait3d:SetCamera(0)
            --     end
            -- else
            --     portrait3d:SetModel([[interface\buttons\TalkToMeQuestionMark.mdx]])
            --     portrait3d:SetModelScale(2.5)
            --     portrait3d:SetPosition(0, 0, -0.25)
            -- end

            local classColor = Color.getUnitClassColorByUnit(unit) or Color.pick("#7b7b7b");
            self:SetBackdropBorderColor(classColor:toVertex());
        end);

        f.portraitFrame = portraitFrame;

        f:HookScript("OnEnter", function(self)
            local uf = self;
            local unit = uf:GetAttribute("unit");
            if (unit == "player" and uf.castBar and uf.castBar:IsVisible() and uf.castBar.spellId) then
                GameTooltip_SetDefaultAnchor(GameTooltip, self);
                GameTooltip:SetSpellByID(uf.castBar.spellId);
                GameTooltip:Show();
            else
                GameTooltip_SetDefaultAnchor(GameTooltip, self);
                GameTooltip:SetUnit(unit);
                GameTooltip:Show();
            end
        end);

        f:HookScript("OnLeave", function(self)
            GameTooltip:Hide();
        end);
    end

    function enableRaidMark(f, width, height)
        if (f.portraitFrame == nil) then
            return;
        end

        local raidMarkTextureRegion = A.Frame:createTextureRegion(f.portraitFrame, 3, 4);
        raidMarkTextureRegion:SetSize(width, height);
        raidMarkTextureRegion:SetPoint("CENTER", f.portraitFrame, "TOPCENTER");

        local function refresh(textureRegion)
            local uf = textureRegion:GetParent():GetParent();
            local unit = uf:GetAttribute("unit");
            local index = GetRaidTargetIndex(unit);
            if index then
                index = index - 1;
                local x = index % 4;
                local y = math.floor(index / 4);
                textureRegion:SetTexCoord(x / 4, (x + 1) / 4, y / 4, (y + 1) / 4);
                textureRegion:Show();
            else
                textureRegion:Hide();
            end
        end

        local shadowFrame = A.Frame.createFrame(f);
        shadowFrame.raidMarkTextureRegion = raidMarkTextureRegion;
        shadowFrame:RegisterEvent("RAID_TARGET_UPDATE");
        shadowFrame:SetScript("OnEvent", function(self, event, ...)
            refresh(self.raidMarkTextureRegion);
        end);
    end

    function enablePressedEffect(f, shrinkedSize)
        if (f.portraitFrame == nil) then
            return;
        end

        f.portraitFrame:ClearAllPoints();
        f.portraitFrame:SetPoint("CENTER");

        local function setPressed(f, isPressed)
            local w = isPressed and (f:GetWidth() - shrinkedSize) or f:GetWidth();
            local h = isPressed and (f:GetHeight() - shrinkedSize) or f:GetHeight();
            f.portraitFrame:SetSize(w, h);
        end

        -- keep frame size sync
        f:HookScript("OnSizeChanged", function(self)
            f.portraitFrame:SetSize(f:GetSize());
        end);

        f:HookScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                setPressed(self, true);
            end
        end);
        f:HookScript("OnMouseUp", function(self)
            setPressed(self, false);
        end);
        f:HookScript("OnLeave", function(self)
            setPressed(self, false);
        end);
    end

    function enableUnderAttackEffect(f)
        if (f.portraitFrame == nil or f.portraitFrame.portraitTextureRegion == nil) then
            return;
        end

        local function setGrayed(portraitTextureRegion, shows)
            portraitTextureRegion.isGrayed = shows;
            portraitTextureRegion:SetDesaturated(shows);
        end

        local function setRedout(portraitTextureRegion, shows)
            shows = (shows == "TOGGLE") and not portraitTextureRegion.isRedout or shows;
            portraitTextureRegion.isRedout = shows;
            local color = Color.pick(shows and "Red" or "White");
            portraitTextureRegion:SetVertexColor(color:toVertex());
        end

        local shadowFrame = A.Frame.createFrame(f);
        shadowFrame.flashTotalSeconds = 4;
        shadowFrame.flashIntervalSeconds = 0.5;
        shadowFrame.deadGlowFrame = f.portraitFrame.deadGlowFrame;
        shadowFrame.portraitTextureRegion = f.portraitFrame.portraitTextureRegion;
        shadowFrame.healthBar = f.healthBar;
        shadowFrame.manaBar = f.manaBar;
        shadowFrame.castBar = f.castBar;
        shadowFrame:RegisterEvent("UNIT_HEALTH");
        shadowFrame:RegisterEvent("UNIT_HEALTH_FREQUENT");
        shadowFrame:RegisterEvent("UNIT_MAXHEALTH");
        shadowFrame:SetScript("OnEvent", function(self, event, unit, ...)
            if (unit == nil or unit ~= self:GetParent().GetAttribute("unit")) then
                return;
            end

            local health = UnitHealth(unit);
            local maxHealth = UnitHealthMax(unit);

            -- TODO directly by events
            if (UnitIsDeadOrGhost(unit)) then
                setGrayed(self.portraitTextureRegion, true);
                if (self.deadGlowFrame) then
                    self.deadGlowFrame:Show();
                end
                if (self.healthBar) then
                    self.healthBar:Hide();
                end
                if (self.manaBar) then
                    self.manaBar:Hide();
                end
                if (self.castBar) then
                    self.castBar:Hide();
                end
                return;
            end

            setGrayed(self.portraitTextureRegion, false);
            if (self.deadGlowFrame) then
                self.deadGlowFrame:Hide();
            end
            if (self.healthBar) then
                self.healthBar:Show();
            end
            if (self.manaBar) then
                self.manaBar:Show();
            end

            if (maxHealth ~= self.lastMaxHealth) then
                self.lastMaxHealth = maxHealth;
            elseif (health / maxHealth < 0.2) then
                self.flashRemainingSeconds = 0;
                self:SetScript("OnUpdate", nil);
                setRedout(self.portraitTextureRegion, true);
            elseif (health < self.lastHealth) then
                -- under attack TODO exclude equip change
                self.flashRemainingSeconds = self.flashTotalSeconds;
                if (not self:GetScript("OnUpdate")) then
                    -- state change
                    self.elapsed = 0;
                    setRedout(self.portraitTextureRegion, true);
                    self:SetScript("OnUpdate", function(self, elapsed)
                        self.elapsed = self.elapsed + elapsed;
                        if (self.elapsed < self.flashIntervalSeconds) then
                            return;
                        end
                        self.elapsed = self.elapsed - self.flashIntervalSeconds;
                        self.flashRemainingSeconds = self.flashRemainingSeconds - self.flashIntervalSeconds;
                        if (self.flashRemainingSeconds > 0) then
                            setRedout(self.portraitTextureRegion, "TOGGLE");
                        else
                            self:SetScript("OnUpdate", nil);
                            setRedout(self.portraitTextureRegion, false);
                        end
                    end);
                end
            end
            self.lastHealth = health;
        end);
    end

    function enableHealthBarAndManaBarAndCastBar(f, barMargin, barHeight)
        local backdrop = {
            bgFile = A.Res.tile32,
            insets = {
                left = -barMargin,
                right = -barMargin,
                top = -barMargin,
                bottom = -barMargin,
            },
        };

        local healthBar = A.Frame.createProgressBar(f);
        healthBar:SetBackdrop(backdrop);
        healthBar:SetBackdropColor(0, 0, 0, 0.85);
        healthBar:SetHeight(barHeight);
        healthBar:SetPoint("TOPLEFT", f, "BOTTOMLEFT", barMargin, -barMargin);
        healthBar:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", -barMargin, -barMargin);

        healthBar:RegisterEvent("UNIT_HEALTH_FREQUENT");
        healthBar:RegisterEvent("UNIT_MAXHEALTH");
        healthBar:SetScript("OnEvent", function(self, eventName, unit, ...)
            if (unit == nil or unit ~= self:GetParent():GetAttribute("unit")) then
                return;
            end

            local currentValue = UnitHealth(unit);
            local maxValue = UnitHealthMax(unit);

            local barValue = currentValue / maxValue;
            if (barValue < 0.01) then
                barValue = 0;
            elseif (barValue > 0.99) then
                barValue = 1;
            end
            self:SetValue(barValue);

            local l = 0.2; -- 斩杀线
            local r = 0.7;
            if (barValue > r) then
                self:SetStatusBarColor(0, 1, 0);
            else if (barValue < l) then
                self:SetStatusBarColor(1, 0, 0);
            else
                local p = (barValue - l) / (r - l);
                if (p > 0.5) then
                    self:SetStatusBarColor((1 - p) * 2, 1, 0);
                else
                    -- go down red
                    self:SetStatusBarColor(1, p * 2, 0);
                end
            end
            self:SetStatusBarColor(Color.pick("Green"):toVertex());

            if (self.countdownTextRegion) then
                self.countdownTextRegion:SetText(currentValue);
            end
        end);

        f.healthBar = healthBar;

        ----------------

        local manaBar = A.Frame.createProgressBar(f);
        manaBar:SetBackdrop(backdrop);
        manaBar:SetBackdropColor(0, 0, 0, 0.85);
        manaBar:SetHeight(barHeight);
        manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -barMargin);
        manaBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, -barMargin);

        manaBar:RegisterEvent("UNIT_POWER_FREQUENT");
        manaBar:RegisterEvent("UNIT_MAXPOWER");
        manaBar:RegisterEvent("UNIT_DISPLAYPOWER");
        manaBar:SetScript("OnEvent", function(self, eventName, unit, ...)
            if (unit == nil or unit ~= self:GetParent():GetAttribute("unit")) then
                return;
            end
            if (eventName == "UNIT_DISPLAYPOWER") then
                local barColor = Color.getManaTypeColorByUnit(unit);
                self:SetStatusBarColor(barColor:toVertex());
            else
                local currentValue = UnitPower(unit);
                local maxValue = UnitPowerMax(unit);
                local barValue = currentValue / maxValue;
                if (barValue < 0.01) then
                    barValue = 0;
                elseif (barValue > 0.99) then
                    barValue = 1;
                end
                self:SetValue(barValue);

                if (self.countdownTextRegion) then
                    self.countdownTextRegion:SetText(currentValue);
                end
            end
        end);

        f.manaBar = manaBar;

        ----------------

        local castBar = A.Frame.createProgressBar(f);
        castBar:SetBackdrop(backdrop);
        castBar:SetBackdropColor(0, 0, 0, 0.85);
        castBar:SetStatusBarTexture(A.Res.tgaBar1);
        castBar:SetAllPoints(f.manaBar);
        castBar:Hide();

        -- shielded cast
        local glowFrame = A.Frame.createDefaultGlowFrame(castBar);
        glowFrame:SetBackdropBorderColor(Color.pick("Silver"):toVertex());
        glowFrame:Hide();
        castBar.glowFrame = glowFrame;

        local spellTextureRegion = A.Frame.createTextureRegion(castBar);
        A.Frame.cropTextureRegion(spellTextureRegion);
        spellTextureRegion:SetAllPoints(f.portraitFrame.portraitTextureRegion);
        castBar.spellTextureRegion = spellTextureRegion;

        function updateModel(castBar, unit)
            local spellName;
            local spellText;
            local spellTexture;
            local startTimeMilliseconds;
            local endTimeMilliseconds;
            local notInterruptible;
            local spellId;

            -- is casting?
            spellName, spellText, spellTexture, startTimeMilliseconds, endTimeMilliseconds, _, _, notInterruptible, spellId = UnitCastingInfo(unit);
            if (spellName ~= nil) then
                castBar.spellId = spellId;
                castBar.spellName = spellName;
                castBar.spellTexture = spellTexture;
                castBar.spellStartTime = startTimeMilliseconds / 1000;
                castBar.spellEndTime = endTimeMilliseconds / 1000;
                castBar.spellIsInterruptible = not notInterruptible;
                castBar.spellProgressing = "CASTING";
                return;
            end

            -- is channeling?
            spellName, spellText, spellTexture, startTimeMilliseconds, endTimeMilliseconds, _, notInterruptible, spellId = UnitChannelInfo(unit);
            if (spellName ~= nil) then
                castBar.spellId = spellId;
                castBar.spellName = spellName;
                castBar.spellTexture = spellTexture;
                castBar.spellStartTime = startTimeMilliseconds / 1000;
                castBar.spellEndTime = endTimeMilliseconds / 1000;
                castBar.spellIsInterruptible = not notInterruptible;
                castBar.spellProgressing = "CHANNELING";
                return;
            end

            -- make clean
            castBar.spellId = nil;
            castBar.spellName = nil;
            castBar.spellTexture = nil;
            castBar.spellStartTime = 0;
            castBar.spellEndTime = 0;
            castBar.spellIsInterruptible = true;
            castBar.spellProgressing = nil;
        end

        function invalidateBarColor(castBar)
            if (not castBar.spellProgressing) then
                castBar.glowFrame:Hide();
                return;
            end

            if (castBar.isChanneling) then
                castBar:SetStatusBarColor(Color.pick("Green"):toVertex());
            else
                castBar:SetStatusBarColor(Color.pick("Gold"):toVertex());
            end

            if (castBar.spellIsInterruptible) then
                castBar.glowFrame:Hide();
            else
                castBar.glowFrame:Show();
            end
        end

        function invalidateBarValue(castBar)
            if (not castBar.spellProgressing) then
                return;
            end

            local currentTime = GetTime();
            if (currentTime >= castBar.spellEndTime) then
                return;
            end

            local totalSeconds = castBar.spellEndTime - castBar.spellStartTime;
            local elapsedSeconds = currentTime - castBar.spellStartTime;
            local barValue = elapsedSeconds / totalSeconds;
            if (castBar.spellProgressing == "CHANNELING") then
                castBar:SetValue(1 - barValue);
            else
                castBar:SetValue(barValue);
            end

            if (castBar.countdownTextRegion) then
                castBar.countdownTextRegion:SetFormattedText("%.1f", totalSeconds - elapsedSeconds);
            end
        end

        function onEventCastStart(castBar, unit)
            if (unit == nil or unit ~= castBar:GetParent():GetAttribute("unit")) then
                return;
            end

            updateModel(castBar, unit);

            if (not castBar.spellProgressing) then
                onEventCastEnd(castBar, unit);
                return;
            end

            if (castBar.spellTextureRegion) then
                castBar.spellTextureRegion:SetTexture(castBar.spellTexture);
            end
            if (castBar.nameTextRegion) then
                castBar.nameTextRegion:SetText(castBar.spellName);
            end
            invalidateBarColor(castBar);
            invalidateBarValue(castBar);
            castBar:Show();
            castBar:SetScript("OnUpdate", function(self, elapsed)
                if (GetTime() < self.spellEndTime) then
                    invalidateBarValue(self);
                else
                    onEventCastEnd(self, unit);
                end
            end);
        end

        -- hide all and clean up
        function onEventCastEnd(castBar, unit)
            if (unit == nil or unit ~= castBar:GetParent():GetAttribute("unit")) then
                return;
            end
            castBar:SetScript("OnUpdate", nil);
            castBar:Hide();
        end

        function onEventCastInterruptibleChanged(castBar, unit, isInterruptible)
            if (unit == nil or unit ~= castBar:GetParent():GetAttribute("unit")) then
                return;
            end
            castBar.spellIsInterruptible = isInterruptible;
            invalidateBarColor(castBar);
        end

        local events = {
            ["UNIT_SPELLCAST_START"] = onEventCastStart,
            ["UNIT_SPELLCAST_FAILED"] = onEventCastEnd,
            ["UNIT_SPELLCAST_INTERRUPTED"] = onEventCastEnd,
            ["UNIT_SPELLCAST_INTERRUPTIBLE"] = function(self, unit)
                onEventCastInterruptibleChanged(self, unit, true);
            end,
            ["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = function(self, unit)
                onEventCastInterruptibleChanged(self, unit, false);
            end,
            ["UNIT_SPELLCAST_DELAYED"] = onEventCastStart,
            ["UNIT_SPELLCAST_STOP"] = onEventCastEnd,
            ["UNIT_SPELLCAST_CHANNEL_START"] = onEventCastStart,
            ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = onEventCastStart,
            ["UNIT_SPELLCAST_CHANNEL_STOP"] = onEventCastEnd,
        };
        for eventName, handler in pairs(events) do
            castBar:RegisterEvent(eventName);
        end
        castBar:SetScript("OnEvent", function(self, eventName, ...)
            if (events[eventName]) then
                events[eventName](self, ...);
            end
        end);
    end

    return {
        createUnitFrame = function(unit)
            unit = string.lower(unit);

            -- transparent
            local f = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate");
            f:SetAttribute("unit", unit);
            f:SetAttribute("*type1", "target");
            f:SetAttribute("*type2", "menu");
            f.menu = function(self)
                ToggleDropDownMenu(1, nil, dropdown, self, 120, 10);
            end

            local barMargin = 2 * px;
            local barHeight = 4 * px;

            enablePortrait(f, barMargin);
            enableRaidMark(f);
            enablePressedEffect(f, 3 * px);
            enableUnderAttackEffect(f);
            enableHealthBarAndManaBarAndCastBar(f, barMargin, barHeight);

            RegisterUnitWatch(f);

            return f;
        end,
    };
end);

P.ask("HeroUnitFrame").answer("demo", function(HeroUnitFrame)
    local myHero = HeroUnitFrame.createUnitFrame("PLAYER");
    myHero:SetPoint("CENTER", 0, -60 * dp);
    myHero:SetSize(60 * dp, 60 * dp);
    myHero:Show();
end);

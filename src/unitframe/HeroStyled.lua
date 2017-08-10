T.ask().answer("HeroStyled.HpWarning", function()

    local function stopTicking(uf)
        local m = uf.m.hpW;
        m.isTicking = false;
        m.elapsed = 0;
        m.total = 0;
        uf.portrait:setRedout(false);
    end

    local function appearUnderAttack(uf, enabled)
        local m = uf.m.hpW;

        if not enabled then
            stopTicking(uf);
            return;
        end

        m.total = 3;
        if not m.isTicking then
            m.isTicking = true;
            uf.portrait:setRedout(true);
        end
    end

    local function appearDead(uf, enabled)
        if enabled then
            uf.imageDiv:setGlowShown(true);
            uf.portrait:setBlackout(true);
            uf.barDiv:Hide();
        else
            uf.imageDiv:setGlowShown(false);
            uf.portrait:setBlackout(false);
            uf.barDiv:Show();
        end
    end

    local function refresh(uf, unit)
        if not UnitExists(unit) then
            return;
        end

        if UnitIsDeadOrGhost(unit) then
            appearUnderAttack(uf, false);
            appearDead(uf, true);
            return;
        end

        appearDead(uf, false);

        local hp = UnitHealth(unit);
        local maxHp = UnitHealthMax(unit);

        if maxHp > 0 and hp / maxHp <= 0.4 then
            appearUnderAttack(uf, false);
            uf.portrait:setRedout(true);
            return;
        end

        local m = uf.m.hpW;
        m.hp = m.hp or 0;
        m.maxHp = m.maxHp or 0;

        if not m.isTicking then
            uf.portrait:setRedout(false);
        end

        if maxHp >= m.maxHp then
            if hp < m.hp then
                appearUnderAttack(uf, true);
            end
        else
            m.maxHp = maxHp;
        end
        m.hp = hp;
    end

    local events = {
        ["PLAYER_TARGET_CHANGED"] = function(self)
            local uf = self.uf;
            local eventUnit = "target";
            if eventUnit and eventUnit == uf.m.unit then
                uf.m.hpW.hp = 0;
                uf.m.hpW.maxHp = 0;
                refresh(uf, eventUnit);
            end
        end,
        ["PLAYER_FOCUS_CHANGED"] = function(self)
            local uf = self.uf;
            local eventUnit = "focus";
            if eventUnit and eventUnit == uf.m.unit then
                uf.m.hpW.hp = 0;
                uf.m.hpW.maxHp = 0;
                refresh(uf, eventUnit);
            end
        end,
        ["UNIT_HEALTH"] = function(self, eventUnit)
            local uf = self.uf;
            if eventUnit and eventUnit == uf.m.unit then
                refresh(uf, eventUnit);
            end
        end,
        ["UNIT_HEALTH_FREQUENT"] = function(self, eventUnit)
            local uf = self.uf;
            if eventUnit and eventUnit == uf.m.unit then
                refresh(uf, eventUnit);
            end
        end,
        ["UNIT_MAXHEALTH"] = function(self, unit)
            local uf = self.uf;
            if unit == uf.m.unit then
                uf.m.hpW.maxHp = UnitHealthMax(unit) or 0;
            end
        end,
        ["OnCreate"] = function(self)
            local uf = self.uf;
            uf.m = uf.m or {};
            uf.m.hpW = {};
            stopTicking(uf);
        end,
        ["OnTick"] = function(self, elapsed)
            local uf = self.uf;
            local m = uf.m.hpW;

            if not m.isTicking then
                return
            end

            local INTERVAL = 0.5;

            m.elapsed = m.elapsed + elapsed;
            if m.elapsed >= INTERVAL then
                if m.total > INTERVAL then
                    m.elapsed = m.elapsed - INTERVAL;
                    m.total = m.total - INTERVAL;
                    uf.portrait:toggleRedout();
                else
                    stopTicking(uf);
                    return;
                end
            end
        end,
    };

    return {
        events = events
    };
end);

T.ask("resource", "env", "widget", "unitframe.UnitFrame", "HeroStyled.HpWarning").answer("HeroStyled", function(res, env, widget, UnitFrame, HpWarning)
    local Color = widget.Color;
    local Div = widget.Div;
    local Bar = widget.Bar;
    local Button = widget.Button;
    local Image = widget.Image;

    local function createLayout()
        local IMAGE_CONTENT_WIDTH = 64 * env.pixel;
        local IMAGE_CONTENT_HEIGHT = IMAGE_CONTENT_WIDTH * 0.75;
        local PADDING = 1 * env.pixel;
        local BORDER = 1 * env.pixel;
        local EXTENDED = 1 * env.pixel;
        local BUTTON_WIDTH = IMAGE_CONTENT_WIDTH + PADDING * 2 + BORDER * 2;
        local BUTTON_HEIGHT = IMAGE_CONTENT_HEIGHT + PADDING * 2 + BORDER * 2;

        local uf = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate");
        table.merge(uf, Div.p);
        uf:setZ(0, 0);
        uf:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);

        local BACKGROUND_COLOR = "#333333";

        -- 视觉区域初始与响应区域保持一致
        local imageDiv = CreateFrame("Frame", nil, uf, nil);
        table.merge(imageDiv, Div.p, Button.p);
        imageDiv:setZ(0, 1);
        imageDiv:SetSize(uf:GetWidth(), uf:GetHeight());
        imageDiv:SetPoint("CENTER", uf, "TOP", 0, -imageDiv:GetHeight() / 2);
        uf.imageDiv = imageDiv;

        imageDiv:addBackgroundAndBorder(BORDER, EXTENDED);
        imageDiv:setBackgroundColor(BACKGROUND_COLOR);
        imageDiv:addGlow(EXTENDED, 5 * env.pixel);
        imageDiv:setGlowColor("white");
        imageDiv:setGlowShown(false);

        local portrait = Image.createImage(uf.imageDiv, 0, 1);
        table.merge(portrait, Image.p);
        portrait:SetTexCoord(4/64, 60/64, 10/64, 52/64);
        portrait:SetPoint("TOPLEFT", BORDER + PADDING, -BORDER - PADDING);
        portrait:SetPoint("BOTTOMRIGHT", -BORDER - PADDING, BORDER + PADDING);
        uf.portrait = portrait;

        local CLASS_SIZE = 24 * env.pixel;

        local classDiv = CreateFrame("Frame", nil, uf, nil);
        table.merge(classDiv, Div.p);
        classDiv:addBackgroundAndBorder(BORDER, EXTENDED);
        classDiv:setBackgroundColor("#00000099");
        classDiv:setZ(0, 2);
        classDiv:SetSize(CLASS_SIZE, CLASS_SIZE);
        classDiv:SetPoint("TOPLEFT");
        uf.classDiv = classDiv;

        local classImage = Image.createCroppedImage(uf.classDiv, 0, 0);
        table.merge(classImage, Image.p);
        classImage:SetPoint("TOPLEFT", uf.classDiv, "TOPLEFT", BORDER + PADDING, -BORDER - PADDING);
        classImage:SetPoint("BOTTOMRIGHT", uf.classDiv, "BOTTOMRIGHT", -BORDER - PADDING, BORDER + PADDING);
        uf.classImage = classImage;

        local ICON_SIZE = 22 * env.pixel;
        local ICON_OFFSET = 4 * env.pixel;

        local roleDiv = CreateFrame("Frame", nil, uf, nil);
        table.merge(roleDiv, Div.p);
        roleDiv:setZ(0, 3);
        roleDiv:SetSize(ICON_SIZE, ICON_SIZE);
        roleDiv:SetPoint("CENTER", uf, "TOPRIGHT", -ICON_OFFSET, -ICON_OFFSET);
        uf.roleDiv = roleDiv;

        local roleIcon = Image.createCroppedImage(uf.roleDiv, 0, 0);
        roleIcon:SetAllPoints();
        uf.roleIcon = roleIcon;

        local markIcon = Image.createCroppedImage(uf.imageDiv, 0, 4);
        markIcon:SetSize(ICON_SIZE, ICON_SIZE);
        markIcon:SetPoint("CENTER");
        uf.markIcon = markIcon;

        local BAR_HEIGHT = 4 * env.pixel;

        local barDiv = CreateFrame("Frame", nil, uf, nil);
        table.merge(barDiv, Div.p);
        barDiv:setZ(0, 2);
        barDiv:addBackgroundAndBorder(0, EXTENDED);
        barDiv:setBackgroundColor(BACKGROUND_COLOR);
        barDiv:SetPoint("TOPLEFT", uf, "BOTTOMLEFT", 0, -EXTENDED);
        barDiv:SetPoint("TOPRIGHT", uf, "BOTTOMRIGHT", 0, -EXTENDED);
        barDiv:SetHeight(BAR_HEIGHT * 2 + EXTENDED);
        uf.barDiv = barDiv;

        local hpBar = Bar.createBar(barDiv);
        hpBar:SetStatusBarTexture(res.texture.SQUARE);
        hpBar:setZ(0, 3);
        hpBar:SetPoint("TOPLEFT");
        hpBar:SetPoint("TOPRIGHT");
        hpBar:SetHeight(BAR_HEIGHT);
        uf.hpBar = hpBar;

        local mpBar = Bar.createBar(barDiv);
        mpBar:SetStatusBarTexture(res.texture.SQUARE);
        mpBar:setZ(0, 3);
        mpBar:SetPoint("TOPLEFT", uf.hpBar, "BOTTOMLEFT", 0, -EXTENDED);
        mpBar:SetPoint("TOPRIGHT", uf.hpBar, "BOTTOMRIGHT", 0, -EXTENDED);
        mpBar:SetHeight(BAR_HEIGHT);
        uf.mpBar = mpBar;

        local castingBar = Bar.createBar(barDiv);
        castingBar:SetStatusBarTexture(res.texture.NORM1);
        castingBar:setZ(0, 4);
        castingBar:SetAllPoints(uf.mpBar);
        uf.castingBar = castingBar;

        local castingImage = Image.createImage(uf.imageDiv, 0, 2);
        castingImage:SetAllPoints(uf.portrait);
        castingImage:SetTexCoord(uf.portrait:GetTexCoord());
        castingBar.icon = castingImage;

        return uf;
    end

    local p = {};

    local function updateTeamRole(icon, unit)
        if not UnitIsPlayer(unit) then
            icon:Hide();
            return;
        else
            if not IsInGroup() then
                icon:Hide();
                return;
            end
        end

        if UnitIsGroupLeader(unit) then
            if HasLFGRestrictions() then
                -- show guide
                icon:SetTexture("Interface/LFGFrame/UI-LFG-ICON-PORTRAITROLES");
                icon:SetTexCoord(0, 0.296875, 0.015625, 0.3125);
            else
                -- show leader
                icon:SetTexture("Interface/GroupFrame/UI-Group-LeaderIcon");
                icon:SetTexCoord(0, 1, 0, 1);
            end
            icon:Show();
            return;
        end

        local lootMethod, partyLooter, raidLooter = GetLootMethod();
        if partyLooter == 0 then
            icon:SetTexture("Interface/GroupFrame/UI-Group-MasterLooter");
            icon:Show();
            return;
        end

        local role = UnitGroupRolesAssigned(unit);
        if role == "TANK" or role == "HEALER" then
            icon:SetTexture("Interface/LFGFrame/UI-LFG-ICON-PORTRAITROLES");
            icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
            icon:Show();
            return;
        end

        icon:Hide();
    end

    local function updateMark(icon, unit)
        local index = GetRaidTargetIndex(unit);
        if index then
            index = index - 1;
            local x = mod(index , 4);
            local y = floor(index / 4);
            icon:SetTexCoord(x / 4, (x + 1) / 4, y / 4, (y + 1) / 4);
            icon:Show();
            return;
        end

        icon:Hide();
    end

    local function updateHpColor(uf, unit)
        local hp = UnitHealth(unit);
        local maxHp = UnitHealthMax(unit);

        local hpRatio = hp / maxHp;

        local START = 0.3;
        local END = 0.5;
        local color = nil;
        if hpRatio < START then
            color = "red";
        elseif hpRatio > END then
            color = "green";
        else
            local ratio = (hpRatio - START) / (END - START);
            if ratio > 0.5 then
                color = Color.fromVertex((1.0 - ratio) * 2, 1.0, 0.0);
            else
                color = Color.fromVertex(1.0, ratio * 2, 0.0);
            end
        end

        uf.hpBar:SetStatusBarColor(Color.toVertex(color));
    end

    function p.refresh(uf)
        local unit = uf.m.unit;

        -- show/hide is delegated

        local hostileColor = Color.fromUnitHostile(unit) or "#7b7b7b";
        uf.imageDiv:setBorderColor(hostileColor);
        if UnitIsPlayer(unit) then
            uf.classImage:setUnitClassImage(unit);
            uf.classDiv:setBorderColor(hostileColor);
            uf.classDiv:Show();
        else
            uf.classDiv:Hide();
        end

        uf.portrait:refresh(unit);
        updateTeamRole(uf.roleIcon, unit);
        updateMark(uf.markIcon, unit);
        -- TODO ready check

        updateHpColor(uf, unit);
        uf.hpBar:refresh(unit);
        uf.mpBar:refresh(unit);
        uf.castingBar:refresh(unit);
        -- TODO uf:updateCooling();

        -- TODO uf:updateBuff();
    end

    local callback = {};

    local function checkEventUnit(uf, eventUnit)
        return eventUnit and uf.m.unit == string.lower(eventUnit);
    end

    function callback.onRefresh(uf, eventUnit)
        if checkEventUnit(uf, eventUnit) then
            uf:refresh();
        end
    end

    function callback.onRefreshEach(uf)
        uf:refresh();
    end

    function callback.onUpdateHpColor(uf, eventUnit)
        if checkEventUnit(uf, eventUnit) then
            updateHpColor(uf, eventUnit);
        end
    end

    local events = {
        ["PLAYER_ENTERING_WORLD"] = callback.onRefreshEach,

        ["PLAYER_TARGET_CHANGED"] = function(uf)
            if checkEventUnit(uf, "target") then
                uf:refresh();
            end
        end,
        ["PLAYER_FOCUS_CHANGED"] = function(uf)
            if checkEventUnit(uf, "focus") then
                uf:refresh();
            end
        end,

        ["PARTY_LEADER_CHANGED"] = callback.onRefreshEach,
        ["PARTY_MEMBERS_CHANGED"] = callback.onRefreshEach,
        ["GROUP_ROSTER_UPDATE"] = callback.onRefreshEach,

        ["PARTY_MEMBER_ENABLE"] = callback.onRefresh,
        ["PARTY_MEMBER_DISABLED"] = callback.onRefresh,
        ["ROLE_CHANGED_INFORM"] = function(uf, name, owner, oldRole, newRole)
            uf:refresh();
        end,

        ["UNIT_CONNECTION"] = callback.onRefresh,

        ["UNIT_HEALTH"] = callback.onUpdateHpColor,
        ["UNIT_HEALTH_FREQUENT"] = callback.onUpdateHpColor,
        ["UNIT_MAXHEALTH"] = callback.onUpdateHpColor,
    };

    local function createUnitFrame(unit)
        local uf = createLayout();
        table.merge(uf, p, UnitFrame.p);
        uf.m = { unit = unit };
        uf.events = events;
        uf.subscribers = { [1] = uf };

        uf:SetAttribute("*type1", "target");
        --uf:SetAttribute("*type1", "macro");
        --uf:SetAttribute("macrotext", "/target " .. unit);
        uf:SetAttribute("*type2", "menu");
        uf:SetAttribute("unit", unit);
        uf.menu = menuCallback; -- TODO

        RegisterUnitWatch(uf);

        uf:HookScript("OnMouseDown", function(self, which)
            if which == "LeftButton" then
                self.imageDiv:setPressed(true);
            end
        end);
        uf:HookScript("OnMouseUp", function(self)
            self.imageDiv:setPressed(false);
        end);
        uf:HookScript("OnEnter", function(self)
        end);
        uf:HookScript("OnLeave", function(self)
            self.imageDiv:setPressed(false);
        end);

        uf:HookScript("OnEnter", function(self)
            if self.castingBar.m.unit == "player" and self.castingBar:IsVisible() then
                GameTooltip_SetDefaultAnchor(GameTooltip, self);
                GameTooltip:SetSpellByID(self.castingBar.m.spellId);
                GameTooltip:Show();
            elseif self.portrait:IsVisible() then
                GameTooltip_SetDefaultAnchor(GameTooltip, self);
                GameTooltip:SetUnit(uf.m.unit);
                GameTooltip:Show();
            end
        end);
        uf:HookScript("OnLeave", function(self)
            GameTooltip:Hide();
        end);

        uf.portrait.m = { unit = unit };
        uf:addSubscriber(uf.portrait, "Portrait");

        uf.hpBar.m = { unit = unit };
        uf:addSubscriber(uf.hpBar, "HpBar");

        uf.mpBar.m = { unit = unit };
        uf:addSubscriber(uf.mpBar, "MpBar");

        uf.castingBar.m = { unit = unit };
        uf:addSubscriber(uf.castingBar, "CastingBar");

        uf:addSubscriber({ uf = uf }, HpWarning);

        return uf;
    end

    local playerUnit = createUnitFrame("player");
    playerUnit:SetPoint("CENTER", -400 * env.on1024, 200 * env.on1024);
    playerUnit:start();
    playerUnit:refresh();

    local OFFSET = 40 * env.on1024;

    local targetUnit = createUnitFrame("target");
    targetUnit:SetPoint("LEFT", playerUnit, "RIGHT", OFFSET, 0);
    targetUnit:start();
    targetUnit:refresh();

    local focusUnit = createUnitFrame("focus");
    focusUnit:SetPoint("TOP", targetUnit, "BOTTOM", 0, -OFFSET);
    focusUnit:start();
    focusUnit:refresh();

    local party1Unit = createUnitFrame("party1");
    party1Unit:SetPoint("TOP", playerUnit, "BOTTOM", 0, -OFFSET);
    party1Unit:start();
    party1Unit:refresh();

    local party2Unit = createUnitFrame("party2");
    party2Unit:SetPoint("TOP", party1Unit, "BOTTOM", 0, -OFFSET);
    party2Unit:start();
    party2Unit:refresh();

    local party3Unit = createUnitFrame("party3");
    party3Unit:SetPoint("TOP", party2Unit, "BOTTOM", 0, -OFFSET);
    party3Unit:start();
    party3Unit:refresh();

    local party4Unit = createUnitFrame("party4");
    party4Unit:SetPoint("TOP", party3Unit, "BOTTOM", 0, -OFFSET);
    party4Unit:start();
    party4Unit:refresh();
end);

-- 美化与修正
T.ask("resource", "env", "api").answer("tweakTooltip", function(res, env, api)
    GameTooltip:SetBackdrop({
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        insets = {
            left = -env.dotsPerPixel,
            right = -env.dotsPerPixel,
            top = -env.dotsPerPixel,
            bottom = -env.dotsPerPixel
        },
        edgeFile = res.texture.SQUARE,
        edgeSize = env.dotsPerPixel,
        tile = false,
        tileSize = 0
    });
    GameTooltip:SetBackdropColor(
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)

    GameTooltipStatusBar:ClearAllPoints();
    GameTooltipStatusBar:SetPoint("topleft", GameTooltip, "bottomleft", 0, -env.dotsPerPixel);
    GameTooltipStatusBar:SetPoint("topright", GameTooltip, "bottomright", 0, -env.dotsPerPixel);

    GameTooltipStatusBar:SetStatusBarTexture(res.texture.SQUARE);
    api.setFrameBackdrop(GameTooltipStatusBar, 0, 1);

    local hpPercentage = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpPercentage:SetWidth(60 * env.dotsPerPixel);
    hpPercentage:SetJustifyH("right");
    hpPercentage:SetPoint("left", -8 * env.dotsPerPixel, 0);

    local hpValue = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpValue:SetJustifyH("right");
    hpValue:SetPoint("right", -2 * env.dotsPerPixel, 0);

    local function updateStatusbarText(self)
        local curhp = self:GetValue();
        local _, maxhp = self:GetMinMaxValues();
        hpPercentage:SetFormattedText("%.1f%%", curhp / maxhp * 100);
        if curhp <= 1 and maxhp == 1 then
            hpValue:SetText("");
        else
            hpValue:SetFormattedText("%d", curhp);
        end
    end

    GameTooltipStatusBar:HookScript("OnShow", updateStatusbarText);
    GameTooltipStatusBar:HookScript("OnValueChanged", updateStatusbarText);

    -- GameTooltip:
    -- BlizUI在OnHide时将重置边框颜色。但其有淡出效果，淡出未完成时不触发OnHide。
    -- 当鼠标快速移动时其实显示的是最后一次设置的颜色。
    -- BlizUI在任何情况下都不改变边框颜色，所以看起来没有问题。
    -- 一旦设定边框颜色表示玩家职业、NPC敌意、物品品质，
    -- 若不修正此BUG，将可看到五颜六色的商店招牌。
    GameTooltip:HookScript("OnTooltipCleared", function(self)
        self:SetBackdropBorderColor(1, 1, 1);
    end);
end);

-- add buff caster name to gametooltip
T.ask().answer("buffCasterTooltip", function()
    local addCasterName = function(self, unit, index, filter)
        local src = select(8, UnitAura(unit, index, filter));
        if src then
            self:AddLine("");
            local text = "by " .. GetUnitName(src, 1);
            if src == "pet" or src == "vehicle" then
                text = string.format("(%s)", GetUnitName("player", true));
            else
                local ppet = src:match("^partypet(%d+)$");
                local rpet = src:match("^raidpet(%d+)$");
                if ppet then
                    text = string.format("(%s)", GetUnitName("party" .. ppet, true));
                elseif rpet then
                    text = string.format("(%s)", GetUnitName("raid" .. rpet, true));
                end
            end
            self:AddLine(text);
            self:Show();
        end
    end
    hooksecurefunc(GameTooltip, "SetUnitAura", addCasterName)
    hooksecurefunc(GameTooltip, "SetUnitBuff", addCasterName)
end);

-- unit target
T.ask("resource").answer("unitTargetTooltip", function(res)
    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit();
        if unit then
            if UnitIsPlayer(unit) then
                self:SetBackdropBorderColor(
                        res.color.toSequence(res.color.fromClass(unit)));
            else
                self:SetBackdropBorderColor(UnitSelectionColor(unit))
            end
            local unitTarget = unit .. "target"
            if UnitExists(unitTarget) then
                local t = UnitName(unitTarget)
                if UnitIsPlayer(unitTarget) then
                    if UnitIsUnit(unitTarget, "player") then
                        t = "|cffff0000!!!|r"
                    elseif UnitIsFriend(unitTarget, "player") then
                        t = "|cff00ff00" .. t .. "|r"
                    else
                        t = "|cffff0000" .. t .. "|r"
                    end
                end
                self:AddLine("→ " .. t, 1, 1, 1)
            end
        end
    end);
end);

-- item border quality
T.ask().answer("itemQualityTooltip", function()
    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local itemName, itemLink = self:GetItem()
        if itemLink then
            local itemId = itemLink:match("item:(%d+)")
            if (itemId) then
                self:AddLine("id: " .. itemId, 0, 1, 1);
            end
            local _, _, q, lv = GetItemInfo(itemLink);

            -- 4.3 BlizUI已加入了物品lv
            -- if lv then
            -- self:AddLine("lv: " .. lv, 0, 1, 1);
            -- end
            if q then
                self:SetBackdropBorderColor(GetItemQualityColor(q));
            end
        end
    end);
end);

-- spell id
T.ask().answer("spellIdTooltip", function()
    GameTooltip:HookScript("OnTooltipSetSpell", function(self)
        local spellName, spellRank, spellId = self:GetSpell()
        if spellId then
            self:AddLine("spellId: " .. spellId, 0, 1, 1);
        end
    end);
end);

-- timer manager
T.ask("VARIABLES_LOADED", "api").answer("timerManagerTooltip", function(_, api)

    hooksecurefunc("TimeManagerClockButton_Update", function()
        TimeManagerClockTicker:SetVertexColor(select(2, api.getLag()));
    end)

    function TimeManagerClockButton_UpdateTooltip()
        GameTooltip:ClearLines();
        if TimeManagerClockTicker.alarmFiring then
            if gsub(Settings.alarmMessage, "%s", "") ~= "" then
                GameTooltip:AddLine(
                        Settings.alarmMessage,
                        HIGHLIGHT_FONT_COLOR.r,
                        HIGHLIGHT_FONT_COLOR.g,
                        HIGHLIGHT_FONT_COLOR.b,
                        1);
            end
            GameTooltip:AddLine(TIMEMANAGER_ALARM_TOOLTIP_TURN_OFF);
        end

        GameTooltip:AddLine(format("%d fps", api.getFps()) .. " / " .. format("%d ms", api.getLag()), 1, 1, 1);

        UpdateAddOnMemoryUsage();

        local totalMemory = 0;
        for i = 1, GetNumAddOns() do
            local addonName, _, _, enabled = GetAddOnInfo(i);
            if (enabled) then
                local addonMemory = GetAddOnMemoryUsage(i);
                GameTooltip:AddDoubleLine(addonName, format("|cff00ff00%.1f KB|r", addonMemory));
                totalMemory = totalMemory + addonMemory;
            end
        end
        if (totalMemory > 0) then
            GameTooltip:AddLine("----------------------------------");
        end
        GameTooltip:AddDoubleLine("Total Memory", format("|cff00ff00%.1f KB|r", totalMemory));
        GameTooltip:AddLine("(click to gc)");
        GameTooltip:Show();
    end

    TimeManagerClockButton:SetScript("OnClick", function(self, button)
        if self.alarmFiring then
            PlaySound("igMainMenuQuit");
            TimeManager_TurnOffAlarm();
        else
            if (button == "LeftButton") then
                collectgarbage("collect");
            else
                TimeManager_Toggle();
            end
        end
    end);
end);

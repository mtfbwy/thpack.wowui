P.ask("res", "api").answer("tweakTooltip", function(res, api)

    local pixel = res.pixel;
    local Color = api.Color;

    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.edgeFile = res.texture.SQUARE;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.edgeSize = pixel;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.tile = false;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.tileSize = 0;
    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.insets = {
        left = -pixel,
        right = -pixel,
        top = -pixel,
        bottom = -pixel,
    };

    GameTooltip:SetBackdropColor(
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
            TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)

    -- GameTooltip有淡出动画，动画完成时才会重置边框颜色(OnHide)。
    -- 当鼠标快速移动时其实显示的是最后一次设置的颜色。
    -- BlizUI在任何情况下都不改变边框颜色，所以看起来没有问题。
    -- 若不修正，一旦设定可变的边框颜色(如物品品质)，则将看到五颜六色的商店招牌。
    GameTooltip:HookScript("OnTooltipCleared", function(self)
        self:SetBackdropBorderColor(1, 1, 1);
    end);

    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit();
        if unit then
            if UnitIsPlayer(unit) then
                self:SetBackdropBorderColor(Color.toVertex(Color.fromUnitClass(unit)));
            else
                self:SetBackdropBorderColor(UnitSelectionColor(unit));
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

    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local itemName, itemLink = self:GetItem()
        if itemLink then
            local itemId = itemLink:match("item:(%d+)")
            if (itemId) then
                self:AddLine("id: " .. itemId, 0, 1, 1);
            end
            local _, _, q, lv = GetItemInfo(itemLink);

            if lv then
                self:AddLine("lv: " .. lv, 0, 1, 1);
            end
            if q then
                self:SetBackdropBorderColor(GetItemQualityColor(q));
            end
        end
    end);

    GameTooltip:HookScript("OnTooltipSetSpell", function(self)
        local spellName, spellRank, spellId = self:GetSpell()
        if spellId then
            self:AddLine("id: " .. spellId, 0, 1, 1);
        end
    end);
end);

P.ask("res", "api").answer("tweakTooltipStatusBar", function(res, api)

    local pixel = res.pixel;
    local dip = res.dip;

    GameTooltipStatusBar:ClearAllPoints();
    GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, -pixel);
    GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", 0, -pixel);

    GameTooltipStatusBar:SetBackdrop({
        bgFile = nil,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            left = 0,
        },
        tile = false,
        tileSize = 0,
        edgeFile = res.texture.SQUARE,
        edgeSize = pixel,
    });
    GameTooltipStatusBar:SetStatusBarTexture(res.texture.SQUARE);

    local hpPercentage = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpPercentage:SetWidth(60);
    hpPercentage:SetJustifyH("RIGHT");
    hpPercentage:SetPoint("LEFT", -8, 0);

    local hpValue = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpValue:SetJustifyH("RIGHT");
    hpValue:SetPoint("RIGHT", -2 * pixel, 0);

    function updateStatusBarText(self)
        local curhp = self:GetValue();
        local _, maxhp = self:GetMinMaxValues();
        hpPercentage:SetFormattedText("%.1f%%", curhp / maxhp * 100);
        if curhp <= 1 and maxhp == 1 then
            hpValue:SetText("");
        else
            hpValue:SetFormattedText("%d", curhp);
        end
    end

    GameTooltipStatusBar:HookScript("OnShow", updateStatusBarText);
    GameTooltipStatusBar:HookScript("OnValueChanged", updateStatusBarText);
end);

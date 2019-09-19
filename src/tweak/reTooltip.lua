P.ask("pp").answer("reTooltip", function(pp)

    local texSquare = A.Res.texSquare;
    local pixel = pp.px;

    GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.edgeFile = texSquare;
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

    -- tooltip status bar

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
        edgeFile = texSquare,
        edgeSize = pixel,
    });
    GameTooltipStatusBar:SetStatusBarTexture(texSquare);

    local hpPercentage = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpPercentage:SetWidth(60);
    hpPercentage:SetJustifyH("RIGHT");
    hpPercentage:SetPoint("LEFT", -8, 0);

    local hpValue = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    hpValue:SetJustifyH("RIGHT");
    hpValue:SetPoint("RIGHT", -2 * pixel, 0);

    function updateStatusBarText(self)
        local currentValue = self:GetValue();
        local _, maxValue = self:GetMinMaxValues();
        hpPercentage:SetFormattedText("%.1f%%", currentValue / maxValue * 100);
        if currentValue <= 1 and maxValue == 1 then
            hpValue:SetText("");
        else
            hpValue:SetFormattedText("%d", currentValue);
        end
    end

    GameTooltipStatusBar:HookScript("OnShow", updateStatusBarText);
    GameTooltipStatusBar:HookScript("OnValueChanged", updateStatusBarText);
end);

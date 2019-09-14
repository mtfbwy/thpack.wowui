P.ask("pp").answer("reCastBar", function(pp)

    local texSquare = Addon.Res.texSquare;
    local pixel = pp.px;
    local dp = pp.dp;

    local castBar = CastingBarFrame;

    -- layerLevel:BACKGROUND
    local regions = { castBar:GetRegions() };
    for i = 1, #regions do
        local region = regions[i];
        if region:GetObjectType() == "Texture" and not region:GetName() then
            local r, g, b, a = region:GetVertexColor();
            if r == 0 and g == 0 and b == 0 and a == 0.5 then
                region:SetTexture(nil);
            end
        end
    end

    -- layerLevel:ARTWORK
    castBar.Border:SetTexture(nil);
    castBar.BorderShield:SetTexture(nil);
    castBar.nameText = castBar.Text;
    castBar.icon = castBar.Icon;

    -- layerLevel:OVERLAY, alphaMode:ADD
    castBar.Spark:SetTexture(nil);
    castBar.Flash:SetTexture(nil);

    -- complete it

    castBar:SetSize(240 * dp, 24 * dp);
    castBar:SetBackdrop({
        bgFile = nil,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        },
        tile = false,
        tileSize = 0,
        edgeFile = texSquare,
        edgeSize = pixel,
    });
    castBar:SetBackdropBorderColor(1, 1, 1);
    castBar:SetStatusBarTexture(texSquare);
    castBar:SetStatusBarColor(1, 0.7, 0, 1);
    castBar:SetMinMaxValues(0, 1);
    castBar:SetValue(0.7749); -- for test

    if not castBar.nameText then
        castBar.nameText = castBar:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Small");
    end
    local nameText = castBar.nameText;
    nameText:SetJustifyH("LEFT");
    nameText:ClearAllPoints();
    nameText:SetPoint("LEFT", 2 * pixel, 0);
    nameText:SetPoint("RIGHT");

    if not castBar.numberText then
        castBar.numberText = castBar:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Small");
    end
    local numberText = castBar.numberText;
    numberText:SetJustifyH("RIGHT");
    numberText:ClearAllPoints();
    numberText:SetPoint("LEFT");
    numberText:SetPoint("RIGHT", -2 * pixel, 0);

    if not castBar.iconFrame then
        castBar.iconFrame = CreateFrame("frame", nil, castBar);
    end
    local iconFrame = castBar.iconFrame;
    iconFrame:SetFrameStrata(castBar:GetFrameStrata());
    iconFrame:SetFrameLevel(castBar:GetFrameLevel());
    local iconFrameSize = castBar:GetHeight() * 1.5 + 4 * dp;
    iconFrame:SetSize(iconFrameSize, iconFrameSize);
    iconFrame:SetBackdrop({
        bgFile = texSquare,
        insets = {
            left = -pixel,
            right = -pixel,
            top = -pixel,
            bottom = -pixel,
        },
        tile = false,
        tileSize = 0,
        edgeFile = texSquare,
        edgeSize = pixel,
    });
    iconFrame:SetBackdropColor(0, 0, 0, 0.15);
    iconFrame:SetPoint("RIGHT", castBar, "LEFT", -8 * dp, 0);

    if not castBar.icon then
        castBar.icon = castBar:CreateTexture(nil, "ARTWORK", nil, 1);
    end
    local icon = castBar.icon;
    icon:SetTexCoord(5/64, 59/64, 5/64, 59/64); -- get rid of border
    icon:SetParent(iconFrame);
    icon:ClearAllPoints();
    icon:SetPoint("TOPLEFT", 2 * pixel, -2 * pixel);
    icon:SetPoint("BOTTOMRIGHT", -2 * pixel, 2 * pixel);
    icon:Show();

    castBar:HookScript("OnUpdate", function(self, elapsed)
        local eta = 0;
        if self.casting then
            eta = self.maxValue - self.value;
        end
        if self.channeling then
            eta = self.value;
        end
        if eta < 0 then
            eta = 0;
        end
        self.numberText:SetFormattedText("%.1f", eta);
    end);
end);

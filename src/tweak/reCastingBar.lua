P.ask("Env").answer("reCastingBar", function(Env)

    local pixel = Env.pixel;
    local dip = Env.dip;

    local castingBar = CastingBarFrame;

    -- layerLevel:BACKGROUND
    local regions = { castingBar:GetRegions() };
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
    castingBar.Border:SetTexture(nil);
    castingBar.BorderShield:SetTexture(nil);
    castingBar.nameText = castingBar.Text;
    castingBar.icon = castingBar.Icon;

    -- layerLevel:OVERLAY, alphaMode:ADD
    castingBar.Spark:SetTexture(nil);
    castingBar.Flash:SetTexture(nil);

    -- complete it

    castingBar:SetSize(240 * dip, 24 * dip);
    castingBar:SetBackdrop({
        bgFile = nil,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        },
        tile = false,
        tileSize = 0,
        edgeFile = Env.texture.SQUARE,
        edgeSize = pixel,
    });
    castingBar:SetBackdropBorderColor(1, 1, 1);
    castingBar:SetStatusBarTexture(Env.texture.SQUARE);
    castingBar:SetStatusBarColor(1, 0.7, 0, 1);
    castingBar:SetMinMaxValues(0, 1);
    castingBar:SetValue(0.7749); -- for test

    if not castingBar.nameText then
        castingBar.nameText = castingBar:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Small");
    end
    local nameText = castingBar.nameText;
    nameText:SetJustifyH("LEFT");
    nameText:ClearAllPoints();
    nameText:SetPoint("LEFT", 2 * pixel, 0);
    nameText:SetPoint("RIGHT");

    if not castingBar.numberText then
        castingBar.numberText = castingBar:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Small");
    end
    local numberText = castingBar.numberText;
    numberText:SetJustifyH("RIGHT");
    numberText:ClearAllPoints();
    numberText:SetPoint("LEFT");
    numberText:SetPoint("RIGHT", -2 * pixel, 0);

    if not castingBar.iconFrame then
        castingBar.iconFrame = CreateFrame("frame", nil, castingBar);
    end
    local iconFrame = castingBar.iconFrame;
    iconFrame:SetFrameStrata(castingBar:GetFrameStrata());
    iconFrame:SetFrameLevel(castingBar:GetFrameLevel());
    local iconFrameSize = castingBar:GetHeight() * 1.5 + 4 * dip;
    iconFrame:SetSize(iconFrameSize, iconFrameSize);
    iconFrame:SetBackdrop({
        bgFile = Env.texture.SQUARE,
        insets = {
            left = -pixel,
            right = -pixel,
            top = -pixel,
            bottom = -pixel,
        },
        tile = false,
        tileSize = 0,
        edgeFile = Env.texture.SQUARE,
        edgeSize = pixel,
    });
    iconFrame:SetBackdropColor(0, 0, 0, 0.15);
    iconFrame:SetPoint("RIGHT", castingBar, "LEFT", -8 * dip, 0);

    if not castingBar.icon then
        castingBar.icon = castingBar:CreateTexture(nil, "ARTWORK", nil, 1);
    end
    local icon = castingBar.icon;
    icon:SetTexCoord(5/64, 59/64, 5/64, 59/64); -- get rid of border
    icon:SetParent(iconFrame);
    icon:ClearAllPoints();
    icon:SetPoint("TOPLEFT", 2 * pixel, -2 * pixel);
    icon:SetPoint("BOTTOMRIGHT", -2 * pixel, 2 * pixel);
    icon:Show();

    castingBar:HookScript("OnUpdate", function(self, elapsed)
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

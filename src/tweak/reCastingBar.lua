T.ask("resource", "env", "api").answer(function(res, env, api)

    local function completeCastingBar(castingBar)
        if not castingBar.nameText then
            castingBar.nameText = castingBar:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Small");
        end
        local nameText = castingBar.nameText;
        nameText:SetJustifyH("LEFT");
        nameText:ClearAllPoints();
        --nameText:SetPoint("TOP", 0, 5);
        nameText:SetPoint("LEFT", 2 * env.dotsPerPixel, 0);
        nameText:SetPoint("RIGHT");

        if not castingBar.numberText then
            castingBar.numberText = castingBar:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Small");
        end
        local numberText = castingBar.numberText;
        numberText:SetJustifyH("RIGHT");
        numberText:ClearAllPoints();
        numberText:SetPoint("LEFT");
        numberText:SetPoint("RIGHT", -2 * env.dotsPerPixel, 0);

        if not castingBar.icon then
            castingBar.icon = castingBar:CreateTexture(nil, "ARTWORK", nil, 1);
        end
        castingBar.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64); -- get rid of border
    end

    local function recreateBlizCastingBar(castingBar)
        -- layerLevel:BACKGROUND
        local regions = { castingBar:GetRegions() };
        for i = 1, #regions do
            local v = regions[i];
            if v:GetObjectType() == "Texture" and not v:GetName() then
                local r, g, b, a = v:GetVertexColor();
                if r == 0 and g == 0 and b == 0 and a == 0.5 then
                    v:SetTexture(nil);
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

        completeCastingBar(castingBar);

        api.setFrameBackdrop(CastingBarFrame, 1, 0);
        castingBar:SetMinMaxValues(0, 1);
        castingBar:SetStatusBarTexture(res.texture.SQUARE);
        castingBar:SetValue(0.7749); -- for test

        return castingBar;
    end

    local castingBar = CastingBarFrame;

    recreateBlizCastingBar(castingBar);
    castingBar:SetSize(240 * env.dotsRelative, 24 * env.dotsRelative);

    if not castingBar.iconFrame then
        castingBar.iconFrame = CreateFrame("frame", nil, castingBar);
    end
    local iconFrame = castingBar.iconFrame;
    api.setFrameBackdrop(iconFrame, 1, 1);
    iconFrame:SetFrameStrata(castingBar:GetFrameStrata());
    iconFrame:SetFrameLevel(castingBar:GetFrameLevel());
    local size = castingBar:GetHeight() * 1.5 + 4 * env.dotsRelative;
    iconFrame:SetSize(size, size);
    iconFrame:SetPoint("RIGHT", castingBar, "LEFT", -8 * env.dotsRelative, 0);

    local icon = castingBar.icon;
    icon:SetParent(iconFrame);
    icon:ClearAllPoints();
    icon:SetPoint("TOPLEFT", 2 * env.dotsRelative, -2 * env.dotsRelative);
    icon:SetPoint("BOTTOMRIGHT", -2 * env.dotsRelative, 2 * env.dotsRelative);
    icon:Show();

    castingBar:HookScript("OnUpdate", function(self, elapsed)
        local etc = 0;
        if self.casting then
            etc = self.maxValue - self.value;
        end
        if self.channeling then
            etc = self.value;
        end
        if etc < 0 then
            etc = 0;
        end
        self.numberText:SetFormattedText("%.1f", etc);
    end);
end);

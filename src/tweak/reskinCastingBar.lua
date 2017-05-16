T.ask("resource", "env", "api").answer(function(res, env, api)
    CastingBarFrame:SetStatusBarTexture(res.texture.SQUARE);
    CastingBarFrame:SetSize(240 * env.dotsRelative, 24 * env.dotsRelative);
    api.setFrameBackdrop(CastingBarFrame, 1, 0);

    local list = { CastingBarFrame:GetRegions() };
    for i = 1, #list do
        local v = list[i];
        if v:GetObjectType() == "Texture" and not v:GetName() then
            local r, g, b, a = v:GetVertexColor();
            if r == 0 and g == 0 and b == 0 and a == 0.5 then
                v:Hide();
            end
        end
    end
    list = nil;

    CastingBarFrame.Spark:SetTexture(nil);
    CastingBarFrame.Spark:Hide();

    CastingBarFrame.Flash:SetTexture(nil);
    CastingBarFrame.Flash:Hide();

    CastingBarFrame.Border:SetTexture(nil);
    CastingBarFrame.Border:Hide();

    CastingBarFrame.Text:SetFont(res.font.DEFAULT, 20 * env.dotsRelative);
    CastingBarFrame.Text:SetSize(240 * env.dotsRelative, 20 * env.dotsRelative);
    CastingBarFrame.Text:SetJustifyH("left");
    CastingBarFrame.Text:ClearAllPoints();
    CastingBarFrame.Text:SetPoint("left", CastingBarFrame, "left", 2 * env.dotsRelative, 0);

    local etcText = CastingBarFrame:CreateFontString();
    etcText:SetJustifyH("right");
    etcText:SetJustifyV("bottom");
    etcText:SetFont(res.font.DEFAULT, 20 * env.dotsRelative);
    etcText:SetSize(240 * env.dotsRelative, 20 * env.dotsRelative);
    etcText:SetPoint("right", CastingBarFrame, "right", -4 * env.dotsRelative, 0);

    local iconFrame = CreateFrame("frame", nil, CastingBarFrame);
    iconFrame:SetFrameStrata(CastingBarFrame:GetFrameStrata());
    iconFrame:SetFrameLevel(CastingBarFrame:GetFrameLevel());
    iconFrame:SetSize(40 * env.dotsRelative, 40 * env.dotsRelative);
    api.setFrameBackdrop(iconFrame, 1, 1);
    iconFrame:SetPoint("right", CastingBarFrame, "left", -8 * env.dotsRelative, 0);

    CastingBarFrame.Icon:SetTexCoord(5/64, 1 - 5/64, 5/64, 1 - 5/64);
    CastingBarFrame.Icon:ClearAllPoints();
    CastingBarFrame.Icon:SetParent(iconFrame);
    CastingBarFrame.Icon:SetPoint("topleft", 2 * env.dotsRelative, -2 * env.dotsRelative);
    CastingBarFrame.Icon:SetPoint("bottomright", -2 * env.dotsRelative, 2 * env.dotsRelative);
    CastingBarFrame.Icon:Show();

    local tick = 0;
    CastingBarFrame:HookScript("OnUpdate", function(self, elapsed)
        if self.casting then
            tick = self.maxValue - self.value;
        end
        if self.channeling then
            tick = self.value;
        end
        if tick < 0 then
            tick = 0;
        end
        etcText:SetFormattedText("%.1f", tick);
    end);
end);

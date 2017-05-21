T.ask("resource", "env", "api").answer("Bar", function(res, env, api)

    local function createProgressbar(parentView, backdropOutsetPixels)
        local bar = api.createFrame("statusbar", parentView);
        api.setFrameBackdrop(bar, 0, backdropOutsetPixels); -- 边框透明
        bar:SetMinMaxValues(0, 1);
        bar:SetStatusBarTexture(res.texture.SQUARE);
        bar:SetStatusBarColor(res.color.toSequence("008000")); -- for test
        bar:SetValue(0.8); -- for test

        local text1 = bar:CreateFontString();
        text1:SetFont(res.font.DEFAULT, 14 * env.dotsRelative, "outline");
        text1:SetJustifyH("left");
        text1:SetPoint("left", 2 * env.dotsPerPixel, -env.dotsPerPixel);
        bar.text1 = text1;

        local text2 = bar:CreateFontString();
        text2:SetFont(res.font.DEFAULT, 14 * env.dotsRelative, "outline");
        text2:SetJustifyH("right");
        text2:SetPoint("right", -env.dotsPerPixel, env.dotsPerPixel);
        bar.text2 = text2;

        return bar;
    end

    local function updateBar(bar, v, maxV)
        if maxV and maxV > 0 then
            bar:SetValue(v / maxV);
            bar.text2:SetFormattedText("%d", v);
        else
            bar:SetValue(0);
            bar.text2:SetText("");
        end
    end

    local function updateHpBar(bar, unit)
        local hp, maxHp = api.getUnitHp(unit);
        updateBar(bar, hp, maxHp);
    end

    local function updateMpBar(bar, unit)
        local mp, maxMp = api.getUnitMp(unit);
        updateBar(bar, mp, maxMp);
        bar:SetStatusBarColor(res.color.toSequence(res.color.fromPower(unit)));
    end

    local function createCastingBar(parentView)
        local castingBar = createProgressbar(parentView, 0);
        castingBar:SetFrameLevel(2);
        castingBar.icon = iconView;
        castingBar:Hide();

        local castingIcon = castingBar:CreateTexture(nil, "artwork", nil, 1);
        castingIcon:SetTexCoord(5/64, 59/64, 5/64, 59/64); -- get rid of border
        castingIcon:SetTexture(nil);
        castingBar.icon = castingIcon;

        return castingBar;
    end

    local function clearCastingBar(castingBar)
        castingBar:Hide();
        castingBar.text1:SetText();
        castingBar.text2:SetText();
        if castingBar.icon then
            castingBar.icon:SetTexture(nil);
        end
        castingBar:Hide();
    end

    local function setCastingbarShielded(castingBar, isShielded)
        local color = isShielded and "coral" or "gold";
        castingBar:SetStatusBarColor(res.color.toSequence(color));
    end

    local function updateCastingBar(castingBar, elapsed, total, isChannelling)
        -- TODO when channelling, the boundary remains left to right
        -- but the active texture is in the right
        if elapsed >= total then
            clearCastingBar(castingBar)
        else
            castingBar:SetValue(elapsed / total);
            castingBar.text2:SetFormattedText("%.1f", total - elapsed);
            castingBar:Show();
        end
    end

    local function initializeCastingBar(castingBar, unit)
        local isChannelling = nil;
        local name, _, _, texture, startTime, endTime, _, _, shielded = UnitCastingInfo(unit)
        if startTime and endTime then
            isChannelling = false;
        else
            name, _, _, texture, startTime, endTime, _, shielded = UnitChannelInfo(unit)
            if startTime and endTime then
                isChannelling = true;
            else
                -- in case the last target is casting
                clearCastingBar(castingBar);
                return;
            end
        end

        startTime = startTime / 1000;
        endTime = endTime / 1000;
        local curTime = GetTime();
        if endTime < curTime then
            clearCastingBar(castingBar);
            return;
        end

        local elapsed = curTime - startTime;
        local total = endTime - startTime;

        if castingBar.icon then
            castingBar.icon:SetTexture(texture);
        end

        castingBar.text1:SetText(name);

        setCastingbarShielded(castingBar, shielded);
        updateCastingBar(castingBar, elapsed, total, isChannelling);

        return elapsed, total, isChannelling;
    end

    return {
        createHpBar = createProgressbar,
        updateHpBar = updateHpBar,
        createMpBar = createProgressbar,
        updateMpBar = updateMpBar,
        createCastingBar = createCastingBar,
        initializeCastingBar = initializeCastingBar,
        updateCastingBar = updateCastingBar,
        setCastingbarShielded = setCastingbarShielded,
    };
end);

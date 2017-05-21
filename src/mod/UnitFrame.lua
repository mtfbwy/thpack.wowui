T.ask("resource", "env", "api", "Bar", "ClassIcon").answer("UnitFrame", function(res, env, api, Bar, ClassIcon)

    local function createPortraitFrame(parent)
        local frame = api.createFrame("frame", parent);
        api.setFrameBackdrop(frame, 2, 1);
        frame:SetFrameStrata("medium");
        frame:SetFrameLevel(1);

        frame.glow = api.createFrameGlow(frame, 1);
        frame.glow:SetFrameStrata("low");
        frame.glow:SetFrameLevel(0);

        -- 动态头像
        -- local portrait3d = CreateFrame("PlayerModel", nil, frame);
        -- portrait3d:SetPoint("topleft", 3 * env.dotsPerPixel, -3 * env.dotsPerPixel);
        -- portrait3d:SetPoint("bottomright", -3 * env.dotsPerPixel, 3 * env.dotsPerPixel);

        -- 静态头像
        local portrait2d = frame:CreateTexture(nil, "artwork", nil, 0);
        portrait2d:SetTexCoord(5/64, 59/64, 5/64, 59/64);
        -- portrait2d:SetDrawLayer("artwork");
        portrait2d:SetPoint("topleft", 3 * env.dotsPerPixel, -3 * env.dotsPerPixel);
        portrait2d:SetPoint("bottomright", -3 * env.dotsPerPixel, 3 * env.dotsPerPixel);
        frame.portrait = portrait2d;

        return frame;
    end

    local function createBarFrame(parent)
        local frame = api.createFrame("frame", parent);
        api.setFrameBackdrop(frame, 0, 1);
        frame:SetBackdropBorderColor(res.color.toSequence("00000000"));

        frame.glow = api.createFrameGlow(frame, 1);

        local hpBar = Bar.createHpBar(frame, 0);
        hpBar:SetPoint("topleft");
        hpBar:SetPoint("topright");
        frame.hpBar = hpBar;

        local mpBar = Bar.createMpBar(frame, 0);
        mpBar:SetPoint("bottomleft");
        mpBar:SetPoint("bottomright");
        frame.mpBar = mpBar;

        return frame;
    end

    local function createHierarchy(parent)
        local unitFrame = api.createFrame("frame", parent);
        unitFrame:SetSize(200 * env.dotsRelative, 68 * env.dotsRelative);

        local idText = unitFrame:CreateFontString();
        idText:SetSize(140 * env.dotsRelative, 24 * env.dotsRelative);
        idText:SetPoint("topright");
        idText:SetFont(res.font.DEFAULT, 24 * env.dotsRelative, "outline");
        idText:SetJustifyH("left");
        idText:SetJustifyV("bottom");
        unitFrame.idText = idText;

        local imageFrame = createPortraitFrame(unitFrame);
        imageFrame:SetSize(40 * env.dotsRelative, 40 * env.dotsRelative);
        imageFrame:SetPoint("topleft", 16 * env.dotsRelative, 0);
        unitFrame.imageFrame = imageFrame;

        local classIcon = ClassIcon.create(imageFrame);
        classIcon:SetAllPoints();
        imageFrame.classIcon = classIcon;

        local barFrame = createBarFrame(unitFrame);
        barFrame:SetPoint("bottomleft");
        barFrame:SetPoint("bottomright");
        barFrame:SetHeight(40 * env.dotsRelative);
        barFrame.hpBar:SetHeight(23 * env.dotsRelative);
        barFrame.mpBar:SetHeight(16 * env.dotsRelative);
        unitFrame.barFrame = barFrame;

        -- 施法图标(高优先级)
        -- 1.被变形意味着施法被打断
        -- 2.不会在读条的同时变换形态
        -- 3.极少在读条过程中换装备
        -- 基于以上三点，施法图标和头像可以共用
        -- 基于同样的理由，施法条和能量条也可以共用
        -- 但是，不共用
        local castingBar = Bar.createCastingBar(barFrame);
        castingBar:SetAllPoints(barFrame.mpBar);
        castingBar.icon:SetAllPoints(imageFrame.portrait);
        barFrame.castingBar = castingBar;

        return unitFrame;
    end

    function updateIdText(unitFrame, unit)
        local idText = unitFrame.idText;

        local id = UnitName(unit);
        if not UnitIsSameServer("player", unit) then
            id = "*" .. id;
        end
        idText:SetText(id);

        local classColor;
        if UnitIsPlayer(unit) then
            classColor = res.color.fromClass(unit);
        else
            classColor = "7B7B7B";
        end
        idText:SetTextColor(res.color.toSequence(classColor));
    end

    function updateUnitFramePortrait(unitFrame, unit)
        local portrait = unitFrame.imageFrame.portrait;

        if not UnitIsConnected(unit) then
            portrait:SetTexture("TODO");
            return;
        end

        SetPortraitTexture(portrait, unit);

        -- 动态头像
        -- local portrait3d = unitFrame.imageFrame.portrait3d;
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
    end

    -- TODO hostile change could be caused by duel start/end, reputation changed, etc
    function updateHostile(unitFrame, unit)
        local hostileColor = res.color.fromAttidute(unit);
        unitFrame.imageFrame:SetBackdropBorderColor(res.color.toSequence(hostileColor));
    end

    function update(unitFrame, unit)
        if not UnitExists(unit) then
            unitFrame:Hide();
            return;
        end

        if not unitFrame:IsShown() then
            unitFrame:Show();
        end

        updateIdText(unitFrame, unit);
        updateHostile(unitFrame, unit);

        ClassIcon.update(unitFrame.imageFrame.classIcon, unit);

        updateUnitFramePortrait(unitFrame, unit);
        Bar.updateHpBar(unitFrame.barFrame.hpBar, unit);
        Bar.updateMpBar(unitFrame.barFrame.mpBar, unit);
        Bar.initializeCastingBar(unitFrame.barFrame.castingBar, unit);
    end

    return {
        create = createHierarchy,
        update = update;
        updatePortrait = updateUnitFramePortrait;
    };
end);

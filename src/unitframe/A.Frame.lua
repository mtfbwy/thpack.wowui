P.ask("pp").answer("A.Frame", function(pp)

    local px = pp.px;
    local dp = pp.dp;

    -- border-box
    function createFrame(parentFrame)
        local f = CreateFrame("Frame", nil, parentFrame, nil);
        f:SetFrameStrata("BACKGROUND");
        f:SetFrameLevel(1);
        return f;
    end

    -- border is usually frame backdrop
    function createBorderFrame(parentFrame, backdrop)
        if (parentFrame == nil) then
            error("NullPointerException");
            return;
        end

        local frame = createFrame(parentFrame);
        frame:SetBackdrop(backdrop);
        frame:SetPoint("TOPLEFT", -backdrop.edgeSize, backdrop.edgeSize);
        frame:SetPoint("BOTTOMRIGHT", backdrop.edgeSize, -backdrop.edgeSize);
        return frame;
    end

    function createDefaultGlowFrame(parentFrame)
        if (parentFrame == nil) then
            error("NullPointerException");
            return;
        end

        locla frame = createBorderFrame(parentFrame, {
            edgeFile = A.Res.glow1,
            edgeSize = 5 * px,
        });
        frame:SetBackdropBorderColor(0, 0, 0, 0.85);
        return frame;
    end

    function setFrameDefaultBorder(frame)
        if (frame == nil) then
            error("NullPointerException");
            return;
        end

        local pixelBackdrop = {
            edgeFile = A.Res.texBackground,
            edgeSize = 1 * px,
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            tile = false,
            tileSize = 0,
            insets = {
                left = -1 * px,
                right = -1 * px,
                top = -1 * px,
                bottom = -1 * px,
            },
        };

        if (frame:GetObjectType() == "StatusBar") then
            createBorderFrame(frame, pixelBackdrop);
        else
            frame:SetBackdrop(pixelBackdrop);
        end
    end

    -- no size, position
    function createProgressBar(parentFrame)
        local f = CreateFrame("StatusBar", nil, parentFrame, nil);
        f:SetFrameStrata("BACKGROUND");
        f:SetFrameLevel(1);
        f:SetStatusBarTexture(A.Res.texBar);
        f:SetMinMaxValues(0, 1);
        f:SetValue(0.7749);
        return f;
    end

    function createTextRegion(parentFrame)
        return parentFrame:CreateFontString(nil, "ARTWORK", "TextStatusBarText");
    end

    function createIconRegion(parentFrame)
        local icon = parentFrame:CreateTexture(nil, "ARTWORK", nil, 0);
        icon:SetTexCoord(5/64, 59/64, 5/64, 59/64); -- cut off border
        return icon;
    end

    A.Frame = {
        createFrame = createFrame,
        createBorderFrame = createBorderFrame,
        createDefaultGlowFrame = createDefaultGlowFrame,
        setFrameDefaultBorder = setFrameDefaultBorder,
        createProgressBar = createProgressBar,
        createTextRegion = createTextRegion,
        createIconRegion = createIconRegion,
    };
end);

A.Frame = (function()

    -- border is usually frame backdrop
    -- that makes frame a "border-box"
    -- for pixel style,
    --  background: rgba(0, 0, 0, 0.4);
    --  margin: 1px;
    --  border: 1px white;
    --  padding: 1px;

    -- border-box
    function createFrame(parentFrame)
        local f = CreateFrame("Frame", nil, parentFrame, nil);
        f:SetFrameStrata("BACKGROUND");
        f:SetFrameLevel(1);
        return f;
    end

    -- content-box
    function createBorderFrame(parentFrame, backdrop, borderOffset)
        if (parentFrame == nil) then
            error("NullPointerException");
            return;
        end

        borderOffset = borderOffset or backdrop.edgeSize;
        local frame = createFrame(parentFrame);
        frame:SetBackdrop(backdrop);
        frame:SetPoint("TOPLEFT", -borderOffset, borderOffset);
        frame:SetPoint("BOTTOMRIGHT", borderOffset, -borderOffset);
        return frame;
    end

    function createDefaultGlowFrame(parentFrame)
        if (parentFrame == nil) then
            error("NullPointerException");
            return;
        end

        locla frame = createBorderFrame(parentFrame, {
            edgeFile = A.Res.path .. "/3p/glow.tga",
            edgeSize = 5,
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
            edgeFile = A.Res.tile32,
            edgeSize = 1,
            bgFile = A.Res.tile32,
            tile = false,
            tileSize = 0,
            insets = {
                left = -1,
                right = -1,
                top = -1,
                bottom = -1,
            },
        };

        if (frame:GetObjectType() == "StatusBar") then
            local borderFrame = createBorderFrame(frame, pixelBackdrop, 2);
            borderFrame:SetBackdropColor(0, 0, 0, 0.15);
        else
            frame:SetBackdrop(pixelBackdrop);
            frame:SetBackdropColor(0, 0, 0, 0.15);
        end
    end

    -- no size, position
    function createProgressBar(parentFrame)
        local f = CreateFrame("StatusBar", nil, parentFrame, nil);
        f:SetFrameStrata("BACKGROUND");
        f:SetFrameLevel(1);
        f:SetStatusBarTexture(A.Res.hpbar32);
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

    return {
        createFrame = createFrame,
        createBorderFrame = createBorderFrame,
        createDefaultGlowFrame = createDefaultGlowFrame,
        setFrameDefaultBorder = setFrameDefaultBorder,
        createProgressBar = createProgressBar,
        createTextRegion = createTextRegion,
        createIconRegion = createIconRegion,
    };
end)();

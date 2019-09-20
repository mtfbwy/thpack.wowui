A.Frame = (function()

    function safeInvoke(callback, f)
        if (not InCombatLockdown()) then
            callback();
            return;
        end
        if (f == nil) then
            f = CreateFrame("Frame");
        end
        f:RegisterEvent("PLAYER_REGEN_ENABLED");
        f:SetScript("OnEvent", function(self, event)
            self:UnregisterAllEvents();
            self:SetScript("OnEvent", nil);
            callback();
        end);
    end

    function attachEvents(frame, events)
        frame.events = frame.events or {};
        table.merge(frame.events, events);
        for event, handler in pairs(events) do
            frame:RegisterEvent(event)
        end
        frame:SetScript("OnEvent", function(self, event, ...)
            local handler = self.events[event];
            if (type(handler) == "function") then
                handler(self, ...);
            end
        end);
    end

    -- frame strata > frame level
    local FrameStratas = {
        "BACKGROUND",
        "LOW",
        "MEDIUM",
        "HIGH",
        "DIALOG",
        "FULLSCREEN",
        "FULLSCREEN_DIALOG",
        "TOOLTIP",
    };

    local TextureLayers = {
        "BACKGROUND",
        "BORDER",
        "ARTWORK",
        "OVERLAY",
        "HIGHLIGHT",
    };

    -- border is usually frame backdrop
    -- that makes frame a "border-box"
    -- for pixel style,
    --  background: rgba(0, 0, 0, 0.4);
    --  margin: 1px;
    --  border: 1px white;
    --  padding: 1px;

    function createFrame(parentFrame, major, minor)
        major = major or 1; -- default to "BACKGROUND"
        minor = minor or 1;
        local f = CreateFrame("Frame", nil, parentFrame, nil);
        f:SetFrameStrata(FrameStratas[major]);
        f:SetFrameLevel(minor);
        return f;
    end

    function createDragAnchorFrame(parentFrame)
        local anchorFrame = createFrame(parentFrame);
        anchorFrame:SetSize(40, 10);
        anchorFrame:SetBackdrop({
            bgFile = A.Res.tile32
        });
        anchorFrame:SetBackdropColor(0, 0, 0, 0);

        anchorFrame:SetMovable(true);
        anchorFrame:RegisterForDrag("LeftButton");
        anchorFrame:SetScript("OnMouseDown", function(self, button)
            if (IsLeftControlKeyDown() and button == "LeftButton") then
                self:StartMoving();
            end
        end);
        anchorFrame:SetScript("OnMouseUp", function(self, button)
            self:StopMovingOrSizing();
        end);

        anchorFrame:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.2);
            GameTooltip:SetOwner(self);
            GameTooltip:AddLine("hold <Ctrl> to drag");
            GameTooltip:Show();
        end);
        anchorFrame:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0);
            GameTooltip:Hide();
        end);

        return anchorFrame;
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

    -- no size or position
    function createProgressBar(parentFrame, major, minor)
        major = major or 1;
        minor = minor or 1;

        local f = CreateFrame("StatusBar", nil, parentFrame, nil);
        f:SetFrameStrata(FrameStratas[major]);
        f:SetFrameLevel(1);
        f:SetStatusBarTexture(A.Res.hpbar32);
        f:SetMinMaxValues(0, 1);
        f:SetValue(0.7749);
        return f;
    end

    function createTextRegion(parentFrame)
        return parentFrame:CreateFontString(nil, "ARTWORK", "TextStatusBarText");
    end

    function createTextureRegion(parentFrame, major, minor)
        major = major or 3;  -- default to "ARTWORK"
        minor = minor or 1;
        return parentFrame:CreateTexture(nil, TextureLayers[major], nil, minor);
    end

    -- cut off texture border
    function cropTextureRegion(textureRegion)
        textureRegion:SetTexCoord(5/64, 59/64, 5/64, 59/64);
        return textureRegion;
    end

    return {
        createFrame = createFrame,
        createBorderFrame = createBorderFrame,
        createDefaultGlowFrame = createDefaultGlowFrame,
        setFrameDefaultBorder = setFrameDefaultBorder,
        createProgressBar = createProgressBar,
        createTextRegion = createTextRegion,
        createTextureRegion = createTextureRegion,
        cropTextureRegion = cropTextureRegion,
    };
end)();

addonName, addon = ...;

if (addon.FrameBook) then
    return;
end

addon.FrameBook = {};
local FrameBook = addon.FrameBook;

FrameBook.safeInvoke = FrameBook.safeInvoke or function(callback, f)
    if (not InCombatLockdown()) then
        callback();
        return;
    end
    if (f == nil) then
        f = CreateFrame("Frame");
    end
    f:RegisterEvent("PLAYER_REGEN_ENABLED");
    f:SetScript("OnEvent", function(self, eventName)
        self:UnregisterAllEvents();
        self:SetScript("OnEvent", nil);
        callback();
    end);
end;

FrameBook.attachEventHandlers = FrameBook.attachEventHandlers or function(frame, eventHandlers)
    for eventName, handler in pairs(eventHandlers) do
        frame:RegisterEvent(eventName)
    end
    frame:SetScript("OnEvent", function(self, eventName, ...)
        local handler = eventHandlers[eventName];
        if (type(handler) == "function") then
            handler(self, ...);
        end
    end);
end;

FrameBook.createBlizzardRoundButton = FrameBook.createBlizzardRoundButton or function(parent, template, size)
    local button = CreateFrame("Button", nil, parent, template);
    button:SetSize(size, size);

    local highlightTexture = button:CreateTexture(nil, "HIGHLIGHT");
    highlightTexture:SetTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]]);
    highlightTexture:SetPoint("TOPLEFT", size * -1/64, size * 1/64);
    highlightTexture:SetPoint("BOTTOMRIGHT", size * -1/64, size * 1/64);
    button:SetHighlightTexture(highlightTexture);

    local backgroundTexture = button:CreateTexture(nil, "BACKGROUND");
    backgroundTexture:SetTexture([[Interface\Minimap\UI-Minimap-Background]]);
    backgroundTexture:SetVertexColor(0, 0, 0, 0.6);
    backgroundTexture:SetPoint("TOPLEFT", size * 4/64, "TOPLEFT", size * -4/64);
    backgroundTexture:SetPoint("BOTTOMRIGHT", size * -4/64, "TOPLEFT", size * 4/64);

    local borderTexture = button:CreateTexture(nil, "OVERLAY");
    borderTexture:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]]);
    borderTexture:SetTexCoord(0, 38/64, 0, 38/64);
    borderTexture:SetAllPoints();

    local artworkTexture = button:CreateTexture(nil, "ARTWORK");
    artworkTexture:SetPoint("TOPLEFT", size * 12/64, size * -10/64);
    artworkTexture:SetPoint("BOTTOMRIGHT", size * -12/64, size * 14/64);
    button.artworkTexture = artworkTexture;

    return button;
end;

table.merge(FrameBook, (function()

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

    local function createFrame(parentFrame, major, minor)
        major = major or 1; -- default to "BACKGROUND"
        minor = minor or 1;
        local f = CreateFrame("Frame", nil, parentFrame, nil);
        f:SetFrameStrata(FrameStratas[major]);
        f:SetFrameLevel(minor);
        return f;
    end

    local function createDraggerFrame(parentFrame)
        local draggerFrame = createFrame(parentFrame);
        draggerFrame:SetSize(40, 10);
        draggerFrame:SetBackdrop({
            bgFile = A.Res.tile32
        });
        draggerFrame:SetBackdropColor(0, 0, 0, 0);

        draggerFrame:SetMovable(true);
        draggerFrame:RegisterForDrag("LeftButton");
        draggerFrame:SetScript("OnMouseDown", function(self, button)
            if (IsLeftControlKeyDown() and button == "LeftButton") then
                self:StartMoving();
            end
        end);
        draggerFrame:SetScript("OnMouseUp", function(self, button)
            self:StopMovingOrSizing();
        end);

        draggerFrame:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.2);
            GameTooltip:SetOwner(self);
            GameTooltip:AddLine("hold <Ctrl> to drag");
            GameTooltip:Show();
        end);
        draggerFrame:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0);
            GameTooltip:Hide();
        end);

        return draggerFrame;
    end

    -- content-box
    local function createBorderFrame(parentFrame, backdrop, extraBorderOffset)
        if (parentFrame == nil) then
            error("NullPointerException");
            return;
        end

        local borderOffset = (backdrop.edgeSize or 0) + (extraBorderOffset or 0);
        local frame = createFrame(parentFrame);
        frame:SetBackdrop(backdrop);
        frame:SetPoint("TOPLEFT", -borderOffset, borderOffset);
        frame:SetPoint("BOTTOMRIGHT", borderOffset, -borderOffset);
        return frame;
    end

    local function createDefaultGlowFrame(parentFrame)
        if (parentFrame == nil) then
            error("NullPointerException");
            return;
        end

        local frame = createBorderFrame(parentFrame, {
            edgeFile = A.Res.path .. "/3p/glow.tga",
            edgeSize = 5,
        });
        frame:SetBackdropBorderColor(0, 0, 0, 0.85);
        return frame;
    end

    local function setFrameDefaultBorder(frame)
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
            local borderFrame = createBorderFrame(frame, pixelBackdrop, 1);
            borderFrame:SetBackdropColor(0, 0, 0, 0.15);
        else
            frame:SetBackdrop(pixelBackdrop);
            frame:SetBackdropColor(0, 0, 0, 0.15);
        end
    end

    -- no size or position
    local function createProgressBar(parentFrame, major, minor)
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

    local function createTextRegion(parentFrame)
        return parentFrame:CreateFontString(nil, "ARTWORK", "TextStatusBarText");
    end

    local function createTextureRegion(parentFrame, major, minor)
        major = major or 3;  -- default to "ARTWORK"
        minor = minor or 1;
        return parentFrame:CreateTexture(nil, TextureLayers[major], nil, minor);
    end

    -- cut off texture border
    local function cropTextureRegion(textureRegion)
        textureRegion:SetTexCoord(5/64, 59/64, 5/64, 59/64);
        return textureRegion;
    end

    return {
        createFrame = createFrame,
        createBorderFrame = createBorderFrame,
        createProgressBar = createProgressBar,
        cropTextureRegion = cropTextureRegion,
    };
end)());

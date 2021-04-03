local addonName, addon = ...;

local A = A;

local FrameBook = addon.FrameBook;

--------

local CellView = {};

-- 躯壳
-- never manipulate components outside the view
-- stick to view item
function CellView.newView(parent)
    local f = CreateFrame("Frame", nil, parent, nil);

    local mainImage = f:CreateTexture(nil, "BACKGROUND", nil, 1);
    --A.cropTextureRegion(mainImage);
    mainImage:SetAllPoints();
    f.mainImage = mainImage;

    -- borderImage BORDER:2

    local checkedStateImage = f:CreateTexture(nil, "OVERLAY", nil, 3);
    --A.cropTextureRegion(checkedStateImage);
    checkedStateImage:SetTexture("interface/buttons/CheckButtonHilight");
    checkedStateImage:SetBlendMode("ADD");
    checkedStateImage:SetAllPoints();
    f.checkedStateImage = checkedStateImage;

    -- mouse hover
    local hoveredStateImage = f:CreateTexture(nil, "OVERLAY", nil, 4);
    hoveredStateImage:SetTexture("interface/buttons/ButtonHilight-Square");
    hoveredStateImage:SetBlendMode("ADD");
    hoveredStateImage:SetAllPoints();
    f.hoveredStateImage = hoveredStateImage;

    -- keyboard focus
    local focusedStateImage = f:CreateTexture(nil, "OVERLAY", nil, 5);
    focusedStateImage:SetBlendMode("ADD");
    focusedStateImage:SetAllPoints();
    f.focusedStateImage = focusedStateImage;

    local pressedStateImage = f:CreateTexture(nil, "OVERLAY", nil, 6);
    pressedStateImage:SetTexture("interface/buttons/UI-Quickslot-Depress");
    pressedStateImage:SetBlendMode("ADD");
    pressedStateImage:SetAllPoints();
    f.pressedStateImage = pressedStateImage;

    local pinImage = f:CreateTexture(nil, "BACKGROUND", nil, 2);
    pinImage:SetColorTexture(Color.pick("magenta"):toVertex());
    pinImage:SetPoint("TOPRIGHT", -3, -3);
    pinImage:SetSize(4, 4);
    f.pinImage = pinImage;

    -- stack count for buff or recharge count for action
    local quantityText = f:CreateFontString(nil, "OVERLAY", nil);
    quantityText:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE");
    quantityText:SetShadowColor(0, 0, 0, 1);
    quantityText:SetShadowOffset(1, 1);
    quantityText:SetJustifyH("RIGHT");
    quantityText:SetPoint("BOTTOMRIGHT", ttlBar, "TOPRIGHT", -1, 2);
    f.quantityText = quantityText;

    -- buff: time to live
    local ttlBar = CreateFrame("StatusBar", nil, f, nil);
    ttlBar:SetStatusBarTexture(A.Res.tile32);
    ttlBar:SetStatusBarColor(0, 1, 0, 0.85);
    ttlBar:SetHeight(4);
    ttlBar:SetPoint("BOTTOMLEFT");
    ttlBar:SetPoint("BOTTOMRIGHT");
    ttlBar:SetMinMaxValues(0, 6);
    ttlBar:SetValue(0);
    f.ttlBar = ttlBar;

    -- action: time to cooldown
    local ttcBar = CreateFrame("StatusBar", nil, f, nil);
    ttcBar:SetStatusBarTexture(A.Res.tile32);
    ttcBar:SetStatusBarColor(1, 1, 1, 0.85);
    ttcBar:SetHeight(4);
    ttcBar:SetPoint("BOTTOMLEFT");
    ttcBar:SetPoint("BOTTOMRIGHT");
    ttcBar:SetMinMaxValues(0, 6);
    ttcBar:SetValue(0);
    ttcBar:SetFrameLevel(f.ttlBar:GetFrameLevel() + 1);
    f.ttcBar = ttcBar;

    local glowFrame = FrameBook.createBorderFrame(f, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 8,
    });
    f.glowFrame = glowFrame;

    return f;
end

-- only accept this kind of view item
-- very few and simple logic
function CellView.render(f, cellItem)
    if (not cellItem) then
        return;
    end

    if (cellItem.stateShown) then
        f:Show();
    else
        f:Hide();
        return;
    end

    f.mainImage:SetTexture(cellItem.textureId);

    f.mainImage:SetDesaturated(not cellItem.stateEnabled);

    if (cellItem.stateChecked) then
        f.checkedStateImage:Show();
    else
        f.checkedStateImage:Hide();
    end

    if (cellItem.stateHovered) then
        f.hoveredStateImage:Show();
    else
        f.hoveredStateImage:Hide();
    end

    if (cellItem.stateFocused) then
        f.focusedStateImage:Show();
    else
        f.focusedStateImage:Hide();
    end

    if (cellItem.statePressed) then
        f.pressedStateImage:Show();
    else
        f.pressedStateImage:Hide();
    end

    if (cellItem.hasPin) then
        f.pinImage:Show();
    else
        f.pinImage:Hide();
    end

    f.quantityText:SetText((cellItem.quantity or 0) > 1 and cellItem.quantity or nil);

    f.ttlBar:SetValue(cellItem.ttl or 0);

    f.ttcBar:SetValue(cellItem.ttc or 0);

    local glowColor = cellItem.glowColor or Color.pick("transparent");
    f.glowFrame:SetBackdropBorderColor(glowColor:toVertex());
end

--------

addon.CellItem = {};
local CellItem = addon.CellItem;

function CellItem.newItem()
    local o = {};
    setProto(o, CellItem);
    o:reset();
    return o;
end

function CellItem.reset(self)
    self.textureId = nil;
    self.stateShown = false;
    self.stateEnabled = false;
    self.stateChecked = false;
    self.stateHovered = false;
    self.stateFocused = false;
    self.statePressed = false;
    self.hasPin = nil;
    self.quantity = 0;
    self.ttl = 0;
    self.ttc = 0;
    self.glowColor = nil;
end

--------
-- CellCtrl controls grid layout and renders data to view

addon.CellCtrl = {};
local CellCtrl = addon.CellCtrl;

function CellCtrl.newCtrl(f)
    local o = {};
    setProto(o, CellCtrl);

    o.CELL_SIZE = 36;
    o.CELL_MARGIN = 4;
    o.X_SLOTS = 6;
    o.cellViews = {};

    if (not f) then
        f = CreateFrame("Frame", nil, UIParent, nil);
        f:SetPoint("TOPLEFT", UIParent, "CENTER");
        f:SetSize(1, 1);
    end
    o.f = f;

    return o;
end

function CellCtrl.getOrCreateCellView(self, i)
    local cellView = self.cellViews[i];
    if (not cellView) then
        cellView = CellView.newView(self.f);
        local j = i - 1;
        local yPos = math.floor(j / self.X_SLOTS);
        local xPos = j - yPos * self.X_SLOTS;
        cellView:ClearAllPoints();
        cellView:SetPoint("TOPLEFT", self.f, "TOPLEFT",
                xPos * (self.CELL_SIZE + self.CELL_MARGIN),
                yPos * (self.CELL_SIZE + self.CELL_MARGIN));
        cellView:SetSize(self.CELL_SIZE, self.CELL_SIZE);
        self.cellViews[i] = cellView;
    end
    return cellView;
end

function CellCtrl.render(self, cellItems)
    for i, cellItem in ipairs(cellItems) do
        local cellView = self:getOrCreateCellView(i);
        CellView.render(cellView, cellItem);
    end
    for i = array.size(cellItems) + 1, array.size(self.cellViews), 1 do
        local cellView = self.cellViews[i];
        cellView:Hide();
    end
end

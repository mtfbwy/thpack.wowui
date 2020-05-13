local A = A;

--------

local function activateBlizzardActionButtonOverlayGlow(spellId, enabled)
    local actionButtonGroups = {
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarLeftButton",
        "MultiBarRightButton"
    };
    for _, g in ipairs(actionButtonGroups) do
        for i = 1, 12 do
            local actionButton = _G[g .. i];
            local onEvent = actionButton:GetScript("OnEvent");
            if (onEvent) then
                if (enabled) then
                    -- visual impulse
                    onEvent(actionButton, "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", spellId);
                    onEvent(actionButton, "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", spellId);
                else
                    onEvent(actionButton, "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", spellId);
                end
            end
        end
    end
end

--------

local CellItem = {};

function CellItem.newCell()
    --  isEnabled: ui shows
    --  isReadyToCast: it is able to cast with 1 press
    --  isSuggested: it believes you should cast
    local cell = {
        spellId = 0,

        isEnabled = false,
        isReadyToCast = false,
        isChecked = false,
        isSuggested = false,
        isSuggestedCancel = false,
    };

    setProto(cell, CellItem);

    return cell;
end

function CellItem.initCell(cell)
    local localName = GetSpellInfo(cell.hintSpell);
    if (localName) then
        local spellName, _, spellIcon, _, _, _, spellId = GetSpellInfo(localName);
        cell.spellName = spellName;
        cell.spellIcon = spellIcon;
        cell.spellId = spellId;
        return true;
    end
    return false;
end

function CellItem.onCleuEvent(cell, ...)
end

function CellItem.refreshCell(cell)
end

--------

local CellView = {};

-- icon's 躯壳
function CellView.newView(parentFrame, size)
    local f = CreateFrame("Frame", nil, parentFrame, nil);
    if (size and size > 0) then
        f:SetSize(size, size);
    end

    local glowFrame = A.createBorderFrame(f, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 8,
    });
    f.glowFrame = glowFrame;

    local bgImage = f:CreateTexture(nil, "BACKGROUND", nil, 1);
    --A.cropTextureRegion(bgImage);
    bgImage:SetAllPoints();
    f.bgImage = bgImage;

    --local pressedHighlight = "interface/buttons/UI-Quickslot-Depress";
    --local hoveredHighlight = "interface/buttons/ButtonHilight-Square";

    local checkedStateImage = f:CreateTexture(nil, "OVERLAY", nil, 3);
    --A.cropTextureRegion(checkedStateImage);
    checkedStateImage:SetTexture("interface/buttons/CheckButtonHilight");
    checkedStateImage:SetBlendMode("ADD");
    checkedStateImage:SetAllPoints();
    f.checkedStateImage = checkedStateImage;

    --local cooldownPin = f:CreateTexture(nil, "BACKGROUND", nil, 2);
    --cooldownPin:SetColorTexture(1, 1, 1);
    --cooldownPin:SetPoint("TOPRIGHT", -6, -6);
    --cooldownPin:SetSize(6, 6);
    --f.cooldownPin = cooldownPin;

    --local countText = f:CreateFontString(nil, "OVERLAY", nil);
    --countText:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE");
    --countText:SetShadowColor(0, 0, 0, 1);
    --countText:SetShadowOffset(1, 1);
    --countText:SetJustifyH("RIGHT");
    --countText:SetPoint("BOTTOMRIGHT", ttlBar, "TOPRIGHT", -1, 2);
    --f.countText = countText;

    local ttlBar = CreateFrame("StatusBar", nil, f, nil);
    ttlBar:SetStatusBarTexture(A.Res.tile32);
    ttlBar:SetStatusBarColor(0, 1, 0, 0.85);
    ttlBar:SetHeight(4);
    ttlBar:SetPoint("BOTTOMLEFT");
    ttlBar:SetPoint("BOTTOMRIGHT");
    ttlBar:SetMinMaxValues(0, 6);
    ttlBar:SetValue(0);
    f.ttlBar = ttlBar;

    return f;
end

function CellView.initView(cellView, cell)
    cellView.bgImage:SetTexture(cell.spellIcon);
end

function CellView.refreshView(cellView, cell)
    if (cell.uiFlipActionButtonOverlayGlow == 1) then
        cell.uiFlipActionButtonOverlayGlow = 0;
        -- PlaySoundFile("sound/spells/clearcasting_impact_chest.ogg", "Master");
        PlaySound(4874);
    elseif (cell.uiFlipActionButtonOverlayGlow == -1) then
        cell.uiFlipActionButtonOverlayGlow = 0;
    end

    local f = cellView;

    if (cell.ttl) then
        cellView.ttlBar:SetValue(cell.ttl);
    end

    if (cell.isEnabled) then
        f:Show();
    else
        f:Hide();
        return;
    end

    f.bgImage:SetDesaturated(not cell.isReadyToCast);

    if (cell.isChecked) then
        f.checkedStateImage:Show();
    else
        f.checkedStateImage:Hide();
    end

    if (cell.isSuggested) then
        f.glowFrame:SetBackdropBorderColor(1, 1, 1, 0.85);
    elseif (cell.isSuggestedCancel) then
        f.glowFrame:SetBackdropBorderColor(1, 0.85, 0, 0.85);
    else
        f.glowFrame:SetBackdropBorderColor(1, 1, 1, 0);
    end
end

--------

-- test
(function()
    if (true) then
        return;
    end
    local cell = CellItem.newCell();
    cell.spellId = 7384;
    cell.isEnabled = true;
    cell.isReadyToCast = true;
    cell.isChecked = false;
    cell.isSuggested = false;
    cell.isSuggestedCancel = true;

    local cellView = CellView.newView(UIParent, 48);
    cellView:SetPoint("CENTER", 0, 200);
    cellView.ttlBar:SetValue(3);
    CellView.initView(cellView, cell);
    CellView.refreshView(cellView, cell);
end)();

--------

local addonName, addon = ...;
addon.TriggerWatch = addon.TriggerWatch or {};
addon.TriggerWatch.GridCtrl = addon.TriggerWatch.GridCtrl or {};
local GridCtrl = addon.TriggerWatch.GridCtrl;

function GridCtrl.newGrid()
    local grid = {};
    setProto(grid, GridCtrl);

    grid.candidateCells = {};
    grid.cells = {};

    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 120);
    f:SetSize(1, 1);
    grid.f = f;

    return grid;
end

function GridCtrl.addCellView(grid, cellView)
    local CELL_SIZE = 36;
    local CELL_MARGIN = 4;
    local X_SLOTS = 6;

    local i = array.size(grid.cells);
    local yPos = math.floor(i / X_SLOTS);
    local xPos = i - yPos * X_SLOTS;

    cellView:ClearAllPoints();
    cellView:SetPoint("TOPLEFT", grid.f, "TOPLEFT",
            xPos * (CELL_SIZE + CELL_MARGIN),
            yPos * (CELL_SIZE + CELL_MARGIN));
    cellView:SetSize(CELL_SIZE, CELL_SIZE);
end

function GridCtrl.registerCell(grid, hintSpell, callback)
    local cell = CellItem.newCell();
    cell.hintSpell = hintSpell;
    cell = callback(cell) or cell;
    array.insert(grid.candidateCells, cell);
end

function GridCtrl.init(grid)
    array.clear(grid.cells);
    array.foreach(grid.candidateCells, function(i, v)
        if (v:initCell()) then
            local cellView = CellView.newView(grid.f);
            CellView.initView(cellView, v);
            grid:addCellView(cellView);
            v.cellView = cellView;
            array.insert(grid.cells, v);
        end
    end);
end

function GridCtrl.start(grid)
    local f = grid.f;

    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");

    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            -- dispatch
            array.foreach(grid.cells, function(i, v)
                v:onCleuEvent(CombatLogGetCurrentEventInfo());
            end);
        elseif (event == "PLAYER_ENTERING_WORLD") then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
            grid:init();
            if (array.size(grid.cells) == 0) then
                -- no valid trigger, halt
                self:UnregisterAllEvents();
            end
        end
    end);

    f:SetScript("OnUpdate", function(self, elapsed)
        array.foreach(grid.cells, function(i, v)
            --CellItem.refreshCell(v);
            --local fn = rawget(v, "refreshCell");
            --if (fn) then
            --    fn(v);
            --end
            v:refreshCell();
            CellView.refreshView(v.cellView, v);
        end);
    end);
end

--------

local grid = GridCtrl.newGrid();
GridCtrl.instance = grid;
GridCtrl.instance:start();

local addonName, addon = ...;

local A = A;
local CellCtrl = addon.CellCtrl;

--------

addon.WatchItem = (function()
    local p = {};
    setProto(p, addon.CellItem);
    return p;
end)();
local WatchItem = addon.WatchItem;

function WatchItem.newItem()
    local o = {};
    setProto(o, WatchItem);

    o.hintSpellId = nil;
    o.isAttractive = false;
    o.ttl = nil;
    o.suggestion = nil;
    return o;
end

function WatchItem.onInit(self)
    local hintSpellName, _, hintSpellTextureId = GetSpellInfo(self.hintSpellId);
    self.hintSpellName = hintSpellName;
    self.textureId = hintSpellTextureId;
    return true;
end

function WatchItem.onCleu(self, ...)
end

function WatchItem.onUpdate(self)
end

function WatchItem.updateSpell(self)
    local cellItem = self;
    local hintSpellId = self.hintSpellId;

    local fineResource, noMana = SpellBook.hasSpellCastResource(hintSpellId);
    local cooldownEndTime, cooldownFlag = SpellBook.getSpellCooldownEndTime(hintSpellId);

    cellItem.hasPin = not fineResource and not noMana;

    cellItem.quantity = GetSpellCharges(hintSpellId);

    --cellItem.ttl

    cellItem.ttc = cooldownEndTime - GetTime();

    local suggestion = self.suggestion;
    if (suggestion == "cast") then
        cellItem.glowColor = Color.fromVertex(1, 1, 1, 0.85);
    elseif (suggestion == "cancel") then
        cellItem.glowColor = Color.fromVertex(1, 0.85, 0, 0.85);
    else
        cellItem.glowColor = Color.fromVertex(1, 1, 1, 0);
    end

    cellItem.stateShown = true;
    cellItem.stateEnabled = fineResource and (cellItem.ttc < 0.1);
    cellItem.stateChecked = cooldownFlag == "casting";
    cellItem.stateHovered = false;
    cellItem.stateFocused = false;
    cellItem.statePressed = false;
end

--------

addon.TriggerWatch = {};
local TriggerWatch = addon.TriggerWatch;

function TriggerWatch.newWatch()
    local o = {};
    setProto(o, TriggerWatch);

    o.candidateItems = {};

    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 120);
    f:SetSize(1, 1);
    o.f = f;

    return o;
end

function TriggerWatch.register(self, callback)
    local item = WatchItem.newItem();
    callback(item);
    array.insert(self.candidateItems, item);
end

function TriggerWatch.start(self)
    local f = self.f;

    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");

    f:SetScript("OnEvent", function(_self, event, ...)
        if (event == "PLAYER_ENTERING_WORLD") then
            _self:UnregisterEvent("PLAYER_ENTERING_WORLD");

            local validItems = {};
            for _, item in ipairs(self.candidateItems) do
                if (item:onInit()) then
                    array.insert(validItems, item);
                end
            end
            self.validItems = validItems;

            self.cellCtrl = CellCtrl.newCtrl(f);
        elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            -- dispatch
            for _, item in ipairs(self.validItems) do
                item:onCleu(CombatLogGetCurrentEventInfo());
            end
        end
    end);

    f:SetScript("OnUpdate", function(_self, elapsed)
        for _, item in ipairs(self.validItems) do
            item:onUpdate();
        end
        self.cellCtrl:render(self.validItems);
    end);
end

--------

TriggerWatch.instance = TriggerWatch.newWatch();
TriggerWatch.instance:start();

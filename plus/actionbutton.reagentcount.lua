(function()
    local SPELL_REAGENTS = GetText("SPELL_REAGENTS");
    local tooltip = CreateFrame("GameTooltip", "ReagentCountTooltip", nil, "GameTooltipTemplate");
    local function getReagentName(actionSlot)
        tooltip:ClearLines();
        tooltip:SetOwner(UIParent, "ANCHOR_NONE");
        tooltip:SetAction(actionSlot);
        for _, region in pairs({ tooltip:GetRegions() }) do
            if (region and region:GetObjectType() == "FontString") then
                local line = region:GetText();
                local s = string.match(line or "", SPELL_REAGENTS .. "(.+)");
                if (s) then
                    return s;
                end
            end
        end
    end

    local function showReagentCount(actionButton)
        local actionSlot = actionButton.action;
        local actionType, id, subType = GetActionInfo(actionSlot);
        if (actionType == "spell" or actionType == "macro") then
            local reagentName = getReagentName(actionSlot);
            if (reagentName) then
                local itemCountTextView = actionButton.Count;
                local n = GetItemCount(reagentName);
                if (n > 99) then
                    itemCountTextView:SetText("*");
                else
                    itemCountTextView:SetText(n);
                end
            end
        end
    end

    hooksecurefunc("ActionButton_UpdateCount", showReagentCount);
end)();

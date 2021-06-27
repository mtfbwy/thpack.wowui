local addonName, addon = ...;
local A = addon.A;

(function()
    local tooltip = CreateFrame("GameTooltip");
    local function repairAll()
        local amount, fixable = GetRepairAllCost();
        if fixable then
            RepairAllItems();
            ShowRepairCursor();
            for id = 0, NUM_BAG_FRAMES, 1 do
                for slot = 1, GetContainerNumSlots(id), 1 do
                    local _, repairCost = tooltip:SetBagItem(id, slot);
                    if repairCost and repairCost > 0 then
                        amount = amount + repairCost;
                        PickupContainerItem(id, slot);
                    end
                end
            end
            HideRepairCursor();
        end
        return amount;
    end

    local f = CreateFrame("Frame");
    f:RegisterEvent("MERCHANT_SHOW");
    f:SetScript("OnEvent", function(self, event, ...)
        if CanMerchantRepair() then
            local amount = repairAll();
            if amount > 0 then
                A.logi("Auto repair for " .. GetCoinTextureString(amount));
            end
        end
    end);
end)();

local addonName, addon = ...;
local A = addon.A;

(function()
    local tooltipAmount = 0;
    local tooltip = CreateFrame("GameTooltip");
    tooltip:SetScript("OnTooltipAddMoney", function(self, amount)
        tooltipAmount = amount;
    end)

    local function sellAllGrayItems()
        local amount = 0;
        for id = 0, NUM_BAG_FRAMES, 1 do
            for slot = 1, GetContainerNumSlots(id), 1 do
                tooltipAmount = 0;
                local link = GetContainerItemLink(id, slot);
                if link and link:match(ITEM_QUALITY_COLORS[0].hex) then
                    tooltip:SetBagItem(id, slot);
                    amount = amount + tooltipAmount;
                    UseContainerItem(id, slot);
                end
            end
        end
        return amount;
    end

    local f = CreateFrame("Frame");
    f:RegisterEvent("MERCHANT_SHOW");
    f:SetScript("OnEvent", function(self, event, ...)
        local amount = sellAllGrayItems();
        if amount > 0 then
            A.logi("Auto sell for " .. GetCoinTextureString(amount));
        end
    end);
end)();

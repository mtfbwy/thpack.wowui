-- GameTooltip有淡出动画，动画完成时才会重置边框颜色(OnHide)。
-- 当鼠标快速移动时其实显示的是最后一次设置的颜色。
-- BlizUI在任何情况下都不改变边框颜色，本来没有问题。
-- 但一旦设定可变的边框颜色(如物品品质)，则将看到五颜六色的商店招牌。
local function resetTooltipBorderColor(tooltip)
    tooltip:SetBackdropBorderColor(1, 1, 1);
end

local function addItemInfo(tooltip)
    local _, itemLink = tooltip:GetItem();
    if (itemLink) then
        local itemId = itemLink:match("item:(%d+)");
        local _, _, itemQuality, itemLevel, _, _, _, _, _, _, itemSellPrice, _, _, _, _, _, _ = GetItemInfo(itemLink);

        if (itemLevel) then
            tooltip:AddLine("Level " .. itemLevel, 0, 1, 1);
        end

        if (itemSellPrice and itemSellPrice > 0 and not MerchantFrame:IsShown()) then
            tooltip:AddLine("Recycle for " .. GetCoinTextureString(itemSellPrice), 1, 1, 1);
        end

        if (itemQuality) then
            tooltip:SetBackdropBorderColor(GetItemQualityColor(itemQuality));
        end
    end
end

for i, tooltip in pairs({ GameTooltip, ItemRefTooltip }) do
    tooltip:HookScript("OnTooltipCleared", resetTooltipBorderColor);
    tooltip:HookScript("OnTooltipSetItem", addItemInfo);
end

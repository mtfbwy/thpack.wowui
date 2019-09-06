(function()

    -- GameTooltip有淡出动画，动画完成时才会重置边框颜色(OnHide)。
    -- 当鼠标快速移动时其实显示的是最后一次设置的颜色。
    -- BlizUI在任何情况下都不改变边框颜色，所以看起来没有问题。
    -- 若不修正，一旦设定可变的边框颜色(如物品品质)，则将看到五颜六色的商店招牌。
    GameTooltip:HookScript("OnTooltipCleared", function(self)
        self:SetBackdropBorderColor(1, 1, 1);
    end);

    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        local itemName, itemLink = self:GetItem()
        if itemLink then
            local itemId = itemLink:match("item:(%d+)")

            local name, link, quality, level, _, _, _, _, _, _, sellPrice = GetItemInfo(itemLink);

            local levelString = nil;
            if level then
                levelString = "Level: " .. level;
            end

            local sellPriceString = nil;
            if sellPrice and sellPrice > 0 then
                sellPriceString = GetCoinTextureString(sellPrice);
            end

            self:AddDoubleLine(levelString, sellPriceString, 0, 1, 1, 1, 1, 1);

            if quality then
                self:SetBackdropBorderColor(GetItemQualityColor(quality));
            end
        end
    end);
end)();
